-- QuestData.lua
-- Modul data statik untuk Quest (Daily & Weekly).
-- Letakkan di: ReplicatedStorage/Modules/QuestData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local QuestData = {}

QuestData.Quests = {
	-- === Daily Quests ===
	{
		Id = "Daily_Capture_3",
		Name = "Tangkap 3 Arwah",
		Description = "Tangkap 3 jenis hantu berbeda dalam sehari",
		Type = "Daily",
		Requirement = { Stat = "CaughtGhosts", Value = 3 },
		Reward = { Rupiah = 500, Gems = 2 },
		Icon = "👻",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Collect_500",
		Name = "Kumpulkan 500 Rupiah",
		Description = "Kumpulkan setotal 500 Rupiah dari berburu",
		Type = "Daily",
		Requirement = { Stat = "Currency_Rupiah", Value = 500 },
		Reward = { Rupiah = 200, Gems = 0 },
		Icon = "🪙",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Use_Emote",
		Name = "Pakai Emote",
		Description = "Gunakan emote 5 kali dalam sehari",
		Type = "Daily",
		Requirement = { Stat = "EmotesUsed", Value = 5 },
		Reward = { Rupiah = 100, Gems = 1 },
		Icon = "🎭",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Equip",
		Name = "Pakai Equipment",
		Description = "Equip 1 senjata dan 1 pelindung",
		Type = "Daily",
		Requirement = { Stat = "EquipmentEquipped", Value = 2 },
		Reward = { Rupiah = 150, Gems = 0 },
		Icon = "⚔️",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Shop",
		Name = "Beli dari Toko",
		Description = "Belanja 1 item dari toko",
		Type = "Daily",
		Requirement = { Stat = "ItemsPurchased", Value = 1 },
		Reward = { Rupiah = 300, Gems = 0 },
		Icon = "🛒",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_BattlePass",
		Name = "Dapatkan EXP Battle Pass",
		Description = "Dapatkan 100 EXP Battle Pass",
		Type = "Daily",
		Requirement = { Stat = "BattlePassEXP", Value = 100 },
		Reward = { Rupiah = 250, Gems = 1 },
		Icon = "📊",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Gacha",
		Name = "Gacha 1x",
		Description = "Lakukan 1 pull gacha",
		Type = "Daily",
		Requirement = { Stat = "GachaRolls", Value = 1 },
		Reward = { Rupiah = 50, Gems = 0 },
		Icon = "🎁",
		ResetTime = "00:00",
	},
	{
		Id = "Daily_Hunter_Level",
		Name = "Naik Level",
		Description = "Naik level 1 kali",
		Type = "Daily",
		Requirement = { Stat = "Level", Value = 1 },
		Reward = { Rupiah = 400, Gems = 3 },
		Icon = "⭐",
		ResetTime = "00:00",
	},

	-- === Weekly Quests ===
	{
		Id = "Weekly_Capture_20",
		Name = "Tangkap 20 Arwah",
		Description = "Tangkap 20 jenis hantu berbeda dalam seminggu",
		Type = "Weekly",
		Requirement = { Stat = "CaughtGhosts", Value = 20 },
		Reward = { Rupiah = 2000, Gems = 15 },
		Icon = "👻",
		ResetTime = "Mingguan",
	},
	{
		Id = "Weekly_Kill_100",
		Name = "Bunuh 100 Arwah",
		Description = "Bunuh 100 arwah dalam seminggu",
		Type = "Weekly",
		Requirement = { Stat = "GhostsKilled", Value = 100 },
		Reward = { Rupiah = 1500, Gems = 10 },
		Icon = "💀",
		ResetTime = "Mingguan",
	},
	{
		Id = "Weekly_Gems_200",
		Name = "Kumpulkan 200 Gems",
		Description = "Dapatkan total 200 Gems dalam seminggu",
		Type = "Weekly",
		Requirement = { Stat = "Currency_Gems", Value = 200 },
		Reward = { Rupiah = 5000, Gems = 20 },
		Icon = "💎",
		ResetTime = "Mingguan",
	},
	{
		Id = "Weekly_Gacha_20",
		Name = "Gacha 20x",
		Description = "Lakukan 20 pull gacha dalam seminggu",
		Type = "Weekly",
		Requirement = { Stat = "GachaRolls", Value = 20 },
		Reward = { Rupiah = 3000, Gems = 25 },
		Icon = "🎁",
		ResetTime = "Mingguan",
	},
	{
		Id = "Weekly_Shop_5",
		Name = "Beli 5 Item",
		Description = "Belanja 5 item dari toko dalam seminggu",
		Type = "Weekly",
		Requirement = { Stat = "ItemsPurchased", Value = 5 },
		Reward = { Rupiah = 1000, Gems = 5 },
		Icon = "🛒",
		ResetTime = "Mingguan",
	},
}

QuestData.QUANTITY_PER_RESET = {
	Daily = 3,
	Weekly = 2,
}

-- Helper
function QuestData:GetDailyQuests()
	local result = {}
	for _, quest in ipairs(self.Quests) do
		if quest.Type == "Daily" then
			table.insert(result, quest)
		end
	end
	return result
end

function QuestData:GetWeeklyQuests()
	local result = {}
	for _, quest in ipairs(self.Quests) do
		if quest.Type == "Weekly" then
			table.insert(result, quest)
		end
	end
	return result
end

function QuestData:GetById(id)
	for _, quest in ipairs(self.Quests) do
		if quest.Id == id then
			return quest
		end
	end
	return nil
end

return QuestData