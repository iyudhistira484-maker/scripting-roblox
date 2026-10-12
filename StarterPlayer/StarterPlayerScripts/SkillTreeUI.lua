-- SkillTreeUI.lua
-- Visualisasi pohon skill
-- Letakkan di: StarterPlayer/StarterPlayerScripts/SkillTreeUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local SkillTreeData = require(ReplicatedStorage.Modules.SkillTreeData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SkillTree")
local requestSkills = remotes:WaitForChild("RequestSkills")
local skillsResponse = remotes:WaitForChild("SkillsResponse")
local unlockSkill = remotes:WaitForChild("UnlockSkill")
local unlockResult = remotes:WaitForChild("UnlockResult")

local ui, refs = nil, {}
local isOpen = false
local unlocked = {}
local points = 0

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end
local function ornament(col, sz, p) local d = UIHelpers.createDiamondOrnament(col, sz); d.Parent = p; return d end

local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, -350, 0.5, -260)
		}):Play()
		requestSkills:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1)
		}):Play()
		delay(0.3, function() refs.screenGui.Enabled = false; refs.toggleBtn.Visible = true end)
	end
end

local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkillTreeUI"; screenGui.ResetOnSpawn = false; screenGui.Enabled = false

	refs.toggleBtn = Instance.new("TextButton")
	refs.toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	refs.toggleBtn.Position = UDim2.new(0, 20, 0.5, -24)
	refs.toggleBtn.BackgroundColor3 = Theme.COLORS.Card; refs.toggleBtn.Text = "🌳"
	refs.toggleBtn.Font = Theme.FONTS.Label; refs.toggleBtn.TextSize = 20
	refs.toggleBtn.TextColor3 = Theme.COLORS.JadeGlow; refs.toggleBtn.AutoButtonColor = false
	refs.toggleBtn.Parent = screenGui
	newUICorner(8):Parent = refs.toggleBtn; newUIStroke(Theme.COLORS.JadeGlow, 1):Parent = refs.toggleBtn

	refs.panel = Instance.new("Frame")
	refs.panel.Size = UDim2.new(0, 700, 0, 520)
	refs.panel.Position = UDim2.new(0.5, -350, 0.5, -260)
	refs.panel.BackgroundColor3 = Theme.COLORS.Panel; refs.panel.BorderSizePixel = 0
	newUICorner(16):Parent = refs.panel; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.panel
	refs.panel.Parent = screenGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -2, 1, -2); bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep; bg.BorderSizePixel = 0
	newUICorner(14):Parent = bg; bg.Parent = refs.panel
	ornament(Theme.COLORS.Gold, 12, refs.panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = ornament(Theme.COLORS.Gold, 12, refs.panel); d2.Position = UDim2.new(1, -8, 0, 8); d2.AnchorPoint = Vector2.new(1, 0)

	refs.header = Instance.new("Frame")
	refs.header.Size = UDim2.new(1, 0, 0, 50); refs.header.BackgroundColor3 = Theme.COLORS.Indigo; refs.header.BorderSizePixel = 0
	newUICorner(16):Parent = refs.header; refs.header.Parent = refs.panel

	refs.title = Instance.new("TextLabel")
	refs.title.Size = UDim2.new(1, -50, 1, -10); refs.title.Position = UDim2.new(0, 10, 0, 5)
	refs.title.BackgroundTransparency = 1; refs.title.Font = Theme.FONTS.Title; refs.title.TextSize = 24
	refs.title.TextColor3 = Theme.COLORS.Gold; refs.title.Text = " GALANGAN KEMAMPUAN "
	refs.title.TextXAlignment = Enum.TextXAlignment.Left; refs.title.Parent = refs.header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 14)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card; closeBtn.Text = "✕"; closeBtn.Font = Theme.FONTS.Label
	closeBtn.TextSize = 16; closeBtn.TextColor3 = Theme.COLORS.Bone; closeBtn.AutoButtonColor = false
	newUICorner(3):Parent = closeBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = refs.header

	refs.pointsLabel = Instance.new("TextLabel")
	refs.pointsLabel.Size = UDim2.new(1, -20, 0, 24); refs.pointsLabel.Position = UDim2.new(0, 10, 0, 60)
	refs.pointsLabel.BackgroundTransparency = 1; refs.pointsLabel.Font = Theme.FONTS.Label
	refs.pointsLabel.TextSize = 14; refs.pointsLabel.TextColor3 = Theme.COLORS.GoldDim
	refs.pointsLabel.Text = "Poin Skill: 0"; refs.pointsLabel.Parent = refs.panel

	refs.treeContainer = Instance.new("Frame")
	refs.treeContainer.Size = UDim2.new(1, -20, 1, -90); refs.treeContainer.Position = UDim2.new(0, 10, 0, 90)
	refs.treeContainer.BackgroundTransparency = 1; refs.treeContainer.BorderSizePixel = 0
	refs.treeContainer.Parent = refs.panel

	refs.closeBtn = closeBtn
	refs.screenGui = screenGui

	-- Events
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(toggleUI)

	skillsResponse.OnClientEvent:Connect(function(data)
		unlocked = data.UnlockedSkills or {}
		points = data.AvailablePoints or 0
		refs.pointsLabel.Text = "Poin Skill: " .. points
		populateTree()
	end)

	unlockResult.OnClientEvent:Connect(function(nodeId, success, remainingPoints)
		if success then
			points = remainingPoints
			refs.pointsLabel.Text = "Poin Skill: " .. points
			requestSkills:FireServer() -- refresh
		end
	end)
end

-- Draw connections between nodes
local function drawConnections()
	-- Simplified: draw lines between prerequisite nodes
end

-- Populate skill tree
local function populateTree()
	-- Clear
	for _, child in ipairs(refs.treeContainer:GetChildren()) do
		child:Destroy()
	end

	local nodes = SkillTreeData.Nodes
	local nodeSize = 60
	local startX = 50
	local startY = 10

	for i, node in ipairs(nodes) do
		local nodeBtn = Instance.new("TextButton")
		nodeBtn.Name = "Node_" .. node.Id
		nodeBtn.Size = UDim2.new(0, nodeSize, 0, nodeSize)
		nodeBtn.Position = UDim2.new(0, startX + (i % 4) * 150, 0, startY + math.floor(i / 4) * 110)

		local isUnlocked = unlocked[node.Id] ~= nil
		local canUnlock = points >= node.Cost and
			(not node.Prerequisite or unlocked[node.Prerequisite] ~= nil) and
			not isUnlocked

		nodeBtn.BackgroundColor3 = isUnlocked and Theme.COLORS.Gold or (canUnlock and Theme.COLORS.JadeGlow or Theme.COLORS.Card)
		nodeBtn.BorderSizePixel = 0
		nodeBtn.AutoButtonColor = false
		nodeBtn.Font = Theme.FONTS.Label
		nodeBtn.Text = node.Icon or "?"
		nodeBtn.TextSize = 24
		nodeBtn.TextColor3 = isUnlocked and Theme.COLORS.Void or Theme.COLORS.BoneDim
		newUICorner(8):Parent = nodeBtn
		newUIStroke(isUnlocked and Theme.COLORS.Gold or Theme.COLORS.GoldDim, 1):Parent = nodeBtn
		nodeBtn.Parent = refs.treeContainer

		nodeBtn.MouseButton1Click:Connect(function()
			if canUnlock then
				unlockSkill:FireServer(node.Id)
			end
		end)

		nodeBtn.MouseEnter:Connect(function()
			if not isUnlocked and canUnlock then
				TweenService:Create(nodeBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, nodeSize + 10, 0, nodeSize + 10), Position = nodeBtn.Position - UDim2.new(0, 5, 0, 5)}):Play()
			end
		end)
		nodeBtn.MouseLeave:Connect(function()
			if not isUnlocked and canUnlock then
				TweenService:Create(nodeBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, nodeSize, 0, nodeSize), Position = nodeBtn.Position + UDim2.new(0, 5, 0, 5)}):Play()
			end
		end)
	end
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		if not playerGui:FindFirstChild("SkillTreeUI") then
			ui.Parent = playerGui
		end
	end
end

init()

return { Toggle = function() if ui then toggleUI() end end }
