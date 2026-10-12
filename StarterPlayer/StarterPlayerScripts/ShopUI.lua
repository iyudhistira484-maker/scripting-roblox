-- ShopUI.lua
-- Antarmuka klien untuk Shop (Toko Barang).
-- Letakkan di: StarterPlayer/StarterPlayerScripts/ShopUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local ShopData = require(ReplicatedStorage.Modules.ShopData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop")
local requestItems = remotes:WaitForChild("RequestItems")
local itemsResponse = remotes:WaitForChild("ItemsResponse")
local buyItem = remotes:WaitForChild("BuyItem")
local purchaseResult = remotes:WaitForChild("PurchaseResult")

-- State
local ui = nil
local refs = {}
local isOpen = false
local shopItems = {}
local activeCategory = "Senjata"

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
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, -350, 0.5, -260)
		}):Play()
		requestItems:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 100, 0, 100)
		}):Play()
		delay(0.3, function()
			refs.screenGui.Enabled = false
			refs.toggleBtn.Visible = true
		end)
	end
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShopUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	toggleBtn.Position = UDim2.new(0, 20, 0.5, -24)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🛒"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 700, 0, 520)
	panel.Position = UDim2.new(0.5, -350, 0.5, -260)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	newUICorner(14):Parent = panel
	newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	newUICorner(12):Parent = bg
	bg.Parent = panel

	-- Diamond ornaments
	createDiamondOrnamentHelper(Theme.COLORS.Gold, 12, panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = createDiamondOrnamentHelper(Theme.COLORS.Gold, 12, panel)
	d2.Position = UDim2.new(1, -8, 0, 8)
	d2.AnchorPoint = Vector2.new(1, 0)

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	newUICorner(14):Parent = header
	header.Parent = panel

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -50, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "TOKO BARANG"
	title.Font = Theme.FONTS.Title
	title.TextSize = 26
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -24, 0, 18)
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

	-- Category tabs
	local tabContainer = Instance.new("Frame")
	tabContainer.Name = "TabContainer"
	tabContainer.Size = UDim2.new(1, -20, 0, 35)
	tabContainer.Position = UDim2.new(0, 10, 0, 10)
	tabContainer.BackgroundTransparency = 1
	tabContainer.Parent = panel

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = 8
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Parent = tabContainer

	-- Create tabs
	for _, category in ipairs(ShopData.Categories) do
		local tab = Instance.new("TextButton")
		tab.Name = "Tab_" .. category
		tab.Size = UDim2.new(0, 110, 1, 0)
		tab.BackgroundColor3 = activeCategory == category and Theme.COLORS.Gold or Theme.COLORS.Card
		tab.BorderSizePixel = 0
		tab.Font = Theme.FONTS.Label
		tab.Text = category
		tab.TextSize = 14
		tab.TextColor3 = activeCategory == category and Theme.COLORS.Void or Theme.COLORS.Bone
		tab.AutoButtonColor = false
		newUICorner(6):Parent = tab
		newUIStroke(Theme.COLORS.GoldDim, 1):Parent = tab
		tab.Parent = tabContainer

		tab.MouseButton1Click:Connect(function()
			for _, other in ipairs(tabContainer:GetChildren()) do
				if other:IsA("TextButton") then
					local isActive = other.Name == tab.Name
					other.BackgroundColor3 = isActive and Theme.COLORS.Gold or Theme.COLORS.Card
					other.TextColor3 = isActive and Theme.COLORS.Void or Theme.COLORS.Bone
				end
			end
			activeCategory = category
			populateGrid()
		end)
	end

	-- Grid
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -20, 1, -80)
	grid.Position = UDim2.new(0, 10, 0, 55)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, -24, 0, 110)
	layout.CellPadding = UDim2.new(0, 8, 0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = grid

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.CanvasSize = UDim2.new(0, 0, 0, math.max(grid.AbsoluteContentSize.Y + 20, 0))
	end)

	-- Notify label
	local notifyLabel = Instance.new("TextLabel")
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Size = UDim2.new(1, -20, 0, 20)
	notifyLabel.Position = UDim2.new(0, 10, 1, -25)
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Font = Theme.FONTS.Body
	notifyLabel.TextSize = 13
	notifyLabel.TextColor3 = Theme.COLORS.JadeGlow
	notifyLabel.Text = ""
	notifyLabel.Parent = panel

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		closeBtn = closeBtn,
		tabContainer = tabContainer,
		grid = grid,
		layout = layout,
		notifyLabel = notifyLabel,
	}
end

-- Populate grid
local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	for _, item in ipairs(shopItems) do
		if item.Category == activeCategory then
			local card = Instance.new("Frame")
			card.Name = "Card_" .. item.Id
			card.Size = UDim2.new(1, -24, 0, 110)
			card.BackgroundColor3 = item.Owned and Theme.COLORS.Indigo or Theme.COLORS.Card
			card.BorderSizePixel = 0
			card.BackgroundTransparency = item.Owned and 0.3 or 0
			card.Parent = refs.grid
			newUICorner(8):Parent = card
			newUIStroke(Theme.COLORS.GoldDim, 1):Parent = card

			-- Icon
			local icon = Instance.new("ImageLabel")
			icon.Name = "Icon"
			icon.Size = UDim2.new(0, 45, 0, 45)
			icon.Position = UDim2.new(0, 6, 0, 6)
			icon.BackgroundTransparency = 1
			icon.Image = item.IconImage or ""
			icon.ImageColor3 = item.Owned and Theme.COLORS.GoldDim or Theme.COLORS.Bone
			icon.Parent = card

			-- Name
			local nameLabel = Instance.new("TextLabel")
			nameLabel.Name = "NameLabel"
			nameLabel.Size = UDim2.new(1, -58, 0, 20)
			nameLabel.Position = UDim2.new(0, 56, 0, 4)
			nameLabel.BackgroundTransparency = 1
			nameLabel.Font = Theme.FONTS.Label
			nameLabel.TextSize = 14
			nameLabel.TextColor3 = Theme.COLORS.Bone
			nameLabel.Text = item.Name
			nameLabel.TextXAlignment = Enum.TextXAlignment.Left
			nameLabel.Parent = card

			-- Price
			local priceText = ""
			if item.Price.Rupiah and item.Price.Rupiah > 0 then
				priceText = priceText .. item.Price.Rupiah .. " 🪙"
			end
			if item.Price.Gems and item.Price.Gems > 0 then
				if priceText ~= "" then priceText = priceText .. " +" end
				priceText = priceText .. " " .. item.Price.Gems .. " 💎"
			end

			local priceLabel = Instance.new("TextLabel")
			priceLabel.Name = "PriceLabel"
			priceLabel.Size = UDim2.new(1, -58, 0, 16)
			priceLabel.Position = UDim2.new(0, 56, 0, 24)
			priceLabel.BackgroundTransparency = 1
			priceLabel.Font = Theme.FONTS.Number
			priceLabel.TextSize = 13
			priceLabel.TextColor3 = Theme.COLORS.Gold
			priceLabel.Text = priceText
			priceLabel.TextXAlignment = Enum.TextXAlignment.Left
			priceLabel.Parent = card

			-- Buy button
			local buyBtn = Instance.new("TextButton")
			buyBtn.Name = "BuyBtn"
			buyBtn.Size = UDim2.new(0, 66, 0, 24)
			buyBtn.Position = UDim2.new(1, -70, 0, 83)
			buyBtn.BackgroundColor3 = item.Owned and Theme.COLORS.GoldDim : lerp(Theme.COLORS.Gold, 1, 1)
			buyBtn.BorderSizePixel = 0
			buyBtn.Font = Theme.FONTS.Label
			buyBtn.Text = item.Owned and "DIMILIKI" : lerp("BELI", 1, 1)
			buyBtn.TextSize = 12
			buyBtn.TextColor3 = item.Owned and Theme.COLORS.Void : lerp(Theme.COLORS.Bone, 1, 1)
			buyBtn.AutoButtonColor = false
			buyBtn.Visible = not item.Owned
			newUICorner(4):Parent = buyBtn
			newUIStroke(Theme.COLORS.GoldDim, 1):Parent = buyBtn
			buyBtn.Parent = card

			buyBtn.MouseButton1Click:Connect(function()
				buyItem:FireServer(item.Id)
			end)
		end
	end
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	itemsResponse.OnClientEvent:Connect(function(items)
		shopItems = items
		populateGrid()
	end)

	purchaseResult.OnClientEvent:Connect(function(itemId, success, item)
		if success and refs.notifyLabel then
			refs.notifyLabel.Text = (" Berhasil membeli: %s"):format(item.Name)
			delay(3, function()
				if refs.notifyLabel then
					refs.notifyLabel.Text = ""
				end
			end)
		end
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("ShopUI") then
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