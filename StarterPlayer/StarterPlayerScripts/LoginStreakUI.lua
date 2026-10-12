-- LoginStreakUI.lua
-- Tampilan kalender streak harian
-- Letakkan di: StarterPlayer/StarterPlayerScripts/LoginStreakUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local LoginStreakData = require(ReplicatedStorage.Modules.LoginStreakData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LoginStreak")
local requestStreak = remotes:WaitForChild("RequestStreak")
local streakResponse = remotes:WaitForChild("StreakResponse")
local claimReward = remotes:WaitForChild("ClaimReward")
local claimResult = remotes:WaitForChild("ClaimResult")

local ui, refs = nil, {}
local isOpen = false
local currentStreak = 0
local claimedToday = false
local rewards = LoginStreakData:GetAll()

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end
local function ornament(col, sz, p) local d = UIHelpers.createDiamondOrnament(col, sz); d.Parent = p; return d end

local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 0, 460), Position = UDim2.new(0.5, -190, 0.5, -230)}):Play()
		requestStreak:FireServer()
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 100, 0, 100)}):Play()
		delay(0.3, function() refs.screenGui.Enabled = false end)
	end
end

local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LoginStreakUI"; screenGui.ResetOnSpawn = false; screenGui.Enabled = false

	refs.panel = Instance.new("Frame")
	refs.panel.Size = UDim2.new(0, 380, 0, 460)
	refs.panel.Position = UDim2.new(0.5, -190, 0.5, -230)
	refs.panel.BackgroundColor3 = Theme.COLORS.Panel; refs.panel.BorderSizePixel = 0
	newUICorner(14):Parent = refs.panel; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.panel
	refs.panel.Parent = screenGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -2, 1, -2); bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep; bg.BorderSizePixel = 0
	newUICorner(12):Parent = bg; bg.Parent = refs.panel

	ornament(Theme.COLORS.Gold, 12, refs.panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = ornament(Theme.COLORS.Gold, 12, refs.panel); d2.Position = UDim2.new(1, -8, 0, 8); d2.AnchorPoint = Vector2.new(1, 0)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 50); header.BackgroundColor3 = Theme.COLORS.Indigo; header.BorderSizePixel = 0
	newUICorner(14):Parent = header; header.Parent = refs.panel

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, -10); title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1; title.Font = Theme.FONTS.Title; title.TextSize = 24
	title.TextColor3 = Theme.COLORS.Gold; title.Text = " STREAK HARIAN "
	title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 14)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card; closeBtn.Text = "✕"; closeBtn.Font = Theme.FONTS.Label
	closeBtn.TextSize = 16; closeBtn.TextColor3 = Theme.COLORS.Bone; closeBtn.AutoButtonColor = false
	newUICorner(3):Parent = closeBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = header

	refs.streakLabel = Instance.new("TextLabel")
	refs.streakLabel.Size = UDim2.new(1, -20, 0, 24); refs.streakLabel.Position = UDim2.new(0, 10, 0, 60)
	refs.streakLabel.BackgroundTransparency = 1; refs.streakLabel.Font = Theme.FONTS.Label
	refs.streakLabel.TextSize = 16; refs.streakLabel.TextColor3 = Theme.COLORS.Gold
	refs.streakLabel.Text = "Streak: 0 hari"; refs.streakLabel.Parent = refs.panel

	refs.grid = Instance.new("Frame")
	refs.grid.Size = UDim2.new(1, -20, 1, -110); refs.grid.Position = UDim2.new(0, 10, 0, 90)
	refs.grid.BackgroundTransparency = 1; refs.grid.BorderSizePixel = 0; refs.grid.Parent = refs.panel
	refs.gridLayout = Instance.new("UIGridLayout")
	refs.gridLayout.CellSize = UDim2.new(1, -18, 0, 40)
	refs.gridLayout.CellPadding = UDim2.new(0, 2, 0, 2)
	refs.gridLayout.Parent = refs.grid

	refs.claimBtn = Instance.new("TextButton")
	refs.claimBtn.Size = UDim2.new(1, -20, 0, 36); refs.claimBtn.Position = UDim2.new(0, 10, 1, -42)
	refs.claimBtn.BackgroundColor3 = Theme.COLORS.Gold; refs.claimBtn.BorderSizePixel = 0
	refs.claimBtn.Font = Theme.FONTS.Label; refs.claimBtn.Text = "KLAIM HADIAH"; refs.claimBtn.TextSize = 14
	refs.claimBtn.TextColor3 = Theme.COLORS.Void; refs.claimBtn.AutoButtonColor = false
	newUICorner(6):Parent = refs.claimBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = refs.claimBtn
	refs.claimBtn.Parent = refs.panel

	refs.toggleBtn = Instance.new("TextButton")
	refs.toggleBtn.Size = UDim2.new(0, 44, 0, 44); refs.toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
	refs.toggleBtn.BackgroundColor3 = Theme.COLORS.Card; refs.toggleBtn.Text = "📅"; refs.toggleBtn.Font = Theme.FONTS.Label
	refs.toggleBtn.TextSize = 18; refs.toggleBtn.TextColor3 = Theme.COLORS.Gold; refs.toggleBtn.AutoButtonColor = false
	refs.toggleBtn.Parent = screenGui
	newUICorner(8):Parent = refs.toggleBtn; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.toggleBtn

	refs.closeBtn = closeBtn
	refs.screenGui = screenGui

	-- Events
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(toggleUI)
	refs.claimBtn.MouseButton1Click:Connect(function() claimReward:FireServer() end)

	streakResponse.OnClientEvent:Connect(function(data)
		currentStreak = data.CurrentStreak or 0
		claimedToday = data.ClaimedToday or false
		refs.streakLabel.Text = "Streak: " .. currentStreak .. " hari"
		refs.claimBtn.Visible = not claimedToday
	end)

	claimResult.OnClientEvent:Connect(function(success, reward)
		if success and reward then
			refs.claimBtn.Visible = false
			refs.claimBtn.Text = "SUDAH DIKLAIM"
		end
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		if not playerGui:FindFirstChild("LoginStreakUI") then
			ui.Parent = playerGui
		end
	end
end

init()

-- Populate calendar
local function populateCalendar()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then child:Destroy() end
	end
	for _, reward in ipairs(rewards) do
		local dayBtn = Instance.new("TextButton")
		dayBtn.Name = "Day_" .. reward.Day
		dayBtn.Size = UDim2.new(1, -4, 0, 36)
		dayBtn.BackgroundColor3 = currentStreak >= reward.Day and Theme.COLORS.Gold or (Theme.COLORS.Indigo)
		dayBtn.BackgroundTransparency = currentStreak < reward.Day and 0.7 or 0
		dayBtn.BorderSizePixel = 0; dayBtn.Font = Theme.FONTS.Number; dayBtn.TextSize = 11
		dayBtn.TextColor3 = currentStreak >= reward.Day and Theme.COLORS.Void or Theme.COLORS.BoneDim
		dayBtn.AutoButtonColor = false
		dayBtn.Text = "Hari " .. reward.Day .. "\n" .. reward.Rupiah .. "🪙 " .. (reward.Gems or 0) .. "💎"
		if reward.Special then dayBtn.Text = dayBtn.Text .. " ⭐" end
		newUICorner(4):Parent = dayBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = dayBtn
		dayBtn.Parent = refs.grid
	end
end

return { Toggle = function() if ui then toggleUI() end end }
