-- MusicController.lua
-- Kontrol pemutaran musik latar dengan crossfade.
-- Letakkan di: StarterPlayer/StarterPlayerScripts/MusicController.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Muat modul
local Theme = require(ReplicatedStorage.Modules.Theme)
local MusicData = require(ReplicatedStorage.Modules.MusicData)

-- RemoteEvents
local remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Music")
local requestMusicState = remotes:WaitForChild("RequestMusicState")
local musicStateResponse = remotes:WaitForChild("MusicStateResponse")
local updateMusicState = remotes:WaitForChild("UpdateMusicState")

-- State
local currentContext = "Menu"
local currentTrack = nil
local musicEnabled = true
local musicVolume = 0.5

-- Sound group untuk musik
local musicGroup = SoundService:FindFirstChild("Music")
if not musicGroup then
	musicGroup = Instance.new("SoundGroup")
	musicGroup.Name = "Music"
	musicGroup.Parent = SoundService
end
musicGroup.Volume = musicVolume

-- Suara saat ini
local currentSound = nil
local previousSound = nil

-- Buat suara baru
local function createSound(track)
	local sound = Instance.new("Sound")
	sound.Name = track.Id
	sound.SoundId = track.AssetId
	sound.Volume = track.Volume * musicVolume
	sound.Looped = track.Loop
	sound.SoundGroup = musicGroup
	sound.Parent = musicGroup
	return sound
end

-- Crossfade dari suara sebelumnya ke suara baru
local function crossfadeToTrack(track, crossfadeTime)
	if not track then return end

	-- Simpan suara sebelumnya
	local oldSound = currentSound

	-- Buat suara baru
	local newSound = createSound(track)
	newSound.Volume = 0  -- Mulai dari 0, lalu fade in

	-- Mulai mainkan
	newSound:Play()

	-- Fade in suara baru
	TweenService:Create(newSound, TweenInfo.new(crossfadeTime or track.Crossfade or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = track.Volume * musicVolume
	}):Play()

	-- Fade out suara lama jika ada
	if oldSound then
		TweenService:Create(oldSound, TweenInfo.new(crossfadeTime or track.Crossfade or 3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 0
		}):Play()

		-- Hapus setelah fade out selesai
		delay(crossfadeTime or track.Crossfade or 3, function()
			if oldSound and oldSound.Parent then
				oldSound:Destroy()
			end
		end)
	end

	currentSound = newSound
end

-- Perbarui volume musik
local function updateVolume()
	musicGroup.Volume = musicVolume
	-- Update semua suara yang sedang dimainkan
	if currentSound then
		local track = MusicData:GetById(currentSound.Name)
		if track then
			currentSound.Volume = track.Volume * musicVolume
		end
	end
end

-- Transisi ke konteks baru
local function transitionToContext(context, immediate)
	if context == currentContext and currentSound then
		return
	end

	currentContext = context
	local track = MusicData:GetByContext(context)

	if not track then
		return
	end

	if not musicEnabled then
		-- Hanya update state, jangan mainkan musik
		if currentSound then
			currentSound:Stop()
		end
		return
	end

	if immediate then
		-- Stop suara lama langsung
		if currentSound then
			currentSound:Stop()
			currentSound:Destroy()
		end
		currentSound = nil
	end

	crossfadeToTrack(track, immediate and 0 or track.Crossfade)

	-- Kirim ke server tentang state
	updateMusicState:FireServer({
		Context = context,
		TrackId = track.Id,
		Enabled = musicEnabled,
		Volume = musicVolume,
	})
end

-- Handler: Respons state musik dari server
musicStateResponse.OnClientEvent:Connect(function(state)
	if state then
		musicEnabled = state.Enabled
		if state.Volume then
			musicVolume = state.Volume
		end
		updateVolume()

		-- Jika konteks berbeda, transition
		if state.Context and state.Context ~= currentContext then
			transitionToContext(state.Context)
		end
	end
end)

-- Handler: Update musik state dari server (sync dari pemain lain)
updateMusicState.OnClientEvent:Connect(function(state)
	if not state then return end
	-- Hanya terima jika bukan dari pemain kita
	local fromPlayer = state.Player
	if fromPlayer and fromPlayer == player then return end

	if state.Context then
		transitionToContext(state.Context, true)
	end
end)

-- Inisialisasi saat game dimulai
local function init()
	-- Minta state awal dari server
	requestMusicState:FireServer()

	-- Mulai dengan konteks menu
	delay(1, function()
		transitionToContext("Menu", true)
	end)
end

-- Delay untuk memastikan semua modul siap
if RunService:IsStudio() then
	init()
else
	delay(2, init)
end

-- Export fungsi untuk penggunaan eksternal
return {
	SetContext = function(context, immediate)
		transitionToContext(context, immediate)
	end,

	GetContext = function()
		return currentContext
	end,

	SetEnabled = function(enabled)
		musicEnabled = enabled
		if currentSound then
			if enabled then
				currentSound:Resume()
			else
				currentSound:Pause()
			end
		end
	end,

	SetVolume = function(volume)
		musicVolume = math.clamp(volume, 0, 1)
		updateVolume()
	end,
}