-- SkinUI.lua
-- Galeri skin dengan preview 3D
-- Letakkan di: StarterPlayer/StarterPlayerScripts/SkinUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local SkinData = require(ReplicatedStorage.Modules.SkinData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Skin")
local requestSkins = remotes:WaitForChild("RequestSkins")
local skinsResponse = remotes:WaitForChild("SkinsResponse")
local equipSkin = remotes:WaitForChild("EquipSkin")
local skinEquipped = remotes:WaitForChild("SkinEquipped")

local ui, refs = nil, {}
local isOpen = false
local skinList = {}
local activeCategory = "Character"
local showOwnedOnly = false
local selectedSkin = nil

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end
local function ornament(col, sz, p) local d = UIHelpers.createDiamondOrnament(col, sz); d.Parent = p; return d end

local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, -350, 0.5, -260)
		}):Play()
		requestSkins:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 100, 0, 100)
		}):Play()
		delay(0.3, function() refs.screenGui.Enabled = false; refs.toggleBtn.Visible = true end)
	end
end

local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkinUI"; screenGui.ResetOnSpawn = false; screenGui.Enabled = false

	refs.toggleBtn = Instance.new("TextButton")
	refs.toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	refs.toggleBtn.Position = UDim2.new(0, 20, 0.5, -24)
	refs.toggleBtn.BackgroundColor3 = Theme.COLORS.Card; refs.toggleBtn.Text = "👗"
	refs.toggleBtn.Font = Theme.FONTS.Label; refs.toggleBtn.TextSize = 20
	refs.toggleBtn.TextColor3 = Theme.COLORS.Crimson; refs.toggleBtn.AutoButtonColor = false
	refs.toggleBtn.Parent = screenGui
	newUICorner(8):Parent = refs.toggleBtn; newUIStroke(Theme.COLORS.Crimson, 1):Parent = refs.toggleBtn

	refs.panel = Instance.new("Frame")
	refs.panel.Size = UDim2.new(0, 700, 0, 520)
	refs.panel.Position = UDim2.new(0.5, -350, 0.5, -260)
	refs.panel.BackgroundColor3 = Theme.COLORS.Panel; refs.panel.BorderSizePixel = 0
	newUICorner(16):Parent = refs.panel; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.panel
	refs.panel.Parent = screenGui

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -2, 1, -2); bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep; bg.BorderSizePixel = 0
	newUICorner(14):Parent = bg; bg.Parent = refs.panel
	ornament(Theme.COLORS.Gold, 12, refs.panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = ornament(Theme.COLORS.Gold, 12, refs.panel); d2.Position = UDim2.new(1, -8, 0, 8); d2.AnchorPoint = Vector2.new(1, 0)

	refs.header = Instance.new("Frame")
	refs.header.Size = UDim2.new(1, 0, 0, 50); refs.header.BackgroundColor3 = Theme.COLORS.Indigo; refs.header.BorderSizePixel = 0
	newUICorner(16):Parent = refs.header; refs.header.Parent = refs.panel

	refs.title = Instance.new("TextLabel")
	refs.title.Size = UDim2.new(1, -50, 1, -10); refs.title.Position = UDim2.new(0, 10, 0, 5)
	refs.title.BackgroundTransparency = 1; refs.title.Font = Theme.FONTS.Title; refs.title.TextSize = 24
	refs.title.TextColor3 = Theme.COLORS.Gold; refs.title.Text = " GALLERI KOSTUM "
	refs.title.TextXAlignment = Enum.TextXAlignment.Left; refs.title.Parent = refs.header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 14)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card; closeBtn.Text = "✕"; closeBtn.Font = Theme.FONTS.Label
	closeBtn.TextSize = 16; closeBtn.TextColor3 = Theme.COLORS.Bone; closeBtn.AutoButtonColor = false
	newUICorner(3):Parent = closeBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = refs.header

	-- Category tabs
	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(1, -20, 0, 30); tabContainer.Position = UDim2.new(0, 10, 0, 5)
	tabContainer.BackgroundTransparency = 1; tabContainer.Parent = refs.panel

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal; tabLayout.Padding = 6
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; tabLayout.Parent = tabContainer

	local categories = {"Character", "Weapon", "Tool"}
	for _, cat in ipairs(categories) do
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 80, 1, 0); tab.BackgroundColor3 = activeCategory == cat and Theme.COLORS.Gold or Theme.COLORS.Card
		tab.Text = cat; tab.Font = Theme.FONTS.Label; tab.TextSize = 12
		tab.TextColor3 = activeCategory == cat and Theme.COLORS.Void or Theme.COLORS.Bone
		tab.AutoButtonColor = false; newUICorner(4):Parent = tab; tab.Parent = tabContainer
		tab.MouseButton1Click:Connect(function() activeCategory = cat; populateGrid() end)
	end

	-- Filter toggle
	local filterBtn = Instance.new("TextButton")
	filterBtn.Size = UDim2.new(0, 90, 0, 24); filterBtn.Position = UDim2.new(1, -100, 0, 5)
	filterBtn.BackgroundColor3 = showOwnedOnly and Theme.COLORS.Gold or Theme.COLORS.Card
	filterBtn.Text = showOwnedOnly and "DIMILIKI" or "SEMUA"; filterBtn.Font = Theme.FONTS.Label
	filterBtn.TextSize = 11; filterBtn.TextColor3 = showOwnedOnly and Theme.COLORS.Void or Theme.COLORS.Bone
	filterBtn.AutoButtonColor = false; newUICorner(4):Parent = filterBtn
	filterBtn.Parent = refs.header
	filterBtn.MouseButton1Click:Connect(function()
		showOwnedOnly = not showOwnedOnly
		filterBtn.BackgroundColor3 = showOwnedOnly and Theme.COLORS.Gold or Theme.COLORS.Card
		filterBtn.TextColor3 = showOwnedOnly and Theme.COLORS.Void or Theme.COLORS.Bone
		filterBtn.Text = showOwnedOnly and "DIMILIKI" or "SEMUA"
		populateGrid()
	end)

	-- 3D Preview viewport
	refs.previewView = Instance.new("Frame")
	refs.previewView.Size = UDim2.new(0, 200, 0, 200); refs.previewView.Position = UDim2.new(0, 10, 0, 90)
	refs.previewView.BackgroundColor3 = Theme.COLORS.Indigo; refs.previewView.BorderSizePixel = 0
	newUICorner(8):Parent = refs.previewView; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = refs.previewView
	refs.previewView.Parent = refs.panel

	-- Grid for skin list
	refs.grid = Instance.new("ScrollingFrame")
	refs.grid.Size = UDim2.new(0, 450, 1, -280); refs.grid.Position = UDim2.new(0, 220, 0, 90)
	refs.grid.BackgroundTransparency = 1; refs.grid.BorderSizePixel = 0; refs.grid.ScrollBarThickness = 6
	refs.grid.CanvasSize = UDim2.new(0, 0, 1, 0); refs.grid.Parent = refs.panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, -14, 0, 60); layout.CellPadding = UDim2.new(0, 4, 0, 4)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.Parent = refs.grid
	refs.grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refs.grid.CanvasSize = UDim2.new(0, 0, 0, math.max(refs.grid.AbsoluteContentSize.Y + 10, 0))
	end)

	-- Equip button
	refs.equipBtn = Instance.new("TextButton")
	refs.equipBtn.Size = UDim2.new(0, 200, 0, 36); refs.equipBtn.Position = UDim2.new(0, 10, 1, -40)
	refs.equipBtn.BackgroundColor3 = Theme.COLORS.Gold; refs.equipBtn.BorderSizePixel = 0
	refs.equipBtn.Font = Theme.FONTS.Label; refs.equipBtn.Text = "PAKAI"; refs.equipBtn.TextSize = 14
	refs.equipBtn.TextColor3 = Theme.COLORS.Void; refs.equipBtn.AutoButtonColor = false
	refs.equipBtn.Visible = false
	newUICorner(6):Parent = refs.equipBtn

	refs.closeBtn = closeBtn; refs.screenGui = screenGui

	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(toggleUI)

	skinsResponse.OnClientEvent:Connect(function(skins)
		skinList = skins
		populateGrid()
	end)

	skinEquipped.OnClientEvent:Connect(function(skinId, category)
		selectedSkin = nil
		refs.equipBtn.Visible = false
	end)
end

local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then child:Destroy() end
	end

	for _, skin in ipairs(skinList) do
		if skin.Category == activeCategory then
			if not showOwnedOnly or skin.Owned then
				local rarityColor = SkinData:GetRarityColor(skin.Rarity)
				local card = Instance.new("TextButton")
				card.Name = "Skin_" .. skin.Id
				card.Size = UDim2.new(1, -14, 0, 56)
				card.BackgroundColor3 = skin.Active and Theme.COLORS.Gold or Theme.COLORS.Card
				card.BorderSizePixel = 0
				card.Font = Theme.FONTS.Label
				card.Text = skin.Name
				card.TextSize = 12
				card.TextColor3 = skin.Active and Theme.COLORS.Void : lerp(rarityColor, 1, 1)
				card.AutoButtonColor = false
				newUICorner(6):Parent = card
				local stroke = newUIStroke(rarityColor, 1); stroke.Enabled = not skin.Owned; stroke.Parent = card
				card.Parent = refs.grid

				card.MouseButton1Click:Connect(function()
					selectedSkin = skin
					refs.equipBtn.Visible = true
					refs.equipBtn.Text = skin.Active and "SUDAH PAKAI" or "PASANG"
					refs.equipBtn.BackgroundColor3 = skin.Active and Theme.COLORS.GoldDim : lerp(Theme.COLORS.Gold, 1, 1)
				end)

				refs.equipBtn.MouseButton1Click:Connect(function()
					if selectedSkin and not selectedSkin.Active then
						equipSkin:FireServer(selectedSkin.Id)
					end
				end)
			end
		end
	end
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		if not playerGui:FindFirstChild("SkinUI") then
			ui.Parent = playerGui
		end
	end
end

init()

return { Toggle = function() if ui then toggleUI() end end }
