-- GachaUI.lua
-- Antarmuka klien untuk Gacha (Gacha Roll).
-- Letakkan di: StarterPlayer/StarterPlayerScripts/GachaUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local GachaData = require(ReplicatedStorage.Modules.GachaData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gacha")
local rollGacha = remotes:WaitForChild("RollGacha")
local rollResult = remotes:WaitForChild("RollResult")
local requestHistory = remotes:WaitForChild("RequestHistory")
local historyResponse = remotes:WaitForChild("HistoryResponse")

-- State
local ui = nil
local refs = {}
local isOpen = false
local pityCount = 0
local lastResults = {}

-- Helper functions
local function newUICorner(radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	return c
end

local function newUIStroke(color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.COLORS.Gold
	s.Thickness = thickness or 1
	return s
end

local function createDiamondOrnamentHelper(color, size, parent)
	local d = UIHelpers.createDiamondOrnament(color, size)
	d.Parent = parent
	return d
end

-- Toggle panel
local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 560),
			Position = UDim2.new(0.5, -350, 0.5, -280)
		}):Play()
		requestHistory:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1),
			Position = UDim2.new(0.5, 0, 0.5, -1)
		}):Play()
		delay(0.5, function()
			refs.screenGui.Enabled = false
			refs.toggleBtn.Visible = true
		end)
	end
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GachaUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	toggleBtn.Position = UDim2.new(1, -180, 0.5, -24)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🎁"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Crimson
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Crimson, 1):Parent = toggleBtn

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 700, 0, 560)
	panel.Position = UDim2.new(0.5, -350, 0.5, -280)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	newUICorner(16):Parent = panel
	newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	newUICorner(14):Parent = bg
	bg.Parent = panel

	-- Diamond ornaments
	createDiamondOrnamentHelper(Theme.COLORS.Crimson, 12, panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = createDiamondOrnamentHelper(Theme.COLORS.Crimson, 12, panel)
	d2.Position = UDim2.new(1, -8, 0, 8)
	d2.AnchorPoint = Vector2.new(1, 0)

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	newUICorner(16):Parent = header
	header.Parent = panel

	-- Banner title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -150, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "GACHA: STANDAR"
	title.Font = Theme.FONTS.Title
	title.TextSize = 26
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Banner icon
	local bannerIcon = Instance.new("ImageLabel")
	bannerIcon.Name = "BannerIcon"
	bannerIcon.Size = UDim2.new(0, 40, 0, 40)
	bannerIcon.Position = UDim2.new(1, -50, 0, 10)
	bannerIcon.BackgroundTransparency = 1
	bannerIcon.Image = ""
	bannerIcon.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -28, 0, 18)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Theme.FONTS.Label
	closeBtn.Text = "✕"
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = Theme.COLORS.Bone
	closeBtn.AutoButtonColor = false
	newUICorner(4):Parent = closeBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = header

	-- Pity counter
	local pityLabel = Instance.new("TextLabel")
	pityLabel.Name = "PityLabel"
	pityLabel.Size = UDim2.new(0, 120, 0, 20)
	pityLabel.Position = UDim2.new(0, 10, 1, -230) -- relatif terhadap header
	pityLabel.BackgroundTransparency = 1
	pityLabel.Font = Theme.FONTS.Number
	pityLabel.TextSize = 13
	pityLabel.TextColor3 = Theme.COLORS.Crimson
	pityLabel.Text = "Pity: 0/90"
	pityLabel.TextXAlignment = Enum.TextXAlignment.Left
	pityLabel.Parent = panel

	-- Roll buttons
	local btn1 = Instance.new("TextButton")
	btn1.Name = "RollBtn1"
	btn1.Size = UDim2.new(0, 280, 0, 40)
	btn1.Position = UDim2.new(0.5, -290, 0, 100)
	btn1.BackgroundColor3 = Theme.COLORS.Gold
	btn1.BorderSizePixel = 0
	btn1.Font = Theme.FONTS.Label
	btn1.Text = "1x Roll (5 💎)"
	btn1.TextSize = 14
	btn1.TextColor3 = Theme.COLORS.Void
	btn1.AutoButtonColor = false
	newUICorner(6):Parent = btn1
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn1
	btn1.Parent = panel

	local btn10 = Instance.new("TextButton")
	btn10.Name = "RollBtn10"
	btn10.Size = UDim2.new(0, 280, 0, 40)
	btn10.Position = UDim2.new(0.5, 10, 0, 100)
	btn10.BackgroundColor3 = Theme.COLORS.Crimson
	btn10.BorderSizePixel = 0
	btn10.Font = Theme.FONTS.Label
	btn10.Text = "10x Roll (45 💎)"
	btn10.TextSize = 14
	btn10.TextColor3 = Theme.COLORS.Bone
	btn10.AutoButtonColor = false
	newUICorner(6):Parent = btn10
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn10
	btn10.Parent = panel

	-- Roll area (animation container)
	local rollArea = Instance.new("Frame")
	rollArea.Name = "RollArea"
	rollArea.Size = UDim2.new(1, -40, 1, -160)
	rollArea.Position = UDim2.new(0, 20, 0, 150)
	rollArea.BackgroundTransparency = 1
	rollArea.BorderSizePixel = 0
	rollArea.Parent = panel

	-- Results display
	local resultFrame = Instance.new("Frame")
	resultFrame.Name = "ResultFrame"
	resultFrame.Size = UDim2.new(1, 0, 0, 100)
	resultFrame.Position = UDim2.new(0, 0, 0, 0)
	resultFrame.BackgroundTransparency = 1
	resultFrame.BorderSizePixel = 0
	resultFrame.Parent = rollArea

	local resultLayout = Instance.new("UIGridLayout")
	resultLayout.FillDirection = Enum.FillDirection.Horizontal
	resultLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	resultLayout.Padding = 8
	resultLayout.Parent = resultFrame

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		bannerIcon = bannerIcon,
		closeBtn = closeBtn,
		pityLabel = pityLabel,
		btn1 = btn1,
		btn10 = btn10,
		rollArea = rollArea,
		resultFrame = resultFrame,
		resultLayout = resultLayout,
	}
end

-- Show roll result with animation
local function showRollResult(rolls, banner)
	-- Clear previous results
	for _, child in ipairs(refs.resultFrame:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	-- Play roll animation (boxes opening)
	local function playRollAnimation(callback)
		local boxes = {}
		for i = 1, #rolls do
			local box = Instance.new("Frame")
			box.Name = "Box_" .. i
			box.Size = UDim2.new(0, 50, 0, 50)
			box.Position = UDim2.new(0, (i - 1) * 60 - 100, 0.5, -25)
			box.BackgroundColor3 = Theme.COLORS.Crimson
			box.BorderSizePixel = 0
			box.Parent = refs.rollArea
			newUICorner(6):Parent = box
			newUIStroke(Theme.COLORS.Gold, 2):Parent = box

			local label = Instance.new("TextLabel")
			label.Name = "Label"
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Font = Theme.FONTS.Title
			label.TextSize = 24
			label.TextColor3 = Theme.COLORS.Bone
			label.Text = "❓"
			label.Parent = box

			table.insert(boxes, box)
		end

		-- Animate boxes flying in
		for i, box in ipairs(boxes) do
			delay(0.1 * i, function()
				TweenService:Create(box, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, (i - 1) * 60, 0.5, -25)
				}):Play()
			end)
		end

		-- Wait then reveal
		delay(1, function()
			for i, roll in ipairs(rolls) do
				local rarityColor = GachaData:GetRarityColor(roll.Rarity)
				TweenService:Create(boxes[i], TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = rarityColor
				}):Play()
				boxes[i].Label.Text = roll.ItemId:sub(-4) -- short id
			end

			delay(2, function()
				-- Move boxes to result frame
				for i, box in ipairs(boxes) do
					box.Parent = refs.resultFrame
					box.Size = UDim2.new(0, 50, 0, 50)
				end
				boxes = {}
				if callback then callback() end
			end)
		end)
	end

	playRollAnimation(function()
		-- Update last results
		lastResults = rolls
	end)
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	refs.btn1.MouseButton1Click:Connect(function()
		rollGacha:FireServer("Standard", 1)
	end)

	refs.btn10.MouseButton1Click:Connect(function()
		rollGacha:FireServer("Standard", 10)
	end)

	rollResult.OnClientEvent:Connect(function(rolls, banner)
		showRollResult(rolls, banner)
	end)

	historyResponse.OnClientEvent:Connect(function(pityInfo)
		pityCount = (pityInfo.SSRCount or 0)
		refs.pityLabel.Text = ("Pity: %d/90"):format(pityCount)
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("GachaUI") then
			ui.Parent = playerGui
		end
	end
end

init()

return {
	Toggle = function()
		if ui then
			toggleUI()
		end
	end,
}