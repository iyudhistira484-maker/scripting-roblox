-- InviteUI.lua
-- Antarmuka klien untuk Invite System (Ajak Teman).
-- Letakkan di: StarterPlayer/StarterPlayerScripts/InviteUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SocialService = game:GetService("SocialService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Invite")
local promptInvite = remotes:WaitForChild("PromptInvite")
local useReferralCode = remotes:WaitForChild("UseReferralCode")
local inviteResult = remotes:WaitForChild("InviteResult")

-- State
local ui = nil
local refs = {}
local isOpen = false
local myReferralCode = ""
local inviteCount = 0

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
		promptInvite:FireServer()
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		refs.panel.Position = UDim2.new(0.5, 0, 0.5, -1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 500, 0, 420),
			Position = UDim2.new(0.5, -250, 0.5, -210)
		}):Play()
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1)
		}):Play()
		delay(0.3, function()
			refs.screenGui.Enabled = false
		end)
	end
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InviteUI"
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
	toggleBtn.Text = "👥"
	toggleBtn.TextSize = 20
	toggleBtn.TextColor3 = Theme.COLORS.JadeGlow
	toggleBtn.AutoButtonColor = false
	toggleBtn.Parent = screenGui
	newUICorner(8):Parent = toggleBtn
	newUIStroke(Theme.COLORS.JadeGlow, 1):Parent = toggleBtn

	-- Panel
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 500, 0, 420)
	panel.Position = UDim2.new(0.5, -250, 0.5, -210)
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

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -50, 1, -10)
	title.Position = UDim2.new(0, 10, 0, 5)
	title.BackgroundTransparency = 1
	title.Text = "UNDANG TEMAN"
	title.Font = Theme.FONTS.Title
	title.TextSize = 24
	title.TextColor3 = Theme.COLORS.Gold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

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

	-- Referral code display
	local codeLabel = Instance.new("TextLabel")
	codeLabel.Name = "CodeLabel"
	codeLabel.Size = UDim2.new(1, -20, 0, 20)
	codeLabel.Position = UDim2.new(0, 10, 0, 60)
	codeLabel.BackgroundTransparency = 1
	codeLabel.Font = Theme.FONTS.Label
	codeLabel.TextSize = 14
	codeLabel.TextColor3 = Theme.COLORS.Bone
	codeLabel.Text = "Kode Referral Anda:"
	codeLabel.TextXAlignment = Enum.TextXAlignment.Left
	codeLabel.Parent = panel

	local codeBox = Instance.new("Frame")
	codeBox.Name = "CodeBox"
	codeBox.Size = UDim2.new(1, -20, 0, 36)
	codeBox.Position = UDim2.new(0, 10, 0, 80)
	codeBox.BackgroundColor3 = Theme.COLORS.Indigo
	codeBox.BorderSizePixel = 0
	newUICorner(6):Parent = codeBox
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = codeBox
	codeBox.Parent = panel

	local codeText = Instance.new("TextLabel")
	codeText.Name = "CodeText"
	codeText.Size = UDim2.new(1, -48, 1, 0)
	codeText.Position = UDim2.new(0, 6, 0, 0)
	codeText.BackgroundTransparency = 1
	codeText.Font = Theme.FONTS.Number
	codeText.TextSize = 18
	codeText.TextColor3 = Theme.COLORS.Gold
	codeText.Text = "Belum ada"
	codeText.TextXAlignment = Enum.TextXAlignment.Left
	codeText.Parent = codeBox

	local copyBtn = Instance.new("TextButton")
	copyBtn.Name = "CopyBtn"
	copyBtn.Size = UDim2.new(0, 32, 0, 24)
	copyBtn.Position = UDim2.new(1, -36, 0.5, -12)
	copyBtn.BackgroundColor3 = Theme.COLORS.Card
	copyBtn.BorderSizePixel = 0
	copyBtn.Font = Theme.FONTS.Label
	copyBtn.Text = "📋"
	copyBtn.TextSize = 12
	copyBtn.TextColor3 = Theme.COLORS.Bone
	copyBtn.AutoButtonColor = false
	newUICorner(3):Parent = copyBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = copyBtn
	copyBtn.Parent = codeBox

	-- Invite button
	local inviteBtn = Instance.new("TextButton")
	inviteBtn.Name = "InviteBtn"
	inviteBtn.Size = UDim2.new(1, -20, 0, 40)
	inviteBtn.Position = UDim2.new(0, 10, 0, 126)
	inviteBtn.BackgroundColor3 = Theme.COLORS.JadeGlow
	inviteBtn.BorderSizePixel = 0
	inviteBtn.Font = Theme.FONTS.Label
	inviteBtn.Text = " UNDANG TEMAN KE PERMAINAN "
	inviteBtn.TextSize = 14
	inviteBtn.TextColor3 = Theme.COLORS.Void
	inviteBtn.AutoButtonColor = false
	newUICorner(6):Parent = inviteBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = inviteBtn
	inviteBtn.Parent = panel

	inviteBtn.MouseButton1Click:Connect(function()
		-- Coba pakai Roblox native invite jika tersedia
		local success, err = pcall(function()
			if SocialService:PromptGameInvite(player, 0) then
				return
			end
		end)
		if not success or err then
			-- Fallback: Salin kode referral ke clipboard
			if myReferralCode ~= "" then
				setclipboard("Mainkan game Hunt Mystic Ghost!\nGunakan kode referral: " .. myReferralCode)
				if refs.notifyLabel then
					refs.notifyLabel.Text = " Kode referral disalin!"
				end
			end
		end
	end)

	-- Enter referral code section
	local enterLabel = Instance.new("TextLabel")
	enterLabel.Name = "EnterLabel"
	enterLabel.Size = UDim2.new(1, -20, 0, 20)
	enterLabel.Position = UDim2.new(0, 10, 0, 180)
	enterLabel.BackgroundTransparency = 1
	enterLabel.Font = Theme.FONTS.Label
	enterLabel.TextSize = 14
	enterLabel.TextColor3 = Theme.COLORS.Bone
	enterLabel.Text = "Masukkan Kode Referral:"
	enterLabel.TextXAlignment = Enum.TextXAlignment.Left
	enterLabel.Parent = panel

	local codeInput = Instance.new("TextBox")
	codeInput.Name = "CodeInput"
	codeInput.Size = UDim2.new(1, -20, 0, 30)
	codeInput.Position = UDim2.new(0, 10, 0, 200)
	codeInput.BackgroundColor3 = Theme.COLORS.Indigo
	codeInput.BorderSizePixel = 0
	codeInput.Font = Theme.FONTS.Number
	codeInput.TextSize = 16
	codeInput.TextColor3 = Theme.COLORS.Bone
	codeInput.Text = ""
	codeInput.PlaceholderText = "Ketik kode referral teman..."
	newUICorner(6):Parent = codeInput
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = codeInput
	codeInput.Parent = panel

	local submitCodeBtn = Instance.new("TextButton")
	submitCodeBtn.Name = "SubmitCodeBtn"
	submitCodeBtn.Size = UDim2.new(1, -20, 0, 36)
	submitCodeBtn.Position = UDim2.new(0, 10, 0, 240)
	submitCodeBtn.BackgroundColor3 = Theme.COLORS.Gold
	submitCodeBtn.BorderSizePixel = 0
	submitCodeBtn.Font = Theme.FONTS.Label
	submitCodeBtn.Text = "GUNAKAN KODE"
	submitCodeBtn.TextSize = 14
	submitCodeBtn.TextColor3 = Theme.COLORS.Void
	submitCodeBtn.AutoButtonColor = false
	newUICorner(6):Parent = submitCodeBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = submitCodeBtn
	submitCodeBtn.Parent = panel

	submitCodeBtn.MouseButton1Click:Connect(function()
		if codeInput.Text and codeInput.Text ~= "" then
			useReferralCode:FireServer(codeInput.Text)
		end
	end)

	-- Progress label
	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(1, -20, 0, 60)
	progressLabel.Position = UDim2.new(0, 10, 0, 296)
	progressLabel.BackgroundTransparency = 1
	progressLabel.Font = Theme.FONTS.Body
	progressLabel.TextSize = 13
	progressLabel.TextColor3 = Theme.COLORS.BoneDim
	progressLabel.Text = ("Unduhan berhasil: %d\nReward: 1000 Rupiah untukmu, 10 💎 untuk teman"):format(inviteCount)
	progressLabel.TextWrapped = true
	progressLabel.TextXAlignment = Enum.TextXAlignment.Left
	progressLabel.Parent = panel

	-- Notify label
	local notifyLabel = Instance.new("TextLabel")
	notifyLabel.Name = "NotifyLabel"
	notifyLabel.Size = UDim2.new(1, -20, 0, 20)
	notifyLabel.Position = UDim2.new(0, 10, 0, 366)
	notifyLabel.BackgroundTransparency = 1
	notifyLabel.Font = Theme.FONTS.Body
	notifyLabel.TextSize = 12
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
		codeText = codeText,
		codeInput = codeInput,
		submitCodeBtn = submitCodeBtn,
		progressLabel = progressLabel,
		notifyLabel = notifyLabel,
	}
end

-- Setup events
local function setupEvents()
	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(function() toggleUI() end)
	refs.copyBtn.MouseButton1Click:Connect(function()
		if myReferralCode ~= "" then
			setclipboard(myReferralCode)
			refs.notifyLabel.Text = " Kode referral disalin!"
			delay(2, function()
				if refs.notifyLabel then
					refs.notifyLabel.Text = ""
				end
			end)
		end
	end)

	inviteResult.OnClientEvent:Connect(function(success, inviterName, rewardRupiah, rewardGems)
		if success then
			refs.notifyLabel.Text = (" Kode referral diterima! Dapat %d Rupiah"):format(rewardRupiah)
			inviteCount = inviteCount + 1
			refs.progressLabel.Text = ("Unduhan berhasil: %d\nReward: 1000 Rupiah untukmu, 10 💎 untuk teman"):format(inviteCount)
		else
			refs.notifyLabel.Text = (" Teman %s berhasilundang! Dapat %d 💎"):format(inviterName, rewardGems)
		end
		delay(2, function()
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
		if not playerGui:FindFirstChild("InviteUI") then
			ui.Parent = playerGui
		end
	end
	-- Minta kode referral dari server
	promptInvite:FireServer()
end

init()

return {
	Toggle = function()
		if ui then
			toggleUI()
		end
	end,
}