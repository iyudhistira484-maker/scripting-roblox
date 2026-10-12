-- EquipmentUI.lua
-- Antarmuka klien untuk Equipment (Alat Berburu)
-- Letakkan di: StarterPlayer/StarterPlayerScripts/EquipmentUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Modules
local Theme = require(ReplicatedStorage.Modules.Theme)
local EquipmentData = require(ReplicatedStorage.Modules.EquipmentData)
local UIHelpers = require(ReplicatedStorage.Modules.EquipmentUIHelpers)

-- Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Equipment")
local equipEvent = remotes:WaitForChild("EquipItem")
local unequipEvent = remotes:WaitForChild("UnequipItem")
local requestInventory = remotes:WaitForChild("RequestInventory")
local inventoryResponse = remotes:WaitForChild("InventoryResponse")
local equipmentUpdated = remotes:WaitForChild("EquipmentUpdated")

-- State
local isOpen = false
local inventoryItems = {}
local equippedItems = {}
local activeCategory = "Senjata"

-- References
local refs = {}

-- Categories
local CATEGORIES = {"Senjata", "Pelindung", "Alat"}

-- ========================================
-- Build UI
-- ========================================
local function build()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EquipmentUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 44, 0, 44)
	toggleBtn.Position = UDim2.new(0, 66, 0.5, -22)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "⚔️"
	toggleBtn.TextSize = 18
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	UIHelpers.newUICorner(8):Parent = toggleBtn
	UIHelpers.newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn

	-- Main panel
	local panel = Instance.new("Frame")
	panel.Name = "MainPanel"
	panel.Size = UDim2.new(0, 500, 0, 450)
	panel.Position = UDim2.new(0.5, -250, 0.5, -225)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	UIHelpers.newUICorner(14):Parent = panel
	UIHelpers.newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	UIHelpers.newUICorner(12):Parent = bg
	bg.Parent = panel

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
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
	title.Text = "INVENTORI ALAT"
	title.Font = Theme.FONTS.Title
	title.TextSize = 24
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 20, 0, 20)
	closeBtn.Position = UDim2.new(1, -24, 0, 15)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card
	closeBtn.BorderSizePixel = 0
	closeBtn.Font = Theme.FONTS.Label
	closeBtn.Text = "✕"
	closeBtn.TextSize = 16
	closeBtn.TextColor3 = Theme.COLORS.Bone
	closeBtn.AutoButtonColor = false
	UIHelpers.newUICorner(3):Parent = closeBtn
	UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
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
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Padding = 8
	tabLayout.Parent = tabContainer

	-- Create category tabs
	for _, category in ipairs(CATEGORIES) do
		local tab = Instance.new("TextButton")
		tab.Name = "Tab_" .. category
		tab.Size = UDim2.new(0, 110, 1, 0)
		tab.BackgroundColor3 = (category == activeCategory and Theme.COLORS.Gold or Theme.COLORS.Card)
		tab.BorderSizePixel = 0
		tab.Font = Theme.FONTS.Label
		tab.Text = category
		tab.TextSize = 14
		tab.TextColor3 = (category == activeCategory and Theme.COLORS.Void or Theme.COLORS.Bone)
		tab.AutoButtonColor = false
		UIHelpers.newUICorner(6):Parent = tab
		UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = tab
		tab.Parent = tabContainer

		tab.MouseButton1Click:Connect(function()
			for _, otherTab in ipairs(tabContainer:GetChildren()) do
				if otherTab:IsA("TextButton") then
					local isActive = otherTab.Name == tab.Name
					otherTab.BackgroundColor3 = isActive and Theme.COLORS.Gold or Theme.COLORS.Card
					otherTab.TextColor3 = isActive and Theme.COLORS.Void or Theme.COLORS.Bone
				end
			end
			activeCategory = category
			populateGrid()
		end)
	end

	-- Grid container
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -20, 1, -110)
	grid.Position = UDim2.new(0, 10, 0, 100)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(1, -24, 0, 110)
	gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = grid

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.CanvasSize = UDim2.new(0, 0, 0, math.max(grid.AbsoluteContentSize.Y + 20, 0))
	end)

	-- Equipped slots (right side)
	local equipPanel = Instance.new("Frame")
	equipPanel.Name = "EquipPanel"
	equipPanel.Size = UDim2.new(0, 130, 1, -120)
	equipPanel.Position = UDim2.new(1, -20, 0, 110)
	equipPanel.BackgroundColor3 = Theme.COLORS.Card
	equipPanel.BorderSizePixel = 0
	equipPanel.Visible = false
	equipPanel.Parent = panel
	UIHelpers.newUICorner(10):Parent = equipPanel

	-- Equipped label
	local equipLabel = Instance.new("TextLabel")
	equipLabel.Name = "EquipLabel"
	equipLabel.Size = UDim2.new(1, -10, 0, 20)
	equipLabel.Position = UDim2.new(0, 5, 0, 5)
	equipLabel.BackgroundTransparency = 1
	equipLabel.Font = Theme.FONTS.Label
	equipLabel.TextSize = 14
	equipLabel.TextColor3 = Theme.COLORS.Gold
	equipLabel.Text = "DI PAKAI"
	equipLabel.Parent = equipPanel

	-- Store references
	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		closeBtn = closeBtn,
		tabContainer = tabContainer,
		grid = grid,
		gridLayout = gridLayout,
		equipPanel = equipPanel,
		equipLabel = equipLabel,
	}

		return screenGui, refs
	end

	-- ========================================
	-- Populate Grid
	-- ========================================
	local function populateGrid()
		-- Clear existing children except layout
		for _, child in ipairs(refs.grid:GetChildren()) do
			if not child:IsA("UIGridLayout") then
				child:Destroy()
			end
		end

		-- Get items for active category
		for _, item in ipairs(inventoryItems) do
			if item.Category == activeCategory then
				local card = Instance.new("Frame")
				card.Name = "Card_" .. item.Id
				card.Size = UDim2.new(1, -24, 0, 110)
				card.BackgroundColor3 = Theme.COLORS.Indigo
				card.BorderSizePixel = 0
				card.BackgroundTransparency = 0
				card.Parent = refs.grid

				UIHelpers.newUICorner(8):Parent = card

				local rarity = EquipmentData:GetRarityByName(item.Rarity)
				UIHelpers.newUIStroke(rarity.Color, 1):Parent = card

				-- Icon
				local icon = Instance.new("ImageLabel")
				icon.Name = "Icon"
				icon.Size = UDim2.new(0, 45, 0, 45)
				icon.Position = UDim2.new(0, 6, 0, 6)
				icon.BackgroundTransparency = 1
				icon.Image = item.IconImage or ""
				icon.Parent = card

				-- Name label
				local nameLabel = Instance.new("TextLabel")
				nameLabel.Name = "NameLabel"
				nameLabel.Size = UDim2.new(1, -56, 0, 18)
				nameLabel.Position = UDim2.new(0, 56, 0, 5)
				nameLabel.BackgroundTransparency = 1
				nameLabel.Font = Theme.FONTS.Label
				nameLabel.TextSize = 14
				nameLabel.TextColor3 = rarity.Color
				nameLabel.Text = item.Name
				nameLabel.TextXAlignment = Enum.TextXAlignment.Left
				nameLabel.Parent = card

				-- Stats label
				local statsLabel = Instance.new("TextLabel")
				statsLabel.Name = "StatsLabel"
				statsLabel.Size = UDim2.new(1, -56, 0, 16)
				statsLabel.Position = UDim2.new(0, 56, 0, 23)
				statsLabel.BackgroundTransparency = 1
				statsLabel.Font = Theme.FONTS.Number
				statsLabel.TextSize = 12
				statsLabel.TextColor3 = Theme.COLORS.BoneDim
				local statText = ""
				if item.Stats.Damage then
					statText = statText .. "Dmg: " .. item.Stats.Damage .. "  "
				end
				if item.Stats.Defense then
					statText = statText .. "Def: " .. item.Stats.Defense .. "  "
				end
				if item.Stats.Radius then
					statText = statText .. "Rng: " .. item.Stats.Radius .. "  "
				end
				if item.Stats.Durability then
					statText = statText .. "Dur: " .. item.Stats.Durability
				end
				statsLabel.Text = statText
				statsLabel.TextXAlignment = Enum.TextXAlignment.Left
				statsLabel.Parent = card

				-- Equip button
				local equipBtn = Instance.new("TextButton")
				equipBtn.Name = "EquipBtn"
				equipBtn.Size = UDim2.new(0, 60, 0, 24)
				equipBtn.Position = UDim2.new(1, -64, 0, 7)
				equipBtn.BackgroundColor3 = item.Equipped and Theme.COLORS.Gold or Theme.COLORS.GoldDim
				equipBtn.BorderSizePixel = 0
				equipBtn.Font = Theme.FONTS.Label
				equipBtn.Text = item.Equipped and "Pasang" or "Pakai"
				equipBtn.TextSize = 12
				equipBtn.TextColor3 = item.Equipped and Theme.COLORS.Void or Theme.COLORS.Bone
				equipBtn.AutoButtonColor = false
				UIHelpers.newUICorner(4):Parent = equipBtn
				UIHelpers.newUIStroke(Theme.COLORS.GoldDim, 1):Parent = equipBtn
				equipBtn.Parent = card

				equipBtn.MouseButton1Click:Connect(function()
					equipEvent:FireServer(item.Id, item.Category)
					equipBtn.BackgroundColor3 = Theme.COLORS.Gold
					equipBtn.TextColor3 = Theme.COLORS.Void
					equipBtn.Text = "Pasang"
				end)

				-- Hover effect (show stats tooltip)
				local hoverTimer = 0
				card.MouseEnter:Connect(function()
					hoverTimer = tick()
				end)
				card.MouseLeave:Connect(function()
					hoverTimer = 0
				end)
				card.MouseButton1Click:Connect(function()
					if tick() - hoverTimer > 0.1 then
						-- Quick click to view details
					end
				end)
			end
		end

		-- Update grid canvas size
		refs.grid.CanvasSize = UDim2.new(0, 0, 0, math.max(refs.grid.AbsoluteContentSize.Y, 0))
	end

	-- ========================================
	-- Event Handlers
	-- ========================================
	local function toggleUI()
		isOpen = not isOpen
		if isOpen then
			refs.screenGui.Enabled = true
			-- Request inventory from server
			requestInventory:FireServer()
			-- Show panel with animation
			refs.panel.Size = UDim2.new(0, 0, 0, 1)
			UIHelpers.tween(refs.panel, {Size = UDim2.new(0, 500, 0, 450)}, 0.4)
			UIHelpers.tween(refs.toggleBtn, {TextColor3 = Theme.COLORS.JadeGlow}, 0.2)
		else
			UIHelpers.tween(refs.panel, {Size = UDim2.new(0, 0, 0, 1)}, 0.4)
			UIHelpers.tween(refs.toggleBtn, {TextColor3 = Theme.COLORS.Gold}, 0.2)
			wait(0.4)
			refs.screenGui.Enabled = false
		end
	end

	local function setupEvents()
		-- Toggle button
		refs.toggleBtn.MouseButton1Click:Connect(toggleUI)

		-- Close button
		refs.closeBtn.MouseButton1Click:Connect(function()
			toggleUI()
		end)

		-- Keyboard toggle (E key by default, can be customized)
		UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then return end
			if input.KeyCode == Enum.KeyCode.B then
				if not isOpen then
					toggleUI()
				end
			end
		end)

		-- Handle inventory response from server
		inventoryResponse.OnClientEvent:Connect(function(itemList, equippedList)
			inventoryItems = itemList
			equippedItems = equippedList
			populateGrid()
		end)

		-- Handle equipment updated from server
		equipmentUpdated.OnClientEvent:Connect(function(category, itemId, stats)
			-- Update local state
			if itemId then
				equippedItems[category] = itemId
			else
				equippedItems[category] = nil
			end
			-- Refresh grid
			for _, item in ipairs(inventoryItems) do
				if item.Category == category then
					item.Equipped = (item.Id == itemId)
				end
			end
			populateGrid()
		end)
	end

	-- ========================================
	-- Init
	-- ========================================
	local function init()
		if not refs.screenGui then
			build()
		end
		ui = refs.screenGui

		if not ui.Parent then
			ui.Parent = playerGui
		end

		setupEvents()
	end

	-- Run init
	init()

	-- Export
	return {
		Toggle = function()
			if refs.screenGui then
				toggleUI()
			end
		end,
	}
