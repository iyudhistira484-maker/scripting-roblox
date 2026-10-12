-- SettingsService.lua
-- Logik pelayan untuk mengelola pengaturan pemain
-- Letakkan di: ServerScriptService/SettingsService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

local SettingsService = {}

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Settings")
local updateSettingsEvent = remotesFolder:WaitForChild("UpdateSettings")

-- Validasi pengaturan yang diterima dari klien
local function validateSettings(settings)
	if typeof(settings) ~= "table" then
		return false, "Data tidak valid"
	end

	-- Validasi JumpscareIntensity
	local validIntensities = {"Full", "Reduced", "Off"}
	if settings.JumpscareIntensity then
		local valid = false
		for _, v in ipairs(validIntensities) do
			if v == settings.JumpscareIntensity then
				valid = true
				break
			end
		end
		if not valid then
			settings.JumpscareIntensity = "Full"
		end
	end

	-- Validasi Vibration (boolean)
	if settings.Vibration ~= nil then
		settings.Vibration = (settings.Vibration == true)
	end

	-- Validasi Brightness (0.1 - 3.0)
	if settings.Brightness then
		settings.Brightness = math.clamp(settings.Brightness, 0.1, 3.0)
	end

	-- Validasi FOV (30 - 120)
	if settings.FOV then
		settings.FOV = math.clamp(settings.FOV, 30, 120)
	end

	-- Validasi MusicVolume (0 - 1)
	if settings.MusicVolume then
		settings.MusicVolume = math.clamp(settings.MusicVolume, 0, 1)
	end

	return true, settings
end

-- Handler: Update settings dari klien
local function handleUpdateSettings(player, settings)
	-- Validasi
	local valid, result = validateSettings(settings)

	if not valid then
		warn(("Pengaturan tidak valid dari %s: %s"):format(player.Name, result))
		return
	end

	-- Simpan ke PlayerDataService
	local data = PlayerDataService:Get(player)
	if not data.Settings then
		data.Settings = {}
	end

	for key, value in pairs(result) do
		data.Settings[key] = value
	end

	PlayerDataService:_internal_fireChange(player, "Settings", data.Settings)
	PlayerDataService:Save(player)

	-- Notifikasi ke sistem lain yang butuh settings (misal: JumpscareService)
	local settingsChanged = game.ServerScriptService:FindFirstChild("SettingsChanged")
	if settingsChanged and settingsChanged:IsA("BindableEvent") then
		settingsChanged:Fire(player, result)
	end
end

-- Handler: Request settings dari klien
local requestSettingsEvent = remotesFolder:FindFirstChild("RequestSettings")
if not requestSettingsEvent then
	requestSettingsEvent = Instance.new("RemoteEvent")
	requestSettingsEvent.Name = "RequestSettings"
	requestSettingsEvent.Parent = remotesFolder
end

local settingsResponseEvent = remotesFolder:FindFirstChild("SettingsResponse")
if not settingsResponseEvent then
	settingsResponseEvent = Instance.new("RemoteEvent")
	settingsResponseEvent.Name = "SettingsResponse"
	settingsResponseEvent.Parent = remotesFolder
end

requestSettingsEvent.OnServerEvent:Connect(function(player)
	local data = PlayerDataService:Get(player)
	local settings = data.Settings or {
		JumpscareIntensity = "Full",
		Vibration = true,
		Brightness = 1,
		FOV = 70,
		MusicVolume = 0.5,
	}
	settingsResponseEvent:FireClient(player, settings)
end)

updateSettingsEvent.OnServerEvent:Connect(handleUpdateSettings)

-- API publik
function SettingsService:GetSettings(player)
	local data = PlayerDataService:Get(player)
	return data.Settings or {
		JumpscareIntensity = "Full",
		Vibration = true,
		Brightness = 1,
		FOV = 70,
		MusicVolume = 0.5,
	}
end

function SettingsService:GetJumpIntensity(player)
	local settings = self:GetSettings(player)
	return settings.JumpscareIntensity or "Full"
end

return SettingsService