-- SkinData.lua
-- Modul data statik untuk Skin/Kostum Karakter (Fitur 22).
-- Letakkan di: ReplicatedStorage/Modules/SkinData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local SkinData = {}

SkinData.Skins = {
	-- === Karakter ===
	{
		Id = "Karakter_Peserta_Leluh",
		Name = "Peserta Leluh",
		Category = "Character",
		Source = "gratis", -- gratis/beli/gacha/event
		Description = "Kostum dasar peserta",
		IconImage = "rbxasset://textures/Skins/KarakterPesertaLeluh.png",
		Rarity = "Common",
		Price = nil,
		MeshId = nil,
		BodyColors = {},
	},
	{
		Id = "Karakter_Baju_Koklo",
		Name = "Baju Koklo",
		Category = "Character",
		Source = "beli",
		Description = "Pakaian tradisional dari lepasan Nusantara",
		IconImage = "rbxasset://textures/Skins/KarakterBajuKoklo.png",
		Rarity = "Uncommon",
		Price = { Rupiah = 1500, Gems = 0 },
	},
	{
		Id = "Karakter_Adat_Keraton",
		Name = "Adat Keraton",
		Category = "Character",
		Source = "gacha",
		Description = "Pakaian kerajaan kuno",
		IconImage = "rbxasset://textures/Skins/KarakterAdatKeraton.png",
		Rarity = "Rare",
		Price = nil,
		DropRate = 0.05,
	},
	{
		Id = "Karakter_Raja_Roh",
		Name = "Raja Roh",
		Category = "Character",
		Source = "event",
		Description = "Kostum misterius dari alam roh",
		IconImage = "rbxasset://textures/Skins/KarakterRajaRoh.png",
		Rarity = "Mythic",
		Price = nil,
	},

	-- === Senjata ===
	{
		Id = "Senjata_Keris_Berlian",
		Name = "Keris Berlian",
		Category = "Weapon",
		Source = "beli",
		Description = "Pisau yang dipelukis dengan berlian",
		IconImage = "rbxasset://textures/Skins/SenjataKerisBerlian.png",
		Rarity = "Rare",
		Price = { Rupiah = 2000, Gems = 5 },
	},
	{
		Id = "Senjata_Pedang_Raja",
		Name = "Pedang Putih",
		Category = "Weapon",
		Source = "gacha",
		Description = "Pedang raja kuno dengan sinar bersinar",
		IconImage = "rbxasset://textures/Skins/SenjataPedangRaja.png",
		Rarity = "Legend",
		Price = nil,
		DropRate = 0.03,
	},

	-- === Alat ===
	{
		Id = "Alat_Senter_Mata",
		Name = "Senter Mata",
		Category = "Tool",
		Source = "beli",
		Description = "Senter yang menampilkan visi malam",
		IconImage = "rbxasset://textures/Skins/AlatSenterMata.png",
		Rarity = "Epic",
		Price = { Rupiah = 0, Gems = 15 },
	},
}

SkinData.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Uncommon = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Rare = { Name = "Langka", Color = Theme.COLORS.Gold, Icon = "◆◆◆" },
	Epic = { Name = "Epik", Color = Theme.COLORS.Crimson, Icon = "◆◆◆◆" },
	Legend = { Name = "Legendaris", Color = Theme.COLORS.GoldHi, Icon = "◆◆◆◆◆" },
	Mythic = { Name = "Mitos", Color = Theme.COLORS.Gold, Icon = "◆◆◆◆◆" },
}

function SkinData:GetById(id)
	for _, skin in ipairs(self.Skins) do
		if skin.Id == id then
			return skin
		end
	end
	return nil
end

function SkinData:GetByCategory(category)
	local result = {}
	for _, skin in ipairs(self.Skins) do
		if skin.Category == category then
			table.insert(result, skin)
		end
	end
	return result
end

function SkinData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

return SkinData