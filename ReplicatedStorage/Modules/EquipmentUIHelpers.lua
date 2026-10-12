-- EquipmentUIHelpers.lua
-- Fungsi pembantu UI untuk Equipment
-- Letakkan di: ReplicatedStorage/Modules/EquipmentUIHelpers.lua

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
	dots.Size = UDim2.new(0, width or 100, 0, 1)
	dots.BackgroundTransparency = 1
	dots.BorderSizePixel = 0

	-- Create multiple dot images
	local dotCount = math.floor((width or 100) / 6)
	for i = 1, dotCount do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 3, 1, 0)
		dot.Position = UDim2.new(0, (i - 1) * 6, 0, 0)
		dot.BackgroundColor3 = Color3.fromRGB(201, 162, 75)
		dot.BorderSizePixel = 0
		dot.Parent = dots
	end

	return dots
end

return helpers