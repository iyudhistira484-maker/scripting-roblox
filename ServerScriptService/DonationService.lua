-- DonationService.lua
-- Logik pelayan untuk Donation (Donasi Antar Pemain).
-- Letakkan di: ServerScriptService/DonationService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Donation")
local requestPlayersEvent = remotesFolder:WaitForChild("RequestPlayers")
local sendDonationEvent = remotesFolder:WaitForChild("SendDonation")

local DonationService = {}

-- State
local donationCooldown = {}
local MAX_DONATION_PER_HOUR = 50000
local COOLDOWN_BETWEEN_DONATIONS = 10

-- Handler: Request daftar pemain untuk donasi
local function handleRequestPlayers(player)
	local playersList = {}
	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player and targetPlayer.Parent then
			table.insert(playersList, {
				UserId = targetPlayer.UserId,
				Name = targetPlayer.Name,
				DisplayName = targetPlayer.DisplayName or targetPlayer.Name,
				Level = PlayerDataService:GetField(targetPlayer, "Level") or 1,
			})
		end
	end

	local responseEvent = remotesFolder:FindFirstChild("PlayersResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "PlayersResponse"
		responseEvent.Parent = remotesFolder
	end
	responseEvent:FireClient(player, playersList)
end

-- Handler: Kirim donasi
local function handleSendDonation(player, targetUserId, currencyType, amount)
	-- Validasi input
	if not targetUserId or typeof(targetUserId) ~= "number" then return end
	if not currencyType or typeof(currencyType) ~= "string" then return end
	if not amount or typeof(amount) ~= "number" or amount <= 0 then return end

	-- Cari pemain target
	local targetPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p.UserId == targetUserId then
			targetPlayer = p
			break
		end
	end
	if not targetPlayer then
		return
	end

	-- Cek cooldown
	local lastDonation = donationCooldown[player.UserId] or 0
	if tick() - lastDonation < COOLDOWN_BETWEEN_DONATIONS then
		return
	end

	-- Validasi currency type
	if currencyType ~= "Rupiah" and currencyType ~= "Gems" then
		return
	end

	-- Validasi saldo pemain yang mengirim
	local senderBalance = PlayerDataService:GetCurrency(player, currencyType)
	if senderBalance < amount then
		return
	end

	-- Cek maksimal donasi per jam
	if not donationCooldown[player.UserId .. "_hourly"] then
		donationCooldown[player.UserId .. "_hourly"] = { total = 0, resetTime = tick() + 3600 }
	end
	local hourlyData = donationCooldown[player.UserId .. "_hourly"]
	if tick() > hourlyData.resetTime then
		hourlyData.total = 0
		hourlyData.resetTime = tick() + 3600
	end
	if hourlyData.total + amount > MAX_DONATION_PER_HOUR then
		return
	end

	-- Validasi: jangan biarkan pemain mengirim uang ke diri sendiri
	if player.UserId == targetUserId then
		return
	end

	-- Proses transfer
	PlayerDataService:RemoveCurrency(player, currencyType, amount)
	PlayerDataService:AddCurrency(targetPlayer, currencyType, amount)
	PlayerDataService:Save(player)
	PlayerDataService:Save(targetPlayer)

	-- Update cooldown
	donationCooldown[player.UserId] = tick()
	hourlyData.total = hourlyData.total + amount

	-- Kirim notifikasi ke kedua pemain
	local resultEvent = remotesFolder:FindFirstChild("DonationResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "DonationResult"
		resultEvent.Parent = remotesFolder
	end

	-- Kirim ke pemain pengirim
	resultEvent:FireClient(player, targetPlayer.Name, currencyType, amount, true)
	-- Kirim ke pemain penerima
	resultEvent:FireClient(targetPlayer, player.Name, currencyType, amount, false)

	print(("Pemain %s mengirim %d %s ke %s"):format(player.Name, amount, currencyType, targetPlayer.Name))
end

-- Connect events
requestPlayersEvent.OnServerEvent:Connect(handleRequestPlayers)
sendDonationEvent.OnServerEvent:Connect(handleSendDonation)

-- API publik
function DonationService:CanDonate(player, targetPlayer, currencyType, amount)
	local senderBalance = PlayerDataService:GetCurrency(player, currencyType)
	return senderBalance >= amount
end

return DonationService