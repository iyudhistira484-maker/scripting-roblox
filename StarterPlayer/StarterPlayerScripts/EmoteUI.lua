-- EmoteUI.lua
-- Antarmuka klien untuk Emote.
-- Letakkan di: StarterPlayer/StarterPlayerScripts/EmoteUI.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local EmoteData = require(ReplicatedStorage.Modules.EmoteData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Emote")
local playEmote = remotes:WaitForChild("PlayEmote")
local requestEmotes = remotes:WaitForChild("RequestEmotes")
local emotesResponse = remotes:WaitForChild("EmotesResponse")
local emotePlayed = remotes:WaitForChild("EmotePlayed")

-- State
local ui = nil
local refs = {}
local isOpen = false
local emoteList = {}
local isOpenPanel = false

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

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EmoteUI"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Toggle button (hotbar slot)
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleBtn"
	toggleBtn.Size = UDim2.new(0, 56, 0, 56)
	toggleBtn.Position = UDim2.new(0.5, -28, 1, -70)
	toggleBtn.BackgroundColor3 = Theme.COLORS.Card
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Font = Theme.FONTS.Label
	toggleBtn.Text = "🎭"
	toggleBtn.TextSize = 24
	toggleBtn.TextColor3 = Theme.COLORS.Gold
	toggleBtn.AutoButtonColor = false
	toggleBtn.Visible = false
	newUICorner(10):Parent = toggleBtn
	newUIStroke(Theme.COLORS.Gold, 1):Parent = toggleBtn
	toggleBtn.Parent = screenGui

	-- Panel emote (grid)
	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.new(0, 400, 0, 200)
	panel.Position = UDim2.new(0.5, -200, 1, -220)
	panel.BackgroundColor3 = Theme.COLORS.Panel
	panel.BorderSizePixel = 0
	panel.Visible = false
	panel.Parent = screenGui
	newUICorner(12):Parent = panel
	newUIStroke(Theme.COLORS.Gold, 1):Parent = panel

	-- Background dalam
	local bg = Instance.new("Frame")
	bg.Name = "Background"
	bg.Size = UDim2.new(1, -2, 1, -2)
	bg.Position = UDim2.new(0, 1, 0, 1)
	bg.BackgroundColor3 = Theme.COLORS.IndigoDeep
	bg.BorderSizePixel = 0
	newUICorner(10):Parent = bg
	bg.Parent = panel

	-- Diamond ornaments
	local ornamentPositions = {
		{UDim2.new(0, 6, 0, 6), Vector2.new(0, 0)},
		{UDim2.new(1, -6, 0, 6), Vector2.new(1, 0)},
	}
	for _, entry in ipairs(ornamentPositions) do
		local d = createDiamondOrnamentHelper(Theme.COLORS.GoldDim, 8, panel)
		d.Position = entry[1]
		d.AnchorPoint = entry[2]
	end

	-- Grid untuk emote
	local grid = Instance.new("Frame")
	grid.Name = "Grid"
	grid.Size = UDim2.new(1, -16, 1, -16)
	grid.Position = UDim2.new(0, 8, 0, 8)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.Parent = panel

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 56, 0, 56)
	gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
	gridLayout.FillDirection = Enum.FillDirection.Horizontal
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = grid

	refs = {
		screenGui = screenGui,
		toggleBtn = toggleBtn,
		panel = panel,
		grid = grid,
		gridLayout = gridLayout,
	}
end

-- Populate emote grid
local function populateGrid()
	for _, child in ipairs(refs.grid:GetChildren()) do
		if not child:IsA("UIGridLayout") then
			child:Destroy()
		end
	end

	for _, emote in ipairs(emoteList) do
		local rarityColor = Theme.COLORS.Gold
		if emote.Rarity then
			rarityColor = EmoteData:GetRarityColor(emote.Rarity)
		end

		local btn = Instance.new("TextButton")
		btn.Name = "Emote_" .. emote.Id
		btn.Size = UDim2.new(0, 56, 0, 56)
		btn.BackgroundColor3 = Theme.COLORS.Card
		btn.BorderSizePixel = 0
		btn.Font = Theme.FONTS.Label
		btn.Text = emote.Icon or "?"
		btn.TextSize = 24
		btn.TextColor3 = rarityColor
		btn.AutoButtonColor = false
		btn.Parent = refs.grid
		newUICorner(8):Parent = btn
		newUIStroke(rarityColor, 1):Parent = btn

		btn.MouseButton1Click:Connect(function()
			-- Kirim request ke server
			playEmote:FireServer(emote.Id)
			-- Tutup panel
			isOpen = false
			refs.panel.Visible = false
			refs.toggleBtn.Visible = false
		end)

		-- Hover effect
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Theme.COLORS.Indigo
			}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Theme.COLORS.Card
			}):Play()
		end)
	end
end

-- Show/hide panel emote
local function toggleEmotePanel()
	isOpen = not isOpen
	if isOpen then
		refs.panel.Visible = true
		refs.panel.Size = UDim2.new(0, 0, 0, 200)
		TweenService:Create(refs.panel, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 400, 0, 200)
		}):Play()
	else
		TweenService:Create(refs.panel, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 200)
		}):Play()
		delay(0.2, function()
			refs.panel.Visible = false
		end)
	end
end

-- Setup events
local function setupEvents()
	-- Toggle button muncul otomatis (bisa lewat hotbar)
	refs.toggleBtn.MouseButton1Click:Connect(toggleEmotePanel)

	-- Respons emote dari server
	emotesResponse.OnClientEvent:Connect(function(emotes)
		emoteList = emotes
		populateGrid()
	end)

	-- Dengar pemutaran emote oleh pemain lain
	emotePlayed.OnClientEvent:Connect(function(playerWho, animationId)
		if playerWho == player then
			-- Ini pemain kita sendiri - biarkan animation controller yang handle
			return
		end

		-- Cari karakter pemain yang memainkan emote
		local character = playerWho.Character or playerWho.CharacterAdded:Wait()
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local anim = Instance.new("Animation")
				anim.AnimationId = animationId
				local track = humanoid:LoadAnimation(anim)
				track:Play()

				-- Auto cleanup
				track.Ended:Connect(function()
					track:Destroy()
				end)
			end
		end
	end)

	-- Hotkey untuk toggle (tombol B)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.B then
			if not isOpen then
				-- Minta data emote dari server
				requestEmotes:FireServer()
				toggleEmotePanel()
			else
				toggleEmotePanel()
			end
		end
	end)
end

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		setupEvents()
		if not playerGui:FindFirstChild("EmoteUI") then
			ui.Parent = playerGui
		end
	end
	-- Minta data emote
	requestEmotes:FireServer()
end

init()

-- Export
return {
	Toggle = function()
		if ui then
			toggleEmotePanel()
		end
	end,
}