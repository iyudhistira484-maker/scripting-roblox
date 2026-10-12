-- InviteService.lua
-- Logik pelayan untuk Invite System (Ajak Teman via Referral).
-- Letakkan di: ServerScriptService/InviteService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Muat modul
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Invite")
local useReferralEvent = remotesFolder:WaitForChild("UseReferralCode")

local InviteService = {}

-- Config
local INVITE_REWARD_RUPIAH = 1000
local INVITER_REWARD_GEMS = 10
local INVITEE_REWARD_RUPIAH = 2000
local MIN_LEVEL_FOR_REWARD = 3

-- Handler: Gunakan kode referral
local function handleUseReferralCode(player, referralCode)
	-- Validasi
	if not referralCode or typeof(referralCode) ~= "string" or #referralCode < 3 then
		return
	end

	local data = PlayerDataService:Get(player)

	-- Cek apakah pemain sudah punya kode referral
	if data.InvitedBy and data.InvitedBy ~= "" then
		return
	end

	-- Cari pemain yang memiliki kode referral ini
	local inviterPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		local inviterData = PlayerDataService:Get(p)
		if inviterData.ReferralCode and inviterData.ReferralCode == referralCode then
			inviterPlayer = p
			break
		end
	end

	if not inviterPlayer then
		return
	end

	-- Validasi: tidak bisa invite ke diri sendiri
	if inviterPlayer == player then
		return
	end

	-- Simpan invitation
	data.InvitedBy = referralCode
	PlayerDataService:Save(player)

	-- Cek apakah inviter sudah dapat reward dari pemain ini
	local inviterData = PlayerDataService:Get(inviterPlayer)
	if not inviterData.InviteRewards then
		inviterData.InviteRewards = {}
	end
	if inviterData.InviteRewards[player.UserId] then
		return
	end

	-- Beri reward ke inviter (saat invitee mencapai level 3)
	local function checkAndGiveInviterReward()
		local currentLevel = data.Level or 1
		if currentLevel >= MIN_LEVEL_FOR_REWARD then
			PlayerDataService:AddCurrency(inviterPlayer, "Gems", INVITER_REWARD_GEMS)
			PlayerDataService:Save(inviterPlayer)
			inviterData.InviteRewards[player.UserId] = true
			PlayerDataService:Save(inviterPlayer)
		end
	end

	-- Beri reward ke invitee saat join
	PlayerDataService:AddCurrency(player, "Rupiah", INVITEE_REWARD_RUPIAH)
	PlayerDataService:Save(player)

	-- Cek level setiap kali pemain naik level
	local function onLevelUp(newLevel)
		if newLevel >= MIN_LEVEL_FOR_REWARD then
			checkAndGiveInviterReward()
		end
	end

	-- Listen level up (via BindableEvent)
	local levelUpEvent = game.ServerScriptService:FindFirstChild("LevelUpInternal")
	if levelUpEvent and levelUpEvent:IsA("BindableEvent") then
		levelUpEvent.Event:Connect(function(p, newLevel)
			if p == player then
				onLevelUp(newLevel)
			end
		end)
	end

	-- Cek level saat ini juga
	if (data.Level or 1) >= MIN_LEVEL_FOR_REWARD then
		checkAndGiveInviterReward()
	end

	-- Kirim notifikasi
	local resultEvent = remotesFolder:FindFirstChild("InviteResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "InviteResult"
		resultEvent.Parent = remotesFolder
	end

	resultEvent:FireClient(player, true, inviterPlayer.Name, INVITEE_REWARD_RUPIAH, INVITER_REWARD_GEMS)
	resultEvent:FireClient(inviterPlayer, false, player.Name, INVITER_REWARD_GEMS)

	print(("Pemain %s bergabung dengan kode referral dari %s"):format(player.Name, inviterPlayer.Name))
end

-- Generate referral code untuk pemain baru
local function generateReferralCode(player)
	local data = PlayerDataService:Get(player)
	if data.ReferralCode and data.ReferralCode ~= "" then
		return data.ReferralCode
	end

	-- Generate kode: inisiaNama + 4 digit angka
	local shortName = player.Name:sub(1, 3):upper()
	local numbers = tostring(math.random(1000, 9999))
	local code = shortName .. numbers

	-- Cek unik
	local existingCodes = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local pdata = PlayerDataService:Get(p)
		if pdata.ReferralCode then
			existingCodes[pdata.ReferralCode] = true
		end
	end

	while existingCodes[code] do
		numbers = tostring(math.random(1000, 9999))
		code = shortName .. numbers
	end

	data.ReferralCode = code
	PlayerDataService:Save(player)
	return code
end

-- Connect events
useReferralEvent.OnServerEvent:Connect(handleUseReferralCode)

-- Generate kode saat pemain bergabung
Players.PlayerAdded:Connect(function(player)
	generateReferralCode(player)
end)

-- API publik
function InviteService:GetPlayerCode(player)
	local data = PlayerDataService:Get(player)
	return data.ReferralCode or ""
end

function InviteService:GetInviteProgress(player)
	local data = PlayerDataService:Get(player)
	local inviteCount = 0
	for _ in pairs(data.InviteRewards or {}) do
		inviteCount = inviteCount + 1
	end
	return inviteCount
end

return InviteService