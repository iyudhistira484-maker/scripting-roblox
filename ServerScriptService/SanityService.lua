-- SanityService.lua
-- Logik pelayan untuk Sanity / Ketakutan (Fitur 21).
-- Letakkan di: ServerScriptService/SanityService.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

-- Muat modul
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

local SanityService = {}

-- Config
local SANITY_MAX = 100
local SANITY_MIN = 0
local DARK_AREA_THRESHOLD = 0.3 -- Lighting brightness di bawah ini = area gelap
local SANITY_LOSS_PER_SEC_DARK = 0.2
local SANITY_GAIN_PER_SEC_LIGHT = 0.5
local CHECK_INTERVAL = 5 -- per detik

-- State
local playerSanity = {}
local playerAreas = {} -- light status per pemain

-- Helper: Cek area terang/gelap
local function isAreaBright(position)
	if not position then return true end

	-- Hitung rata-rata brightness di area pemain
	local lightLevel = Lighting.Brightness
	
	-- Cek jarak ke sumber cahaya
	local nearestLight = math.huge
	for _, light in ipairs(workspace:GetChildren()) do
		if light:IsA("PointLight") or light:IsA("SurfaceLight") then
			local lightPos = light.Parent and light.Parent:IsA("BasePart") and light.Parent.Position
			if lightPos then
				local dist = (position - lightPos).magnitude
				if dist < nearestLight then
					nearestLight = dist
				end
			end
		end
	end

	-- Area dianggap terang jika dekat dengan cahaya atau lighting terang
	return lightLevel > DARK_AREA_THRESHOLD or nearestLight < 20
end

-- Get player stats modifier berdasarkan sanity
function SanityService:GetPlayerStatsModifier(player)
	local data = PlayerDataService:Get(player)
	local sanity = data.Sanity or 100

	local modifier = {
		MoveSpeed = 1.0,
		Damage = 1.0,
	}

	if sanity < 20 then
		-- Kritis: kecepatan & akurasi turun
		modifier.MoveSpeed = 0.8
		modifier.Damage = 0.8
	elseif sanity < 40 then
		modifier.MoveSpeed = 0.9
		modifier.Damage = 0.9
	elseif sanity < 70 then
		modifier.MoveSpeed = 0.95
		modifier.Damage = 0.95
	end

	return modifier
end

-- Check sanity setiap interval
coroutine.wrap(function()
	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local position = character.HumanoidRootPart.Position
				local isBright = isAreaBright(position)

				local data = PlayerDataService:Get(player)
				local currentSanity = data.Sanity or 100

				if isBright then
					-- Pulihkan sanity di area terang
					local newSanity = math.min(SANITY_MAX, currentSanity + SANITY_GAIN_PER_SEC_LIGHT * CHECK_INTERVAL)
					if newSanity ~= currentSanity then
						data.Sanity = newSanity
						PlayerDataService:Save(player)
					end
				else
					-- Turunkan sanity di area gelap
					local multiplier = 1.0
					-- Jika pemain pakai senter aktif, kurangi loss
					local equipped = data.Equipped or {}
					if equipped.Senjata and equipped.Senjata:find("Senter") then
						multiplier = 0.5
					end

					local newSanity = math.max(SANITY_MIN, currentSanity - SANITY_LOSS_PER_SEC_DARK * CHECK_INTERVAL * multiplier)
					if newSanity ~= currentSanity then
						data.Sanity = newSanity
						PlayerDataService:Save(player)

						-- Jika sanity rendah, trigger jumpscare lebih sering
 	if newSanity < 20 and math.random() < 0.3 then
 							local jumpscareModule = game.ServerScriptService:FindFirstChild("JumpscareTriggerService")
 							if jumpscareModule then
 								local jumpscareService = require(jumpscareModule)
 								if jumpscareService then
 									jumpscareService:Trigger(player, "Light")
 								end
 							end
 						end
					end
				end
			end
		end
		wait(CHECK_INTERVAL)
	end
end)()

-- Player join
Players.PlayerAdded:Connect(function(player)
	playerSanity[player] = 100
end)

-- API publik
function SanityService:GetSanity(player)
	local data = PlayerDataService:Get(player)
	return data.Sanity or 100
end

function SanityService:GetMaxSanity()
	return SANITY_MAX
end

return SanityService