-- MusicData.lua
-- Modul data statik untuk semua track musik latar.
-- Letakkan di: ReplicatedStorage/Modules/MusicData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local MusicData = {}

-- Format: Id, Nama, AssetId, Konteks Pemutaran
-- Konteks: "Menu", "Day", "Night", "Tense", "Encounter"
MusicData.Tracks = {
	{
		Id = "Menu_Theme",
		Name = "Menu Theme",
		AssetId = "rbxassetid://987654321",
		Context = "Menu",
		Loop = true,
		Crossfade = 3.0,
		Volume = 0.5,
	},
	{
		Id = "Day_Tycoon",
		Name = "Day Tycoon",
		AssetId = "rbxassetid://987654322",
		Context = "Day",
		Loop = true,
		Crossfade = 3.0,
		Volume = 0.5,
	},
	{
		Id = "Night_Hunt",
		Name = "Night Hunt",
		AssetId = "rbxassetid://987654323",
		Context = "Night",
		Loop = true,
		Crossfade = 4.0,
		Volume = 0.5,
	},
	{
		Id = "Tense_Ambient",
		Name = "Tense Ambient",
		AssetId = "rbxassetid://987654324",
		Context = "Tense",
		Loop = true,
		Crossfade = 2.0,
		Volume = 0.6,
	},
	{
		Id = "Encounter_Scare",
		Name = "Encounter Scare",
		AssetId = "rbxassetid://987654325",
		Context = "Encounter",
		Loop = true,
		Crossfade = 1.0,
		Volume = 0.7,
	},
	{
		Id = "Victory_Jingle",
		Name = "Victory Jingle",
		AssetId = "rbxassetid://987654326",
		Context = "Victory",
		Loop = false,
		Crossfade = 2.0,
		Volume = 0.5,
	},
}

-- Mapping konteks ke track
MusicData.CONTEXT_MAP = {
	Menu = "Menu_Theme",
	TycoonDay = "Day_Tycoon",
	HuntingNight = "Night_Hunt",
	Tense = "Tense_Ambient",
	Encounter = "Encounter_Scare",
	Victory = "Victory_Jingle",
}

-- Helper: Dapatkan track berdasarkan ID
function MusicData:GetById(id)
	for _, track in ipairs(self.Tracks) do
		if track.Id == id then
			return track
		end
	end
	return nil
end

-- Helper: Dapatkan track berdasarkan konteks
function MusicData:GetByContext(context)
	local trackId = self.CONTEXT_MAP[context]
	if trackId then
		return self:GetById(trackId)
	end
	return self:GetById("Menu_Theme")
end

-- Helper: Dapatkan semua tracks
function MusicData:GetAll()
	return self.Tracks
end

return MusicData