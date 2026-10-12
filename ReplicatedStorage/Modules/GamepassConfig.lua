-- GamepassConfig.lua
-- Konfigurasi gamepass untuk Hunt Mystic Ghost.
-- Letakkan di: ReplicatedStorage/Modules/GamepassConfig.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local GamepassConfig = {}

-- Daftar gamepass dengan ID Roblox dan benefit
-- Ganti ID di bawah dengan ID gamepass sebenarnya dari developer portal
GamepassConfig.Passes = {
	{
		Id = "Double_Rupiah",
		Name = "Rupiah Ganda",
		GamepassId = 123456789, -- Ganti dengan ID gamepass sebenarnya
		Description = "Dapatkan 2x Rupiah dari semua sumber",
		Benefit = { CurrencyMultiplier = { Rupiah = 2 } },
		Icon = "💰",
		IconImage = "rbxasset://textures/Gamepasses/DoubleRupiah.png",
		Rarity = "Langka",
		Price = { Display = "75 💎" },
	},
	{
		Id = "Extra_Inventory",
		Name = "Slot Inventori Ekstra",
		GamepassId = 123456790,
		Description = "Kapasitas inventori bertambah 20 slot",
		Benefit = { InventorySlots = 20 },
		Icon = "🎒",
		IconImage = "rbxasset://textures/Gamepasses/ExtraInventory.png",
		Rarity = "Langka",
		Price = { Display = "50 💎" },
	},
	{
		Id = "Auto_Collect",
		Name = "Auto Koleksi",
		GamepassId = 123456791,
		Description = "Item dan mata uang dikumpulkan otomatis",
		Benefit = { AutoCollect = true },
		Icon = "⚡",
		IconImage = "rbxasset://textures/Gamepasses/AutoCollect.png",
		Rarity = "Legendaris",
		Price = { Display = "100 💎" },
	},
	{
		Id = "Double_XP",
		Name = "XP Ganda",
		GamepassId = 123456792,
		Description = "Dapatkan 2x EXP dari semua aktivitas",
		Benefit = { XPMultiplier = 2 },
		Icon = "⭐",
		IconImage = "rbxasset://textures/Gamepasses/DoubleXP.png",
		Rarity = "Langka",
		Price = { Display = "60 💎" },
	},
	{
		Id = "Exclusive_Emote",
		Name = "Emote Eksklusif",
		GamepassId = 123456793,
		Description = "Dapatkan emote eksklusi 'Ghost King'",
		Benefit = { UnlockEmote = "GhostKing" },
		Icon = "👑",
		IconImage = "rbxasset://textures/Gamepasses/ExclusiveEmote.png",
		Rarity = "Epic",
		Price = { Display = "40 💎" },
	},
}

-- Rarity definitions
GamepassConfig.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Langka = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Epic = { Name = "Epik", Color = Theme.COLORS.Crimson, Icon = "◆◆◆" },
	Legendaris = { Name = "Legendaris", Color = Theme.COLORS.Gold, Icon = "◆◆◆◆" },
}

-- Helper: Dapatkan gamepass berdasarkan ID internal
function GamepassConfig:GetById(id)
	for _, pass in ipairs(self.Passes) do
		if pass.Id == id then
			return pass
		end
	end
	return nil
end

-- Helper: Dapatkan rarity color
function GamepassConfig:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

-- Helper: Dapatkan semua gamepass
function GamepassConfig:GetAll()
	return self.Passes
end

return GamepassConfig