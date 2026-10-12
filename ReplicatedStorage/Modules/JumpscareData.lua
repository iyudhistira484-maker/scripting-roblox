-- JumpscareData.lua
-- Data statik untuk Jump Scare (Fitur 15).
-- Letakkan di: ReplicatedStorage/Modules/JumpscareData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local JumpscareData = {}

JumpscareData.Types = {
	Light = {
		Id = "Light",
		Name = "Menggairahkan",
		Description = "Efek ringan untuk pemain sensitif",
		Effects = {
			ScreenFlash = false,
			ScreenShake = false,
			SoundSting = true,
			VignettePulse = true,
			Intensity = 0.3,
		},
		SoundId = "rbxassetid://567890123",
		Duration = 0.5,
	},
	Medium = {
		Id = "Medium",
		Name = "Sedang",
		Description = "Efek standar jumpscare",
		Effects = {
			ScreenFlash = true,
			ScreenShake = true,
			SoundSting = true,
			VignettePulse = true,
			Intensity = 0.7,
		},
		SoundId = "rbxassetid://567890124",
		Duration = 1.0,
	},
	Heavy = {
		Id = "Heavy",
		Name = "Berat",
		Description = "Efek penuh untuk pengalaman intens",
		Effects = {
			ScreenFlash = true,
			ScreenShake = true,
			SoundSting = true,
			VignettePulse = true,
			Darkness = true,
			Intensity = 1.0,
		},
		SoundId = "rbxassetid://567890125",
		Duration = 2.0,
	},
}

-- Mapping setting intensity -> jumpscare type
JumpscareData.INTENSITY_MAP = {
	["Full"] = "Heavy",
	["Reduced"] = "Medium",
	["Off"] = "Light",
}

-- Helper
function JumpscareData:GetById(id)
	return self.Types[id]
end

function JumpscareData:GetByIntensitySetting(setting)
	local typeId = self.INTENSITY_MAP[setting] or "Medium"
	return self:GetById(typeId)
end

return JumpscareData