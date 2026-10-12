-- SettingsUIHelpers.lua
-- Fungsi pembantu UI untuk SettingsMenu
-- Letakkan di: ReplicatedStorage/Modules/SettingsUIHelpers.lua

local TweenService = game:GetService("TweenService")

local helpers = {}

function helpers.newUICorner(radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	return c
end

function helpers.newUIStroke(color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Color3.fromRGB(201, 162, 75) -- Gold
	s.Thickness = thickness or 1
	return s
end

function helpers.tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function helpers.createDotDivider(width)
	local dots = Instance.new("Frame")
	dots.Name = "DotDivider"
	dots.Size = UDim2.new(0, width or 100, 0, 4)
	dots.BackgroundTransparency = 1
	dots.BorderSizePixel = 0

	for i = 1, 38 do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 4, 0, 2)
		dot.Position = UDim2.new(0, (i - 1) * 14 + 2, 0, 0)
		dot.BackgroundColor3 = Color3.fromRGB(201, 162, 75)
		dot.BorderSizePixel = 0
		helpers.newUICorner(2):Parent = dot
		dot.Parent = dots

		if i < 38 then
			local gap = Instance.new("Frame")
			gap.Size = UDim2.new(0, 10, 0, 2)
			gap.Position = UDim2.new(0, i * 14 - 6, 0, 0)
			gap.BackgroundColor3 = Color3.fromRGB(11, 15, 29)
			gap.BorderSizePixel = 0
			gap.Parent = dots
		end
	end

	return dots
end

function helpers.createDiamondOrnament(color, size)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(0, size or 14, 0, size or 14)
	d.BackgroundColor3 = color or Color3.fromRGB(201, 162, 75)
	d.BorderSizePixel = 0
	helpers.newUICorner((size or 14) / 2):Parent = d
	return d
end

function helpers.createSettingCard(titleText, yPos, descText, theme)
	local card = Instance.new("Frame")
	card.Name = "Card_" .. (titleText or ""):gsub("[^%w]", "_")
	card.Size = UDim2.new(1, -10, 0, 90)
	card.Position = UDim2.new(0, 5, 0, yPos)
	card.BackgroundColor3 = theme.COLORS.Card
	card.BorderSizePixel = 0

	helpers.newUICorner(10):Parent = card
	helpers.newUIStroke(theme.COLORS.GoldDim, 1):Parent = card

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Name = "Title"
	titleLbl.Size = UDim2.new(1, -100, 0, 22)
	titleLbl.Position = UDim2.new(0, 12, 0, 8)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = theme.FONTS.Label
	titleLbl.TextSize = 16
	titleLbl.TextColor3 = theme.COLORS.Bone
	titleLbl.Text = titleText or ""
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = card

	local descLbl = Instance.new("TextLabel")
	descLbl.Name = "Desc"
	descLbl.Size = UDim2.new(1, -100, 0, 18)
	descLbl.Position = UDim2.new(0, 12, 0, 30)
	descLbl.BackgroundTransparency = 1
	descLbl.Font = theme.FONTS.Body
	descLbl.TextSize = 12
	descLbl.TextColor3 = theme.COLORS.BoneDim
	descLbl.TextWrapped = true
	descLbl.Text = descText or ""
	descLbl.Parent = card

	return card
end

return helpers