-- DonationUI.lua
-- Antarmuka klien untuk Donation (Donasi Antar Pemain).
-- Letakkan di: StarterPlayer/StarterPlayerScripts/DonationUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Donation")
local requestPlayers = remotes:WaitForChild("RequestPlayers")
local playersResponse = remotes:WaitForChild("PlayersResponse")
local sendDonation = remotes:WaitForChild("SendDonation")
local donationResult = remotes:WaitForChild("DonationResult")

-- State
local ui = nil
local refs = {}
local isOpen = false
local playerList = {}
local selectedPlayer = nil
local selectedCurrency = "Rupiah"

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
		requestPlayers:FireServer()
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 500, 0, 480),
			Position = UDim2.new(0.5, -250, 0.5, -240)
		}):Play()
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 100, 0, 100)
		}):Play()
		delay(0.3, function()
			refs.screenGui.Enabled = false
		end)
	end
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DonationUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	toggleBtn.Position = UDim2.new(1, -180, 1, -60)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🎁"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.JadeGlow
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.JadeGlow, 1):Parent = toggleBtn

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 500, 0, 480)
	panel.Position = UDim2.new(0.5, -250, 0.5, -240)
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
	createDiamondOrnamentHelper(Theme.COLORS.Gold, 10, panel).Position = UDim2.new(0, 8, 0, 8)
	local d2 = createDiamondOrnamentHelper(Theme.COLORS.Gold, 10, panel)
	d2.Position = UDim2.new(1, -8, 0, 8)
	d2.AnchorPoint = Vector2.new(1, 0)

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 50)
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
	title.Text = "KIRIM DONASI"
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
	newUICorner(3):Parent = closeBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = header

	-- Player list
	local listLabel = Instance.new("TextLabel")
	listLabel.Name = "ListLabel"
	listLabel.Size = UDim2.new(1, -20, 0, 20)
	listLabel.Position = UDim2.new(0, 10, 0, 60)
	listLabel.BackgroundTransparency = 1
	listLabel.Font = Theme.FONTS.Label
	listLabel.TextSize = 14
	listLabel.TextColor3 = Theme.COLORS.Bone
	listLabel.Text = "Pilih Pemain:"
	listLabel.TextXAlignment = Enum.TextXAlignment.Left
	listLabel.Parent = panel

	local playerListFrame = Instance.new("ScrollingFrame")
	playerListFrame.Name = "PlayerList"
	playerListFrame.Size = UDim2.new(1, -20, 0, 140)
	playerListFrame.Position = UDim2.new(0, 10, 0, 80)
	playerListFrame.BackgroundColor3 = Theme.COLORS.Indigo
	playerListFrame.BorderSizePixel = 0
	playerListFrame.ScrollBarThickness = 6
	playerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	newUICorner(8):Parent = playerListFrame
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = playerListFrame
	playerListFrame.Parent = panel

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = 4
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = playerListFrame

	playerListFrame:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		playerListFrame.CanvasSize = UDim2.new(0, 0, 0, playerListFrame.AbsoluteContentSize.Y + 10)
	end)

	-- Currency selector
	local curLabel = Instance.new("TextLabel")
	curLabel.Name = "CurrencyLabel"
	curLabel.Size = UDim2.new(1, -20, 0, 20)
	curLabel.Position = UDim2.new(0, 10, 0, 230)
	curLabel.BackgroundTransparency = 1
	curLabel.Font = Theme.FONTS.Label
	curLabel.TextSize = 14
	curLabel.TextColor3 = Theme.COLORS.Bone
	curLabel.Text = "Mata Uang:"
	curLabel.TextXAlignment = Enum.TextXAlignment.Left
	curLabel.Parent = panel

	local curToggle = Instance.new("Frame")
	curToggle.Name = "CurrencyToggle"
	curToggle.Size = UDim2.new(1, -20, 0, 30)
	curToggle.Position = UDim2.new(0, 10, 0, 250)
	curToggle.BackgroundTransparency = 1
	curToggle.Parent = panel

	local curLayout = Instance.new("UIListLayout")
	curLayout.FillDirection = Enum.FillDirection.Horizontal
	curLayout.Padding = 8
	curLayout.Parent = curToggle

	-- Currency buttons
	local rupiahBtn = Instance.new("TextButton")
	rupiahBtn.Name = "RupiahBtn"
	rupiahBtn.Size = UDim2.new(0, 100, 1, 0)
	rupiahBtn.BackgroundColor3 = selectedCurrency == "Rupiah" and Theme.COLORS.Gold or Theme.COLORS.Indigo
	rupiahBtn.BorderSizePixel = 0
	rupiahBtn.Font = Theme.FONTS.Label
	rupiahBtn.Text = "🪙 Rupiah"
	rupiahBtn.TextSize = 13
	rupiahBtn.TextColor3 = selectedCurrency == "Rupiah" and Theme.COLORS.Void or Theme.COLORS.Bone
	rupiahBtn.AutoButtonColor = false
	newUICorner(6):Parent = rupiahBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = rupiahBtn
	rupiahBtn.Parent = curToggle

	local gemsBtn = Instance.new("TextButton")
	gemsBtn.Name = "GemsBtn"
	gemsBtn.Size = UDim2.new(0, 100, 1, 0)
	gemsBtn.BackgroundColor3 = selectedCurrency == "Gems" and Theme.COLORS.Gold or Theme.COLORS.Indigo
	gemsBtn.BorderSizePixel = 0
	gemsBtn.Font = Theme.FONTS.Label
	gemsBtn.Text = "💎 Gems"
	gemsBtn.TextSize = 13
	gemsBtn.TextColor3 = selectedCurrency == "Gems" and Theme.COLORS.Void or Theme.COLORS.Bone
	gemsBtn.AutoButtonColor = false
	newUICorner(6):Parent = gemsBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = gemsBtn
	gemsBtn.Parent = curToggle

	rupiahBtn.MouseButton1Click:Connect(function()
		selectedCurrency = "Rupiah"
		rupiahBtn.BackgroundColor3 = Theme.COLORS.Gold
		rupiahBtn.TextColor3 = Theme.COLORS.Void
		gemsBtn.BackgroundColor3 = Theme.COLORS.Indigo
		gemsBtn.TextColor3 = Theme.COLORS.Bone
	end)

	gemsBtn.MouseButton1Click:Connect(function()
		selectedCurrency = "Gems"
		gemsBtn.BackgroundColor3 = Theme.COLORS.Gold
		gemsBtn.TextColor3 = Theme.COLORS.Void
		rupiahBtn.BackgroundColor3 = Theme.COLORS.Indigo
		rupiahBtn.TextColor3 = Theme.COLORS.Bone
	end)

	-- Amount input
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Name = "AmountLabel"
	amountLabel.Size = UDim2.new(1, -20, 0, 20)
	amountLabel.Position = UDim2.new(0, 10, 0, 290)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Font = Theme.FONTS.Label
	amountLabel.TextSize = 14
	amountLabel.TextColor3 = Theme.COLORS.Bone
	amountLabel.Text = "Jumlah:"
	amountLabel.TextXAlignment = Enum.TextXAlignment.Left
	amountLabel.Parent = panel

	local amountInput = Instance.new("TextBox")
	amountInput.Name = "AmountInput"
	amountInput.Size = UDim2.new(1, -20, 0, 30)
	amountInput.Position = UDim2.new(0, 10, 0, 310)
	amountInput.BackgroundColor3 = Theme.COLORS.Indigo
	amountInput.BorderSizePixel = 0
	amountInput.Font = Theme.FONTS.Number
	amountInput.TextSize = 16
	amountInput.TextColor3 = Theme.COLORS.Bone
	amountInput.Text = ""
	amountInput.PlaceholderText = "Masukkan jumlah"
	newUICorner(6):Parent = amountInput
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = amountInput
	amountInput.Parent = panel

	-- Submit button
	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitBtn"
	submitBtn.Size = UDim2.new(1, -20, 0, 40)
	submitBtn.Position = UDim2.new(0, 10, 0, 350)
	submitBtn.BackgroundColor3 = Theme.COLORS.Gold
	submitBtn.BorderSizePixel = 0
	submitBtn.Font = Theme.FONTS.Label
	submitBtn.Text = "KIRIM DONASI"
	submitBtn.TextSize = 14
	submitBtn.TextColor3 = Theme.COLORS.Void
	submitBtn.AutoButtonColor = false
	newUICorner(6):Parent = submitBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = submitBtn
	submitBtn.Parent = panel

	submitBtn.MouseButton1Click:Connect(function()
		local amount = tonumber(amountInput.Text)
		if not amount or amount <= 0 then return end
		if not selectedPlayer then return end
		sendDonation:FireServer(selectedPlayer.UserId, selectedCurrency, math.floor(amount))
		amountInput.Text = ""
	end)

	submitBtn.MouseEnter:Connect(function()
		TweenService:Create(submitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.GoldHi}):Play()
	end)
	submitBtn.MouseLeave:Connect(function()
		TweenService:Create(submitBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Gold}):Play()
	end)

	-- Notification label
	local notifyLabel = Instance.new("TextLabel")
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Size = UDim2.new(1, -20, 0, 20)
	notifyLabel.Position = UDim2.new(0, 10, 0, 410)
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Font = Theme.FONTS.Body
	notifyLabel.TextSize = 12
	notifyLabel.TextColor3 = Theme.COLORS.JadeGlow
	notifyLabel.Text = ""
	notifyLabel.TextXAlignment = Enum.TextXAlignment.Left
	notifyLabel.Parent = panel

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		header = header,
		title = title,
		closeBtn = closeBtn,
		playerListFrame = playerListFrame,
		listLayout = listLayout,
		rupiahBtn = rupiahBtn,
		gemsBtn = gemsBtn,
		amountInput = amountInput,
		submitBtn = submitBtn,
		notifyLabel = notifyLabel,
	}
end

-- Populate player list
local function populatePlayerList()
	for _, child in ipairs(refs.playerListFrame:GetChildren()) do
		if not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end

	for _, pData in ipairs(playerList) do
		local btn = Instance.new("TextButton")
		btn.Name = "Player_" .. pData.UserId
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = Theme.COLORS.Indigo
		btn.BorderSizePixel = 0
		btn.Font = Theme.FONTS.Label
		btn.Text = pData.DisplayName .. " (Lv. " .. (pData.Level or 1) .. ")"
		btn.TextSize = 13
		btn.TextColor3 = Theme.COLORS.Bone
		btn.AutoButtonColor = false
		newUICorner(4):Parent = btn
		newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn
		btn.Parent = refs.playerListFrame

		btn.MouseButton1Click:Connect(function()
			selectedPlayer = pData
			for _, other in ipairs(refs.playerListFrame:GetChildren()) do
				if other:IsA("TextButton") then
					local isSel = other.Name == btn.Name
					other.BackgroundColor3 = isSel and Theme.COLORS.Gold or Theme.COLORS.Indigo
					other.TextColor3 = isSel and Theme.COLORS.Void or Theme.COLORS.Bone
				end
			end
		end)

		btn.MouseEnter:Connect(function()
			if selectedPlayer and selectedPlayer.UserId ~= pData.UserId then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.IndigoDeep}):Play()
			end
		end)
		btn.MouseLeave:Connect(function()
			if selectedPlayer and selectedPlayer.UserId ~= pData.UserId then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Theme.COLORS.Indigo}):Play()
			end
		end)
	end
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)

	playersResponse.OnClientEvent:Connect(function(players)
		playerList = players
		populatePlayerList()
	end)

	donationResult.OnClientEvent:Connect(function(fromPlayerName, currencyType, amount, isSender)
		if isSender then
			refs.notifyLabel.Text = (" Berhasil kirim %d %s ke %s!"):format(amount, currencyType, fromPlayerName)
		else
			refs.notifyLabel.Text = (" Dapat donasi %d %s dari %s!"):format(amount, currencyType, fromPlayerName)
		end
		TweenService:Create(refs.notifyLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Theme.COLORS.JadeGlow}):Play()
		delay(3, function()
			if refs.notifyLabel then
				refs.notifyLabel.Text = ""
			end
		end)
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("DonationUI") then
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