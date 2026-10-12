-- AchievementUIHelpers.lua
-- Fungsi pembantu UI untuk Achievement
-- Letakkan di: ReplicatedStorage/Modules/AchievementUIHelpers.lua

local TweenService = game:GetService("TweenService")

local helpers = {}

function helpers.newUICorner(radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	return c
end

function helpers.newUIStroke(color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(201, 162, 75)
	s.Thickness = thickness or 1
	return s
end

function helpers.tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function helpers.createDiamondOrnament(color, size)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(0, size or 12, 0, size or 12)
	d.BackgroundColor3 = color or Color3.fromRGB(201, 162, 75)
	d.BorderSizePixel = 0
	helpers.newUICorner((size or 12) / 2):Parent = d
	return d
end

function helpers.createProgressBar(theme, parent, defaultValue)
	local container = Instance.new("Frame")
	container.Name = "ProgressBar"
	container.Size = UDim2.new(1, -24, 0, 14)
	container.Position = UDim2.new(0, 12, 0, 58)
	container.BackgroundColor3 = theme.COLORS.Indigo
	container.BorderSizePixel = 0
	helpers.newUICorner(7):Parent = container
	container.Parent = parent

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = theme.COLORS.Gold
	fill.BorderSizePixel = 0
	helpers.newUICorner(7):Parent = fill
	fill.Parent = container

	local label = Instance.new("TextLabel")
	label.Name = "ProgressLabel"
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = theme.FONTS.Number
	label.TextSize = 12
	label.TextColor3 = theme.COLORS.BoneDim
	label.Text = "0%"
	label.Parent = container

	return fill, label
end

return helpers