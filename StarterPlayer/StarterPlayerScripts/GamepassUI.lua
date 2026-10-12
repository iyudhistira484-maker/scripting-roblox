-- GamepassUI.lua
-- Antarmuka klien untuk Gamepass.
-- Letakkan di: StarterPlayer/StarterPlayerScripts/GamepassUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local GamepassConfig = require(ReplicatedStorage.Modules.GamepassConfig)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gamepass")
local checkOwnership = remotes:WaitForChild("CheckOwnership")
local ownershipResponse = remotes:WaitForChild("OwnershipResponse")

-- State
local ui = nil
local refs = {}
local isOpen = false
local ownedPasses = {}

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
			Size = UDim2.new(0, 680, 0, 520),
			Position = UDim2.new(0.5, -340, 0.5, -260)
		}):Play()
		checkOwnership:FireServer()
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
	screenGui.Name = "GamepassUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	toggleBtn.Position = UDim2.new(1, -120, 0.5, -24)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🔐"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Crimson
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Crimson, 1):Parent = toggleBtn

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 680, 0, 520)
	panel.Position = UDim2.new(0.5, -340, 0.5, -260)
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
	local ornamentPositions = {
		{UDim2.new(0, 8, 0, 8), Vector2.new(0, 0)},
		{UDim2.new(1, -8, 0, 8), Vector2.new(1, 0)},
		{UDim2.new(0, 8, 1, -8), Vector2.new(0, 1)},
		{UDim2.new(1, -8, 1, -8), Vector2.new(1, 1)},
	}
	for _, entry in ipairs(ornamentPositions) do
		local d = createDiamondOrnamentHelper(Theme.COLORS.Gold, 12, panel)
		d.Position = entry[1]
		d.AnchorPoint = entry[2]
	end

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	newUICorner(16):Parent = header
	header.Parent = panel

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -50, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "GAMEPASS"
	title.Font = Theme.FONTS.Title
	title.TextSize = 26
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

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

	-- Grid
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -24, 1, -80)
	grid.Position = UDim2.new(0, 12, 0, 70)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, 0, 0, 120)
	layout.CellPadding = UDim2.new(0, 0, 0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = grid

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.CanvasSize = UDim2.new(0, 0, 0, math.max(grid.AbsoluteContentSize.Y + 20, 0))
	end)

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		closeBtn = closeBtn,
		grid = grid,
		layout = layout,
	}
end

-- Populate grid
local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	for _, pass in ipairs(GamepassConfig:GetAll()) do
		local isOwned = ownedPasses[pass.Id] or false
		local rarityColor = GamepassConfig:GetRarityColor(pass.Rarity)

		local card = Instance.new("Frame")
		card.Name = "Card_" .. pass.Id
		card.Size = UDim2.new(1, 0, 0, 120)
		card.BackgroundColor3 = isOwned and Theme.COLORS.Gold or Theme.COLORS.Card
		card.BorderSizePixel = 0
		card.BackgroundTransparency = 0
		card.Parent = refs.grid
		newUICorner(8):Parent = card
		newUIStroke(rarityColor, 1):Parent = card

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 50, 0, 50)
		icon.Position = UDim2.new(0, 6, 0, 6)
		icon.BackgroundTransparency = 1
		icon.Image = pass.IconImage or ""
		icon.ImageColor3 = isOwned and Theme.COLORS.Void or Theme.COLORS.BoneDim
		icon.Parent = card

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -62, 0, 20)
		nameLabel.Position = UDim2.new(0, 62, 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.FONTS.Label
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = isOwned and Theme.COLORS.Void or rarityColor
		nameLabel.Text = pass.Name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "DescLabel"
		descLabel.Size = UDim2.new(1, -62, 0, 16)
		descLabel.Position = UDim2.new(0, 62, 0, 24)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Theme.FONTS.Body
		descLabel.TextSize = 11
		descLabel.TextColor3 = isOwned and Theme.COLORS.Void or Theme.COLORS.BoneDim
		descLabel.Text = pass.Description
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = card

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Name = "PriceLabel"
		priceLabel.Size = UDim2.new(1, -62, 0, 16)
		priceLabel.Position = UDim2.new(0, 62, 0, 42)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Font = Theme.FONTS.Number
		priceLabel.TextSize = 13
		priceLabel.TextColor3 = Theme.COLORS.Gold
		priceLabel.Text = isOwned and "TERBELI" or pass.Price.Display
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = card

		-- Rarity badge
		local badge = Instance.new("Frame")
		badge.Name = "Badge"
		badge.Size = UDim2.new(0, 20, 0, 20)
		badge.Position = UDim2.new(1, -24, 0, 6)
		badge.BackgroundColor3 = rarityColor
		badge.BorderSizePixel = 0
		badge.Parent = card
		newUICorner(4):Parent = badge

		local badgeText = Instance.new("TextLabel")
		badgeText.Name = "BadgeText"
		badgeText.Size = UDim2.new(1, 0, 1, 0)
		badgeText.BackgroundTransparency = 1
		badgeText.Font = Theme.FONTS.Label
		badgeText.TextSize = 12
		badgeText.TextColor3 = Theme.COLORS.Void
		badgeText.Text = pass.Rarity and pass.Rarity:sub(1, 1) or "?"
		badgeText.Parent = badge

		-- Button
		local btn = Instance.new("TextButton")
		btn.Name = "ActionBtn"
		btn.Size = UDim2.new(1, -20, 0, 26)
		btn.Position = UDim2.new(0, 10, 1, -30)
		btn.BackgroundColor3 = isOwned and Theme.COLORS.JadeGlow or Theme.COLORS.GoldDim
		btn.BorderSizePixel = 0
		btn.Font = Theme.FONTS.Label
		btn.Text = isOwned and "DIMILIKI" or "BELI"
		btn.TextSize = 12
		btn.TextColor3 = isOwned and Theme.COLORS.Void or Theme.COLORS.Bone
		btn.AutoButtonColor = false
		newUICorner(4):Parent = btn
		newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn
		btn.Parent = card

		btn.MouseButton1Click:Connect(function()
			if isOwned then return end
			-- Buka prompt beli gamepass di Roblox
			local success, err = pcall(function()
				MarketplaceService:PromptGamePassPurchase(player, pass.GamepassId)
			end)
			if not success then
				warn("Gagal membuka prompt beli gamepass: " .. tostring(err))
			end
		end)

		btn.MouseEnter:Connect(function()
			if not isOwned then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Crimson}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if not isOwned then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.GoldDim}):Play()
			end
		end)
	end
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	ownershipResponse.OnClientEvent:Connect(function(hasPass, ownedList)
		ownedPasses = hasPass
		populateGrid()
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("GamepassUI") then
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