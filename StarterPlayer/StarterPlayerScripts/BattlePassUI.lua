-- BattlePassUI.lua
-- Antarmuka klien untuk Battle Pass
-- Letakkan di: StarterPlayer/StarterPlayerScripts/BattlePassUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local BattlePassData = require(ReplicatedStorage.Modules.BattlePassData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BattlePass")
local requestBp = remotes:WaitForChild("RequestBattlePass")
local bpResponse = remotes:WaitForChild("BattlePassResponse")
local claimTier = remotes:WaitForChild("ClaimTierReward")
local purchasePremium = remotes:WaitForChild("PurchasePremium")

local ui, refs = nil, {}
local isOpen = false
local tiers = {}
local currentEXP = 0
local currentTier = 1
local claimed = {}
local isPremium = false

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end
local function ornament(col, sz, p) local d = UIHelpers.createDiamondOrnament(col, sz); d.Parent = p; return d end

local function toggleUI()
	isOpen = not isOpen
	if isOpen then
		refs.screenGui.Enabled = true
		refs.panel.Size = UDim2.new(0, 0, 0, 1)
		TweenService:Create(refs.panel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 700, 0, 520),
			Position = UDim2.new(0.5, -350, 0.5, -260)
		}):Play()
		requestBp:FireServer()
		refs.toggleBtn.Visible = false
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 1)
		}):Play()
		delay(0.3, function() refs.screenGui.Enabled = false; refs.toggleBtn.Visible = true end)
	end
end

local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BattlePassUI"; screenGui.ResetOnSpawn = false; screenGui.Enabled = false

	refs.toggleBtn = Instance.new("TextButton")
	refs.toggleBtn.Size = UDim2.new(0, 48, 0, 48)
	refs.toggleBtn.Position = UDim2.new(1, -120, 0.5, -24)
	refs.toggleBtn.BackgroundColor3 = Theme.COLORS.Card; refs.toggleBtn.Text = "🎟️"
	refs.toggleBtn.Font = Theme.FONTS.Label; refs.toggleBtn.TextSize = 20
	refs.toggleBtn.TextColor3 = Theme.COLORS.Gold; refs.toggleBtn.AutoButtonColor = false
	refs.toggleBtn.Parent = screenGui
	newUICorner(8):Parent = refs.toggleBtn; newUIStroke(Theme.COLORS.Gold, 1):Parent = refs.toggleBtn

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
	refs.header.Size = UDim2.new(1, 0, 0, 60); refs.header.BackgroundColor3 = Theme.COLORS.Indigo; refs.header.BorderSizePixel = 0
	newUICorner(16):Parent = refs.header; refs.header.Parent = refs.panel

	refs.title = Instance.new("TextLabel")
	refs.title.Size = UDim2.new(1, -50, 1, -10); refs.title.Position = UDim2.new(0, 10, 0, 5)
	refs.title.BackgroundTransparency = 1; refs.title.Font = Theme.FONTS.Title; refs.title.TextSize = 24
	refs.title.TextColor3 = Theme.COLORS.Gold; refs.title.Text = " BATTLE PASS "
	refs.title.TextXAlignment = Enum.TextXAlignment.Left; refs.title.Parent = refs.header

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 14)
	closeBtn.BackgroundColor3 = Theme.COLORS.Card; closeBtn.Text = "✕"; closeBtn.Font = Theme.FONTS.Label
	closeBtn.TextSize = 16; closeBtn.TextColor3 = Theme.COLORS.Bone; closeBtn.AutoButtonColor = false
	newUICorner(3):Parent = closeBtn; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = closeBtn
	closeBtn.Parent = refs.header

	-- EXP bar
	refs.expBar = Instance.new("Frame")
	refs.expBar.Size = UDim2.new(1, -40, 0, 24); refs.expBar.Position = UDim2.new(0, 20, 0, 70)
	refs.expBar.BackgroundColor3 = Theme.COLORS.Indigo; refs.expBar.BorderSizePixel = 0
	newUICorner(12):Parent = refs.expBar; refs.expBar.Parent = refs.panel

	refs.expFill = Instance.new("Frame")
	refs.expFill.Size = UDim2.new(0, 0, 1, 0); refs.expFill.BackgroundColor3 = Theme.COLORS.Gold; refs.expFill.BorderSizePixel = 0
	newUICorner(12):Parent = refs.expFill; refs.expFill.Parent = refs.expBar

	refs.expLabel = Instance.new("TextLabel")
	refs.expLabel.Size = UDim2.new(1, 0, 1, 0); refs.expLabel.BackgroundTransparency = 1
	refs.expLabel.Font = Theme.FONTS.Number; refs.expLabel.TextSize = 12
	refs.expLabel.TextColor3 = Theme.COLORS.Bone
	refs.expLabel.Text = "EXP: 0/200"; refs.expLabel.Parent = refs.expBar

	-- Tier label
	refs.tierLabel = Instance.new("TextLabel")
	refs.tierLabel.Size = UDim2.new(1, -40, 0, 20); refs.tierLabel.Position = UDim2.new(0, 20, 0, 100)
	refs.tierLabel.BackgroundTransparency = 1; refs.tierLabel.Font = Theme.FONTS.Label
	refs.tierLabel.TextSize = 14; refs.tierLabel.TextColor3 = Theme.COLORS.Bone
	refs.tierLabel.Text = "Tier: 1/50"; refs.tierLabel.Parent = refs.panel

	-- Scrollable tier list
	refs.tierList = Instance.new("ScrollingFrame")
	refs.tierList.Size = UDim2.new(1, -20, 1, -130); refs.tierList.Position = UDim2.new(0, 10, 0, 120)
	refs.tierList.BackgroundTransparency = 1; refs.tierList.BorderSizePixel = 0
	refs.tierList.ScrollBarThickness = 6; refs.tierList.CanvasSize = UDim2.new(0, 0, 0, 0)
	refs.tierList.Parent = refs.panel

	refs.listLayout = Instance.new("UIListLayout")
	refs.listLayout.Padding = 8; refs.listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	refs.listLayout.Parent = refs.tierList

	refs.tierList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		refs.tierList.CanvasSize = UDim2.new(0, 0, 0, refs.tierList.AbsoluteContentSize.Y + 20)
	end)

	-- Premium badge
	refs.premiumBtn = Instance.new("TextButton")
	refs.premiumBtn.Size = UDim2.new(0, 100, 0, 24); refs.premiumBtn.Position = UDim2.new(1, -26, 0, 10)
	refs.premiumBtn.BackgroundColor3 = isPremium and Theme.COLORS.Gold or Theme.COLORS.Crimson
	refs.premiumBtn.BorderSizePixel = 0; refs.premiumBtn.Font = Theme.FONTS.Label
	refs.premiumBtn.Text = isPremium and "PREMIUM" or "UPGRADE"; refs.premiumBtn.TextSize = 12
	refs.premiumBtn.TextColor3 = isPremium and Theme.COLORS.Void or Theme.COLORS.Bone
	refs.premiumBtn.AutoButtonColor = false; newUICorner(4):Parent = refs.premiumBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = refs.premiumBtn; refs.premiumBtn.Parent = refs.panel

	refs.closeBtn = closeBtn; refs.screenGui = screenGui

	refs.toggleBtn.MouseButton1Click:Connect(toggleUI)
	refs.closeBtn.MouseButton1Click:Connect(toggleUI)
	refs.premiumBtn.MouseButton1Click:Connect(function() purchasePremium:FireServer() end)

	bpResponse.OnClientEvent:Connect(function(data)
		tiers = data.Tiers or {}
		currentEXP = data.CurrentEXP or 0
		currentTier = data.CurrentTier or 1
		claimed = data.ClaimedTiers or {}
		isPremium = data.IsPremium or false
		local xpPerTier = data.XPPerTier or 200
		refs.expFill.Size = UDim2.new(math.clamp(currentEXP / xpPerTier, 0, 1), 0, 1, 0)
		refs.expLabel.Text = ("EXP: %d/%d"):format(currentEXP, xpPerTier)
		refs.tierLabel.Text = ("Tier: %d/%d"):format(currentTier, #tiers)
		refs.premiumBtn.BackgroundColor3 = isPremium and Theme.COLORS.Gold or Theme.COLORS.Crimson
		refs.premiumBtn.TextColor3 = isPremium and Theme.COLORS.Void or Theme.COLORS.Bone
		refs.premiumBtn.Text = isPremium and "PREMIUM" or "UPGRADE"
		populateTiers()
	end)
end

local function populateTiers()
	for _, child in ipairs(refs.tierList:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	for _, tier in ipairs(tiers) do
		local frame = Instance.new("Frame")
		frame.Name = "Tier_" .. tier.Level
		frame.Size = UDim2.new(1, 0, 0, 60)
		frame.BackgroundColor3 = Theme.COLORS.Card
		frame.BorderSizePixel = 0; frame.Parent = refs.tierList
		newUICorner(6):Parent = frame; newUIStroke(Theme.COLORS.GoldDim, 1):Parent = frame

		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(0, 60, 1, 0)
		levelLabel.BackgroundTransparency = 1; levelLabel.Font = Theme.FONTS.Number
		levelLabel.TextSize = 16; levelLabel.TextColor3 = Theme.COLORS.Gold
		levelLabel.Text = "T" .. tier.Level
		levelLabel.Parent = frame

		-- Free reward label
		local freeLabel = Instance.new("TextLabel")
		freeLabel.Size = UDim2.new(0, 80, 0, 18)
		freeLabel.Position = UDim2.new(0, 70, 0, 5)
		freeLabel.BackgroundTransparency = 1; freeLabel.Font = Theme.FONTS.Body
		freeLabel.TextSize = 10; freeLabel.TextColor3 = Theme.COLORS.BoneDim
		local freeText = ""
		for _, r in ipairs(tier.FreeReward or {}) do
			if r.Type == "Rupiah" then freeText = r.Amount .. "🪙"
			elseif r.Type == "Gems" then freeText = r.Amount .. "💎"
			else freeText = r.Type end
		end
		freeLabel.Text = freeText; freeLabel.Parent = frame

		-- Claim button
		local claimBtn = Instance.new("TextButton")
		claimBtn.Size = UDim2.new(0, 60, 0, 20); claimBtn.Position = UDim2.new(1, -64, 0, 10)
		claimBtn.BackgroundColor3 = Theme.COLORS.Gold
		claimBtn.Text = "KLAIM"; claimBtn.Font = Theme.FONTS.Label; claimBtn.TextSize = 11
		claimBtn.TextColor3 = Theme.COLORS.Void; claimBtn.AutoButtonColor = false
		claimBtn.Visible = tier.Level <= currentTier and not claimed["Tier_" .. tier.Level]
		newUICorner(3):Parent = claimBtn; claimBtn.Parent = frame
		claimBtn.MouseButton1Click:Connect(function() claimTier:FireServer("Tier_" .. tier.Level) end)
	end
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		if not playerGui:FindFirstChild("BattlePassUI") then
			ui.Parent = playerGui
		end
	end
end

init()

return { Toggle = function() if ui then toggleUI() end end }
