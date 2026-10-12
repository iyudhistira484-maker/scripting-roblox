-- SanityController.lua
-- Kontrol efek visual/audio Sanity / Ketakutan
-- Letakkan di: StarterPlayer/StarterPlayerScripts/SanityController.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Theme = require(ReplicatedStorage.Modules.Theme)
local UIHelpers = require(ReplicatedStorage.Modules.AchievementUIHelpers)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Sanity")
local sanityUpdated = remotes:WaitForChild("SanityUpdated")
local requestSanity = remotes:WaitForChild("RequestSanity")
local sanityResponse = remotes:WaitForChild("SanityResponse")

-- State
local ui, refs = nil, {}
local currentSanity = 100
local maxSanity = 100
local settings = {
	JumpscareIntensity = "Full",
	Vibration = true,
}
local vignette = nil
local heartbeatSound = nil
local whisperSounds = {}

-- Helper functions
local function newUICorner(r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); return c end
local function newUIStroke(c, t) local s = Instance.new("UIStroke"); s.Color = c or Theme.COLORS.Gold; s.Thickness = t or 1; return s end

-- Load settings
local function loadSettings()
	local settingsRemotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Settings")
	local requestSettings = settingsRemotes:WaitForChild("RequestSettings")
	local settingsResponse = settingsRemotes:WaitForChild("SettingsResponse")

	settingsResponse.OnClientEvent:Connect(function(settingsData)
		if settingsData then
			settings.JumpscareIntensity = settingsData.JumpscareIntensity or "Full"
			settings.Vibration = settingsData.Vibration or true
		end
	end)

	delay(1, function()
		requestSettings:FireServer()
	end)
end

-- Create vignette overlay
local function createVignette()
	local screenGui = playerGui:FindFirstChild("SanityEffects")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SanityEffects"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
	end

	vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.Position = UDim2.new(0, 0, 0, 0)
	vignette.BackgroundColor3 = Theme.COLORS.Void
	vignette.BorderSizePixel = 0
	vignette.BackgroundTransparency = 1
	vignette.ZIndex = 50
	vignette.Parent = screenGui

	return vignette
end

-- Create heartbeat sound
local function createHeartbeat()
	if heartbeatSound then return heartbeatSound end

	local sound = Instance.new("Sound")
	sound.Name = "Heartbeat"
	sound.SoundId = "rbxassetid://987654321" -- Ganti dengan heartbeat sound ID
	sound.Volume = 0
	sound.Looped = true
	sound.Parent = workspace
	heartbeatSound = sound
end

-- Update visual effects berdasarkan sanity
local function updateSanityEffects(sanity, intensity)
	if not vignette then
		createVignette()
	end

	-- Hitung intensity vignette (0 = tidak terlihat, 1 = penuh)
	local effectIntensity = math.clamp(1 - (sanity / maxSanity), 0, 1)
	effectIntensity = effectIntensity * 0.7 -- maksimal 70% kegelapan

	-- Jika setting "Off" atau "Reduced", kurangi efek
	if settings.JumpscareIntensity == "Off" then
		effectIntensity = effectIntensity * 0.3
	elseif settings.JumpscareIntensity == "Reduced" then
		effectIntensity = effectIntensity * 0.6
	end

	-- Update vignette
	TweenService:Create(vignette, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1 - effectIntensity
	}):Play()

	-- Update heartbeat sound
	if sanity < 30 then
		if not heartbeatSound then createHeartbeat() end
		heartbeatSound.PlaybackSpeed = 1.0 + ((30 - sanity) / 30) * 2 -- semakin cepat saat kritis
		heartbeatSound.Volume = (30 - sanity) / 30 * 0.5
		if not heartbeatSound.IsPlaying then
			heartbeatSound:Play()
		end
	else
		if heartbeatSound and heartbeatSound.IsPlaying then
			TweenService:Create(heartbeatSound, TweenInfo.new(1), {Volume = 0}):Play()
			delay(1, function()
				if heartbeatSound then
					heartbeatSound:Stop()
				end
			end)
		end
	end

	-- Screen distortion (blur) saat kritis
	if sanity < 20 then
		local camera = workspace.CurrentCamera
		if camera then
			if not camera:FindFirstChild("BlurEffect") then
				local blur = Instance.new("BlurEffect")
				blur.Name = "BlurEffect"
				blur.Size = 0
				blur.Parent = camera
			end
			TweenService:Create(camera.BlurEffect, TweenInfo.new(0.5), {Size = (20 - sanity) * 0.5}):Play()
		end
	else
		local camera = workspace.CurrentCamera
		if camera and camera:FindFirstChild("BlurEffect") then
			TweenService:Create(camera.BlurEffect, TweenInfo.new(1), {Size = 0}):Play()
			delay(1, function()
				if camera and camera:FindFirstChild("BlurEffect") then
					camera.BlurEffect:Destroy()
				end
			end)
		end
	end

	-- Update HUD
	if refs.sanityBar then
		local percent = sanity / maxSanity
		refs.sanityBar.Size = UDim2.new(percent, 0, 1, 0)
		refs.sanityBar.BackgroundColor3 = percent < 0.3 and Theme.COLORS.Crimson or (percent < 0.6 and Theme.COLORS.Gold or Theme.COLORS.JadeGlow)
	end
end

-- Build sanity HUD
local function createHUD()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SanityHUD"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Minimal indikator di pojok
	local container = Instance.new("Frame")
	container.Name = "SanityContainer"
	container.Size = UDim2.new(0, 120, 0, 16)
	container.Position = UDim2.new(0, 15, 0, 80)
	container.BackgroundTransparency = 1
	container.Parent = screenGui

	local barBG = Instance.new("Frame")
	barBG.Name = "BarBackground"
	barBG.Size = UDim2.new(1, 0, 1, 0)
	barBG.BackgroundColor3 = Theme.COLORS.Void
	barBG.BorderSizePixel = 0
	newUICorner(8):Parent = barBG
	barBG.Parent = container

	refs.sanityBar = Instance.new("Frame")
	refs.sanityBar.Name = "SanityFill"
	refs.sanityBar.Size = UDim2.new(1, 0, 1, 0)
	refs.sanityBar.BackgroundColor3 = Theme.COLORS.JadeGlow
	refs.sanityBar.BorderSizePixel = 0
	newUICorner(8):Parent = refs.sanityBar
	refs.sanityBar.Parent = barBG

	return screenGui, container
end

-- Setup events
local function setup()
	loadSettings()
	createHUD()
	createVignette()
	createHeartbeat()

	sanityUpdated.OnClientEvent:Connect(function(sanity)
		currentSanity = sanity
		updateSanityEffects(sanity, 1)
	end)

	-- Request initial sanity
	delay(1, function()
		requestSanity:FireServer()
	end)
end

setup()

return {
	GetSanity = function() return currentSanity end,
	GetMaxSanity = function() return maxSanity end,
}
