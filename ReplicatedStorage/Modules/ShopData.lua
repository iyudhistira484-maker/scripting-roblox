-- ShopData.lua
-- Modul data statik untuk Shop (Toko Senjata/Armor/Minuman/Makanan).
-- Letakkan di: ReplicatedStorage/Modules/ShopData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local ShopData = {}

-- Kategori: Senjata, Armor, Minuman, Makanan
ShopData.Categories = {
	"Senjata",
	"Armor",
	"Minuman",
	"Makanan",
}

-- Format: Id, Nama, Kategori, Stats, Harga, Deskripsi, Icon, IconImage
ShopData.Items = {
	-- === Senjata ===
	{
		Id = "Senter_Roti",
		Name = "Senter Roti",
		Category = "Senjata",
		Stats = { Damage = 12, Radius = 5, Durability = 50 },
		Price = { Rupiah = 300, Gems = 0 },
		Description = "Senter roti kuno, memberi cahaya lemah",
		Icon = "🪔",
		IconImage = "rbxasset://textures/Shop/SenterRoti.png",
	},
	{
		Id = "Keris_Dapur",
		Name = "Keris Dapur",
		Category = "Senjata",
		Stats = { Damage = 18, Radius = 6, Durability = 75 },
		Price = { Rupiah = 600, Gems = 3 },
		Description = "Pisau dapur tajam yang dipakai untuk membelah arwah",
		Icon = "🔪",
		IconImage = "rbxasset://textures/Shop/KerisDapur.png",
	},

	-- === Armor ===
	{
		Id = "Pelindung_Kain",
		Name = "Pelindung Kain",
		Category = "Armor",
		Stats = { Defense = 8, Weight = 1 },
		Price = { Rupiah = 250, Gems = 0 },
		Description = "Kain tebal yang menyaring sebagian damage",
		Icon = "🛡️",
		IconImage = "rbxasset://textures/Shop/PelindungKain.png",
	},
	{
		Id = "Baju_Batik",
		Name = "Baju Batik Tradisional",
		Category = "Armor",
		Stats = { Defense = 12, Weight = 2, Effect = "ColdResist" },
		Price = { Rupiah = 500, Gems = 4 },
		Description = "Baju batik yang enak dipakai di cuaca sejuk",
		Icon = "👘",
		IconImage = "rbxasset://textures/Shop/BajuBatik.png",
	},

	-- === Minuman ===
	{
		Id = "Minum_Kopi",
		Name = "Kopi Hitam",
		Category = "Minuman",
		Stats = { Effect = "SpeedBoost", Duration = 30, Value = 15 },
		Price = { Rupiah = 150, Gems = 0 },
		Description = "Minuman panas yang meningkatkan kecepatan sejenak",
		Icon = "☕",
		IconImage = "rbxasset://textures/Shop/KopiHitam.png",
	},
	{
		Id = "Minum_Jamu",
		Name = "Jamu Tradisional",
		Category = "Minuman",
		Stats = { Effect = "DamageBoost", Duration = 30, Value = 20 },
		Price = { Rupiah = 300, Gems = 2 },
		Description = "Minuman herbal tradisional yang meningkatkan damage",
		Icon = "🍯",
		IconImage = "rbxasset://textures/Shop/JamuTradisional.png",
	},

	-- === Makanan ===
	{
		Id = "Makan_Keripik",
		Name = "Keripik Singkong",
		Category = "Makanan",
		Stats = { Effect = "Heal", Value = 20 },
		Price = { Rupiah = 80, Gems = 0 },
		Description = "Makanan ringan yang memulihkan sebagian health",
		Icon = "🍴",
		IconImage = "rbxasset://textures/Shop/KeripikSingkong.png",
	},
	{
		Id = "Makan_Kue",
		Name = "Kue Lapis",
		Category = "Makanan",
		Stats = { Effect = "FullHeal", Value = 50 },
		Price = { Rupiah = 200, Gems = 1 },
		Description = "Kue tradisional yang memulihkan health penuh",
		Icon = "🍰",
		IconImage = "rbxasset://textures/Shop/KueLapis.png",
	},
}

-- Helper
function ShopData:GetById(id)
	for _, item in ipairs(self.Items) do
		if item.Id == id then
			return item
		end
	end
	return nil
end

function ShopData:GetByCategory(category)
	local result = {}
	for _, item in ipairs(self.Items) do
		if item.Category == category then
			table.insert(result, item)
		end
	end
	return result
end

function ShopData:GetAll()
	return self.Items
end

return ShopData