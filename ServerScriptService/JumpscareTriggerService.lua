-- JumpscareTriggerService.lua
-- Logik pelayan untuk Jump Scare Trigger (Fitur 15).
-- Letakkan di: ServerScriptService/JumpscareTriggerService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local JumpscareData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("JumpscareData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Jumpscare")
local triggerEvent = remotesFolder:WaitForChild("TriggerJumpscare")

local JumpscareTriggerService = {}

-- Trigger jumpscare ke pemain tertentu
function JumpscareTriggerService:Trigger(player, intensityLevel)
	if not player or not player.Parent then return end

	-- Baca setting intensity dari pemain
	local settings = PlayerDataService:Get(player).Settings
	local intensity = intensityLevel or settings.JumpscareIntensity

	-- Dapatkan konfigurasi jumpscare berdasarkan setting
	local jumpscareType = JumpscareData:GetByIntensitySetting(intensity)

	-- Kirim ke target saja (bukan semua pemain)
	triggerEvent:FireClient(player, jumpscareType)

	print(("Jumpscare trigger ke %s dengan intensitas %s"):format(player.Name, intensity))
end

-- Trigger ke semua pemain (untuk event server-wide)
function JumpscareTriggerService:TriggerAll(intensityLevel)
	for _, player in ipairs(Players:GetPlayers()) do
		self:Trigger(player, intensityLevel)
	end
end

-- Trigger berdasarkan lokasi (area tertentu)
function JumpscareTriggerService:TriggerInArea(position, radius, intensityLevel)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - position).magnitude
			if distance <= radius then
				self:Trigger(player, intensityLevel)
			end
		end
	end
end

return JumpscareTriggerService