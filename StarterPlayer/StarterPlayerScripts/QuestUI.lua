-- QuestUI.lua (simplified)
-- UI untuk Quest system
-- Letakkan di: StarterPlayer/StarterPlayerScripts/QuestUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Quest")
local requestQuests = remotes:WaitForChild("RequestQuests")
local questsResponse = remotes:WaitForChild("QuestsResponse")
local claimReward = remotes:WaitForChild("ClaimReward")

local ui, refs = nil, {}
local isOpen = false
local questData = {}
local activeTab = "Daily"

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end
local function ornament(col, sz, p) local d = UIHelpers.createDiamondOrnament(col, sz); d.Parent = p; return d end

local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 480)}):Play()
		requestQuests:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 100, 0, 100)}):Play()
		delay(0.3, function() refs.screenGui.Enabled = false; refs.toggleBtn.Visible = true end)
	end
end

local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestUI"; screenGui.ResetOnSpawn = false; screenGui.Enabled = false
	
	-- Toggle btn
	refs.toggleBtn = Instance.new("TextButton")
	refs.toggleBtn.Size = UDim2.new(0, 52, 0, 52)
	refs.toggleBtn.Position = UDim2.new(0, 20, 0.5, -26)
	refs.toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	refs.toggleBtn.Text = "📜"; refs.toggleBtn.Font = Theme.FONTS.Label; refs.toggleBtn.TextSize = 20
	refs.toggleBtn.TextColor3 = Theme.COLORS.Gold; refs.toggleBtn.AutoButtonColor = false
	refs.toggleBtn.Parent = screenGui
	newUICorner(10):Parent = refs.toggleBtn; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.toggleBtn

	-- Panel
	refs.panel = Instance.new("Frame")
	refs.panel.Size = UDim2.new(0, 650, 0, 480)
	refs.panel.Position = UDim2.new(0.5, -325, 0.5, -260)
	refs.panel.BackgroundColor3 = Theme.COLORS.Panel; refs.panel.BorderSizePixel = 0
	newUICorner(14):Parent = refs.panel; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.panel
	refs.panel.Parent = screenGui

	-- bg
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -2, 1, -2); bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep; bg.BorderSizePixel = 0
	newUICorner(12):Parent = bg; bg.Parent = refs.panel
	ornament(Theme.COLORS.Gold, 12, refs.panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = ornament(Theme.COLORS.Gold, 12, refs.panel); d2.Position = UDim2.new(1, -8, 0, 8); d2.AnchorPoint = Vector2.new(1, 0)

	-- Header
	refs.header = Instance.new("Frame")
	refs.header.Size = UDim2.new(1, 0, 0, 50); refs.header.BackgroundColor3 = Theme.COLORS.Indigo; refs.header.BorderSizePixel = 0
	newUICorner(14):Parent = refs.header; refs.header.Parent = refs.panel

	refs.title = Instance.new("TextLabel")
	refs.title.Size = UDim2.new(1, -50, 1, -10); refs.title.Position = UDim2.new(0, 10, 0, 5)
	refs.title.BackgroundTransparency = 1; refs.title.Font = Theme.FONTS.Title; refs.title.TextSize = 24
	refs.title.TextColor3 = Theme.COLORS.Gold; refs.title.Text = "MISI HARIAN"
	refs.title.TextXAlignment = Enum.TextXAlignment.Left; refs.title.Parent = refs.header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 14)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card; closeBtn.Text = "✕"
	closeBtn.Font = Theme.FONTS.Label; closeBtn.TextSize = 16; closeBtn.TextColor3 = Theme.COLORS.Bone
	closeBtn.AutoButtonColor = false; newUICorner(3):Parent = closeBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = refs.header

	-- Tabs
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, -20, 0, 35); tabContainer.Position = UDim2.new(0, 10, 0, 10)
	tabContainer.BackgroundTransparency = 1; tabContainer.Parent = refs.panel
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = 6
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; tabLayout.Parent = tabContainer

	local dailyTab = Instance.new("TextButton")
	dailyTab.Name = "DailyTab"; dailyTab.Size = UDim2.new(0, 90, 1, 0)
	dailyTab.BackgroundColor3 = Theme.COLORS.Gold; dailyTab.Text = "Harian"; dailyTab.Font = Theme.FONTS.Label
	dailyTab.AutoButtonColor = false; newUICorner(5):Parent = dailyTab; dailyTab.Parent = tabContainer

	local weeklyTab = Instance.new("TextButton")
	weeklyTab.Name = "WeeklyTab"; weeklyTab.Size = UDim2.new(0, 90, 1, 0)
	weeklyTab.BackgroundColor3 = Theme.COLORS.Card; weeklyTab.Text = "Mingguan"; weeklyTab.Font = Theme.FONTS.Label
	weeklyTab.AutoButtonColor = false; newUICorner(5):Parent = weeklyTab; weeklyTab.Parent = tabContainer

	-- Grid
	refs.grid = Instance.new("ScrollingFrame")
	refs.grid.Size = UDim2.new(1, -20, 1, -80); refs.grid.Position = UDim2.new(0, 10, 0, 60)
	refs.grid.BackgroundTransparency = 1; refs.grid.BorderSizePixel = 0; refs.grid.ScrollBarThickness = 6
	refs.grid.CanvasSize = UDim2.new(0, 0, 1, 0); refs.grid.Parent = refs.panel
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, -24, 0, 90); layout.CellPadding = UDim2.new(0, 0, 0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = refs.grid
	refs.grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refs.grid.CanvasSize = UDim2.new(0, 0, 0, math.max(refs.grid.AbsoluteContentSize.Y + 20, 0))
	end)

	-- Tab switching
	dailyTab.MouseButton1Click:Connect(function() activeTab = "Daily"; populateGrid() end)
	weeklyTab.MouseButton1Click:Connect(function() activeTab = "Weekly"; populateGrid() end)

	-- Toggle events
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	closeBtn.MouseButton1Click:Connect(toggleUI)

	-- Response handler
	questsResponse.OnClientEvent:Connect(function(data)
		questData = data
		populateGrid()
	end)

	refs.screenGui = screenGui
end

function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then child:Destroy() end
	end
	local quests = questData[activeTab] or {}
	for _, q in ipairs(quests) do
		local card = Instance.new("Frame")
		card.Name = "Card_" .. q.Id
		card.Size = UDim2.new(1, -24, 0, 90)
		card.BackgroundColor3 = Theme.COLORS.Indigo
		card.BackgroundTransparency = q.Completed and 0 or 0.5
		card.Parent = refs.grid
		newUICorner(8):Parent = card

		local name = Instance.new("TextLabel")
		name.Size = UDim2.new(1, -10, 0, 20); name.Position = UDim2.new(0, 5, 0, 4)
		name.BackgroundTransparency = 1; name.Font = Theme.FONTS.Label; name.TextSize = 13
		name.TextColor3 = Theme.COLORS.Bone; name.Text = q.Name
		name.TextXAlignment = Enum.TextXAlignment.Left; name.Parent = card

		local reqVal = q.Requirement.Value or 1
		local progress = math.clamp(q.Current or 0, 0, reqVal)
		local percent = progress / reqVal

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -10, 0, 12); bar.Position = UDim2.new(0, 5, 0, 26)
		bar.BackgroundColor3 = Theme.COLORS.Void; bar.BorderSizePixel = 0; newUICorner(6):Parent = bar; bar.Parent = card

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(percent, 0, 1, 0)
		fill.BackgroundColor3 = q.Completed and Theme.COLORS.Gold or Theme.COLORS.Crimson
		fill.BorderSizePixel = 0; newUICorner(6):Parent = fill; fill.Parent = bar

		local claimBtn = Instance.new("TextButton")
		claimBtn.Size = UDim2.new(0, 60, 0, 20); claimBtn.Position = UDim2.new(1, -64, 0, 70)
		claimBtn.BackgroundColor3 = Theme.COLORS.Gold; claimBtn.Text = "KLAIM"; claimBtn.Font = Theme.FONTS.Label
		claimBtn.TextSize = 11; claimBtn.TextColor3 = Theme.COLORS.Void; claimBtn.AutoButtonColor = false
		claimBtn.Visible = q.Completed and not q.Claimed
		newUICorner(3):Parent = claimBtn; claimBtn.Parent = card
		claimBtn.MouseButton1Click:Connect(function() claimReward:FireServer(q.Id) end)
	end
end

-- Init
if not ui then
	createBaseUI()
	ui = refs.screenGui
	if not playerGui:FindFirstChild("QuestUI") then
		ui.Parent = playerGui
	end
end

return { Toggle = function() if ui then toggleUI() end end }
