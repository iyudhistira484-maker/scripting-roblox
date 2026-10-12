-- AchievementData.lua
-- Modul data statik untuk semua achievement
-- Letakkan di: ReplicatedStorage/Modules/AchievementData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local AchievementData = {}

-- Format: Id, Nama, Deskripsi, Syarat (stat & nilai minimal), Reward
AchievementData.Achievements = {
	-- === Ghost Collection ===
	{
		Id = "Ghost_Hunter_1",
		Name = "Pemburu Arwah Pemula",
		Description = "Tangkap 1 jenis hantu pertama kali",
		Icon = "👻",
		Rarity = "Umum",
		Requirement = { Stat = "CaughtGhosts", Value = 1 },
		Reward = { Rupiah = 500, Gems = 0 },
		IconImage = "rbxasset://textures/Achievements/GhostHunter1.png",
	},
	{
		Id = "Ghost_Collector",
		Name = "Pengumpul Arwah",
		Description = "Tangkap 5 jenis hantu berbeda",
		Icon = "📚",
		Rarity = "Langka",
		Requirement = { Stat = "CaughtGhosts", Value = 5 },
		Reward = { Rupiah = 2000, Gems = 5 },
		IconImage = "rbxasset://textures/Achievements/GhostCollector.png",
	},
	{
		Id = "Ghost_Master",
		Name = "Master Arwah",
		Description = "Tangkap semua jenis hantu",
		Icon = "👑",
		Rarity = "Legendaris",
		Requirement = { Stat = "CaughtGhosts", Value = 12 },
		Reward = { Rupiah = 10000, Gems = 30 },
		IconImage = "rbxasset://textures/Achievements/GhostMaster.png",
	},

	-- === Currency ===
	{
		Id = "Rich_1",
		Name = "Cukup Berkat",
		Description = "Kumpulkan 1.000 Rupiah",
		Icon = "💰",
		Rarity = "Umum",
		Requirement = { Stat = "Currency_Rupiah", Value = 1000 },
		Reward = { Rupiah = 300, Gems = 2 },
		IconImage = "rbxasset://textures/Achievements/Rich1.png",
	},
	{
		Id = "Rich_2",
		Name = "Kaya Raya",
		Description = "Kumpulkan 10.000 Rupiah",
		Icon = "💸",
		Rarity = "Langka",
		Requirement = { Stat = "Currency_Rupiah", Value = 10000 },
		Reward = { Rupiah = 2000, Gems = 10 },
		IconImage = "rbxasset://textures/Achievements/Rich2.png",
	},
	{
		Id = "Gem_Lover",
		Name = "Penggemar Berlian",
		Description = "Kumpulkan 50 Gems",
		Icon = "💎",
		Rarity = "Legendaris",
		Requirement = { Stat = "Currency_Gems", Value = 50 },
		Reward = { Rupiah = 5000, Gems = 5 },
		IconImage = "rbxasset://textures/Achievements/GemLover.png",
	},

	-- === Level ===
	{
		Id = "Level_5",
		Name = "Pemburu Muda",
		Description = "Capai level 5",
		Icon = "⭐",
		Rarity = "Umum",
		Requirement = { Stat = "Level", Value = 5 },
		Reward = { Rupiah = 500, Gems = 0 },
		IconImage = "rbxasset://textures/Achievements/Level5.png",
	},
	{
		Id = "Level_20",
		Name = "Pemburu Berpengalaman",
		Description = "Capai level 20",
		Icon = "✨",
		Rarity = "Langka",
		Requirement = { Stat = "Level", Value = 20 },
		Reward = { Rupiah = 3000, Gems = 8 },
		IconImage = "rbxasset://textures/Achievements/Level20.png",
	},

	-- === Equipment ===
	{
		Id = "Equipment_10",
		Name = "Koleksi Alat",
		Description = "Miliki 10 alat berbeda",
		Icon = "🔨",
		Rarity = "Langka",
		Requirement = { Stat = "InventoryCount", Value = 10 },
		Reward = { Rupiah = 1500, Gems = 3 },
		IconImage = "rbxasset://textures/Achievements/Equipment10.png",
	},

	-- === Survival ===
	{
		Id = "Night_Oak",
		Name = "Menakluk Malam",
		Description = "Bertahan di area gelap selama 5 menit tanpa kehilangan sanity penuh",
		Icon = "🌙",
		Rarity = "Legendaris",
		Requirement = { Stat = "NightSurvival", Value = 5 },
		Reward = { Rupiah = 5000, Gems = 15 },
		IconImage = "rbxasset://textures/Achievements/NightOak.png",
	},

	-- === Quest ===
	{
		Id = "Quest_Master",
		Name = "Penyelesai Misiku",
		Description = "Selesaikan 50 quest",
		Icon = "📜",
		Rarity = "Mitos",
		Requirement = { Stat = "CompletedQuests", Value = 50 },
		Reward = { Rupiah = 10000, Gems = 20 },
		IconImage = "rbxasset://textures/Achievements/QuestMaster.png",
	},
}

-- Helper: Dapatkan semua achievement ID
function AchievementData:GetAllIds()
	local ids = {}
	for _, ach in ipairs(self.Achievements) do
		table.insert(ids, ach.Id)
	end
	return ids
end

-- Helper: Dapatkan achievement berdasarkan ID
function AchievementData:GetById(id)
	for _, ach in ipairs(self.Achievements) do
		if ach.Id == id then
			return ach
		end
	end
	return nil
end

-- Helper: Dapatkan achievement berdasarkan stat dan nilai minimum
function AchievementData:GetByRequirement(stat, minValue)
	local results = {}
	for _, ach in ipairs(self.Achievements) do
		if ach.Requirement.Stat == stat and ach.Requirement.Value <= minValue then
			table.insert(results, ach)
		end
	end
	return results
end

-- Helper: Dapatkan rarity color
function AchievementData:GetRarityColor(rarity)
	local rarityMap = {
		["Umum"] = Theme.COLORS.BoneDim,
		["Langka"] = Theme.COLORS.JadeGlow,
		["Legendaris"] = Theme.COLORS.Gold,
		["Mitos"] = Theme.COLORS.Crimson,
	}
	return rarityMap[rarity] or Theme.COLORS.Bone
end

return AchievementData