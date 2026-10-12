-- GamepassService.lua
-- Logik pelayan untuk Gamepass.
-- Letakkan di: ServerScriptService/GamepassService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

-- Muat modul
local GamepassConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GamepassConfig.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gamepass")
local checkOwnershipEvent = remotesFolder:WaitForChild("CheckOwnership")

local GamepassService = {}

-- Cache kepemilikan gamepass per pemain
local playerPasses = {}

-- Cek kepemilikan gamepass
local function checkGamepassOwnership(player, gamepassId)
	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
	end)
	if success then
		return owns
	end
	warn(("Gagal mengecek gamepass untuk %s: %s"):format(player.Name, tostring(owns)))
	return false
end

-- Handler: Request cek kepemilikan dari klien
local function handleCheckOwnership(player)
	local data = PlayerDataService:Get(player)
	local ownedPasses = data.GamepassesOwned or {}
	local hasPass = {}

	for _, passConfig in ipairs(GamepassConfig:GetAll()) do
		hasPass[passConfig.Id] = table.find(ownedPasses, passConfig.Id) ~= nil
	end

	-- Kirim respons
	local responseEvent = remotesFolder:FindFirstChild("OwnershipResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "OwnershipResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, hasPass, ownedPasses)
end

-- Apply benefit gamepass ke pemain
local function applyBenefits(player)
	local data = PlayerDataService:Get(player)
	local ownedPasses = data.GamepassesOwned or {}

	for _, passId in ipairs(ownedPasses) do
		local pass = GamepassConfig:GetById(passId)
		if pass and pass.Benefit then
			-- Currency Multipliers
			if pass.Benefit.CurrencyMultiplier then
				-- Ini bisa digunakan oleh CurrencyService saat menghitung reward
				local multipliers = data.CurrencyMultipliers or {}
				for currency, mult in pairs(pass.Benefit.CurrencyMultiplier) do
					multipliers[currency] = (multipliers[currency] or 1) * mult
				end
				data.CurrencyMultipliers = multipliers
			end

			-- Auto collect
			if pass.Benefit.AutoCollect then
				data.AutoCollectEnabled = true
			end

			-- XP Multiplier
			if pass.Benefit.XPMultiplier then
				data.XPMultiplier = (data.XPMultiplier or 1) * pass.Benefit.XPMultiplier
			end

			-- Unlock emote
			if pass.Benefit.UnlockEmote then
				if not table.find(data.OwnedEmotes, pass.Benefit.UnlockEmote) then
					table.insert(data.OwnedEmotes, pass.Benefit.UnlockEmote)
				end
			end

			-- Inventory slots (hanya informatif, logic di ShopService)
			if pass.Benefit.InventorySlots then
				data.ExtraInventorySlots = (data.ExtraInventorySlots or 0) + pass.Benefit.InventorySlots
			end
		end
	end

	PlayerDataService:Save(player)
	print(("Gamepass benefits diterapkan untuk %s"):format(player.Name))
end

-- Handler: Prompt beli gamepass dari klien
local function handlePurchaseRequest(player, passId)
	local pass = GamepassConfig:GetById(passId)
	if not pass then
		return
	end

	-- Biarkan klien yang handle PromptGamePassPurchase
	-- Ini hanya sebagai backup
end

-- Connect events
checkOwnershipEvent.OnServerEvent:Connect(handleCheckOwnership)

	-- Player join: load dan apply benefits
	Players.PlayerAdded:Connect(function(player)
		-- Load kepemilikan gamepass
	local data = PlayerDataService:Get(player)
	local ownedPasses = data.GamepassesOwned or {}

	for _, passConfig in ipairs(GamepassConfig:GetAll()) do
		if table.find(ownedPasses, passConfig.Id) == nil then
			-- Cek kepemilikan fresh dari MarketplaceService
			if checkGamepassOwnership(player, passConfig.GamepassId) then
				table.insert(data.GamepassesOwned, passConfig.Id)
			end
		end
	end

	PlayerDataService:Save(player)
	applyBenefits(player)
end)

-- API publik
function GamepassService:PlayerOwnsPass(player, passId)
	local data = PlayerDataService:Get(player)
	local owned = data.GamepassesOwned or {}
	return table.find(owned, passId) ~= nil
end

function GamepassService:GetCurrencyMultiplier(player, currency)
	local data = PlayerDataService:Get(player)
	local mult = 1
	if data.CurrencyMultipliers and data.CurrencyMultipliers[currency] then
		mult = data.CurrencyMultipliers[currency]
	end
	return mult
end

function GamepassService:GetXPMultiplier(player)
	local data = PlayerDataService:Get(player)
	return data.XPMultiplier or 1
end

function GamepassService:GetExtraInventorySlots(player)
	local data = PlayerDataService:Get(player)
	return data.ExtraInventorySlots or 0
end

function GamepassService:HasAutoCollect(player)
	local data = PlayerDataService:Get(player)
	return data.AutoCollectEnabled or false
end

return GamepassService