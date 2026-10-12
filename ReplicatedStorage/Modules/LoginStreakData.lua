-- LoginStreakData.lua
-- Modul data statik untuk Login Streak (Fitur 17).
-- Letakkan di: ReplicatedStorage/Modules/LoginStreakData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local LoginStreakData = {}

-- Reward per hari (hari 1-30, siklus)
LoginStreakData.Rewards = {
	-- Hari 1-7
	{ Day = 1, Rupiah = 100, Gems = 0 },
	{ Day = 2, Rupiah = 150, Gems = 0 },
	{ Day = 3, Rupiah = 200, Gems = 1 },
	{ Day = 4, Rupiah = 250, Gems = 0 },
	{ Day = 5, Rupiah = 300, Gems = 1 },
	{ Day = 6, Rupiah = 400, Gems = 2 },
	{ Day = 7, Rupiah = 1000, Gems = 5, Special = true },
	-- Hari 8-14
	{ Day = 8, Rupiah = 200, Gems = 0 },
	{ Day = 9, Rupiah = 250, Gems = 0 },
	{ Day = 10, Rupiah = 300, Gems = 2 },
	{ Day = 11, Rupiah = 350, Gems = 0 },
	{ Day = 12, Rupiah = 400, Gems = 2 },
	{ Day = 13, Rupiah = 500, Gems = 3 },
	{ Day = 14, Rupiah = 1500, Gems = 8, Special = true },
	-- Hari 15-21
	{ Day = 15, Rupiah = 300, Gems = 0 },
	{ Day = 16, Rupiah = 350, Gems = 1 },
	{ Day = 17, Rupiah = 400, Gems = 2 },
	{ Day = 18, Rupiah = 500, Gems = 1 },
	{ Day = 19, Rupiah = 600, Gems = 3 },
	{ Day = 20, Rupiah = 700, Gems = 4 },
	{ Day = 21, Rupiah = 2000, Gems = 10, Special = true },
	-- Hari 22-28
	{ Day = 22, Rupiah = 400, Gems = 0 },
	{ Day = 23, Rupiah = 450, Gems = 1 },
	{ Day = 24, Rupiah = 500, Gems = 2 },
	{ Day = 25, Rupiah = 600, Gems = 3 },
	{ Day = 26, Rupiah = 700, Gems = 4 },
	{ Day = 27, Rupiah = 800, Gems = 5 },
	{ Day = 28, Rupiah = 2500, Gems = 15, Special = true },
	-- Hari 29-30
	{ Day = 29, Rupiah = 1000, Gems = 8 },
	{ Day = 30, Rupiah = 5000, Gems = 30, Special = true },
}

LoginStreakData.TOTAL_DAYS = 30

-- Helper
function LoginStreakData:GetRewardForDay(day)
	local index = ((day - 1) % self.TOTAL_DAYS) + 1
	return self.Rewards[index]
end

function LoginStreakData:GetAll()
	return self.Rewards
end

return LoginStreakData