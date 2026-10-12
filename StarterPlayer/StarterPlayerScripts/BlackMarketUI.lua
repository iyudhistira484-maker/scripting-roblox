-- BlackMarketUI.lua
-- Antarmuka klien untuk Black Market (Pasar Gelap).
-- Letakkan di: StarterPlayer/StarterPlayerScripts/BlackMarketUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local BlackMarketData = require(ReplicatedStorage.Modules.BlackMarketData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BlackMarket")
local requestStock = remotes:WaitForChild("RequestStock")
local stockResponse = remotes:WaitForChild("StockResponse")
local buyItem = remotes:WaitForChild("BuyItem")
local purchaseResult = remotes:WaitForChild("PurchaseResult")

-- State
local ui = nil
local refs = {}
local isOpen = false
local currentStock = {}
local restockTime = 0

-- Helper functions
local function newUICorner(radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	return c
end

local function newUIStroke(color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.COLORS.Crimson
	s.Thickness = thickness or 1
	return s
end

local function createDiamondOrnamentHelper(color, size, parent)
	local d = UIHelpers.createDiamondOrnament(color, size)
	d.Parent = parent
	return d
end

-- Format countdown timer
local function formatCountdown(seconds)
	seconds = math.max(0, seconds)
	local hours = math.floor(seconds / 3600)
	local minutes = math.floor((seconds % 3600) / 60)
	local secs = math.floor(seconds % 60)
	return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

-- Toggle panel
local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -260)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 680, 0, 560),
			Position = UDim2.new(0.5, -340, 0.5, -280)
		}):Play()
		requestStock:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1),
			Position = UDim2.new(0.5, 0, 0.5, -260)
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
	screenGui.Name = "BlackMarketUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	toggleBtn.Position = UDim2.new(0, 70, 0.5, -24)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🕷️"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Crimson
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Crimson, 1):Parent = toggleBtn

	-- Panel main (crimson gelap)
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 680, 0, 560)
	panel.Position = UDim2.new(0.5, -340, 0.5, -280)
	panel.BackgroundColor3 = Color3.fromRGB(139, 38, 53)
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	newUICorner(16):Parent = panel
	newUIStroke(Theme.COLORS.Gold, 2):Parent = panel

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -4, 1, -4)
	bg.Position = UDim2.new(0, 2, 0, 2)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	newUICorner(14):Parent = bg
	bg.Parent = panel

	-- Diamond ornaments (crimson)
	local ornamentPositions = {
		{UDim2.new(0, 8, 0, 8), Vector2.new(0, 0)},
		{UDim2.new(1, -8, 0, 8), Vector2.new(1, 0)},
		{UDim2.new(0, 8, 1, -8), Vector2.new(0, 1)},
		{UDim2.new(1, -8, 1, -8), Vector2.new(1, 1)},
	}
	for _, entry in ipairs(ornamentPositions) do
		local d = createDiamondOrnamentHelper(Theme.COLORS.Crimson, 10, panel)
		d.Position = entry[1]
		d.AnchorPoint = entry[2]
	end

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 64)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	newUICorner(16):Parent = header
	header.Parent = panel

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -80, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = " PASAR GELAP "
	title.Font = Theme.FONTS.Title
	title.TextSize = 28
	title.TextColor3 = Theme.COLORS.Crimson
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -28, 0, 20)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Theme.FONTS.Label
	closeBtn.Text = "✕"
	closeBtn.TextSize = 18
	closeBtn.TextColor3 = Theme.COLORS.Bone
	closeBtn.AutoButtonColor = false
	newUICorner(4):Parent = closeBtn
	newUIStroke(Theme.COLORS.Crimson, 1):Parent = closeBtn
	closeBtn.Parent = header

	-- Restock timer
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.new(0, 130, 0, 20)
	timerLabel.Position = UDim2.new(1, -170, 0, 20)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Font = Theme.FONTS.Number
	timerLabel.TextSize = 13
	timerLabel.TextColor3 = Theme.COLORS.GoldHi
	timerLabel.Text = "00:00:00"
	timerLabel.TextXAlignment = Enum.TextXAlignment.Right
	timerLabel.Parent = header

	-- Grid container
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -24, 1, -84)
	grid.Position = UDim2.new(0, 12, 0, 72)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, -4, 0, 100)
	layout.CellPadding = UDim2.new(0, 2, 0, 8)
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
		timerLabel = timerLabel,
		grid = grid,
		layout = layout,
	}
end

-- Populate stock grid
local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	for _, item in ipairs(currentStock) do
		local rarityColor = BlackMarketData:GetRarityColor(item.Rarity)

		local card = Instance.new("Frame")
		card.Name = "Card_" .. item.Id
		card.Size = UDim2.new(1, -4, 0, 100)
		card.BackgroundColor3 = Theme.COLORS.Card
		card.BorderSizePixel = 0
		card.BackgroundTransparency = 0
		card.Parent = refs.grid
		newUICorner(8):Parent = card
		newUIStroke(rarityColor, 1):Parent = card

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 45, 0, 45)
		icon.Position = UDim2.new(0, 6, 0, 6)
		icon.BackgroundTransparency = 1
		icon.Image = item.IconImage or ""
		icon.ImageColor3 = Theme.COLORS.Crimson
		icon.Parent = card

		-- Name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -58, 0, 18)
		nameLabel.Position = UDim2.new(0, 56, 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.FONTS.Label
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = rarityColor
		nameLabel.Text = item.Name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "DescLabel"
		descLabel.Size = UDim2.new(1, -58, 0, 16)
		descLabel.Position = UDim2.new(0, 56, 0, 22)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Theme.FONTS.Body
		descLabel.TextSize = 11
		descLabel.TextColor3 = Theme.COLORS.BoneDim
		descLabel.Text = item.Description
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = card

		-- Price
		local priceLabel = Instance.new("TextLabel")
		priceLabel.Name = "PriceLabel"
		priceLabel.Size = UDim2.new(1, -58, 0, 16)
		priceLabel.Position = UDim2.new(0, 56, 0, 38)
		priceLabel.BackgroundTransparency = 1
		priceLabel.Font = Theme.FONTS.Number
		priceLabel.TextSize = 13
		priceLabel.TextColor3 = Theme.COLORS.Gold
		local priceText = ""
		if item.Price.Gems and item.Price.Gems > 0 then
			priceText = priceText .. item.Price.Gems .. " 💎"
		end
		if item.Price.Rupiah and item.Price.Rupiah > 0 then
			if priceText ~= "" then priceText = priceText .. " +" end
			priceText = priceText .. " " .. item.Price.Rupiah .. " 🪙"
		end
		priceLabel.Text = priceText
		priceLabel.TextXAlignment = Enum.TextXAlignment.Left
		priceLabel.Parent = card

		-- Stock indicator
		local stockLabel = Instance.new("TextLabel")
		stockLabel.Name = "StockLabel"
		stockLabel.Size = UDim2.new(0, 60, 0, 20)
		stockLabel.Position = UDim2.new(1, -64, 0, 7)
		stockLabel.BackgroundTransparency = 1
		stockLabel.Font = Theme.FONTS.Number
		stockLabel.TextSize = 12
		stockLabel.TextColor3 = Theme.COLORS.BoneDim
		stockLabel.Text = "x" .. (item.Stock or 0)
		stockLabel.Parent = card

		-- Buy button
		local buyBtn = Instance.new("TextButton")
		buyBtn.Name = "BuyBtn"
		buyBtn.Size = UDim2.new(0, 60, 0, 24)
		buyBtn.Position = UDim2.new(1, -64, 0, 33)
		buyBtn.BackgroundColor3 = Theme.COLORS.Crimson
		buyBtn.BorderSizePixel = 0
		buyBtn.Font = Theme.FONTS.Label
		buyBtn.Text = "BELI"
		buyBtn.TextSize = 12
		buyBtn.TextColor3 = Theme.COLORS.Bone
		buyBtn.AutoButtonColor = false
		newUICorner(4):Parent = buyBtn
		newUIStroke(Theme.COLORS.GoldDim, 1):Parent = buyBtn
		buyBtn.Parent = card

		buyBtn.MouseButton1Click:Connect(function()
			buyItem:FireServer(item.Id)
		end)

		buyBtn.MouseEnter:Connect(function()
			TweenService:Create(buyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Crimson}):Play()
		end)
		buyBtn.MouseLeave:Connect(function()
		TweenService:Create(buyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(139, 38, 53)}):Play()
	end)
	end
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	stockResponse.OnClientEvent:Connect(function(stockList, lastRestockTime)
		currentStock = stockList
		restockTime = lastRestockTime
		populateGrid()
	end)

	purchaseResult.OnClientEvent:Connect(function(itemId, success, item)
		if success then
			requestStock:FireServer()
		end
	end)
end

-- Timer update
local function startTimerUpdate()
	spawn(function()
		while true do
			if isOpen then
				local remaining = restockTime + (6 * 60 * 60) - tick()
				refs.timerLabel.Text = formatCountdown(remaining)
			end
			wait(1)
		end
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		startTimerUpdate()
		if not playerGui:FindFirstChild("BlackMarketUI") then
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