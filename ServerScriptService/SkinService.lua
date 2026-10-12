-- SkinService.lua
-- Logik pelayan untuk Skin / Kostum Karakter.
-- Letakkan di: ServerScriptService/SkinService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local SkinData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SkinData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Skin")
local requestSkinsEvent = remotesFolder:WaitForChild("RequestSkins")
local equipSkinEvent = remotesFolder:WaitForChild("EquipSkin")

local SkinService = {}

-- Apply skin ke karakter pemain
function SkinService:ApplySkinToCharacter(player, character)
	local data = PlayerDataService:Get(player)
	local activeSkins = data.ActiveSkins or {}

	for slot, skinId in pairs(activeSkins) do
		local skin = SkinData:GetById(skinId)
		if skin and skin.Category == slot and character then
			-- Apply skin ke karakter sesuai kategori
			if skin.MeshId then
				local mesh = Instance.new("SpecialMesh")
				mesh.MeshId = skin.MeshId
				mesh.Parent = character:FindFirstChild("Head") or character:FindFirstChild("Torso")
			end
		end
	end
end

-- Handler: Request daftar skin
local function handleRequestSkins(player)
	local data = PlayerDataService:Get(player)
	local ownedSkins = data.OwnedSkins or {}
	local activeSkins = data.ActiveSkins or {}

	local skinList = {}
	for _, skin in ipairs(SkinData.Skins) do
		local owned = table.find(ownedSkins, skin.Id) ~= nil
		local active = activeSkins[skin.Category] == skin.Id

		-- Skin gratis selalu dimiliki
		if skin.Source == "gratis" then
			owned = true
		end

		table.insert(skinList, {
			Id = skin.Id,
			Name = skin.Name,
			Category = skin.Category,
			Description = skin.Description,
			IconImage = skin.IconImage,
			Rarity = skin.Rarity,
			Price = skin.Price,
			Owned = owned,
			Active = active,
		})
	end

	local responseEvent = remotesFolder:FindFirstChild("SkinsResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "SkinsResponse"
		responseEvent.Parent = remotesFolder
	end
	responseEvent:FireClient(player, skinList)
end

-- Handler: Equip skin
local function handleEquipSkin(player, skinId)
	local skin = SkinData:GetById(skinId)
	if not skin then return end

	local data = PlayerDataService:Get(player)
	local owned = (data.OwnedSkins and table.find(data.OwnedSkins, skinId) ~= nil) or skin.Source == "gratis"

	if not owned then
		return
	end

	-- Equip skin ke slot kategori yang sesuai
	data.ActiveSkins = data.ActiveSkins or {}
	data.ActiveSkins[skin.Category] = skinId
	PlayerDataService:Save(player)

	-- Apply ke karakter yang ada
	local character = player.Character
	if character then
		SkinService:ApplySkinToCharacter(player, character)
	end

	-- Kirim konfirmasi ke klien
	local equippedEvent = remotesFolder:FindFirstChild("SkinEquipped")
	if not equippedEvent then
		equippedEvent = Instance.new("RemoteEvent")
		equippedEvent.Name = "SkinEquipped"
		equippedEvent.Parent = remotesFolder
	end
	equippedEvent:FireClient(player, skinId, skin.Category)
end

-- Connect events
requestSkinsEvent.OnServerEvent:Connect(handleRequestSkins)
equipSkinEvent.OnServerEvent:Connect(handleEquipSkin)

-- Character spawn
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		delay(1, function()
			SkinService:ApplySkinToCharacter(player, character)
		end)
	end)
end)

-- API publik
function SkinService:PlayerOwnsSkin(player, skinId)
	local data = PlayerDataService:Get(player)
	return table.find(data.OwnedSkins, skinId) ~= nil or SkinData:GetById(skinId).Source == "gratis"
end

return SkinService