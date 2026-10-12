-- RankService.lua
-- Logik pelayan untuk Rank / Title (Pangkat)
-- Letakkan di: ServerScriptService/RankService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local RankData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RankData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rank")

-- RemoteEvent
local rankUpdatedEvent = remotesFolder:FindFirstChild("RankUpdated")
if not rankUpdatedEvent then
	rankUpdatedEvent = Instance.new("RemoteEvent")
	rankUpdatedEvent.Name = "RankUpdated"
	rankUpdatedEvent.Parent = remotesFolder
end

local requestRanksEvent = remotesFolder:WaitForChild("RequestRanks")

-- BindableEvent untuk level up (dari sistem lain)
local LevelUpInternal = game.ServerScriptService:FindFirstChild("LevelUpInternal")

local RankService = {}

-- Handler: Request daftar rank dari klien
local function handleRequestRanks(player)
	local data = PlayerDataService:Get(player)
	local playerLevel = data.Level or 1
	local unlockedRanks = RankData:GetUnlockedRanks(playerLevel)
	local activeRankId = data.ActiveRank

	-- Kirim daftar rank + rank aktif
	local responseEvent = remotesFolder:FindFirstChild("RanksResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "RanksResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, {
		Ranks = unlockedRanks,
		ActiveRank = activeRankId,
		CurrentLevel = playerLevel,
	})
end

-- Handler: Pilih rank dari klien
local function handleSelectRank(player, rankId)
	-- Validasi rank ada
	local rank = RankData:GetById(rankId)
	if not rank then
		warn(("Pemain %s mencoba pilih rank tidak sah: %s"):format(player.Name, tostring(rankId)))
		return
	end

	-- Validasi rank sudah terbuka
	local data = PlayerDataService:Get(player)
	local playerLevel = data.Level or 1
	if playerLevel < rank.MinLevel then
		warn(("Pemain %s mencuba pilih rank yang belum terbuka"):format(player.Name))
		return
	end

	-- Update ActiveRank
	data.ActiveRank = rankId
	PlayerDataService:Save(player)

	-- Beritahu klien
	rankUpdatedEvent:FireClient(player, rankId)

	print(("Pemain %s sekarang menggunakan gelaran: %s"):format(player.Name, rank.Name))
end

-- Handler: Level up (dari BindableEvent internal)
local function handleLevelUp(player, newLevel)
	-- Cek apakah rank baru terbuka
	local data = PlayerDataService:Get(player)
	local hadRanks = RankData:GetUnlockedRanks(data.Level or 1)
	data.Level = newLevel
	local newRanks = RankData:GetUnlockedRanks(newLevel)

	-- Jika ada rank baru yang terbuka, kirim notifikasi
	local newRankFound = false
	for _, rank in ipairs(newRanks) do
		local alreadyHad = false
		for _, oldRank in ipairs(hadRanks) do
			if oldRank.Id == rank.Id then
				alreadyHad = true
				break
			end
		end
		if not alreadyHad then
			-- Rank baru terbuka!
			rankUpdatedEvent:FireClient(player, rank.Id, true, rank)
			newRankFound = true
		end
	end

	PlayerDataService:Save(player)
end

-- Connect events
requestRanksEvent.OnServerEvent:Connect(handleRequestRanks)
rankUpdatedEvent = rankUpdatedEvent or remotesFolder:WaitForChild("RankUpdated")
local selectRankEvent = remotesFolder:WaitForChild("SelectRank")
selectRankEvent.OnServerEvent:Connect(handleSelectRank)

-- Listen untuk level up
if LevelUpInternal and LevelUpInternal:IsA("BindableEvent") then
	LevelUpInternal.Event:Connect(handleLevelUp)
end

-- Inisialisasi rank pemain saat join
Players.PlayerAdded:Connect(function(player)
	-- Pastikan pemain punya ActiveRank yang valid
	local data = PlayerDataService:Get(player)
	if not data.ActiveRank then
		local rank = RankData:GetByLevel(data.Level or 1)
		data.ActiveRank = rank.Id
	end
end)

-- API publik
function RankService:GetPlayerRank(player)
	local data = PlayerDataService:Get(player)
	return data.ActiveRank
end

function RankService:GetRankDisplay(player)
	local rankId = self:GetPlayerRank(player)
	return RankData:GetById(rankId)
end

return RankService