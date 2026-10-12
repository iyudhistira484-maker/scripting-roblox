-- GhostCollectionUI.lua
-- Antarmuka klien untuk Koleksi Hantu ("Jurnal Arwah")
-- Letakkan di: StarterPlayer/StarterPlayerScripts/GhostCollectionUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local GhostData = require(ReplicatedStorage.Modules.GhostData)
local UIHelpers = require(ReplicatedStorage.Modules.GhostCollectionUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GhostCollection")
local capturedEvent = remotes:WaitForChild("GhostCaptured")
local requestCaught = remotes:WaitForChild("RequestCaughtGhosts")
local responseCaught = remotes:WaitForChild("CaughtGhostsResponse")

-- State
local ui = nil
local refs = {}
local caughtGhosts = {}
local isOpen = false
local ghostIds = GhostData:GetAllGhostIds()
local total = GhostData:GetTotalCount()

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

local function tweenToggle(obj, visible, time)
	if visible then
		obj.Visible = true
		TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	else
		TweenService:Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		task.wait(time or 0.3)
		obj.Visible = false
	end
end

-- Buat UI dasar
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GhostCollectionUI"
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
	toggleBtn.Text = "📖"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn

	-- Panel utama
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 700, 0, 500)
	panel.Position = UDim2.new(0.5, -350, 0.5, -250)
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
	local positions = {
		UDim2.new(0, 8, 0, 8),
		UDim2.new(1, -8, 0, 8),
		UDim2.new(0, 8, 1, -8),
		UDim2.new(1, -8, 1, -8),
	}
	for _, pos in ipairs(positions) do
		local d = Instance.new("Frame")
		d.Size = UDim2.new(0, 12, 0, 12)
		d.Position = pos
		d.BackgroundColor3 = Theme.COLORS.Gold
		d.BorderSizePixel = 0
		d.AnchorPoint = Vector2.new(pos.X.Scale, pos.Y.Scale)
		newUICorner(6):Parent = d
		d.Parent = panel
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
	title.Text = "JURNAL ARWAH"
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

	-- Progress bar container
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

	-- Grid container
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
	layout.CellSize = UDim2.new(1, -20, 0, 110)
	layout.CellPadding = UDim2.new(0, 8, 0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = grid

	grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.CanvasSize = UDim2.new(0, 0, 0, math.max(grid.AbsoluteContentSize.Y + 20, 0))
	end)

	-- Detail panel
	local detailPanel = Instance.new("Frame")
	detailPanel.Name = "Detail"
	detailPanel.Size = UDim2.new(0, 280, 1, 0)
	detailPanel.Position = UDim2.new(1, 10, 0, 0)
	detailPanel.BackgroundColor3 = Theme.COLORS.Card
	detailPanel.BorderSizePixel = 0
	detailPanel.Visible = false
	newUICorner(10):Parent = detailPanel
	newUIStroke(Theme.COLORS.Gold, 1):Parent = detailPanel
	detailPanel.Parent = panel

	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.new(0, 24, 0, 24)
	backBtn.Position = UDim2.new(0, 8, 0, 8)
	backBtn.BackgroundColor3 = Theme.COLORS.Indigo
	backBtn.BorderSizePixel = 0
	backBtn.Font = Theme.FONTS.Label
	backBtn.Text = "←"
	backBtn.TextSize = 16
	backBtn.TextColor3 = Theme.COLORS.Bone
	backBtn.AutoButtonColor = false
	newUICorner(4):Parent = backBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = backBtn
	backBtn.Parent = detailPanel

	local detailContent = Instance.new("Frame")
	detailContent.Name = "DetailContent"
	detailContent.Size = UDim2.new(1, -20, 1, -40)
	detailContent.Position = UDim2.new(0, 10, 0, 30)
	detailContent.BackgroundTransparency = 1
	detailContent.Parent = detailPanel

	local detailName = Instance.new("TextLabel")
	detailName.Name = "DetailName"
	detailName.Size = UDim2.new(1, 0, 0, 28)
	detailName.BackgroundTransparency = 1
	detailName.Font = Theme.FONTS.Title
	detailName.TextSize = 22
	detailName.TextColor3 = Theme.COLORS.Gold
	detailName.Text = ""
	detailName.Parent = detailContent

	local detailRarity = Instance.new("TextLabel")
	detailRarity.Name = "DetailRarity"
	detailRarity.Size = UDim2.new(1, 0, 0, 20)
	detailRarity.Position = UDim2.new(0, 0, 0, 32)
	detailRarity.BackgroundTransparency = 1
	detailRarity.Font = Theme.FONTS.Label
	detailRarity.TextSize = 14
	detailRarity.TextColor3 = Theme.COLORS.Bone
	detailRarity.Text = ""
	detailRarity.Parent = detailContent

	local detailIcon = Instance.new("ImageLabel")
	detailIcon.Name = "DetailIcon"
	detailIcon.Size = UDim2.new(0, 70, 0, 70)
	detailIcon.Position = UDim2.new(0, 0, 0, 55)
	detailIcon.BackgroundTransparency = 1
	detailIcon.Image = ""
	detailIcon.Parent = detailContent

	local detailLore = Instance.new("TextLabel")
	detailLore.Name = "DetailLore"
	detailLore.Size = UDim2.new(1, -80, 0, 130)
	detailLore.Position = UDim2.new(0, 80, 0, 55)
	detailLore.BackgroundTransparency = 1
	detailLore.Font = Theme.FONTS.Body
	detailLore.TextSize = 13
	detailLore.TextColor3 = Theme.COLORS.BoneDim
	detailLore.TextWrapped = true
	detailLore.Text = ""
	detailLore.Parent = detailContent

	local detailLocation = Instance.new("TextLabel")
	detailLocation.Name = "DetailLocation"
	detailLocation.Size = UDim2.new(1, 0, 0, 20)
	detailLocation.Position = UDim2.new(0, 0, 0, 190)
	detailLocation.BackgroundTransparency = 1
	detailLocation.Font = Theme.FONTS.Label
	detailLocation.TextSize = 14
	detailLocation.TextColor3 = Theme.COLORS.JadeGlow
	detailLocation.Text = ""
	detailLocation.Parent = detailContent

	local detailReward = Instance.new("TextLabel")
	detailReward.Name = "DetailReward"
	detailReward.Size = UDim2.new(1, 0, 0, 20)
	detailReward.Position = UDim2.new(0, 0, 0, 215)
	detailReward.BackgroundTransparency = 1
	detailReward.Font = Theme.FONTS.Number
	detailReward.TextSize = 15
	detailReward.TextColor3 = Theme.COLORS.Gold
	detailReward.Text = ""
	detailReward.Parent = detailContent

	-- Simpan referensi
	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		title = title,
		closeBtn = closeBtn,
		fill = fill,
		progressLabel = progressLabel,
		grid = grid,
		layout = layout,
		detailPanel = detailPanel,
		backBtn = backBtn,
		detailContent = detailContent,
		detailName = detailName,
		detailRarity = detailRarity,
		detailIcon = detailIcon,
		detailLore = detailLore,
		detailLocation = detailLocation,
		detailReward = detailReward,
	}
end

-- Populate grid dengan kartu hantu
local function populateGrid()
	-- Bersihkan kartu yang ada (ecualikan layout)
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	-- Kemaskini progress bar
	local count = 0
	for _ in pairs(caughtGhosts) do
 		count = count + 1
	end
	refs.fill.Size = UDim2.new(count / total, 0, 1, 0)
	refs.progressLabel.Text = ("(%d / %d)"):format(count, total)

	-- Cipta kartu untuk setiap hantu
	for _, ghostId in ipairs(ghostIds) do
		local ghost = GhostData:GetGhostById(ghostId)
		local rarity = GhostData:GetRarityByName(ghost.Rarity)
		local isCaught = caughtGhosts[ghostId] ~= nil

		local card = Instance.new("Frame")
		card.Name = "Card_" .. ghostId
		card.Size = UDim2.new(1, -16, 0, 104)
		card.BackgroundColor3 = isCaught and Theme.COLORS.Indigo or Theme.COLORS.Void
		card.BorderSizePixel = 0
		card.BackgroundTransparency = isCaught and 0 or 0.3
		card.Parent = refs.grid

		newUICorner(8):Parent = card
		newUIStroke(isCaught and rarity.Color or Theme.COLORS.BoneDim, 1):Parent = card

		-- Icon hantu atau siluet
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 50, 0, 50)
		icon.Position = UDim2.new(0, 6, 0, 6)
		icon.BackgroundTransparency = 1

		if isCaught then
			icon.Image = ghost.IconImage or ""
			icon.ImageTransparency = 0
		else
			-- Siluet placeholder
			icon.Image = ""
			icon.BackgroundColor3 = Theme.COLORS.Void
			icon.BorderSizePixel = 0

			local silhouette = Instance.new("ImageLabel")
			silhouette.Name = "Silhouette"
			silhouette.Size = UDim2.new(1, 0, 1, 0)
			silhouette.BackgroundTransparency = 1
			silhouette.Image = "rbxasset://textures/ui/GhostSilhouette.png"
			silhouette.ImageColor3 = Theme.COLORS.BoneDim
			silhouette.ImageTransparency = 0.8
			silhouette.Parent = icon
		end
		icon.Parent = card

		-- Label nama
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "NameLabel"
		nameLabel.Size = UDim2.new(1, -70, 0, 20)
		nameLabel.Position = UDim2.new(0, 62, 0, 6)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Theme.FONTS.Label
		nameLabel.TextSize = 16
		nameLabel.TextColor3 = isCaught and rarity.Color or Theme.COLORS.BoneDim
		nameLabel.Text = isCaught and ghost.Name or "???"
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		-- Label rarity
		local rarityLabel = Instance.new("TextLabel")
		rarityLabel.Name = "RarityLabel"
		rarityLabel.Size = UDim2.new(1, -70, 0, 16)
		rarityLabel.Position = UDim2.new(0, 62, 0, 26)
		rarityLabel.BackgroundTransparency = 1
		rarityLabel.Font = Theme.FONTS.Label
		rarityLabel.TextSize = 12
		rarityLabel.TextColor3 = rarity.Color
		rarityLabel.Text = rarity.Name .. " " .. rarity.Icon
		rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
		rarityLabel.Parent = card

		-- Tombol lihat detail (hanya untuk yang sudah ditangkap)
		if isCaught then
			local detailBtn = Instance.new("TextButton")
			detailBtn.Name = "DetailBtn"
			detailBtn.Size = UDim2.new(0, 20, 0, 20)
			detailBtn.Position = UDim2.new(1, -24, 0, 6)
			detailBtn.BackgroundColor3 = Theme.COLORS.IndigoDeep
			detailBtn.BorderSizePixel = 0
			detailBtn.Font = Theme.FONTS.Label
			detailBtn.Text = "🔍"
			detailBtn.TextSize = 12
			detailBtn.TextColor3 = Theme.COLORS.Gold
			detailBtn.AutoButtonColor = false
			newUICorner(3):Parent = detailBtn
			newUIStroke(Theme.COLORS.GoldDim, 1):Parent = detailBtn
			detailBtn.Parent = card

			detailBtn.MouseButton1Click:Connect(function()
				-- Tunjukkan detail panel
				tweenToggle(refs.detailPanel, true, 0.3)

				-- Isi detail
				refs.detailName.Text = ghost.Name
				refs.detailRarity.Text = rarity.Name .. " " .. rarity.Icon
				refs.detailIcon.Image = ghost.IconImage or ""
				refs.detailLore.Text = ghost.Lore
				refs.detailLocation.Text = "Lokasi: " .. ghost.Location

				local rewardText = "Reward: "
				if ghost.Reward.Rupiah > 0 then
					rewardText = rewardText .. ghost.Reward.Rupiah .. " Rupiah"
				end
				if ghost.Reward.Gems > 0 then
					if ghost.Reward.Rupiah > 0 then
						rewardText = rewardText .. " + "
					end
					rewardText = rewardText .. ghost.Reward.Gems .. " Gems"
				end
				refs.detailReward.Text = rewardText

				-- Animasi transisi
				tweenToggle(refs.grid, false, 0.01)
				-- Kita akan gunakan Tween untuk memindahkan grid ke kiri
				TweenService:Create(refs.grid, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 380, 1, -90)}):Play()
			end)
		else
			-- Untuk yang belum tertangkap, tombol tetap tidak bisa diklik
			local lockedBtn = Instance.new("TextButton")
			lockedBtn.Name = "LockedBtn"
			lockedBtn.Size = UDim2.new(0, 20, 0, 20)
			lockedBtn.Position = UDim2.new(1, -24, 0, 6)
			lockedBtn.BackgroundColor3 = Theme.COLORS.Void
			lockedBtn.BorderSizePixel = 0
			lockedBtn.Font = Theme.FONTS.Label
			lockedBtn.Text = "?"
			lockedBtn.TextSize = 12
			lockedBtn.TextColor3 = Theme.COLORS.BoneDim
			lockedBtn.AutoButtonColor = false
			newUICorner(3):Parent = lockedBtn
			newUIStroke(Theme.COLORS.GoldDim, 1):Parent = lockedBtn
			lockedBtn.Parent = card
		end
	end
end

-- Buka/tutup UI
local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		-- Buka
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 500)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -250)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 500),
			Position = UDim2.new(0.5, -350, 0.5, -250)
		}):Play()

		-- Minta data terkini dari server
		requestCaught:FireServer()

		-- Sembunyikan toggle button
		tweenToggle(refs.toggleBtn, false, 0.2)
	else
		-- Tutup
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 500),
			Position = UDim2.new(0.5, 0, 0.5, -250)
		}):Play()

		-- Tunggu animasi selesai, baru sembunyikan
		task.wait(0.5)
		refs.screenGui.Enabled = false

		-- Tampilkan toggle button kembali
		tweenToggle(refs.toggleBtn, true, 0.2)
	end
end

-- Event handler
local function setupEvents()
	-- Toggle button
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)

	-- Close button
	refs.closeBtn.MouseButton1Click:Connect(function()
		toggleUI()
	end)

	-- Back button di detail panel
	refs.backBtn.MouseButton1Click:Connect(function()
		tweenToggle(refs.detailPanel, false, 0.3)

		-- Kembalikan ukuran grid
		TweenService:Create(refs.grid, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 1, -90)}):Play()
	end)

	-- Dengar notifikasi penangkapan hantu baru
	capturedEvent.OnClientEvent:Connect(function(ghostId, reward)
		-- Perbarui state lokal
		caughtGhosts[ghostId] = true
		populateGrid()

		-- Mainkan efek sukses
		-- Bisa ditambahkan tween atau partikel di sini
		print(("Berhasil menangkap: %s"):format(ghostId))
	end)

	-- Dengar respons data hantu yang ditangkap
	responseCaught.OnClientEvent:Connect(function(caughtList)
		caughtGhosts = {}
		for _, entry in ipairs(caughtList) do
			caughtGhosts[entry.Id] = true
		end
		populateGrid()
	end)
end

-- Inisialisasi
local function init()
	-- Cipta UI jika belum ada
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()

		-- Tambahkan ke PlayerGui
		if not playerGui:FindFirstChild("GhostCollectionUI") then
			ui.Parent = playerGui
		end
	end

	-- Populate grid setelah UI siap
	if ui then
		populateGrid()
	end
end

-- Mulai inisialisasi
init()

-- Export fungsi toggle untuk digunakan oleh sistem lain (mis. chat command)
return {
	Toggle = function()
		if ui then
			toggleUI()
		end
	end,
}
