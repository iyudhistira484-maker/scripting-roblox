-- CurrencyHUD.lua
-- Tampilan saldo Rupiah & Gems di pojol atas layar.
-- Letakkan di: StarterPlayer/StarterPlayerScripts/CurrencyHUD.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local CurrencyConfig = require(ReplicatedStorage.Modules.CurrencyConfig)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Currency")
local currencyUpdated = remotes:WaitForChild("CurrencyUpdated")
local requestBalance = remotes:WaitForChild("RequestBalance")
local balanceResponse = remotes:WaitForChild("BalanceResponse")

-- State
local ui = nil
local refs = {}
local balances = { Rupiah = 0, Gems = 0 }
local animateTween = nil

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

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CurrencyHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = true

	-- Container
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(0, 200, 0, 70)
	container.Position = UDim2.new(1, -220, 0, 15)
	container.BackgroundTransparency = 1
	container.BorderSizePixel = 0
	container.Parent = screenGui

	-- Kotak Rupiah
	local rupiahBox = Instance.new("Frame")
	rupiahBox.Name = "RupiahBox"
	rupiahBox.Size = UDim2.new(1, 0, 0, 30)
	rupiahBox.Position = UDim2.new(0, 0, 0, 0)
	rupiahBox.BackgroundColor3 = Theme.COLORS.Card
	rupiahBox.BorderSizePixel = 0
	rupiahBox.Parent = container
	newUICorner(6):Parent = rupiahBox
	newUIStroke(Theme.COLORS.Gold, 1):Parent = rupiahBox

	-- Label Rupiah
	local rupiahLabel = Instance.new("TextLabel")
	rupiahLabel.Name = "RupiahLabel"
	rupiahLabel.Size = UDim2.new(1, -10, 1, 0)
	rupiahLabel.Position = UDim2.new(0, 36, 0, 0)
	rupiahLabel.BackgroundTransparency = 1
	rupiahLabel.Font = Theme.FONTS.Number
	rupiahLabel.TextSize = 14
	rupiahLabel.TextColor3 = Theme.COLORS.Gold
	rupiahLabel.Text = "0"
	rupiahLabel.TextXAlignment = Enum.TextXAlignment.Left
	rupiahLabel.Parent = rupiahBox

	local rupiahIcon = Instance.new("TextLabel")
	rupiahIcon.Name = "RupiahIcon"
	rupiahIcon.Size = UDim2.new(0, 30, 1, 0)
	rupiahIcon.Position = UDim2.new(0, 2, 0, 0)
	rupiahIcon.BackgroundTransparency = 1
	rupiahIcon.Font = Theme.FONTS.Label
	rupiahIcon.TextSize = 18
	rupiahIcon.TextColor3 = Theme.COLORS.Gold
	rupiahIcon.Text = "🪙"
	rupiahIcon.Parent = rupiahBox

	-- Kotak Gems
	local gemsBox = Instance.new("Frame")
	gemsBox.Name = "GemsBox"
	gemsBox.Size = UDim2.new(1, 0, 0, 30)
	gemsBox.Position = UDim2.new(0, 0, 0, 35)
	gemsBox.BackgroundColor3 = Theme.COLORS.Card
	gemsBox.BorderSizePixel = 0
	gemsBox.Parent = container
	newUICorner(6):Parent = gemsBox
	newUIStroke(Theme.COLORS.JadeGlow, 1):Parent = gemsBox

	-- Label Gems
	local gemsLabel = Instance.new("TextLabel")
	gemsLabel.Name = "GemsLabel"
	gemsLabel.Size = UDim2.new(1, -10, 1, 0)
	gemsLabel.Position = UDim2.new(0, 36, 0, 0)
	gemsLabel.BackgroundTransparency = 1
	gemsLabel.Font = Theme.FONTS.Number
	gemsLabel.TextSize = 14
	gemsLabel.TextColor3 = Theme.COLORS.JadeGlow
	gemsLabel.Text = "0"
	gemsLabel.TextXAlignment = Enum.TextXAlignment.Left
	gemsLabel.Parent = gemsBox

	local gemsIcon = Instance.new("TextLabel")
	gemsIcon.Name = "GemsIcon"
	gemsIcon.Size = UDim2.new(0, 30, 1, 0)
	gemsIcon.Position = UDim2.new(0, 2, 0, 0)
	gemsIcon.BackgroundTransparency = 1
	gemsIcon.Font = Theme.FONTS.Label
	gemsIcon.TextSize = 18
	gemsIcon.TextColor3 = Theme.COLORS.JadeGlow
	gemsIcon.Text = "💎"
	gemsIcon.Parent = gemsBox

	-- Plus button for Gems (buy with Robux)
	local buyGemsBtn = Instance.new("TextButton")
	buyGemsBtn.Name = "BuyGemsBtn"
	buyGemsBtn.Size = UDim2.new(0, 20, 0, 20)
	buyGemsBtn.Position = UDim2.new(1, -24, 0, 6)
	buyGemsBtn.BackgroundColor3 = Theme.COLORS.Indigo
	buyGemsBtn.BorderSizePixel = 0
	buyGemsBtn.Font = Theme.FONTS.Label
	buyGemsBtn.Text = "+"
	buyGemsBtn.TextSize = 16
	buyGemsBtn.TextColor3 = Theme.COLORS.Gold
	buyGemsBtn.AutoButtonColor = false
	buyGemsBtn.Parent = gemsBox
	newUICorner(4):Parent = buyGemsBtn
	newUIStroke(Theme.COLORS.GoldDim, 1):Parent = buyGemsBtn

	-- Hover effect
	buyGemsBtn.MouseEnter:Connect(function()
		TweenService:Create(buyGemsBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Theme.COLORS.Crimson
		}):Play()
	end)
	buyGemsBtn.MouseLeave:Connect(function()
		TweenService:Create(buyGemsBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Theme.COLORS.Indigo
		}):Play()
	end)

	-- Buy gems menu (hidden by default)
	local buyMenu = Instance.new("Frame")
	buyMenu.Name = "BuyMenu"
	buyMenu.Size = UDim2.new(0, 180, 0, 130)
	buyMenu.Position = UDim2.new(0, 230, 0, 0)
	buyMenu.BackgroundColor3 = Theme.COLORS.Card
	buyMenu.BorderSizePixel = 0
	buyMenu.Visible = false
	buyMenu.Parent = container
	newUICorner(8):Parent = buyMenu
	newUIStroke(Theme.COLORS.JadeGlow, 2):Parent = buyMenu

	local buyTitle = Instance.new("TextLabel")
	buyTitle.Name = "BuyTitle"
	buyTitle.Size = UDim2.new(1, -10, 0, 20)
	buyTitle.Position = UDim2.new(0, 5, 0, 5)
	buyTitle.BackgroundTransparency = 1
	buyTitle.Font = Theme.FONTS.Label
	buyTitle.TextSize = 14
	buyTitle.TextColor3 = Theme.COLORS.Gold
	buyTitle.Text = "BELI BERLIAN"
	buyTitle.Parent = buyMenu

	local buyLayout = Instance.new("UIListLayout")
	buyLayout.Padding = 4
	buyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	buyLayout.Parent = buyMenu

	-- Product buttons
	for _, product in ipairs(CurrencyConfig.DeveloperProducts) do
		local btn = Instance.new("TextButton")
		btn.Name = "Product_" .. product.ProductId
		btn.Size = UDim2.new(1, -10, 0, 30)
		btn.BackgroundColor3 = Theme.COLORS.Indigo
		btn.BorderSizePixel = 0
		btn.Font = Theme.FONTS.Label
		btn.Text = product.Name .. " (" .. product.Gems .. " 💎)"
		btn.TextSize = 12
		btn.TextColor3 = Theme.COLORS.Bone
		btn.AutoButtonColor = false
		newUICorner(4):Parent = btn
		newUIStroke(Theme.COLORS.GoldDim, 1):Parent = btn
		btn.Parent = buyMenu

		btn.MouseButton1Click:Connect(function()
			requestBalance:FireServer(product.ProductId)
		end)
	end

	buyGemsBtn.MouseButton1Click:Connect(function()
		buyMenu.Visible = not buyMenu.Visible
		if buyMenu.Visible then
			buyMenu.Size = UDim2.new(0, 0, 0, 130)
			TweenService:Create(buyMenu, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, 180, 0, 130)
			}):Play()
		else
			TweenService:Create(buyMenu, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 130)
			}):Play()
			delay(0.2, function()
				buyMenu.Visible = false
			end)
		end
	end)

	-- Auto-hide buy menu when mouse leaves
	buyMenu.MouseLeave:Connect(function()
		buyMenu.Visible = false
	end)

	refs = {
		screenGui = screenGui,
		rupiahLabel = rupiahLabel,
		gemsLabel = gemsLabel,
		buyMenu = buyMenu,
		buyGemsBtn = buyGemsBtn,
	}
end

-- Format angka
local function formatNumber(n)
	if n >= 1000000 then
		return string.format("%.1fk", n / 1000000)
	elseif n >= 1000 then
		return string.format("%.1fk", n / 1000)
	end
	return tostring(n)
end

-- Animate number change
local function animateNumber(label, oldValue, newValue, isGem)
	if animateTween then
		animateTween:Cancel()
	end

	local startTick = tick()
	local duration = 0.5
	local startValue = oldValue
	local diff = newValue - startValue

	animateTween = game:GetService("RunService").RenderStepped:Connect(function()
		local elapsed = tick() - startTick
		if elapsed >= duration then
			label.Text = formatNumber(newValue)
			animateTween:Disconnect()
			animateTween = nil
			return
		end
		local progress = elapsed / duration
		local currentValue = startValue + diff * progress
		label.Text = formatNumber(math.floor(currentValue))
	end)
end

-- Setup events
local function setupEvents()
	currencyUpdated.OnClientEvent:Connect(function(currencyType, amount)
		if currencyType == "Rupiah" then
			local oldVal = balances.Rupiah
			balances.Rupiah = amount
			animateNumber(refs.rupiahLabel, oldVal, amount, false)
		elseif currencyType == "Gems" then
			local oldVal = balances.Gems
			balances.Gems = amount
			animateNumber(refs.gemsLabel, oldVal, amount, true)
			-- Sparkle effect
			TweenService:Create(refs.gemsLabel, TweenInfo.new(0.3), {TextColor3 = Theme.COLORS.JadeGlow}):Play()
		end
	end)

	balanceResponse.OnClientEvent:Connect(function(balance)
		balances = balance
		refs.rupiahLabel.Text = formatNumber(balance.Rupiah or 0)
		refs.gemsLabel.Text = formatNumber(balance.Gems or 0)
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("CurrencyHUD") then
			ui.Parent = playerGui
		end
	end
	-- Request initial balance
	requestBalance:FireServer()
end

init()

return {
	Toggle = function()
		if ui then
			ui.Enabled = not ui.Enabled
		end
	end,
}