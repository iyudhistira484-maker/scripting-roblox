-- ShopService.lua
-- Logik pelayan untuk Shop (Toko Barang).
-- Letakkan di: ServerScriptService/ShopService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Muat modul
local ShopData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ShopData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
local requestItemsEvent = remotesFolder:WaitForChild("RequestItems")
local buyItemEvent = remotesFolder:WaitForChild("BuyItem")

local ShopService = {}

-- Handler: Request daftar items dari klien
local function handleRequestItems(player)
	local data = PlayerDataService:Get(player)
	local itemList = {}

	for _, item in ipairs(ShopData:GetAll()) do
		table.insert(itemList, {
			Id = item.Id,
			Name = item.Name,
			Category = item.Category,
			Stats = item.Stats,
			Price = item.Price,
			Description = item.Description,
			IconImage = item.IconImage,
			Icon = item.Icon,
			Owned = PlayerDataService:HasItemInInventory(player, item.Id),
		})
	end

	local responseEvent = remotesFolder:FindFirstChild("ItemsResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "ItemsResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, itemList)
end

-- Handler: Beli item dari klien
local function handleBuyItem(player, itemId)
	local item = ShopData:GetById(itemId)
	if not item then
		warn(("Pemain %s mencuba beli item shop tidak sah: %s"):format(player.Name, tostring(itemId)))
		return
	end

	-- Cek sudah dimiliki (untuk item unik)
	if PlayerDataService:HasItemInInventory(player, itemId) then
		return
	end

	-- Validasi harga
	local price = item.Price
	if not price.Rupiah and not price.Gems then
		return
	end

	-- Cek saldo
	if price.Rupiah and price.Rupiah > 0 then
		local currentRupiah = PlayerDataService:GetCurrency(player, "Rupiah")
		if currentRupiah < price.Rupiah then
			return
		end
	end

	if price.Gems and price.Gems > 0 then
		local currentGems = PlayerDataService:GetCurrency(player, "Gems")
		if currentGems < price.Gems then
			return
		end
	end

	-- Kurangi mata uang
	if price.Rupiah and price.Rupiah > 0 then
		PlayerDataService:RemoveCurrency(player, "Rupiah", price.Rupiah)
	end
	if price.Gems and price.Gems > 0 then
		PlayerDataService:RemoveCurrency(player, "Gems", price.Gems)
	end

	-- Tambahkan ke inventory
	PlayerDataService:AddItemToInventory(player, itemId)
	PlayerDataService:Save(player)

	-- Kirim notifikasi ke klien
	local resultEvent = remotesFolder:FindFirstChild("PurchaseResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "PurchaseResult"
		resultEvent.Parent = remotesFolder
	end

	resultEvent:FireClient(player, itemId, true, item)

	-- Notify ItemAddedInternal untuk AchievementService
	local itemAddedEvent = game.ServerScriptService:FindFirstChild("ItemAddedInternal")
	if itemAddedEvent and itemAddedEvent:IsA("BindableEvent") then
		itemAddedEvent:Fire(player, itemId)
	end

	print(("Pemain %s membeli %s dari Shop"):format(player.Name, item.Name))
end

-- Connect events
requestItemsEvent.OnServerEvent:Connect(handleRequestItems)
buyItemEvent.OnServerEvent:Connect(handleBuyItem)

-- API publik
function ShopService:GetItemInfo(itemId)
	return ShopData:GetById(itemId)
end

return ShopService