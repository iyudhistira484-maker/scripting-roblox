-- AchievementUI.lua
-- Antarmuka klien untuk Achievement (Pencapaian)
-- Letakkan di: StarterPlayer/StarterPlayerScripts/AchievementUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local AchievementData = require(ReplicatedStorage.Modules.AchievementData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Achievement")
local requestProgress = remotes:WaitForChild("RequestProgress")
local progressResponse = remotes:WaitForChild("ProgressResponse")
local achievementUnlocked = remotes:WaitForChild("AchievementUnlocked")

-- State
local ui = nil
local refs = {}
local isOpen = false
local achievementList = {}
local unlockedIds = {}
local currentToast = nil

-- Fungsi bantu UI
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

-- Buat UI dasar
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "AchievementUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button (di samping layar)
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 44, 0, 44)
	toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🏆"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn

	-- Panel utama
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 700, 0, 520)
	panel.Position = UDim2.new(0.5, -350, 0.5, -260)
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
	title.Text = "PENCA PATIAN"
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

	-- Progress bar container (jumlah achievement terkunci)
	local progressBox = Instance.new("Frame")
	progressBox.Name = "ProgressBox"
	progressBox.Size = UDim2.new(1, -40, 0, 30)
	progressBox.Position = UDim2.new(0, 20, 0, 45)
	progressBox.BackgroundColor3 = Theme.COLORS.Card
	progressBox.BorderSizePixel = 0
	newUICorner(6):Parent = progressBox
	progressBox.Parent = panel

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.COLORS.Gold
	fill.BorderSizePixel = 0
	newUICorner(6):Parent = fill
	fill.Parent = progressBox

	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, 0, 1, 0)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Font = Theme.FONTS.Number
	progressLabel.TextSize = 14
	progressLabel.TextColor3 = Theme.COLORS.Bone
	progressLabel.Text = "0 / 0"
	progressLabel.Parent = progressBox

	-- Grid container untuk kartu achievement
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -20, 1, -90)
	grid.Position = UDim2.new(0, 10, 0, 80)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.CanvasSize = UDim2.new(0, 0, 1, 0)
	grid.Parent = panel

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1, 0, 0, 100)
	layout.CellPadding = UDim2.new(0, 0, 0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = grid

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.CanvasSize = UDim2.new(0, 0, 0, math.max(grid.AbsoluteContentSize.Y + 20, 0))
	end)

	-- Toast notification container
	local toastContainer = Instance.new("Frame")
	toastContainer.Name = "ToastContainer"
	toastContainer.Size = UDim2.new(0, 320, 0, 100)
	toastContainer.Position = UDim2.new(0.5, -160, 0, 20)
	toastContainer.BackgroundTransparency = 1
	toastContainer.BorderSizePixel = 0
	toastContainer.Parent = screenGui

	-- Simpan referensi
	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		bg = bg,
		header = header,
		title = title,
		closeBtn = closeBtn,
		fill = fill,
		progressLabel = progressLabel,
		grid = grid,
		layout = layout,
		toastContainer = toastContainer,
	}
end

-- Populate grid dengan kartu achievement
local function populateGrid()
	-- Bersihkan kartu yang ada (kecuali layout)
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	-- Update progress bar
	local total = #achievementList
	local unlockedCount = 0
	for _ in pairs(unlockedIds) do
		unlockedCount = unlockedCount + 1
	end
	refs.fill.Size = UDim2.new(math.clamp(unlockedCount / total, 0, 1), 0, 1, 0)
	refs.progressLabel.Text = ("%d / %d"):format(unlockedCount, total)

	-- Sort achievement: yang terbuka di atas, lalu berdasarkan rarity
	local sorted = {}
	for _, ach in ipairs(achievementList) do
		table.insert(sorted, ach)
	end

	-- Ciptakan kartu untuk setiap achievement
	for _, ach in ipairs(sorted) do
		local isUnlocked = unlockedIds[ach.Id] ~= nil
		local rarityColor = AchievementData:GetRarityColor(ach.Rarity)

		local card = Instance.new("Frame")
		card.Name = "Card_" .. ach.Id
		card.Size = UDim2.new(1, 0, 0, 92)
		card.BackgroundColor3 = isUnlocked and Theme.COLORS.Indigo or Theme.COLORS.Void
		card.BorderSizePixel = 0
		card.BackgroundTransparency = isUnlocked and 0 or 0.7
		card.Parent = refs.grid

		newUICorner(8):Parent = card
		newUIStroke(rarityColor, 1):Parent = card

		-- Icon achievement
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 40, 0, 40)
		icon.Position = UDim2.new(0, 6, 0, 6)
		icon.BackgroundTransparency = 1
		icon.Image = isUnlocked and (ach.IconImage or "") or ""
		icon.ImageTransparency = isUnlocked and 0 or 1
		icon.Parent = card

		-- Jika belum terkunci, tampilkan placeholder emoji
		if not isUnlocked then
			icon.Image = ""
			icon.BackgroundColor3 = Theme.COLORS.Void
			icon.BorderSizePixel = 0

			local placeholder = Instance.new("TextLabel")
			placeholder.Name = "Placeholder"
			placeholder.Size = UDim2.new(1, 0, 1, 0)
			placeholder.BackgroundTransparency = 1
			placeholder.Font = Theme.FONTS.Label
			placeholder.TextSize = 24
			placeholder.TextColor3 = Theme.COLORS.BoneDim
			placeholder.Text = ach.Icon
			placeholder.Parent = icon
		end

		-- Label nama achievement
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -58, 0, 20)
		nameLabel.Position = UDim2.new(0, 50, 0, 4)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.FONTS.Label
		nameLabel.TextSize = 14
		nameLabel.TextColor3 = isUnlocked and rarityColor or Theme.COLORS.BoneDim
		nameLabel.Text = ach.Name
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Label rarity
		local rarityLabel = Instance.new("TextLabel")
		rarityLabel.Name = "RarityLabel"
		rarityLabel.Size = UDim2.new(1, -58, 0, 14)
		rarityLabel.Position = UDim2.new(0, 50, 0, 22)
		rarityLabel.BackgroundTransparency = 1
		rarityLabel.Font = Theme.FONTS.Body
		rarityLabel.TextSize = 12
		rarityLabel.TextColor3 = rarityColor
		rarityLabel.Text = isUnlocked and (ach.Rarity .. " • TERBUKA") or (ach.Rarity .. " • TERKUNCI")
		rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
		rarityLabel.Parent = card

		-- Progress bar mini
		local miniProgress = Instance.new("Frame")
		miniProgress.Name = "MiniProgress"
		miniProgress.Size = UDim2.new(1, -58, 0, 10)
		miniProgress.Position = UDim2.new(0, 50, 0, 42)
		miniProgress.BackgroundColor3 = Theme.COLORS.IndigoDeep
		miniProgress.BorderSizePixel = 0
		newUICorner(5):Parent = miniProgress
		miniProgress.Parent = card

		-- Hitung progress persentase
		local reqValue = ach.Requirement.Value or 1
		local currentPercent = math.clamp(ach.CurrentValue or 0, 0, reqValue) / reqValue
		local miniFill = Instance.new("Frame")
		miniFill.Name = "MiniFill"
		miniFill.Size = UDim2.new(currentPercent, 0, 1, 0)
		miniFill.BackgroundColor3 = isUnlocked and rarityColor or Theme.COLORS.GoldDim
		miniFill.BorderSizePixel = 0
		newUICorner(5):Parent = miniFill
		miniFill.Parent = miniProgress

		-- Label reward
		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Name = "RewardLabel"
		rewardLabel.Size = UDim2.new(1, -58, 0, 14)
		rewardLabel.Position = UDim2.new(0, 50, 0, 58)
		rewardLabel.BackgroundTransparency = 1
		rewardLabel.Font = Theme.FONTS.Number
		rewardLabel.TextSize = 13
		rewardLabel.TextColor3 = Theme.COLORS.BoneDim
		local rewardText = "Hadiah: "
		if ach.Reward.Rupiah and ach.Reward.Rupiah > 0 then
			rewardText = rewardText .. ach.Reward.Rupiah .. " Rupiah"
		end
		if ach.Reward.Gems and ach.Reward.Gems > 0 then
			if ach.Reward.Rupiah and ach.Reward.Rupiah > 0 then
				rewardText = rewardText .. " +"
			end
			rewardText = rewardText .. " " .. ach.Reward.Gems .. " Berlian"
		end
		rewardLabel.Text = rewardText
		rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
		rewardLabel.Parent = card

		-- Tooltip hover effect
		card.MouseEnter:Connect(function()
			TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Theme.COLORS.Indigo
			}):Play()
		end)

		card.MouseLeave:Connect(function()
			TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = isUnlocked and Theme.COLORS.Indigo or Theme.COLORS.Void
			}):Play()
		end)
	end
end

-- Toast notification
local function showToast(ach)
	if not ach then return end

	-- Jika ada toast yang aktif, tunggu selesai
	if currentToast then
		currentToast:Destroy()
	end

	local rarityColor = AchievementData:GetRarityColor(ach.Rarity)

	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.new(0, 320, 0, 80)
	toast.BackgroundColor3 = Theme.COLORS.Card
	toast.BorderSizePixel = 0
	toast.BackgroundTransparency = 1
	toast.Parent = refs.toastContainer
	newUICorner(10):Parent = toast
	newUIStroke(rarityColor, 2):Parent = toast

	-- Fade in
	TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()

	-- Icon
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.Size = UDim2.new(0, 40, 0, 40)
	icon.Position = UDim2.new(0, 8, 0, 8)
	icon.BackgroundTransparency = 1
	icon.Image = ach.IconImage or ""
	icon.ImageTransparency = 0.3
	icon.Parent = toast

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 0, 24)
	title.Position = UDim2.new(0, 52, 0, 6)
	title.BackgroundTransparency = 1
	title.Font = Theme.FONTS.Label
	title.TextSize = 16
	title.TextColor3 = Theme.COLORS.Gold
	title.Text = "• " .. ach.Name .. " •"
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = toast

	-- Description
	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.new(1, -60, 0, 18)
	desc.Position = UDim2.new(0, 52, 0, 28)
	desc.BackgroundTransparency = 1
	desc.Font = Theme.FONTS.Body
	desc.TextSize = 12
	desc.TextColor3 = Theme.COLORS.BoneDim
	desc.Text = ach.Description
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextWrapped = true
	desc.Parent = toast

	-- Rarity badge
	local badge = Instance.new("Frame")
	badge.Name = "Badge"
	badge.Size = UDim2.new(0, 60, 0, 20)
	badge.Position = UDim2.new(1, -64, 0, 8)
	badge.BackgroundColor3 = rarityColor
	badge.BorderSizePixel = 0
	badge.Parent = toast
	newUICorner(4):Parent = badge

	local badgeText = Instance.new("TextLabel")
	badgeText.Name = "BadgeText"
	badgeText.Size = UDim2.new(1, 0, 1, 0)
	badgeText.BackgroundTransparency = 1
	badgeText.Font = Theme.FONTS.Number
	badgeText.TextSize = 11
	badgeText.TextColor3 = Theme.COLORS.Bone
	badgeText.Text = ach.Rarity
	badgeText.Parent = badge

	currentToast = toast

	-- Auto-hide after 4 seconds
	delay(4, function()
		if toast and toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
			delay(0.5, function()
				if toast and toast.Parent then
					toast:Destroy()
				end
			end)
			currentToast = nil
		end
	end)
end

-- Buka/tutup UI
local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		-- Buka
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 520)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -260)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, -350, 0.5, -260)
		}):Play()

		-- Minta data terkini dari server
		requestProgress:FireServer()

		-- Sembunyikan toggle button
		TweenService:Create(refs.toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
		delay(0.2, function() refs.toggleBtn.Visible = false end)
	else
		-- Tutup
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 520),
			Position = UDim2.new(0.5, 0, 0.5, -260)
		}):Play()

		-- Tunggu animasi selesai, baru sembunyikan
		delay(0.5, function()
			refs.screenGui.Enabled = false
			-- Tampilkan toggle button kembali
			refs.toggleBtn.Visible = true
			TweenService:Create(refs.toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
		end)
	end
end

-- Setup event handlers
local function setupEvents()
	-- Toggle button
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)

	-- Close button
	refs.closeBtn.MouseButton1Click:Connect(function()
		toggleUI()
	end)

	-- Dengar respons progress dari server
	progressResponse.OnClientEvent:Connect(function(data)
		achievementList = {}
		unlockedIds = {}

		for _, entry in ipairs(data or {}) do
			if entry.Unlocked then
				unlockedIds[entry.Id] = entry
			end
			table.insert(achievementList, entry)
		end

		populateGrid()
	end)

	-- Dengar notifikasi achievement baru terbuka
	achievementUnlocked.OnClientEvent:Connect(function(ach)
		-- Tambahkan ke daftar unlocked jika belum ada
		unlockedIds[ach.Id] = ach
		-- Update UI
		populateGrid()
		-- Tampilkan toast
		showToast(ach)
	end)
end

-- Inisialisasi
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()

		-- Tambahkan ke PlayerGui
		if not playerGui:FindFirstChild("AchievementUI") then
			ui.Parent = playerGui
		end
	end
end

-- Mulai inisialisasi
init()

-- Export
return {
	Toggle = function()
		if ui then
			toggleUI()
		end
	end,
}