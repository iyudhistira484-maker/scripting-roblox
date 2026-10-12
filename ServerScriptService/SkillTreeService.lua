-- SkillTreeService.lua
-- Logik pelayan untuk Skill Tree (Fitur 18).
-- Letakkan di: ServerScriptService/SkillTreeService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local SkillTreeData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("SkillTreeData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillTree")
local requestSkillsEvent = remotesFolder:WaitForChild("RequestSkills")
local unlockSkillEvent = remotesFolder:WaitForChild("UnlockSkill")

local SkillTreeService = {}

-- State
local skillPoints = {}

-- Handler: Request skills dari klien
local function handleRequestSkills(player)
	local data = PlayerDataService:Get(player)
	local responseEvent = remotesFolder:FindFirstChild("SkillsResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "SkillsResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, {
		Nodes = SkillTreeData.Nodes,
		UnlockedSkills = data.UnlockedSkills or {},
		AvailablePoints = skillPoints[player] or 0,
	})
end

-- Handler: Unlock skill dari klien
local function handleUnlockSkill(player, nodeId)
	local node = SkillTreeData:GetById(nodeId)
	if not node then return end

	local data = PlayerDataService:Get(player)
	local availablePoints = skillPoints[player] or 0

	-- Cek poin cukup
	if availablePoints < node.Cost then
		return
	end

	-- Cek sudah diunlock
	if (data.UnlockedSkills[nodeId]) then
		return
	end

	-- Cek prasyarat
	if node.Prerequisite then
		if not data.UnlockedSkills[node.Prerequisite] then
			return
		end
	end

	-- Unlock skill
	data.UnlockedSkills[nodeId] = true
	skillPoints[player] = availablePoints - node.Cost
	PlayerDataService:Save(player)

	-- Apply stat
	local stats = SkillTreeService:ApplyStats(player)
 	-- Trigger event agar sistem lain tau
 	local skillUnlockedEvent = game.ServerScriptService:FindFirstChild("SkillUnlockedInternal")
 	if not skillUnlockedEvent then
 		skillUnlockedEvent = Instance.new("BindableEvent")
 		skillUnlockedEvent.Name = "SkillUnlockedInternal"
 		skillUnlockedEvent.Parent = game.ServerScriptService
 	end
 	skillUnlockedEvent:Fire(player, nodeId, node)

	-- Kirim update ke klien
	local resultEvent = remotesFolder:FindFirstChild("UnlockResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "UnlockResult"
		resultEvent.Parent = remotesFolder
	end
	resultEvent:FireClient(player, nodeId, true, skillPoints[player])

	-- Notify stat changed
	local statEvent = remotesFolder:FindFirstChild("SkillsResponse") -- already handled via RequestSkills
end

-- Apply stats ke karakter pemain
function SkillTreeService:ApplyStats(player)
	local data = PlayerDataService:Get(player)
	local stats = {}

	for nodeId, _ in pairs(data.UnlockedSkills or {}) do
		local node = SkillTreeData:GetById(nodeId)
		if node and node.Effect then
			if node.Effect.Type == "Stat" then
				local statName = node.Effect.Stat
				stats[statName] = (stats[statName] or 0) + node.Effect.Value
			elseif node.Effect.Type == "Multiplier" then
				local multiplierName = node.Effect.Stat
				stats[multiplierName] = (stats[multiplierName] or 1) * (1 + node.Effect.Value / 100)
			end
		end
	end

	return stats
end

-- Check level up untuk dapat poin skill
local levelUpEvent = game.ServerScriptService:FindFirstChild("LevelUpInternal")
if levelUpEvent and levelUpEvent:IsA("BindableEvent") then
	levelUpEvent.Event:Connect(function(player, newLevel)
		-- Dapatkan poin skill setiap naik level
		local currentPoints = skillPoints[player] or 0
		skillPoints[player] = currentPoints + 1
	end)
end

-- Connect events
requestSkillsEvent.OnServerEvent:Connect(handleRequestSkills)
unlockSkillEvent.OnServerEvent:Connect(handleUnlockSkill)

-- Player join
Players.PlayerAdded:Connect(function(player)
	skillPoints[player] = 0
end)
Players.PlayerRemoving:Connect(function(player)
	skillPoints[player] = nil
end)

-- API publik
function SkillTreeService:GetAvailablePoints(player)
	return skillPoints[player] or 0
end

function SkillTreeService:AddPoints(player, amount)
	skillPoints[player] = (skillPoints[player] or 0) + amount
end

return SkillTreeService