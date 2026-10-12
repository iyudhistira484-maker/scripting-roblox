-- AchievementService.lua
-- Logik pelayan untuk Achievement (Pencapaian)
-- Letakkan di: ServerScriptService/AchievementService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AchievementData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("AchievementData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

local AchievementService = {}

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Achievement")

-- RemoteEvent untuk notifikasi ke klien
local achievementUnlockedEvent = remotesFolder:FindFirstChild("AchievementUnlocked")
if not achievementUnlockedEvent then
	achievementUnlockedEvent = Instance.new("RemoteEvent")
	achievementUnlockedEvent.Name = "AchievementUnlocked"
	achievementUnlockedEvent.Parent = remotesFolder
end

-- RemoteEvent untuk request achievement list dari klien
local requestProgressEvent = remotesFolder:FindFirstChild("RequestProgress")
if not requestProgressEvent then
	requestProgressEvent = Instance.new("RemoteEvent")
	requestProgressEvent.Name = "RequestProgress"
	requestProgressEvent.Parent = remotesFolder
end

-- Cache statistik pemain untuk pengecekan achievement
local playerStats = {}

-- Fungsi untuk memperbarui statistik pemain
local function updatePlayerStat(player, statName, value)
	if not playerStats[player] then
		playerStats[player] = {}
	end

	local current = playerStats[player][statName] or 0
	playerStats[player][statName] = current + value

	-- Cek semua achievement yang sesuai dengan stat ini
	checkAchievements(player, statName, playerStats[player][statName])
end

-- Fungsi untuk mengecek dan mengunci achievement
function checkAchievements(player, statName, newValue)
	if not player then return end

	local current = newValue or 0
	local possibleAchievements = AchievementData:GetByRequirement(statName, current)

	for _, ach in ipairs(possibleAchievements) do
		if not PlayerDataService:HasCompletedAchievement(player, ach.Id) then
			-- Cek syarat terpenuhi
			local req = ach.Requirement
			local achieved = false

			if req.Stat == statName and current >= req.Value then
				achieved = true
			end

			if achieved then
				-- Unlock achievement
				local success = PlayerDataService:UnlockAchievement(player, ach.Id)
				if success then
					-- Beri reward
					local reward = ach.Reward
					if reward.Rupiah and reward.Rupiah > 0 then
						PlayerDataService:AddCurrency(player, "Rupiah", reward.Rupiah)
					end
					if reward.Gems and reward.Gems > 0 then
						PlayerDataService:AddCurrency(player, "Gems", reward.Gems)
					end

					PlayerDataService:Save(player)

					-- Kirim notifikasi ke klien
					achievementUnlockedEvent:FireClient(player, ach)

					print(("Pemain %s mendapat achievement: %s"):format(player.Name, ach.Name))
				end
			end
		end
	end
end

-- Inisialisasi statistik pemain saat join
local function initPlayerStats(player)
	local data = PlayerDataService:Get(player)
	playerStats[player] = {
		CaughtGhosts = PlayerDataService:GetCaughtCount(player),
		Currency_Rupiah = data.Currency.Rupiah or 0,
		Currency_Gems = data.Currency.Gems or 0,
		Level = data.Level or 1,
		InventoryCount = #(data.Inventory or {}),
		CompletedQuests = #(data.CompletedQuests or {}),
		NightSurvival = 0,
	}
end

-- Event handler untuk request progress dari klien
requestProgressEvent.OnServerEvent:Connect(function(player)
	local data = PlayerDataService:Get(player)
	local completed = {}
	local total = 0

	for _, achId in pairs(data.CompletedAchievements) do
		table.insert(completed, achId)
	end

	-- Hitung total achievement
	total = #AchievementData.Achievements

	-- Kirim respons
	local responseEvent = remotesFolder:FindFirstChild("ProgressResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "ProgressResponse"
		responseEvent.Parent = remotesFolder
	end

	local achievementList = {}
	for _, ach in ipairs(AchievementData.Achievements) do
		local req = ach.Requirement
		local current = playerStats[player] and playerStats[player][req.Stat] or 0
		table.insert(achievementList, {
			Id = ach.Id,
			Name = ach.Name,
			Description = ach.Description,
			Rarity = ach.Rarity,
			Icon = ach.Icon,
			IconImage = ach.IconImage,
			Requirement = req,
			CurrentValue = current,
			Unlocked = PlayerDataService:HasCompletedAchievement(player, ach.Id),
			Reward = ach.Reward,
		})
	end

	responseEvent:FireClient(player, achievementList)
end)

-- Internal BindableEvents untuk menerima event dari sistem lain
local function setupInternalListeners()
	-- Ghost Collection - tangkap hantu baru
	local ghostCaughtEvent = game.ServerScriptService:FindFirstChild("GhostCaughtInternal")
	if ghostCaughtEvent and ghostCaughtEvent:IsA("BindableEvent") then
		ghostCaughtEvent.Event:Connect(function(player, ghostId, ghostInfo)
			updatePlayerStat(player, "CaughtGhosts", 1)
		end)
	end

	-- Currency - dapat uang
	local currencyAddedEvent = game.ServerScriptService:FindFirstChild("CurrencyAddedInternal")
	if currencyAddedEvent and currencyAddedEvent:IsA("BindableEvent") then
		currencyAddedEvent.Event:Connect(function(player, currencyType, amount)
			if currencyType == "Rupiah" then
				updatePlayerStat(player, "Currency_Rupiah", amount)
			elseif currencyType == "Gems" then
				updatePlayerStat(player, "Currency_Gems", amount)
			end
		end)
	end

	-- Level up
	local levelUpEvent = game.ServerScriptService:FindFirstChild("LevelUpInternal")
	if levelUpEvent and levelUpEvent:IsA("BindableEvent") then
		levelUpEvent.Event:Connect(function(player, newLevel)
			if playerStats[player] then
				playerStats[player].Level = newLevel
			end
			checkAchievements(player, "Level", newLevel)
		end)
	end

	-- Inventory item added
	local itemAddedEvent = game.ServerScriptService:FindFirstChild("ItemAddedInternal")
	if itemAddedEvent and itemAddedEvent:IsA("BindableEvent") then
		itemAddedEvent.Event:Connect(function(player, itemId)
			updatePlayerStat(player, "InventoryCount", 1)
		end)
	end

	-- Quest completed
	local questCompletedEvent = game.ServerScriptService:FindFirstChild("QuestCompletedInternal")
	if questCompletedEvent and questCompletedEvent:IsA("BindableEvent") then
		questCompletedEvent.Event:Connect(function(player, questId)
			updatePlayerStat(player, "CompletedQuests", 1)
		end)
	end

	-- Night survival
	local nightSurvivedEvent = game.ServerScriptService:FindFirstChild("NightSurvivedInternal")
	if nightSurvivedEvent and nightSurvivedEvent:IsA("BindableEvent") then
		nightSurvivedEvent.Event:Connect(function(player, minutes)
			updatePlayerStat(player, "NightSurvival", minutes)
		end)
	end
end

-- Player join/leave
Players.PlayerAdded:Connect(function(player)
	initPlayerStats(player)
	-- Cek achievement yang sudah terpenuhi saat ini
	for _, ach in ipairs(AchievementData.Achievements) do
		local req = ach.Requirement
		local current = playerStats[player] and playerStats[player][req.Stat] or 0
		if current >= req.Value and not PlayerDataService:HasCompletedAchievement(player, ach.Id) then
			local success = PlayerDataService:UnlockAchievement(player, ach.Id)
			if success then
				local reward = ach.Reward
				if reward.Rupiah and reward.Rupiah > 0 then
					PlayerDataService:AddCurrency(player, "Rupiah", reward.Rupiah)
				end
				if reward.Gems and reward.Gems > 0 then
					PlayerDataService:AddCurrency(player, "Gems", reward.Gems)
				end
				PlayerDataService:Save(player)
				achievementUnlockedEvent:FireClient(player, ach)
			end
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	playerStats[player] = nil
end)

-- Setup internal listeners
setupInternalListeners()

-- API publik
function AchievementService:ForceCheck(player, statName, value)
	checkAchievements(player, statName, value)
end

return AchievementService