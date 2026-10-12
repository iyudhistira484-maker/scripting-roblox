-- EquipmentService.lua
-- Logik pelayan untuk Equipment (Alat Berburu).
-- Letakkan di: ServerScriptService/EquipmentService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EquipmentData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EquipmentData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

local EquipmentService = {}

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Equipment")
local equipEvent = remotesFolder:WaitForChild("EquipItem")
local unequipEvent = remotesFolder:WaitForChild("UnequipItem")
local requestInventoryEvent = remotesFolder:WaitForChild("RequestInventory")
local inventoryResponseEvent = remotesFolder:WaitForChild("InventoryResponse")
local equipmentUpdatedEvent = remotesFolder:WaitForChild("EquipmentUpdated")

-- Buat RemoteEvent jika belum ada
if not equipEvent then
	equipEvent = Instance.new("RemoteEvent")
	equipEvent.Name = "EquipItem"
	equipEvent.Parent = remotesFolder
end

if not unequipEvent then
	unequipEvent = Instance.new("RemoteEvent")
	unequipEvent.Name = "UnequipItem"
	unequipEvent.Parent = remotesFolder
end

if not requestInventoryEvent then
	requestInventoryEvent = Instance.new("RemoteEvent")
	requestInventoryEvent.Name = "RequestInventory"
	requestInventoryEvent.Parent = remotesFolder
end

if not inventoryResponseEvent then
	inventoryResponseEvent = Instance.new("RemoteEvent")
	inventoryResponseEvent.Name = "InventoryResponse"
	inventoryResponseEvent.Parent = remotesFolder
end

if not equipmentUpdatedEvent then
	equipmentUpdatedEvent = Instance.new("RemoteEvent")
	equipmentUpdatedEvent.Name = "EquipmentUpdated"
	equipmentUpdatedEvent.Parent = remotesFolder
end

-- Handler: Equip item
local function handleEquipRequest(player, itemId, category)
	-- Validasi item ada dan kategori sesuai
	local equipment = EquipmentData:GetById(itemId)
	if not equipment then
		warn(("Pemain %s mencuba equip item tidak sah: %s"):format(player.Name, tostring(itemId)))
		return
	end

	if equipment.Category ~= category then
		warn(("Pemain %s mencuba equip item dengan kategori salah"):format(player.Name))
		return
	end

	-- Validasi kepemilikan (cek di inventori)
	if not PlayerDataService:HasItemInInventory(player, itemId) then
		warn(("Pemain %s mencuba equip item yang tidak dimiliki: %s"):format(player.Name, itemId))
		return
	end

	-- Equip item
	PlayerDataService:EquipItem(player, itemId, category)

	-- Simpan
	PlayerDataService:Save(player)

	-- Beri tahu klien
	equipmentUpdatedEvent:FireClient(player, category, itemId, equipment.Stats)

	-- Notifikasi sistem lain (mis. SanityService untuk efek stat)
	local equippedEvent = game.ServerScriptService:FindFirstChild("EquipmentEquippedInternal")
	if equippedEvent and equippedEvent:IsA("BindableEvent") then
		equippedEvent:Fire(player, itemId, equipment)
	end

	print(("Pemain %s telah mequip %s"):format(player.Name, equipment.Name))
end

-- Handler: Unequip item
local function handleUnequipRequest(player, category)
	-- Validasi kategori
	if not category or typeof(category) ~= "string" then
		return
	end

	-- Hapus equipment
	PlayerDataService:UnequipItem(player, category)

	-- Simpan
	PlayerDataService:Save(player)

	-- Beritahu klien
	equipmentUpdatedEvent:FireClient(player, category, nil, nil)

	print(("Pemain %s telah melepas equipment di slot %s"):format(player.Name, category))
end

-- Handler: Request inventory
local function handleInventoryRequest(player)
	local data = PlayerDataService:Get(player)
	local inventoryList = {}

	for _, itemId in ipairs(data.Inventory or {}) do
		local equipment = EquipmentData:GetById(itemId)
		if equipment then
			table.insert(inventoryList, {
				Id = itemId,
				Name = equipment.Name,
				Category = equipment.Category,
				Rarity = equipment.Rarity,
				Stats = equipment.Stats,
				Price = equipment.Price,
				Owned = true,
				Equipped = (data.Equipped[equipment.Category] == itemId),
			})
		end
	end

	inventoryResponseEvent:FireClient(player, inventoryList)
end

-- Handler: Beli item (dari Shop)
local function handlePurchaseRequest(player, itemId)
	local equipment = EquipmentData:GetById(itemId)
	if not equipment then
		return
	end

	local price = equipment.Price
	if not price.Rupiah and not price.Gems then
		return
	end

	-- Validasi saldo cukup
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

	-- Tambahkan ke inventori
	PlayerDataService:AddItemToInventory(player, itemId)

	-- Simpan
	PlayerDataService:Save(player)

	-- Beritahu klien
	local purchaseResultEvent = remotesFolder:FindFirstChild("PurchaseResult")
	if not purchaseResultEvent then
		purchaseResultEvent = Instance.new("RemoteEvent")
		purchaseResultEvent.Name = "PurchaseResult"
		purchaseResultEvent.Parent = remotesFolder
	end

	purchaseResultEvent:FireClient(player, itemId, true)
	print(("Pemain %s membeli %s"):format(player.Name, equipment.Name))
end

-- Connect events
equipEvent.OnServerEvent:Connect(handleEquipRequest)
unequipEvent.OnServerEvent:Connect(handleUnequipRequest)
requestInventoryEvent.OnServerEvent:Connect(handleInventoryRequest)

-- API publik untuk sistem lain
function EquipmentService:ApplyEquipmentStats(player, character)
	local data = PlayerDataService:Get(player)
	local stats = {}

	for category, itemId in pairs(data.Equipped or {}) do
		local equipment = EquipmentData:GetById(itemId)
		if equipment and equipment.Stats then
			for statName, statValue in pairs(equipment.Stats) do
				if typeof(statValue) == "number" then
					stats[statName] = (stats[statName] or 0) + statValue
				end
			end
		end
	end

	return stats
end

return EquipmentService