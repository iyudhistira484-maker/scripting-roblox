-- GachaService.lua
-- Logik pelayan untuk Gacha (Gacha Roll).
-- Letakkan di: ServerScriptService/GachaService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Muat modul
local GachaData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GachaData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gacha")
local rollGachaEvent = remotesFolder:WaitForChild("RollGacha")

local GachaService = {}

-- Helper: Dapatkan random item dari pool
local function rollItem(banner, pullCount, pity)
 	-- Hitung soft pity rate jika diperlukan
 	local pool = banner.Pool

 	local rolls = {}
	for i = 1, pullCount do
		-- Roll berdasarkan rate
		local rand = math.random()
		local cumulative = 0
		local selectedRarity

		for rarity, config in pairs(pool) do
			local rate = config.Chance
			-- Soft pity: meningkatkan SSR/SSSR rate setelah soft pity start
			if rarity == "SSR" then
				local pullsWithoutSSR = pity.SSRCount or 0
				if pullsWithoutSSR >= banner.SoftPityStart then
					rate = rate + (pullsWithoutSSR - banner.SoftPityStart + 1) * 0.01
				end
			end

			cumulative = cumulative + rate
			if rand <= cumulative then
				selectedRarity = rarity
				break
			end
		end

		-- Jika tidak terpilih (floating point), gunakan rarity terakhir
		if not selectedRarity then
			selectedRarity = "Common"
		end

		-- Dapatkan item acak dari pool rarity tersebut
		local rarityConfig = pool[selectedRarity]
		local items = rarityConfig.Items
		local itemName = items[math.random(1, #items)]

		-- Update pity
		if selectedRarity == "SSR" then
			pity.SSRCount = 0
			pity.HardPityCount = 0
		elseif selectedRarity == "SSSR" then
			pity.SSSRCount = 0
			pity.HardPityCount = 0
		else
			pity.SSRCount = (pity.SSRCount or 0) + 1
			pity.SSSRCount = (pity.SSSRCount or 0) + 1
		end

		-- Hard pity: jamin SSR setelah pity guarantee
		if (pity.SSRCount or 0) >= banner.PityGuarantee then
			selectedRarity = "SSR"
			local items = pool.SSR.Items
			itemName = items[math.random(1, #items)]
			pity.SSRCount = 0
		end

		table.insert(rolls, {
			ItemId = itemName,
			Rarity = selectedRarity,
			IsNewPity = selectedRarity == "SSR" or selectedRarity == "SSSR",
		})
	end

	return rolls, pity
end

-- Handler: Roll gacha dari klien
local function handleRollGacha(player, bannerId, count)
	-- Validasi banner
	local banner = GachaData:GetBanner(bannerId)
	if not banner then
		return
	end

	-- Validasi jumlah pull
	count = math.min(count, 10)
	count = math.max(count, 1)

	-- Hitung total harga
	local price = banner.Price
	local priceMulti = banner.PriceMulti
	local totalCost

 	if count >= 10 and priceMulti then
 		totalCost = priceMulti[banner.Currency]
 	else
 		totalCost = price[banner.Currency] * count
 	end

 	-- Validasi saldo
 	local currentBalance = PlayerDataService:GetCurrency(player, banner.Currency)
	if currentBalance < totalCost then
		return
	end

	-- Kurangi mata uang
	PlayerDataService:RemoveCurrency(player, banner.Currency, totalCost)

	-- Dapatkan pity counter
	local data = PlayerDataService:Get(player)
	local pity = data.GachaPity[bannerId] or {
		SSRCount = 0,
		SSSRCount = 0,
		HardPityCount = 0,
	}

 	-- Roll
 	local rolls, newPity = rollItem(banner, count, pity)

	-- Update pity
	data.GachaPity[bannerId] = newPity
	PlayerDataService:Save(player)

	-- Beri item ke pemain
	for _, roll in ipairs(rolls) do
		PlayerDataService:AddItemToInventory(player, roll.ItemId)
	end
	PlayerDataService:Save(player)

	-- Kirim hasil ke klien
	local resultEvent = remotesFolder:FindFirstChild("RollResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "RollResult"
		resultEvent.Parent = remotesFolder
	end

	resultEvent:FireClient(player, rolls, banner)

	print(("Pemain %s melakukan roll gacha %d x di banner %s"):format(player.Name, count, bannerId))
end

-- Handler: Request history dari klien
local function handleRequestHistory(player)
	local data = PlayerDataService:Get(player)

	local responseEvent = remotesFolder:FindFirstChild("HistoryResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "HistoryResponse"
		responseEvent.Parent = remotesFolder
	end

	-- Kirim pity info saat ini
	local pityInfo = data.GachaPity or {}
	responseEvent:FireClient(player, pityInfo)
end

-- Connect events
rollGachaEvent.OnServerEvent:Connect(handleRollGacha)

local requestHistoryEvent = remotesFolder:FindFirstChild("RequestHistory")
if requestHistoryEvent then
	requestHistoryEvent.OnServerEvent:Connect(handleRequestHistory)
end

-- API publik
function GachaService:CanAfford(player, bannerId, count)
	local banner = GachaData:GetBanner(bannerId)
	if not banner then return false end

	local price = banner.Price
	local priceMulti = banner.PriceMulti

	local totalCost
 	if count >= 10 and priceMulti then
 		totalCost = priceMulti[banner.Currency]
 	else
 		totalCost = price[banner.Currency] * count
 	end

 	local balance = PlayerDataService:GetCurrency(player, banner.Currency)
	return balance >= totalCost
end

return GachaService