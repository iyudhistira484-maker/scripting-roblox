-- TrapController.lua
-- Kontrol pemasangan trap di client
-- Letakkan di: StarterPlayer/StarterPlayerScripts/TrapController.lua

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local TrapData = require(ReplicatedStorage.Modules.TrapData)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Trap")
local placeTrap = remotes:WaitForChild("PlaceTrap")
local trapPlaced = remotes:WaitForChild("TrapPlaced")
local requestTraps = remotes:WaitForChild("RequestTrapsOwned")
local trapsResponse = remotes:WaitForChild("TrapsOwnedResponse")

local ui, refs = nil, {}
local isOpen = false
local ownedTraps = {}
local selectedTrap = nil
local preview = nil
local isPlacing = false

local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end

-- Buat preview ghost trap
local function createPreview(trapId)
	if not trapId then return end
	local trap = TrapData:GetById(trapId)
	if not trap then return end

	-- Hapus preview lama
	if preview then preview:Destroy() end

	preview = Instance.new("Part")
	preview.Name = "TrapPreview"
	preview.Size = Vector3.new(trap.Stats.Radius * 2, 1, trap.Stats.Radius * 2)
	preview.Transparency = 0.7
	preview.CanCollide = false
	preview.Anchored = true
	preview.BrickColor = BrickColor.new(247, 121, 121)
	preview.Material = Enum.Material.Neon
	preview.Parent = workspace

	-- Update posisi mengikuti karakter
	return true
end

-- Destroy preview
local function destroyPreview()
	if preview then
		preview:Destroy()
		preview = nil
	end
end

-- Start placing mode
local function startPlacing()
	if not selectedTrap then return end
	 	isPlacing = true
	createPreview(selectedTrap)

	-- Lock mouse
	game:GetService("UserInputService"):SetMouseBehavior(Enum.MouseBehavior.LockCenter)
end

-- Stop placing mode
local function stopPlacing()
		isPlacing = false
	destroyPreview()
	game:GetService("UserInputService"):SetMouseBehavior(Enum.MouseBehavior.Default)
end

-- Build UI
local function createBaseUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TrapController"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = true

	-- Hotbar panel
	local hotbar = Instance.new("Frame")
	hotbar.Name = "Hotbar"
	hotbar.Size = UDim2.new(0, 300, 0, 50)
	hotbar.Position = UDim2.new(0.5, -150, 1, -60)
	hotbar.BackgroundColor3 = Theme.COLORS.Card
	hotbar.BorderSizePixel = 0
	newUICorner(8):Parent = hotbar
	newUIStroke(Theme.COLORS.Gold, 1):Parent = hotbar
	hotbar.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = 8
	layout.Parent = hotbar

 	-- Notification label
 	local notifyLabel = Instance.new("TextLabel")
 	notifyLabel.Name = "NotifyLabel"
 	notifyLabel.Size = UDim2.new(1, -20, 0, 24)
 	notifyLabel.Position = UDim2.new(0, 10, 0, -34)
 	notifyLabel.BackgroundTransparency = 1
 	notifyLabel.Font = Theme.FONTS.Label
 	notifyLabel.TextSize = 14
 	notifyLabel.TextColor3 = Theme.COLORS.Gold
 	notifyLabel.Text = ""
 	notifyLabel.Visible = false
 	notifyLabel.Parent = hotbar

 	-- Auto-hide notification setelah beberapa detik
 	notifyLabel:GetPropertyChangedSignal("Text"):Connect(function()
 		if notifyLabel.Text ~= "" then
 			notifyLabel.Visible = true
 			delay(3, function()
 				if notifyLabel.Text == "" then return end
 				notifyLabel.Text = ""
 				notifyLabel.Visible = false
 			end)
 		end
 	end)

 	refs = {
 		screenGui = screenGui,
 		hotbar = hotbar,
 		notifyLabel = notifyLabel,
 	}

	-- Request owned traps
	requestTraps:FireServer()

	-- Handle placement confirmation
	trapPlaced.OnClientEvent:Connect(function(trapId, position)
		-- Show success feedback
 		if refs.notifyLabel then
 			refs.notifyLabel.Text = " Trap berhasil ditempatkan!"
 		end
	end)

	-- Get traps owned response
	trapsResponse.OnClientEvent:Connect(function(traps)
		ownedTraps = traps
		populateHotbar()
	end)

	-- Render-stepped untuk update preview
	game:GetService("RunService").RenderStepped:Connect(function()
		if isPlacing and preview and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local rootPart = player.Character.HumanoidRootPart
			local direction = rootPart.CFrame.LookVector
			preview.CFrame = CFrame.new(rootPart.Position + direction * 5, rootPart.Position + direction * 5 + Vector3.new(0, 0.5, 0))
		end
	end)
end

-- Populate hotbar dengan trap yang dimiliki
local function populateHotbar()
	for _, child in ipairs(refs.hotbar:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	for i, trapId in ipairs(ownedTraps) do
		local trap = TrapData:GetById(trapId)
		if trap then
			local btn = Instance.new("TextButton")
			btn.Name = "Trap_" .. trapId
			btn.Size = UDim2.new(0, 44, 0, 44)
			btn.BackgroundColor3 = selectedTrap == trapId and Theme.COLORS.Gold : Theme.COLORS.Indigo
			btn.BorderSizePixel = 0
			btn.Font = Theme.FONTS.Label
			btn.Text = trap.Icon or "?"
			btn.TextSize = 18
			btn.AutoButtonColor = false
			newUICorner(6):Parent = btn
			local rarityColor = TrapData:GetRarityColor(trap.Rarity)
			newUIStroke(rarityColor, 1):Parent = btn
			btn.Parent = refs.hotbar

			btn.MouseButton1Click:Connect(function()
				selectedTrap = trapId
isPlacing = true
				createPreview(selectedTrap)
			end)
		end
	end
end

-- Setup input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.T then
 	if isPlacing then
			stopPlacing()
		elseif selectedTrap then
			startPlacing()
		end
 	end
 	if input.KeyCode == Enum.KeyCode.Escape and isPlacing then
		stopPlacing()
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
 	if input.KeyCode == Enum.KeyCode.MouseButton1 and isPlacing and preview then
		-- Tempatkan trap
		local position = preview.Position
		placeTrap:FireServer(selectedTrap, position)
		stopPlacing()
	end
end)

-- Init
local function init()
	if not ui then
		createBaseUI()
		ui = refs.screenGui
		if not playerGui:FindFirstChild("TrapController") then
			ui.Parent = playerGui
		end
	end
end

init()

return {
	SelectTrap = function(trapId)
		selectedTrap = trapId
	end,
	StartPlacing = startPlacing,
	StopPlacing = stopPlacing,
}
