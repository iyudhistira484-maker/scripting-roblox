-- EquipmentData.lua
-- Modul data statik untuk semua alat/pakaian pemburu.
-- Letakkan di: ReplicatedStorage/Modules/EquipmentData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local EquipmentData = {}

-- Definisi rarity alat
EquipmentData.RARITIES = {
	Common = {
		Name = "Umum",
		Color = Theme.COLORS.BoneDim,
		Icon = "◆",
	},
	Uncommon = {
		Name = "Langka",
		Color = Theme.COLORS.JadeGlow,
		Icon = "◆◆",
	},
	Rare = {
		Name = "Langka",
		Color = Theme.COLORS.Gold,
		Icon = "◆◆◆",
	},
	Epic = {
		Name = "Legendaris",
		Color = Theme.COLORS.Crimson,
		Icon = "◆◆◆◆",
	},
	Mythic = {
		Name = "Mitos",
		Color = Theme.COLORS.JadeGlow,
		Icon = "◆◆◆◆◆",
	},
}

function EquipmentData:GetRarityByName(name)
	return self.RARITIES[name] or self.RARITIES.Common
end

-- Format: Id, Nama, Kategori, Rarity, Stats, Harga, Deskripsi
-- Kategori: "Senjata", "Pelindung", "Alat"
EquipmentData.Equipment = {
	-- === Senjata ===
	{
		Id = "Senter_Bambu",
		Name = "Senter Bambu",
		Category = "Senjata",
		Rarity = "Common",
		Stats = { Damage = 10, Radius = 5, Durability = 50 },
		Price = { Rupiah = 200, Gems = 0 },
		Description = "Senter bambu dasar yang memberikan cahaya redup di kegelapan.",
		IconImage = "rbxasset://textures/Equipment/SenterBambu.png",
	},
	{
		Id = "Keris_Raja",
		Name = "Keris Raja",
		Category = "Senjata",
		Rarity = "Rare",
		Stats = { Damage = 25, Radius = 7, Durability = 100 },
		Price = { Rupiah = 800, Gems = 5 },
		Description = "Kris kuno yang dikelilingi energi roh. Melukai arwah dengan tajamnya bilahnya.",
		IconImage = "rbxasset://textures/Equipment/KerisRaja.png",
	},
	{
		Id = "Garam_Seribu",
		Name = "Garam Seribu",
		Category = "Alat",
		Rarity = "Uncommon",
		Stats = { Damage = 5, Radius = 10, Durability = 30, Effect = "Slow" },
		Price = { Rupiah = 350, Gems = 2 },
		Description = "Garam halus dalam segitiga guling. Menyebabkan arwah melambat bila tersentuh.",
		IconImage = "rbxasset://textures/Equipment/GaramSeribu.png",
	},
	{
		Id = "Kamera_Roh",
		Name = "Kamera Roh",
		Category = "Alat",
		Rarity = "Epic",
		Stats = { Damage = 15, Radius = 15, Durability = 75, Effect = "Stun" },
		Price = { Rupiah = 1200, Gems = 8 },
		Description = "Kamera lama yang tersohoh. Foto raknanya bisa membekukan arwah sejenak.",
		IconImage = "rbxasset://textures/Equipment/KameraRoh.png",
	},
	{
		Id = "Pedang_Emas",
		Name = "Pedang Emas",
		Category = "Senjata",
		Rarity = "Mythic",
		Stats = { Damage = 50, Radius = 10, Durability = 200 },
		Price = { Rupiah = 2500, Gems = 20 },
		Description = "Pisau emas kuno dari kerajaan yang hilang. Melukai arwah dengan sinar suci.",
		IconImage = "rbxasset://textures/Equipment/PedangEmas.png",
	},

	-- === Pelindung ===
	{
		Id = "Pelindung_Tali",
		Name = "Tali Pelindung",
		Category = "Pelindung",
		Rarity = "Common",
		Stats = { Defense = 5, Weight = 1 },
		Price = { Rupiah = 150, Gems = 0 },
		Description = "Tali rajut sederhana yang menimbulkan pelindungan lemah.",
		IconImage = "rbxasset://textures/Equipment/TaliPelindung.png",
	},
	{
		Id = "Jubah_Anyam",
		Name = "Jubah Anyam",
		Category = "Pelindung",
		Rarity = "Rare",
		Stats = { Defense = 15, Weight = 3, Effect = "WindResist" },
		Price = { Rupiah = 600, Gems = 4 },
		Description = "Jubah anyam tradisional yang dilapisi benang emas. Menyerap sebagian energi arwah.",
		IconImage = "rbxasset://textures/Equipment/JubahAnyam.png",
	},

	-- === Alat ===
	{
		Id = "Minyak_Pelita",
		Name = "Minyak Pelita",
		Category = "Alat",
		Rarity = "Common",
		Stats = { Uses = 3, Effect = "BrightLight" },
		Price = { Rupiah = 100, Gems = 0 },
		Description = "Minyak tanah dalam sebuah cangkir. Menciptakan cahaya terang untuk waktu terbatas.",
		IconImage = "rbxasset://textures/Equipment/MinyakPelita.png",
	},
	{
		Id = "Kemenyan_Kunyit",
		Name = "Kemenyan & Kunyit",
		Category = "Alat",
		Rarity = "Uncommon",
		Stats = { Uses = 5, Effect = "Detect" },
		Price = { Rupiah = 400, Gems = 3 },
		Description = "Campuran kemenyan dan kunyit. Mendeteksi kehadiran arwah dalam radius.",
		IconImage = "rbxasset://textures/Equipment/KemenyanKunyit.png",
	},
}

-- Helper
function EquipmentData:GetAllIds()
	local ids = {}
	for _, eq in ipairs(self.Equipment) do
		table.insert(ids, eq.Id)
	end
	return ids
end

function EquipmentData:GetById(id)
	for _, eq in ipairs(self.Equipment) do
		if eq.Id == id then
			return eq
		end
	end
	return nil
end

function EquipmentData:GetByCategory(category)
	local result = {}
	for _, eq in ipairs(self.Equipment) do
		if eq.Category == category then
			table.insert(result, eq)
		end
	end
	return result
end

function EquipmentData:GetTotalCount()
	return #self.Equipment
end

return EquipmentData