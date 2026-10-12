-- QuestService.lua
-- Logik pelayan untuk Quest (Daily & Weekly).
-- Letakkan di: ServerScriptService/QuestService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Muat modul
local QuestData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QuestData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Quest")
local requestQuestsEvent = remotesFolder:WaitForChild("RequestQuests")
local claimRewardEvent = remotesFolder:WaitForChild("ClaimReward")

local QuestService = {}

-- State
local playerQuestCache = {}

-- Helper: Dapatkan waktu reset (jam 00:00 UTC)
local function getNextResetTime()
	local now = os.time()
	local today = os.date("!*t", now)
	today.hour = 0
	today.min = 0
	today.sec = 0
	local nextMidnight = os.time(today) + 24 * 3600
	return nextMidnight
end

-- Generate daily quests acak per pemain
local function generateDailyQuests(player)
	local allDaily = QuestData:GetDailyQuests()
	local selected = {}

	-- Acak dan pilih 3 quest
	local shuffled = {}
	for _, q in ipairs(allDaily) do
		table.insert(shuffled, q)
	end

	for i = #shuffled, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end

	for i = 1, math.min(3, #shuffled) do
		local quest = shuffled[i]
		selected[quest.Id] = {
			Id = quest.Id,
			Current = 0,
			Completed = false,
			Claimed = false,
			ResetTime = getNextResetTime(),
		}
	end

	return selected
end

 	-- Generate weekly quests
 	local function generateWeeklyQuests(player)
 		local allWeekly = QuestData:GetWeeklyQuests()
 		local selected = {}

 		-- Acak dan pilih 2 quest
 		local shuffled = {}
 		for _, q in ipairs(allWeekly) do
 			table.insert(shuffled, q)
 		end
 		for i = #shuffled, 2, -1 do
 			local j = math.random(i)
 			shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
 		end

 		for i = 1, math.min(2, #shuffled) do
 			local quest = shuffled[i]
 			selected[quest.Id] = {
 				Id = quest.Id,
 				Current = 0,
 				Completed = false,
 				Claimed = false,
 			}
 		end

 		return selected
 	end

-- Load quests pemain
local function loadQuests(player)
	local data = PlayerDataService:Get(player)
	if not data.ActiveQuests or not data.ActiveQuests.Daily then
		data.ActiveQuests = {
			Daily = generateDailyQuests(player),
			Weekly = generateWeeklyQuests(player),
		}
	elseif data.ActiveQuests.Daily then
		-- Cek reset
		for questId, quest in pairs(data.ActiveQuests.Daily) do
			if tick() > (quest.ResetTime or 0) then
				-- Regenerate daily quests
				data.ActiveQuests.Daily = generateDailyQuests(player)
				break
			end
		end
	end
	PlayerDataService:Save(player)
	playerQuestCache[player] = data.ActiveQuests
end

-- Handler: Request quests dari klien
local function handleRequestQuests(player)
	local data = PlayerDataService:Get(player)
	local responseEvent = remotesFolder:FindFirstChild("QuestsResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "QuestsResponse"
		responseEvent.Parent = remotesFolder
	end

	-- Kirim quests + progress
	local questData = {}
	for type, quests in pairs(data.ActiveQuests or {}) do
		questData[type] = {}
		for questId, quest in pairs(quests) do
			local questConfig = QuestData:GetById(questId)
			if questConfig then
				table.insert(questData[type], {
					Id = questId,
					Name = questConfig.Name,
					Description = questConfig.Description,
					Icon = questConfig.Icon,
					Type = questConfig.Type,
					Requirement = questConfig.Requirement,
					Reward = questConfig.Reward,
					Current = quest.Current,
					Completed = quest.Completed,
					Claimed = quest.Claimed,
				})
			end
		end
	end

	responseEvent:FireClient(player, questData)
end

-- Handler: Claim reward
local function handleClaimReward(player, questId)
	local data = PlayerDataService:Get(player)
	local found = false

	for type, quests in pairs(data.ActiveQuests or {}) do
		for id, quest in pairs(quests) do
			if id == questId then
				if quest.Completed and not quest.Claimed then
					quest.Claimed = true
					local questConfig = QuestData:GetById(questId)
					if questConfig then
						-- Beri reward
						if questConfig.Reward.Rupiah and questConfig.Reward.Rupiah > 0 then
							PlayerDataService:AddCurrency(player, "Rupiah", questConfig.Reward.Rupiah)
						end
						if questConfig.Reward.Gems and questConfig.Reward.Gems > 0 then
							PlayerDataService:AddCurrency(player, "Gems", questConfig.Reward.Gems)
						end
					end
					found = true
				end
			end
		end
	end

	if found then
		PlayerDataService:Save(player)
	end
end

-- Update quest progress (disebut dari sistem lain)
function QuestService:UpdateProgress(player, statName, value)
	local data = PlayerDataService:Get(player)
	if not data.ActiveQuests then return end

	for type, quests in pairs(data.ActiveQuests) do
		for questId, quest in pairs(quests) do
			local questConfig = QuestData:GetById(questId)
			if questConfig and questConfig.Requirement.Stat == statName then
				quest.Current = math.min(quest.Current + value, questConfig.Requirement.Value)
				if quest.Current >= questConfig.Requirement.Value then
					quest.Completed = true
				end
			end
		end
	end
	PlayerDataService:Save(player)
end

-- Connect events
requestQuestsEvent.OnServerEvent:Connect(handleRequestQuests)
claimRewardEvent.OnServerEvent:Connect(handleClaimReward)

-- Player join
Players.PlayerAdded:Connect(function(player)
	loadQuests(player)
end)

-- API publik
return QuestService