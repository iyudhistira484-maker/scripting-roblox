-- BlackMarketData.lua
-- Modul data statik untuk Black Market (Pasar Gelap).
-- Letakkan di: ReplicatedStorage/Modules/BlackMarketData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local BlackMarketData = {}

-- Pool item yang bisa muncul di Black Market
-- Format: Id, Nama, Kategori, Rarity, Harga, Deskripsi, IconImage
-- Rotasi: item yang muncul di black market (harga lebih mahal dari shop)
BlackMarketData.Items = {
	{
		Id = "Keris_Raja_Skin",
		Name = "Skin Keris Raja",
		Category = "Skin",
		Rarity = "Epic",
		Price = { Gems = 25 },
		Description = "Skin langka untuk Keris Raja",
		IconImage = "rbxasset://textures/BlackMarket/KerisRajaSkin.png",
	},
	{
		Id = "Senter_Emas",
		Name = "Senter Emas",
		Category = "Senjata",
		Rarity = "Mythic",
		Stats = { Damage = 35, Radius = 8, Durability = 150 },
		Price = { Gems = 50 },
		Description = "Senter berlapis emas yang menemani langkah di kegelangan",
		IconImage = "rbxasset://textures/BlackMarket/SenterEmas.png",
	},
	{
		Id = "Jubah_Raja",
		Name = "Jubah Raja Arwah",
		Category = "Pelindung",
		Rarity = "Legend",
		Stats = { Defense = 25, Weight = 5, Effect = "GhostResist" },
		Price = { Gems = 75 },
		Description = "Jubah kuno dari penguasa nusantara yang tak terlihat",
		IconImage = "rbxasset://textures/BlackMarket/JubahRaja.png",
	},
	{
		Id = "Serum_Sanity",
		Name = "Serum Sanity",
		Category = "Consumable",
		Rarity = "Rare",
		Price = { Rupiah = 2000, Gems = 5 },
		Description = "Mengembalikan sanity penuh",
		IconImage = "rbxasset://textures/BlackMarket/SerumSanity.png",
	},
	{
		Id = "Kunci_Gacha",
		Name = "Kunci Gacha Premium",
		Category = "Consumable",
		Rarity = "Epic",
		Price = { Gems = 30 },
		Description = "Kunci langka untuk membuka peti gacha premium",
		IconImage = "rbxasset://textures/BlackMarket/KunciPurple.png",
	},
	{
		Id = "Emote_Taunt",
		Name = "Emote: Tantangan",
		Category = "Emote",
		Rarity = "Rare",
		Price = { Gems = 15 },
		Description = "Emote menantang arwah ke datang",
		IconImage = "rbxasset://textures/BlackMarket/EmoteTaunt.png",
	},
	{
		Id = "Scroll_Skill_Reset",
		Name = "Gulungan Reset Skill",
		Category = "Consumable",
		Rarity = "Legend",
		Price = { Gems = 100 },
		Description = "Reset seluruh skill tree sehingga bisa dialokasikan kembali",
		IconImage = "rbxasset://textures/BlackMarket/ScrollReset.png",
	},
	{
		Id = "Medali_Honor",
		Name = "Medali Honorer",
		Category = "Currency",
		Rarity = "Mythic",
		Price = { Gems = 80 },
		Description = "Mata uang premium untuk Battle Pass",
		IconImage = "rbxasset://textures/BlackMarket/MedaliHonor.png",
	},
}

-- Rarity definitions
BlackMarketData.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Rare = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Epic = { Name = "Epik", Color = Theme.COLORS.Crimson, Icon = "◆◆◆" },
	Legend = { Name = "Legendaris", Color = Theme.COLORS.Gold, Icon = "◆◆◆◆" },
	Mythic = { Name = "Mitos", Color = Theme.COLORS.GoldHi, Icon = "◆◆◆◆◆" },
}

-- Helper: Dapatkan item berdasarkan ID
function BlackMarketData:GetById(id)
	for _, item in ipairs(self.Items) do
		if item.Id == id then
			return item
		end
	end
	return nil
end

-- Helper: Dapatkan rarity color
function BlackMarketData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

-- Helper: Dapatkan semua item untuk stock
function BlackMarketData:GetAllForStock()
	return self.Items
end

return BlackMarketData