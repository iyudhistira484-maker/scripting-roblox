-- SettingsMenu.lua
-- Menu pengaturan klien untuk Hunt Mystic Ghost
-- Letakkan di: StarterPlayer/StarterPlayerScripts/SettingsMenu.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local UIHelpers = require(ReplicatedStorage.Modules.SettingsUIHelpers)

local settingsRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Settings")
local updateSettingsEvent = settingsRemotes:WaitForChild("UpdateSettings")

-- State
local isOpen = false
local currentSettings = {
	JumpscareIntensity = "Full",
	Vibration = true,
	Brightness = 1,
	FOV = 70,
	MusicVolume = 0.5,
}

local refs = {}

-- Helper: Apply settings to game
local function applySettings()
	Lighting.Brightness = currentSettings.Brightness
	local cc = Lighting:FindFirstChildOfClass("ColorCorrection")
	if cc then
		cc.Brightness = currentSettings.Brightness
	end
	local camera = workspace.CurrentCamera
	if camera then
		camera.FieldOfView = currentSettings.FOV
	end
	local musicGroup = SoundService:FindFirstChild("Music")
	if musicGroup then
		musicGroup.Volume = currentSettings.MusicVolume
	end
end

-- Helper: Save settings to server
local function saveSettings()
	updateSettingsEvent:FireServer(currentSettings)
end

-- Helper: Toggle settings panel
local function toggleSettings()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.overlay.Visible = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		UIHelpers.tween(refs.panel, {Size = UDim2.new(0, 580, 0, 560)}, 0.4)
		UIHelpers.tween(refs.toggleBtn, {TextColor3 = Theme.COLORS.JadeGlow}, 0.2)
	else
		UIHelpers.tween(refs.overlay, {BackgroundTransparency = 1}, 0.3)
		UIHelpers.tween(refs.panel, {Size = UDim2.new(0, 0, 0, 1)}, 0.4)
		UIHelpers.tween(refs.toggleBtn, {TextColor3 = Theme.COLORS.Gold}, 0.2)
		wait(0.4)
		refs.screenGui.Enabled = false
		refs.overlay.Visible = false
		refs.overlay.BackgroundTransparency = 0.5
	end
end

-- Build the UI
local function buildUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SettingsMenu"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "Toggle"
	toggleBtn.Size = UDim2.new(0, 44, 0, 44)
	toggleBtn.Position = UDim2.new(1, -56, 1, -56)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = ""
	toggleBtn.AutoButtonColor = false
	UIHelpers.newUICorner(8):Parent = toggleBtn
	UIHelpers.newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn
	toggleBtn.Parent = screenGui

	-- Overlay
	local overlay = Instance.new("TextButton")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Theme.COLORS.Void
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Text = ""
	overlay.Visible = false
	overlay.Parent = screenGui

	-- Main panel
	local panel = Instance.new("Frame")
	panel.Name = "MainPanel"
	panel.Size = UDim2.new(0, 580, 0, 560)
	panel.Position = UDim2.new(0.5, -290, 0.5, -280)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	UIHelpers.newUICorner(16):Parent = panel
	UIHelpers.newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "Bg"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	UIHelpers.newUICorner(14):Parent = bg
	bg.Parent = panel

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	UIHelpers.newUICorner(14):Parent = header
	header.Parent = panel

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -50, 1, -5)
	title.Position = UDim2.new(0, 10, 0, 2)
	title.BackgroundTransparency = 1
	title.Text = "PENGATURAN"
	title.Font = Theme.FONTS.Title
	title.TextSize = 26
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "Close"
	closeBtn.Size = UDim2.new(0, 22, 0, 22)
	closeBtn.Position = UDim2.new(1, -26, 0, 19)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card
	closeBtn.Font = Theme.FONTS.Label
	closeBtn.Text = "X"
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Theme.COLORS.Bone
	closeBtn.AutoButtonColor = false
	UIHelpers.newUICorner(4):Parent = closeBtn
	UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = header

	-- Dot divider
	local dotLine = UIHelpers.createDotDivider(520)
	dotLine.Name = "Divider"
	dotLine.Position = UDim2.new(0, 30, 1, 0)
	dotLine.Parent = header

	-- Settings container
	local container = Instance.new("ScrollingFrame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -30, 1, -80)
	container.Position = UDim2.new(0, 15, 0, 65)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.ScrollBarThickness = 6
	container.CanvasSize = UDim2.new(0, 0, 0, 0)
	container.Parent = panel

	container:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		container.CanvasSize = UDim2.new(0, 0, 0, container.AbsoluteContentSize.Y + 30)
	end)

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		closeBtn = closeBtn,
		container = container,
		overlay = overlay,
	}

	-- ========================================
	-- 1. Jumpscare Intensity Card
	-- ========================================
	local jCard = UIHelpers.createSettingCard("Intensitas Jumpscare", 0, "Kontrol seberapa keras efek jumpscare", Theme)

	local jOpts = {"Full", "Reduced", "Off"}
	for i, opt in ipairs(jOpts) do
		local btn = Instance.new("TextButton")
		btn.Name = "Btn_" .. opt
		btn.Size = UDim2.new(0, 60, 0, 24)
		btn.Position = UDim2.new(1, -75 + (i - 1) * 65, 0, 55)
		btn.BackgroundColor3 = Theme.COLORS.Indigo
		btn.Font = Theme.FONTS.Label
		btn.Text = opt
		btn.TextSize = 12
		btn.TextColor3 = Theme.COLORS.Bone
		btn.AutoButtonColor = false
		UIHelpers.newUICorner(4):Parent = btn
		UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn
		btn.Parent = jCard

		if opt == currentSettings.JumpscareIntensity then
			btn.BackgroundColor3 = Theme.COLORS.Gold
			btn.TextColor3 = Theme.COLORS.Void
		end

		btn.MouseButton1Click:Connect(function()
			for _, other in ipairs(jCard:GetChildren()) do
				if other:IsA("TextButton") and other.Name:find("Btn_") then
					other.BackgroundColor3 = Theme.COLORS.Indigo
					other.TextColor3 = Theme.COLORS.Bone
				end
			end
			btn.BackgroundColor3 = Theme.COLORS.Gold
			btn.TextColor3 = Theme.COLORS.Void
			currentSettings.JumpscareIntensity = opt
			saveSettings()
		end)
	end

	-- ========================================
	-- 2. Vibration Card
	-- ========================================
	local vCard = UIHelpers.createSettingCard("Getaran (Mobile)", 100, "Gunakan getaran pada perangkat mobile", Theme)

	local toggleVib = Instance.new("TextButton")
	toggleVib.Name = "VibrationToggle"
	toggleVib.Size = UDim2.new(1, -110, 0, 24)
	toggleVib.Position = UDim2.new(0, 12, 0, 55)
	toggleVib.BackgroundColor3 = currentSettings.Vibration and Theme.COLORS.Gold or Theme.COLORS.Indigo
	toggleVib.Font = Theme.FONTS.Label
	toggleVib.Text = currentSettings.Vibration and "AKTIF" or "NONAKTIF"
	toggleVib.TextSize = 13
	toggleVib.TextColor3 = currentSettings.Vibration and Theme.COLORS.Void or Theme.COLORS.Bone
	toggleVib.AutoButtonColor = false
	UIHelpers.newUICorner(12):Parent = toggleVib
	UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = toggleVib
	toggleVib.Parent = vCard

	toggleVib.MouseButton1Click:Connect(function()
		currentSettings.Vibration = not currentSettings.Vibration
		toggleVib.BackgroundColor3 = currentSettings.Vibration and Theme.COLORS.Gold or Theme.COLORS.Indigo
		toggleVib.Text = currentSettings.Vibration and "AKTIF" or "NONAKTIF"
		toggleVib.TextColor3 = currentSettings.Vibration and Theme.COLORS.Void or Theme.COLORS.Bone
		saveSettings()
	end)

	-- ========================================
	-- 3. Brightness Slider
	-- ========================================
	local bCard = UIHelpers.createSettingCard("Kecerahan", 210, "Kecerahan layar (0.5 - 2.0)", Theme)

	local bSlider = Instance.new("Frame")
	bSlider.Name = "Slider"
	bSlider.Size = UDim2.new(1, -110, 0, 18)
	bSlider.Position = UDim2.new(0, 12, 0, 55)
	bSlider.BackgroundColor3 = Theme.COLORS.Indigo
	bSlider.BorderSizePixel = 0
	bSlider.Active = true
	UIHelpers.newUICorner(9):Parent = bSlider
	bSlider.Parent = bCard

	local bFill = Instance.new("Frame")
	bFill.Name = "Fill"
	bFill.Size = UDim2.new((currentSettings.Brightness - 0.5) / 1.5, 0, 1, 0)
	bFill.BackgroundColor3 = Theme.COLORS.Gold
	bFill.BorderSizePixel = 0
	UIHelpers.newUICorner(9):Parent = bFill
	bFill.Parent = bSlider

	local bLabel = Instance.new("TextLabel")
	bLabel.Name = "ValueLabel"
	bLabel.Size = UDim2.new(0, 50, 1, 0)
	bLabel.Position = UDim2.new(1, 8, 0, 0)
	bLabel.BackgroundTransparency = 1
	bLabel.Font = Theme.FONTS.Number
	bLabel.TextSize = 14
	bLabel.TextColor3 = Theme.COLORS.Bone
	bLabel.Text = string.format("%.1f", currentSettings.Brightness)
	bLabel.Parent = bCard

	local isDraggingB = false
	bSlider.MouseButton1D:Connect(function() isDraggingB = true end)
	bSlider.MouseButton1Up:Connect(function() isDraggingB = false end)
	bSlider.MouseMoved:Connect(function()
		if isDraggingB then
			local mouseX = UserInputService:GetMouseLocation().X - bSlider.AbsolutePosition.X
			local norm = math.clamp(mouseX / bSlider.AbsoluteSize.X, 0, 1)
			currentSettings.Brightness = 0.5 + (norm * 1.5)
			bFill.Size = UDim2.new(norm, 0, 1, 0)
			bLabel.Text = string.format("%.1f", currentSettings.Brightness)
			applySettings()
			saveSettings()
		end
	end)

	-- ========================================
	-- 4. FOV Slider
	-- ========================================
	local fCard = UIHelpers.createSettingCard("Field of View", 320, "Jarak pandang kamera (60 - 120)", Theme)

	local fSlider = Instance.new("Frame")
	fSlider.Name = "Slider"
	fSlider.Size = UDim2.new(1, -110, 0, 18)
	fSlider.Position = UDim2.new(0, 12, 0, 55)
	fSlider.BackgroundColor3 = Theme.COLORS.Indigo
	fSlider.BorderSizePixel = 0
	fSlider.Active = true
	UIHelpers.newUICorner(9):Parent = fSlider
	fSlider.Parent = fCard

	local fFill = Instance.new("Frame")
	fFill.Name = "Fill"
	fFill.Size = UDim2.new((currentSettings.FOV - 60) / 60, 0, 1, 0)
	fFill.BackgroundColor3 = Theme.COLORS.Gold
	fFill.BorderSizePixel = 0
	UIHelpers.newUICorner(9):Parent = fFill
	fFill.Parent = fSlider

	local fLabel = Instance.new("TextLabel")
	fLabel.Name = "ValueLabel"
	fLabel.Size = UDim2.new(0, 50, 1, 0)
	fLabel.Position = UDim2.new(1, 8, 0, 0)
	fLabel.BackgroundTransparency = 1
	fLabel.Font = Theme.FONTS.Number
	fLabel.TextSize = 14
	fLabel.TextColor3 = Theme.COLORS.Bone
	fLabel.Text = tostring(currentSettings.FOV)
	fLabel.Parent = fCard

	local isDraggingF = false
	fSlider.MouseButton1D:Connect(function() isDraggingF = true end)
	fSlider.MouseButton1Up:Connect(function() isDraggingF = false end)
	fSlider.MouseMoved:Connect(function()
		if isDraggingF then
			local mouseX = UserInputService:GetMouseLocation().X - fSlider.AbsolutePosition.X
			local norm = math.clamp(mouseX / fSlider.AbsoluteSize.X, 0, 1)
			currentSettings.FOV = math.floor(60 + (norm * 60))
			fFill.Size = UDim2.new(norm, 0, 1, 0)
			fLabel.Text = tostring(currentSettings.FOV)
			applySettings()
			saveSettings()
		end
	end)

	-- ========================================
	-- 5. Music Volume Slider
	-- ========================================
	local mCard = UIHelpers.createSettingCard("Volume Musik", 430, "Kontrol volume musik latar", Theme)

	local mSlider = Instance.new("Frame")
	mSlider.Name = "Slider"
	mSlider.Size = UDim2.new(1, -110, 0, 18)
	mSlider.Position = UDim2.new(0, 12, 0, 55)
	mSlider.BackgroundColor3 = Theme.COLORS.Indigo
	mSlider.BorderSizePixel = 0
	mSlider.Active = true
	UIHelpers.newUICorner(9):Parent = mSlider
	mSlider.Parent = mCard

	local mFill = Instance.new("Frame")
	mFill.Name = "Fill"
	mFill.Size = UDim2.new(currentSettings.MusicVolume, 0, 1, 0)
	mFill.BackgroundColor3 = Theme.COLORS.Gold
	mFill.BorderSizePixel = 0
	UIHelpers.newUICorner(9):Parent = mFill
	mFill.Parent = mSlider

	local mLabel = Instance.new("TextLabel")
	mLabel.Name = "ValueLabel"
	mLabel.Size = UDim2.new(0, 50, 1, 0)
	mLabel.Position = UDim2.new(1, 8, 0, 0)
	mLabel.BackgroundTransparency = 1
	mLabel.Font = Theme.FONTS.Number
	mLabel.TextSize = 14
	mLabel.TextColor3 = Theme.COLORS.Bone
	mLabel.Text = string.format("%.0f%%", currentSettings.MusicVolume * 100)
	mLabel.Parent = mCard

	local isDraggingM = false
	mSlider.MouseButton1D:Connect(function() isDraggingM = true end)
	mSlider.MouseButton1Up:Connect(function() isDraggingM = false end)
	mSlider.MouseMoved:Connect(function()
		if isDraggingM then
			local mouseX = UserInputService:GetMouseLocation().X - mSlider.AbsolutePosition.X
			local norm = math.clamp(mouseX / mSlider.AbsoluteSize.X, 0, 1)
			currentSettings.MusicVolume = norm
			mFill.Size = UDim2.new(norm, 0, 1, 0)
			mLabel.Text = string.format("%.0f%%", norm * 100)
			applySettings()
			saveSettings()
		end
	end)

	-- ========================================
	-- Event handlers
	-- ========================================
	refs.closeBtn.MouseButton1Click:Connect(function()
		toggleSettings()
	end)

	refs.overlay.MouseButton1Click:Connect(function()
		toggleSettings()
	end)

	refs.toggleBtn.MouseButton1Click:Connect(function()
		toggleSettings()
	end)

	-- Keyboard shortcut
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.F11 then
			toggleSettings()
		end
	end)

	return screenGui
end

-- ========================================
-- Init
-- ========================================
local screenGui = buildUI()
screenGui.Parent = playerGui
applySettings()

-- Export
return {
	Toggle = function()
		toggleSettings()
	end,
	GetSettings = function()
		return currentSettings
	end,
}