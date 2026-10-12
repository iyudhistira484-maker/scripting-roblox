-- GhostCollectionUIHelpers.lua
-- Fungsi pembantu UI untuk Koleksi Hantu

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

function helpers.createDiamondOrnament(color, size)
	local d = Instance.new("Frame")
	d.Size = UDim2.new(0, size or 12, 0, size or 12)
	d.BackgroundColor3 = color or Color3.fromRGB(201, 162, 75)
	d.BorderSizePixel = 0
	helpers.newUICorner(size and size/2 or 6):Parent = d
	return d
end

return helpers
