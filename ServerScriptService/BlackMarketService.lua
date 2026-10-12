-- BlackMarketService.lua
-- Logik pelayan untuk Black Market (Pasar Gelap).
-- Letakkan di: ServerScriptService/BlackMarketService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Muat modul
local BlackMarketData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("BlackMarketData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BlackMarket")
local requestStockEvent = remotesFolder:WaitForChild("RequestStock")
local buyItemEvent = remotesFolder:WaitForChild("BuyItem")

local BlackMarketService = {}

-- State
local currentStock = {}
local lastRestock = tick()
local RESTOCK_INTERVAL = 6 * 60 * 60 -- 6 jam (dalam detik)
local ITEMS_PER_STOCK = 4

-- BindableEvent untuk notifikasi ke sistem lain
local stockRestockedEvent = ServerStorage:FindFirstChild("BlackMarketRestocked")
if not stockRestockedEvent then
	stockRestockedEvent = Instance.new("BindableEvent")
	stockRestockedEvent.Name = "BlackMarketRestocked"
	stockRestockedEvent.Parent = ServerStorage
end

-- Generate stock acak
local function generateStock()
	local allItems = BlackMarketData:GetAllForStock()
	local pool = {}
	for _, item in ipairs(allItems) do
		table.insert(pool, item)
	end

	-- Acak dan pilih ITEM_PER_STOCK item
	local stock = {}
	for i = #pool, 2, -1 do
		local j = math.random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end

	for i = 1, math.min(ITEMS_PER_STOCK, #pool) do
		local item = pool[i]
		stock[item.Id] = {
			Id = item.Id,
			Name = item.Name,
			Category = item.Category,
			Rarity = item.Rarity,
			Price = item.Price,
			Description = item.Description,
			IconImage = item.IconImage,
			Stats = item.Stats,
			Stock = math.random(1, 3), -- Stok terbatas per item
		}
	end

	currentStock = stock
	lastRestock = tick()
	stockRestockedEvent:Fire(stock)
end

-- Handler: Request stock dari klien
local function handleRequestStock(player)
	local responseEvent = remotesFolder:FindFirstChild("StockResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "StockResponse"
		responseEvent.Parent = remotesFolder
	end

	-- Kirim stock ke klien
	local stockList = {}
	for _, item in pairs(currentStock) do
		table.insert(stockList, item)
	end

	responseEvent:FireClient(player, stockList, lastRestock)
end

-- Handler: Beli item dari klien
local function handleBuyItem(player, itemId)
	local item = BlackMarketData:GetById(itemId)
	if not item then
		warn(("Pemain %s mencoba beli item BM tidak sah: %s"):format(player.Name, tostring(itemId)))
		return
	end

	-- Cek stok tersedia
	local stockItem = currentStock[itemId]
	if not stockItem or stockItem.Stock <= 0 then
		return
	end

 	-- Validasi pemain tidak punya item ini (untuk skin/konsumsi unik)
 	local data = PlayerDataService:Get(player)

 	-- Validasi saldo
 	local price = item.Price
 	local paidRupiah = false
 	if price.Rupiah and price.Rupiah > 0 then
 		local rupiah = PlayerDataService:GetCurrency(player, "Rupiah")
 		if rupiah < price.Rupiah then
 			return
 		end
 		PlayerDataService:RemoveCurrency(player, "Rupiah", price.Rupiah)
 		paidRupiah = true
 	end
 	if price.Gems and price.Gems > 0 then
 		local gems = PlayerDataService:GetCurrency(player, "Gems")
 		if gems < price.Gems then
 			-- Refund Rupiah yang sudah dipotong
 			if paidRupiah then
 				PlayerDataService:AddCurrency(player, "Rupiah", price.Rupiah)
 			end
 			return
 		end
 		PlayerDataService:RemoveCurrency(player, "Gems", price.Gems)
 	end

	-- Turunkan stok
	stockItem.Stock = stockItem.Stock - 1

 	-- Beri item ke pemain
 	if item.Category == "Skin" then
 		-- Tambah ke skin yang dimiliki
 		local skinId = itemId:gsub("_Skin$", "")
 		if skinId and skinId ~= itemId then
 			if not table.find(data.OwnedSkins, skinId) then
 				table.insert(data.OwnedSkins, skinId)
 			end
 		end
	elseif item.Category == "Emote" then
		local emoteId = itemId:match("Emote_(.+)")
		if emoteId and not table.find(data.OwnedEmotes, emoteId) then
			table.insert(data.OwnedEmotes, emoteId)
		end
	elseif item.Category == "Consumable" then
		if not table.find(data.Inventory, itemId) then
			table.insert(data.Inventory, itemId)
		end
	elseif item.Category == "Currency" then
		-- Tambah currency langsung
		if item.Id == "Medali_Honor" then
			PlayerDataService:AddCurrency(player, "Gems", 10)
		end
	end

	PlayerDataService:Save(player)

	-- Kirim hasil ke klien
	local resultEvent = remotesFolder:FindFirstChild("PurchaseResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "PurchaseResult"
		resultEvent.Parent = remotesFolder
	end
	resultEvent:FireClient(player, itemId, true, item)

	print(("Pemain %s membeli %s dari Black Market"):format(player.Name, item.Name))
end

-- Connect events
requestStockEvent.OnServerEvent:Connect(handleRequestStock)
buyItemEvent.OnServerEvent:Connect(handleBuyItem)

-- Inisialisasi
generateStock()
print("Black Market telah terbuka dengan stok:", #currentStock, "item")

-- API publik
function BlackMarketService:GetCurrentStock()
	return currentStock
end

function BlackMarketService:GetTimeUntilRestock()
	local elapsed = tick() - lastRestock
	return math.max(0, RESTOCK_INTERVAL - elapsed)
end

return BlackMarketService