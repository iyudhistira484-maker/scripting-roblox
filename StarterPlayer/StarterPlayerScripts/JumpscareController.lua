-- JumpscareController.lua
-- Kontrol efek visual/audio Jump Scare di client.
-- Letakkan di: StarterPlayer/StarterPlayerScripts/JumpscareController.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local JumpscareData = require(ReplicatedStorage.Modules.JumpscareData)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Jumpscare")
local triggerEvent = remotes:WaitForChild("TriggerJumpscare")

-- State
local settings = {
	JumpscareIntensity = "Full",
	Vibration = true,
}
local activeEffects = {}

-- Helper: Get screen gui
local function getScreenGui()
	local screenGui = playerGui:FindFirstChild("JumpscareEffects")
	if not screenGui then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "JumpscareEffects"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = playerGui
	end
	return screenGui
end

-- Effect: Screen flash
local function screenFlash(intensity, duration)
	local screenGui = getScreenGui()
	local flash = Instance.new("Frame")
	flash.Name = "Flash"
	flash.Size = UDim2.new(1, 0, 1, 0)
	flash.Position = UDim2.new(0, 0, 0, 0)
	flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	flash.BorderSizePixel = 0
	flash.BackgroundTransparency = 1
	flash.ZIndex = 100
	flash.Parent = screenGui

	TweenService:Create(flash, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1 - (intensity * 0.3)
	}):Play()

	delay(duration, function()
		TweenService:Create(flash, TweenInfo.new(duration * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1
		}):Play()
		delay(duration * 0.3, function()
			if flash and flash.Parent then
				flash:Destroy()
			end
		end)
	end)
end

-- Effect: Screen shake
local function screenShake(intensity, duration)
	local camera = workspace.CurrentCamera
	if not camera then return end

	local originalCFrame = camera.CFrame
	local shakeIntensity = intensity * 0.5
	local elapsed = 0

	local conn
	conn = RunService.RenderStepped:Connect(function(dt)
		elapsed = elapsed + dt
		if elapsed >= duration then
			camera.CFrame = originalCFrame
			conn:Disconnect()
			return
		end

		local offset = Vector3.new(
			(math.random() - 0.5) * shakeIntensity,
			(math.random() - 0.5) * shakeIntensity,
			(math.random() - 0.5) * shakeIntensity
		)
		camera.CFrame = originalCFrame * CFrame.new(offset)
	end)

	delay(duration, function()
		camera.CFrame = originalCFrame
	end)
end

-- Effect: Vignette pulse
local function vignettePulse(intensity, duration)
	local screenGui = getScreenGui()
	local vignette = Instance.new("Frame")
	vignette.Name = "Vignette"
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.Position = UDim2.new(0, 0, 0, 0)
	vignette.BackgroundColor3 = Theme.COLORS.Void
	vignette.BorderSizePixel = 0
	vignette.BackgroundTransparency = 1 - (intensity * 0.5)
	vignette.ZIndex = 99
	vignette.Parent = screenGui

	TweenService:Create(vignette, TweenInfo.new(duration * 0.3), {
		BackgroundTransparency = 1
	}):Play()

	delay(duration, function()
		if vignette and vignette.Parent then
			vignette:Destroy()
		end
	end)
end

-- Effect: Sound sting
local function playSoundSting(soundId, volume)
	local sound = Instance.new("Sound")
	sound.Name = "JumpscareSound"
	sound.SoundId = soundId
	sound.Volume = volume or 1
	sound.Parent = game.Workspace

	-- Wait for sound to load
	sound:Play()
	delay(3, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
end

-- Effect: Haptic feedback (mobile)
local function triggerHaptic()
	if not settings.Vibration then return end

	local hapticService = game:GetService("HapticService")
	if hapticService then
		local success = pcall(function()
			hapticService:StartVibration(0, 1, Enum.VibrationMotor("LARGE_MOTOR"))
		end)
	end
end

-- Main: Execute jumpscare
local function executeJumpscare(jumpscareType)
	if not jumpscareType then
		jumpscareType = JumpscareData:GetByIntensitySetting("Medium")
	end

	local effects = jumpscareType.Effects
	local intensity = effects.Intensity or 0.5

	-- Flash
	if effects.ScreenFlash then
		screenFlash(intensity, jumpscareType.Duration)
	end

	-- Screen shake
	if effects.ScreenShake then
		screenShake(intensity, jumpscareType.Duration)
	end

	-- Sound
	if effects.SoundSting and jumpscareType.SoundId then
		playSoundSting(jumpscareType.SoundId, intensity)
	end

	-- Vignette
	if effects.VignettePulse then
		vignettePulse(intensity, jumpscareType.Duration)
	end

	-- Haptic
	triggerHaptic()

	-- Darkness effect
	if effects.Darkness then
		local originalBrightness = Lighting.Brightness
		Lighting.Brightness = 0
		delay(jumpscareType.Duration, function()
			TweenService:Create(Lighting, TweenInfo.new(0.5), {Brightness = originalBrightness}):Play()
		end)
	end
end

-- Read settings on init
local function loadSettings()
	local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Settings")
	local requestSettings = remotes:WaitForChild("RequestSettings")
	local settingsResponse = remotes:WaitForChild("SettingsResponse")

	settingsResponse.OnClientEvent:Connect(function(settingsData)
		if settingsData then
			settings.JumpscareIntensity = settingsData.JumpscareIntensity or "Full"
			settings.Vibration = settingsData.Vibration or true
		end
	end)

	-- Request initial settings
	delay(1, function()
		requestSettings:FireServer()
	end)
end

-- Setup
local function setup()
	triggerEvent.OnClientEvent:Connect(function(jumpscareType)
		executeJumpscare(jumpscareType)
	end)

	loadSettings()
end

setup()

return {
	Trigger = function(jumpscareType)
		executeJumpscare(jumpscareType)
	end,
}