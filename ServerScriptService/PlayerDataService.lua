-- PlayerDataService.lua
-- Sumber kebenaran tunggal untuk semua data pemain.
-- Tempatkan di: ServerScriptService/PlayerDataService.lua

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- DataStore (hanya boleh diakses dari server)
local playerDataStore = DataStoreService:GetDataStore("PlayerData_V1")

-- BindableEvent agar sistem lain boleh mendengar perubahan data pemain
local dataChangedEvent
if RunService:IsStudio() then
	dataChangedEvent = Instance.new("BindableEvent")
	dataChangedEvent.Name = "DataChanged"
	dataChangedEvent.Parent = script
end

local DEFAULT_DATA = {
	-- Mata ganang
	Currency = {
		Rupiah = 0,
		Gems = 0,
	},

	-- Inventori pemain (senjata, armor, alat)
	Inventory = {},

	-- Equipment yang sedang dipakai pemain (key = category, value = equipmentId)
	Equipped = {},

	-- Koleksi hantu yang berjaya ditangkap (key = ghostId, value = { caughtAt, location })
	CaughtGhosts = {},

	-- Pangkah / gelaran yang telah dikunci
	UnlockedRanks = { "Pemburu Pemula" },
	ActiveRank = "Pemburu Pemula",

	-- Pencapaian / achievements
	CompletedAchievements = {},

	-- Kemajuan gacha (pity counter)
	GachaPity = {},

	-- Streak log masuk harian
	LoginStreak = {
		CurrentStreak = 0,
		LastLoginDate = "",
		ClaimedToday = false,
	},

	-- Quest harian & mingguan
	ActiveQuests = {},
	CompletedQuests = {},

	-- EXP / Level
	EXP = 0,
	Level = 1,

	-- Skill tree nodes yang telah dibuka
	UnlockedSkills = {},

	-- Battle Pass
	BattlePassEXP = 0,
	BattlePassTier = 1,
	BattlePassClaimed = {},
	BattlePassPremium = false,

	-- Trap yang dimiliki & cooldown
	TrapsOwned = {},
	TrapCooldowns = {},

	-- Nilai sanity
	Sanity = 100,

	-- Skin yang dimiliki & yang sedang dipakai
	OwnedSkins = {},
	ActiveSkins = {},

	-- Emote yang dimiliki
	OwnedEmotes = {},

	-- Lucky wheel spin gratis hari ini
	LuckyWheelSpunToday = false,

	-- Gamepass yang dimiliki
	GamepassesOwned = {},

	-- Sistem invite/referral
	ReferralCode = "",
	InvitedBy = nil,
	InviteRewards = {},

	-- Pengaturan personal (jumpscare, getaran, pencahayaan, FOV, musik)
	Settings = {
		JumpscareIntensity = "Full", -- "Full" / "Reduced" / "Off"
		Vibration = true,
		Brightness = 1,
		FOV = 70,
		MusicVolume = 0.5,
	},
}

-- Helper: dalam ruang lingkup sumber, ini biasanya diganti dengan GetAsync & SetAsync
-- yang sesungguhnya. Di sini kami menyalakannya kerana ini adalah simulasi.
local playerData = {}

local function getPlayerKey(player)
	return "Player_" .. player.UserId
end

local function loadPlayerData(player)
	local key = getPlayerKey(player)
	local success, data = pcall(function()
		return playerDataStore:GetAsync(key)
	end)

	if success and data then
		-- Gabungkan data yang dimuat dengan default untuk medan yang belum ada
		for k, v in pairs(DEFAULT_DATA) do
			if data[k] == nil then
				data[k] = v
			end
		end
		playerData[player] = data
	else
		-- Salin default data untuk pemain baru
		playerData[player] = {}
		for k, v in pairs(DEFAULT_DATA) do
			if type(v) == "table" then
				playerData[player][k] = {}
				for k2, v2 in pairs(v) do
					playerData[player][k][k2] = v2
				end
			else
				playerData[player][k] = v
			end
		end
	end
end

local function savePlayerData(player)
	local key = getPlayerKey(player)
	local data = playerData[player]
	if data then
		local success, err = pcall(function()
			playerDataStore:SetAsync(key, data)
		end)
		if not success then
			warn("Gagal menyimpan data untuk " .. player.Name .. ": " .. tostring(err))
		end
	end
end

-- API umum
local PlayerDataService = {}

function PlayerDataService:Get(player)
	if not playerData[player] then
		loadPlayerData(player)
	end
	return playerData[player]
end

function PlayerDataService:Save(player)
	savePlayerData(player)
end

function PlayerDataService:GetField(player, field)
	local data = self:Get(player)
	return data[field]
end

function PlayerDataService:SetField(player, field, value)
	local data = self:Get(player)
	data[field] = value
	self._internal_fireChange(player, field, value)
end

function PlayerDataService:_internal_fireChange(player, field, value)
	-- Ini hanya akan dipanggil secara dalaman
	if dataChangedEvent then
		dataChangedEvent:Fire(player, field, value)
	end
end

-- API khusus untuk Koleksi Hantu
function PlayerDataService:HasCaughtGhost(player, ghostId)
	local data = self:Get(player)
	return data.CaughtGhosts[ghostId] ~= nil
end

function PlayerDataService:AddCaughtGhost(player, ghostId, location)
	if self:HasCaughtGhost(player, ghostId) then
		return false -- sudah pernah ditangkap, cegah exploit
	end

	local data = self:Get(player)
	data.CaughtGhosts[ghostId] = {
		CaughtAt = tick(),
		Location = location,
	}
	self:_internal_fireChange(player, "CaughtGhosts", data.CaughtGhosts)
	return true
end

function PlayerDataService:GetCaughtCount(player)
	local data = self:Get(player)
	local count = 0
	for _ in pairs(data.CaughtGhosts) do
		count = count + 1
	end
	return count
end

function PlayerDataService:GetTotalGhostCount()
	-- Ini seharusnya dibaca dari modul GhostData nanti
	-- Untuk sekarang, hardcode sementara
	return 0 -- akan diganti setelah GhostData.lua cipta
end

-- API untuk Mata Uang (Currency)
function PlayerDataService:GetCurrency(player, currencyType)
	local data = self:Get(player)
	if not data.Currency[currencyType] then
		data.Currency[currencyType] = 0
	end
	return data.Currency[currencyType]
end

function PlayerDataService:SetCurrency(player, currencyType, amount)
	local data = self:Get(player)
	data.Currency[currencyType] = math.max(0, amount)
	self:_internal_fireChange(player, "Currency", data.Currency)
end

function PlayerDataService:AddCurrency(player, currencyType, amount)
	local current = self:GetCurrency(player, currencyType)
	local newAmount = current + math.max(0, amount)
	self:SetCurrency(player, currencyType, newAmount)
	return newAmount
end

function PlayerDataService:RemoveCurrency(player, currencyType, amount)
	local current = self:GetCurrency(player, currencyType)
	if current < amount then
		return false, "Saldo tidak mencukupi"
	end
	local newAmount = current - amount
	self:SetCurrency(player, currencyType, newAmount)
	return true, newAmount
end

-- API untuk Inventori & Equipment
function PlayerDataService:AddItemToInventory(player, itemId)
	local data = self:Get(player)
	if not table.find(data.Inventory, itemId) then
		table.insert(data.Inventory, itemId)
	end
end

function PlayerDataService:HasItemInInventory(player, itemId)
	local data = self:Get(player)
	return table.find(data.Inventory, itemId) ~= nil
end

function PlayerDataService:RemoveItemFromInventory(player, itemId)
	local data = self:Get(player)
	for i, id in ipairs(data.Inventory) do
		if id == itemId then
			table.remove(data.Inventory, i)
			return true
		end
	end
	return false
end

function PlayerDataService:GetEquipped(player, category)
	local data = self:Get(player)
	return data.Equipped[category]
end

function PlayerDataService:EquipItem(player, itemId, category)
	local data = self:Get(player)
	data.Equipped[category] = itemId
	self:_internal_fireChange(player, "Equipped", data.Equipped)
end

function PlayerDataService:UnequipItem(player, category)
	local data = self:Get(player)
	data.Equipped[category] = nil
	self:_internal_fireChange(player, "Equipped", data.Equipped)
end

-- API for Achievements
function PlayerDataService:HasCompletedAchievement(player, achievementId)
	local data = self:Get(player)
	return data.CompletedAchievements[achievementId] ~= nil
end

function PlayerDataService:UnlockAchievement(player, achievementId)
	if self:HasCompletedAchievement(player, achievementId) then
		return false -- sudah pernah
	end

	local data = self:Get(player)
	data.CompletedAchievements[achievementId] = {
		UnlockedAt = tick(),
	}
	self:_internal_fireChange(player, "CompletedAchievements", data.CompletedAchievements)
	return true
end

function PlayerDataService:GetCompletedAchievementCount(player)
	local data = self:Get(player)
	local count = 0
	for _ in pairs(data.CompletedAchievements) do
		count = count + 1
	end
	return count
end

-- Inisialisasi
Players.PlayerAdded:Connect(function(player)
	loadPlayerData(player)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
	playerData[player] = nil
end)

-- Auto-save periodik
game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerData(player)
	end
end)

return PlayerDataService