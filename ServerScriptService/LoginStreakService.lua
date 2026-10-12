-- LoginStreakService.lua
-- Logik pelayan untuk Login Streak (Fitur 17).
-- Letakkan di: ServerScriptService/LoginStreakService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Muat modul
local LoginStreakData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("LoginStreakData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LoginStreak")
local requestStreakEvent = remotesFolder:WaitForChild("RequestStreak")
local claimRewardEvent = remotesFolder:WaitForChild("ClaimReward")

local LoginStreakService = {}

-- Helper: Dapatkan tanggal hari ini (format YYYY-MM-DD)
local function getTodayDate()
	return os.date("%Y-%m-%d")
end

-- Handler: Request streak info dari klien
local function handleRequestStreak(player)
	local data = PlayerDataService:Get(player)
	local responseEvent = remotesFolder:FindFirstChild("StreakResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "StreakResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, {
		CurrentStreak = data.LoginStreak.CurrentStreak,
		LastLoginDate = data.LoginStreak.LastLoginDate,
		ClaimedToday = data.LoginStreak.ClaimedToday,
		Rewards = LoginStreakData:GetAll(),
	})
end

-- Handler: Claim reward harian
local function handleClaimReward(player)
	local data = PlayerDataService:Get(player)
	local today = getTodayDate()
	local streak = data.LoginStreak

	-- Cek sudah klaim hari ini
	if streak.LastLoginDate == today and streak.ClaimedToday then
		return
	end

	-- Dapatkan reward
	local reward = LoginStreakData:GetRewardForDay(streak.CurrentStreak + 1)

	-- Beri reward
	if reward.Rupiah and reward.Rupiah > 0 then
		PlayerDataService:AddCurrency(player, "Rupiah", reward.Rupiah)
	end
	if reward.Gems and reward.Gems > 0 then
		PlayerDataService:AddCurrency(player, "Gems", reward.Gems)
	end

	-- Update streak
	streak.CurrentStreak = streak.CurrentStreak + 1
	streak.LastLoginDate = today
	streak.ClaimedToday = true

	PlayerDataService:Save(player)

	-- Kirim konfirmasi
	local resultEvent = remotesFolder:FindFirstChild("ClaimResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "ClaimResult"
		resultEvent.Parent = remotesFolder
	end
	resultEvent:FireClient(player, true, reward)
end

-- Check streak pada login
local function checkLoginStreak(player)
	local data = PlayerDataService:Get(player)
	local streak = data.LoginStreak
	local today = getTodayDate()

	if streak.LastLoginDate == "" or streak.LastLoginDate == nil then
		-- Pemain baru
		streak.LastLoginDate = today
		streak.CurrentStreak = 1
		streak.ClaimedToday = false
	elseif streak.LastLoginDate ~= today then
		-- Hari berbeda - cek streak
		-- Hitung berapa hari yang melewati
		local lastDate = os.time({year=today:sub(1,4), month=today:sub(6,7), day=today:sub(9,10)})
		local prevDate = os.time({year=streak.LastLoginDate:sub(1,4), month=streak.LastLoginDate:sub(6,7), day=streak.LastLoginDate:sub(9,10)})
		local dayDiff = math.floor((lastDate - prevDate) / 86400)

		if dayDiff == 1 then
			-- Streak lanjut
			streak.CurrentStreak = streak.CurrentStreak + 1
		else
			-- Streak reset (melepas >1 hari)
			streak.CurrentStreak = 1
		end

		streak.LastLoginDate = today
		streak.ClaimedToday = false
	end
	-- Jika hari yang sama, tidak lakukan apa-apa

	PlayerDataService:Save(player)

	-- Kirim info ke klien untuk popup
	local streakEvent = remotesFolder:FindFirstChild("StreakResponse")
	if not streakEvent then
		streakEvent = Instance.new("RemoteEvent")
		streakEvent.Name = "StreakResponse"
		streakEvent.Parent = remotesFolder
	end

	streakEvent:FireClient(player, {
		CurrentStreak = streak.CurrentStreak,
		LastLoginDate = streak.LastLoginDate,
		ClaimedToday = streak.ClaimedToday,
		Rewards = LoginStreakData:GetAll(),
	})
end

-- Connect events
requestStreakEvent.OnServerEvent:Connect(handleRequestStreak)
claimRewardEvent.OnServerEvent:Connect(handleClaimReward)

-- Player join: check streak
Players.PlayerAdded:Connect(function(player)
	-- Delay sebentar untuk data player siap
	delay(1, function()
		checkLoginStreak(player)
	end)
end)

-- API publik
function LoginStreakService:ShouldShowPopup(player)
	local data = PlayerDataService:Get(player)
	return not data.LoginStreak.ClaimedToday
end

return LoginStreakService