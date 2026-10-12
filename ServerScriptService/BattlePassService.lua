-- BattlePassService.lua
-- Logik pelayan untuk Battle Pass (Fitur 19).
-- Letakkan di: ServerScriptService/BattlePassService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local BattlePassData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BattlePassData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BattlePass")
local requestBpEvent = remotesFolder:WaitForChild("RequestBattlePass")
local claimTierEvent = remotesFolder:WaitForChild("ClaimTierReward")
local purchasePremiumEvent = remotesFolder:WaitForChild("PurchasePremium")

local BattlePassService = {}

-- Handler: Request battle pass info
local function handleRequestBattlePass(player)
	local data = PlayerDataService:Get(player)
	local responseEvent = remotesFolder:FindFirstChild("BattlePassResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "BattlePassResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, {
		Tiers = BattlePassData.Tiers,
		CurrentEXP = data.BattlePassEXP or 0,
		CurrentTier = data.BattlePassTier or 1,
		ClaimedTiers = data.BattlePassClaimed or {},
		IsPremium = data.BattlePassPremium or false,
		XPPerTier = BattlePassData.XP_PER_TIER,
	})
end

-- Handler: Claim tier reward
local function handleClaimTierReward(player, tierId)
	local data = PlayerDataService:Get(player)
	local tierNum = 0
	if tierId and type(tierId) == "string" then
		tierNum = tonumber(tierId:match("Tier_(%d+)")) or 0
	end

	-- Cek tier sudah tercapai
	if tierNum > (data.BattlePassTier or 1) then
		return
	end

	-- Cek sudah diklaim
	if not data.BattlePassClaimed then
		data.BattlePassClaimed = {}
	end
	if data.BattlePassClaimed[tierId] then
		return
	end

	data.BattlePassClaimed[tierId] = true

	-- Beri reward
	local tier = BattlePassData.Tiers[tierNum]
	if tier then
		-- Free reward
		for _, reward in ipairs(tier.FreeReward or {}) do
			if reward.Type == "Rupiah" then
				PlayerDataService:AddCurrency(player, "Rupiah", reward.Amount)
			end
		end

		-- Premium reward (jika punya premium)
		if data.BattlePassPremium then
			for _, reward in ipairs(tier.PremiumReward or {}) do
				if reward.Type == "Rupiah" then
					PlayerDataService:AddCurrency(player, "Rupiah", reward.Amount)
				elseif reward.Type == "Gems" then
					PlayerDataService:AddCurrency(player, "Gems", reward.Amount)
				elseif reward.Type == "EmoteFragment" then
					-- Placeholder - bisa kirim keinventory
				elseif reward.Type == "Skin" then
					if not table.find(data.Inventory, reward.ItemId) then
						table.insert(data.Inventory, reward.ItemId)
					end
				elseif reward.Type == "Title" then
					if not data.BattlePassClaimed.Titles then
						data.BattlePassClaimed.Titles = {}
					end
					table.insert(data.BattlePassClaimed.Titles, reward.Name)
				end
			end
		end
	end

	PlayerDataService:Save(player)
end

-- Handler: Purchase premium
local function handlePurchasePremium(player)
	local data = PlayerDataService:Get(player)

	-- Validasi saldo Gems
	local gems = PlayerDataService:GetCurrency(player, "Gems")
	if gems < BattlePassData.Season.PremiumPrice then
		return
	end

	PlayerDataService:RemoveCurrency(player, "Gems", BattlePassData.Season.PremiumPrice)
	data.BattlePassPremium = true
	PlayerDataService:Save(player)

	-- Beri semua premium reward sebelumnya
	for i = 1, (data.BattlePassTier or 1) do
		local tier = BattlePassData.Tiers[i]
		if tier and not data.BattlePassClaimed["Tier_" .. i] then
			data.BattlePassClaimed["Tier_" .. i] = true
			for _, reward in ipairs(tier.PremiumReward or {}) do
				if reward.Type == "Gems" then
					PlayerDataService:AddCurrency(player, "Gems", reward.Amount)
				end
			end
		end
	end
	PlayerDataService:Save(player)
end

-- Helper: Tambah EXP
function BattlePassService:AddEXP(player, amount)
	local data = PlayerDataService:Get(player)
	local currentEXP = data.BattlePassEXP or 0
	local newEXP = currentEXP + amount
	data.BattlePassEXP = newEXP

	-- Cek level up
	local tier = math.floor(newEXP / BattlePassData.XP_PER_TIER) + 1
	local maxTier = BattlePassData.Season.TotalTiers
	tier = math.min(tier, maxTier)

	local previousTier = data.BattlePassTier or 1
	data.BattlePassTier = tier

	if tier > previousTier then
		PlayerDataService:Save(player)

		-- Kirim notifikasi level up
		local levelUpEvent = remotesFolder:FindFirstChild("BattlePassResponse")
		if levelUpEvent then
			levelUpEvent:FireClient(player, {
				Tiers = BattlePassData.Tiers,
				CurrentEXP = newEXP,
				CurrentTier = tier,
				ClaimedTiers = data.BattlePassClaimed or {},
				IsPremium = data.BattlePassPremium or false,
				XPPerTier = BattlePassData.XP_PER_TIER,
				LevelUp = true,
				NewTier = tier,
			})
		end
	end
end

-- Connect events
requestBpEvent.OnServerEvent:Connect(handleRequestBattlePass)
claimTierEvent.OnServerEvent:Connect(handleClaimTierReward)
purchasePremiumEvent.OnServerEvent:Connect(handlePurchasePremium)

-- API publik
return BattlePassService