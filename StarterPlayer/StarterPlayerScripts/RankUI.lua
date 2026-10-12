-- RankUI.lua
-- Antarmuka klien untuk Rank / Title (Pangkat)
-- Letakkan di: StarterPlayer/StarterPlayerScripts/RankUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local RankData = require(ReplicatedStorage.Modules.RankData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Rank")
local requestRanks = remotes:WaitForChild("RequestRanks")
local ranksResponse = remotes:WaitForChild("RanksResponse")
local rankUpdated = remotes:WaitForChild("RankUpdated")

-- State
local ui = nil
local refs = {}
local isOpen = false
local unlockedRanks = {}
local activeRankId = ""

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
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -260)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 650, 0, 520),
			Position = UDim2.new(0.5, -325, 0.5, -260)
		}):Play()
		requestRanks:FireServer()
		-- Sembunyikan toggle button
		refs.toggleBtn.Visible = false
		refs.toggleBtn.BackgroundTransparency = 1
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1),
			Position = UDim2.new(0.5, 0, 0.5, -260)
		}):Play()
		delay(0.5, function()
			refs.screenGui.Enabled = false
			refs.toggleBtn.Visible = true
			refs.toggleBtn.BackgroundTransparency = 0
		end)
	end
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RankUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 44, 0, 44)
	toggleBtn.Position = UDim2.new(1, -70, 0.5, -22)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🏅"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn

	-- Panel utama
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 650, 0, 520)
	panel.Position = UDim2.new(0.5, -325, 0.5, -260)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	newUICorner(14):Parent = panel
	newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background dalam
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	newUICorner(12):Parent = bg
	bg.Parent = panel

	-- Diamond ornaments di sudut
	local ornamentPositions = {
		{UDim2.new(0, 8, 0, 8), Vector2.new(0, 0)},
		{UDim2.new(1, -8, 0, 8), Vector2.new(1, 0)},
		{UDim2.new(0, 8, 1, -8), Vector2.new(0, 1)},
		{UDim2.new(1, -8, 1, -8), Vector2.new(1, 1)},
	}
	for _, entry in ipairs(ornamentPositions) do
		local pos, anchor = entry[1], entry[2]
		local d = createDiamondOrnamentHelper(Theme.COLORS.Gold, 12, panel)
		d.Position = pos
		d.AnchorPoint = anchor
	end

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Theme.COLORS.Indigo
	header.BorderSizePixel = 0
	newUICorner(14):Parent = header
	header.Parent = panel

	-- Judul
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -50, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "GELARAN PEMBUNUH"
	title.Font = Theme.FONTS.Title
	title.TextSize = 26
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Tombol tutup
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

	-- Grid untuk kartu rank
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -20, 1, -80)
	grid.Position = UDim2.new(0, 10, 0, 70)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, 0, 0, 90)
	layout.CellPadding = UDim2.new(0, 0, 0, 8)
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

-- Populate grid dengan kartu rank
local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	for _, rank in ipairs(unlockedRanks) do
		local isActive = (rank.Id == activeRankId)
		local rarityColor = rank.Color

		local card = Instance.new("Frame")
		card.Name = "Card_" .. rank.Id
		card.Size = UDim2.new(1, 0, 0, 90)
		card.BackgroundColor3 = isActive and Theme.COLORS.Gold or Theme.COLORS.Indigo
		card.BorderSizePixel = 0
		card.BackgroundTransparency = isActive and 0.3 or 0
		card.Parent = refs.grid

		newUICorner(8):Parent = card
		newUIStroke(rarityColor, isActive and 3 or 1):Parent = card

		-- Icon
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 45, 0, 45)
		icon.Position = UDim2.new(0, 6, 0, 6)
		icon.BackgroundTransparency = 1
		icon.Image = rank.IconImage or ""
		icon.ImageColor3 = isActive and Theme.COLORS.Void or Theme.COLORS.Bone
		icon.Parent = card

		-- Name label
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -60, 0, 20)
		nameLabel.Position = UDim2.new(0, 56, 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.FONTS.Label
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = isActive and Theme.COLORS.Void or rarityColor
		nameLabel.Text = rank.Name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Description
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "DescLabel"
		descLabel.Size = UDim2.new(1, -60, 0, 16)
		descLabel.Position = UDim2.new(0, 56, 0, 24)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Theme.FONTS.Body
		descLabel.TextSize = 12
		descLabel.TextColor3 = Theme.COLORS.BoneDim
		descLabel.Text = rank.Description
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = card

		-- Select button (hanya untuk yang belum aktif)
		if not isActive then
			local selectBtn = Instance.new("TextButton")
			selectBtn.Name = "SelectBtn"
			selectBtn.Size = UDim2.new(0, 60, 0, 24)
			selectBtn.Position = UDim2.new(1, -64, 0, 7)
			selectBtn.BackgroundColor3 = Theme.COLORS.Gold
			selectBtn.BorderSizePixel = 0
			selectBtn.Font = Theme.FONTS.Label
			selectBtn.Text = "Pilih"
			selectBtn.TextSize = 12
			selectBtn.TextColor3 = Theme.COLORS.Void
			selectBtn.AutoButtonColor = false
			newUICorner(4):Parent = selectBtn
			newUIStroke(Theme.COLORS.GoldDim, 1):Parent = selectBtn
			selectBtn.Parent = card

			selectBtn.MouseButton1Click:Connect(function()
				remotes:WaitForChild("SelectRank"):FireServer(rank.Id)
				-- Preview feedback
				TweenService:Create(selectBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.GoldHi}):Play()
				delay(0.2, function()
					if selectBtn and selectBtn.Parent then
						selectBtn.BackgroundColor3 = Theme.COLORS.Gold
					end
				end)
			end)
		end

		-- Hover effect
		card.MouseEnter:Connect(function()
			if not isActive then
				TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Indigo}):Play()
			end
		end)
		card.MouseLeave:Connect(function()
			if not isActive then
				TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Indigo}):Play()
			end
		end)
	end
end

-- Show toast for new rank unlocked
local function showRankToast(rank)
	if not rank then return end

	local toast = Instance.new("Frame")
	toast.Name = "RankToast"
	toast.Size = UDim2.new(0, 300, 0, 70)
	toast.BackgroundColor3 = Theme.COLORS.Card
	toast.BorderSizePixel = 0
	toast.BackgroundTransparency = 1
	toast.Position = UDim2.new(0.5, -150, 0, 20)
	toast.Parent = refs.screenGui
	newUICorner(10):Parent = toast
	newUIStroke(rank.Color, 2):Parent = toast

	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0, 8, 0, 8)
	icon.BackgroundTransparency = 1
	icon.Image = rank.IconImage or ""
	icon.Parent = toast

	-- Title
	local toastTitle = Instance.new("TextLabel")
	toastTitle.Name = "Title"
	toastTitle.Size = UDim2.new(1, -60, 0, 20)
	toastTitle.Position = UDim2.new(0, 52, 0, 6)
	toastTitle.BackgroundTransparency = 1
	toastTitle.Font = Theme.FONTS.Label
	toastTitle.TextSize = 16
	toastTitle.TextColor3 = Theme.COLORS.Gold
	toastTitle.Text = "Gelaran Baru: " .. rank.Name
	toastTitle.TextXAlignment = Enum.TextXAlignment.Left
	toastTitle.Parent = toast

	-- Description
	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.new(1, -60, 0, 16)
	desc.Position = UDim2.new(0, 52, 0, 26)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.FONTS.Body
	desc.TextSize = 12
	desc.TextColor3 = Theme.COLORS.BoneDim
	desc.Text = rank.Description
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = toast

	-- Auto-hide after 3 seconds
	delay(3, function()
		if toast and toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
			delay(0.5, function()
				if toast and toast.Parent then
					toast:Destroy()
				end
			end)
		end
	end)
end

-- Setup event handlers
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	ranksResponse.OnClientEvent:Connect(function(data)
		unlockedRanks = data.Ranks or {}
		activeRankId = data.ActiveRank or ""
		populateGrid()
	end)

	rankUpdated.OnClientEvent:Connect(function(rankId, isNewUnlock, rankData)
		if isNewUnlock and rankData then
			showRankToast(rankData)
		end
		if rankId then
			activeRankId = rankId
			populateGrid()
		end
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("RankUI") then
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