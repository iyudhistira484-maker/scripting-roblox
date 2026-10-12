-- RemoteEventInit.lua
-- Skrip ini mencipta semua struktur RemoteEvent yang diperlukan untuk semua ciri.
-- Letakkan di: ServerScriptService/RemoteEventInit.lua
-- Ia harus dijalankan sekali saat permainan bermula untuk menyediakan semua RemoteEvent.

-- Cipta folder Remotes jika belum wujud
local replicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = replicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = replicatedStorage
end

-- Helper untuk mencipta folder & RemoteEvent
local function createRemoteFolder(folderName)
	local folder = remotesFolder:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = remotesFolder
	end
	return folder
end

-- Helper untuk mencipta RemoteEvent di dalam folder
local function createRemoteEvent(folder, eventName)
	local remote = folder:FindFirstChild(eventName)
	if not remote then
		remote = Instance.new("RemoteEvent")
		remote.Name = eventName
		remote.Parent = folder
	end
	return remote
end

-- ========================================
-- Feature 1: Ghost Collection (Jurnal Arwah)
-- ========================================
local ghostCollectionFolder = createRemoteFolder("GhostCollection")
createRemoteEvent(ghostCollectionFolder, "CaptureGhost")          -- Klien -> Pelayan: minta menangkap hantu
createRemoteEvent(ghostCollectionFolder, "GhostCaptured")         -- Pelayan -> Klien: beritahu penangkapan berjaya
createRemoteEvent(ghostCollectionFolder, "RequestCaughtGhosts")   -- Klien -> Pelayan: minta senarai hantu yang ditangkap
createRemoteEvent(ghostCollectionFolder, "CaughtGhostsResponse")  -- Pelayan -> Klien: hantar senarai bertangkapan

-- ========================================
-- Feature 2: Equipment (Alat Berburu)
-- ========================================
local equipmentFolder = createRemoteFolder("Equipment")
createRemoteEvent(equipmentFolder, "EquipItem")
createRemoteEvent(equipmentFolder, "UnequipItem")
createRemoteEvent(equipmentFolder, "RequestInventory")
createRemoteEvent(equipmentFolder, "InventoryResponse")
createRemoteEvent(equipmentFolder, "EquipmentUpdated")
createRemoteEvent(equipmentFolder, "PurchaseResult")

-- ========================================
-- Feature 3: Settings
-- ========================================
local settingsFolder = createRemoteFolder("Settings")
createRemoteEvent(settingsFolder, "UpdateSettings")
createRemoteEvent(settingsFolder, "RequestSettings")
createRemoteEvent(settingsFolder, "SettingsResponse")

-- ========================================
-- Feature 4: Achievement
-- ========================================
local achievementFolder = createRemoteFolder("Achievement")
createRemoteEvent(achievementFolder, "AchievementUnlocked")
createRemoteEvent(achievementFolder, "RequestProgress")
createRemoteEvent(achievementFolder, "ProgressResponse")

-- ========================================
-- Feature 5: Rank / Title
-- ========================================
local rankFolder = createRemoteFolder("Rank")
createRemoteEvent(rankFolder, "SelectRank")
createRemoteEvent(rankFolder, "RankUpdated")
createRemoteEvent(rankFolder, "RequestRanks")
createRemoteEvent(rankFolder, "RanksResponse")

-- ========================================
-- Feature 6: Emote
-- ========================================
 	local emoteFolder = createRemoteFolder("Emote")
 	createRemoteEvent(emoteFolder, "PlayEmote")
 	createRemoteEvent(emoteFolder, "RequestEmotes")
 	createRemoteEvent(emoteFolder, "EmotesResponse")
 	createRemoteEvent(emoteFolder, "EmotePlayed")

-- ========================================
-- Feature 7: Music Controller
-- ========================================
local musicFolder = createRemoteFolder("Music")
createRemoteEvent(musicFolder, "RequestMusicState")
createRemoteEvent(musicFolder, "MusicStateResponse")
createRemoteEvent(musicFolder, "UpdateMusicState")

-- ========================================
-- Feature 8: Black Market
-- ========================================
local blackMarketFolder = createRemoteFolder("BlackMarket")
createRemoteEvent(blackMarketFolder, "RequestStock")
createRemoteEvent(blackMarketFolder, "StockResponse")
createRemoteEvent(blackMarketFolder, "BuyItem")
createRemoteEvent(blackMarketFolder, "PurchaseResult")

-- ========================================
-- Feature 9: Gamepass
-- ========================================
local gamepassFolder = createRemoteFolder("Gamepass")
createRemoteEvent(gamepassFolder, "CheckOwnership")
createRemoteEvent(gamepassFolder, "OwnershipResponse")

-- ========================================
-- Feature 10: Donation
-- ========================================
local donationFolder = createRemoteFolder("Donation")
createRemoteEvent(donationFolder, "RequestPlayers")
createRemoteEvent(donationFolder, "PlayersResponse")
createRemoteEvent(donationFolder, "SendDonation")
createRemoteEvent(donationFolder, "DonationResult")

-- ========================================
-- Feature 11: Invite
-- ========================================
local inviteFolder = createRemoteFolder("Invite")
createRemoteEvent(inviteFolder, "PromptInvite")
createRemoteEvent(inviteFolder, "UseReferralCode")
createRemoteEvent(inviteFolder, "InviteResult")

-- ========================================
-- Feature 12: Shop
-- ========================================
local shopFolder = createRemoteFolder("Shop")
createRemoteEvent(shopFolder, "RequestItems")
createRemoteEvent(shopFolder, "ItemsResponse")
createRemoteEvent(shopFolder, "BuyItem")
createRemoteEvent(shopFolder, "PurchaseResult")

-- ========================================
-- Feature 13: Gacha
-- ========================================
local gachaFolder = createRemoteFolder("Gacha")
createRemoteEvent(gachaFolder, "RollGacha")
createRemoteEvent(gachaFolder, "RollResult")
createRemoteEvent(gachaFolder, "RequestHistory")
createRemoteEvent(gachaFolder, "HistoryResponse")

-- ========================================
-- Feature 14: Currency
-- ========================================
local currencyFolder = createRemoteFolder("Currency")
createRemoteEvent(currencyFolder, "CurrencyUpdated")
createRemoteEvent(currencyFolder, "RequestBalance")
createRemoteEvent(currencyFolder, "BalanceResponse")
createRemoteEvent(currencyFolder, "BuyGems")

-- ========================================
-- Feature 15: Jumpscare
-- ========================================
local jumpscareFolder = createRemoteFolder("Jumpscare")
createRemoteEvent(jumpscareFolder, "TriggerJumpscare")

-- ========================================
-- Feature 16: Quest
-- ========================================
local questFolder = createRemoteFolder("Quest")
createRemoteEvent(questFolder, "RequestQuests")
createRemoteEvent(questFolder, "QuestsResponse")
createRemoteEvent(questFolder, "ClaimReward")
createRemoteEvent(questFolder, "ClaimResult")

-- ========================================
-- Feature 17: Login Streak
-- ========================================
local loginStreakFolder = createRemoteFolder("LoginStreak")
createRemoteEvent(loginStreakFolder, "RequestStreak")
createRemoteEvent(loginStreakFolder, "StreakResponse")
createRemoteEvent(loginStreakFolder, "ClaimReward")
createRemoteEvent(loginStreakFolder, "ClaimResult")

-- ========================================
-- Feature 18: Skill Tree
-- ========================================
local skillTreeFolder = createRemoteFolder("SkillTree")
createRemoteEvent(skillTreeFolder, "RequestSkills")
createRemoteEvent(skillTreeFolder, "SkillsResponse")
createRemoteEvent(skillTreeFolder, "UnlockSkill")
createRemoteEvent(skillTreeFolder, "UnlockResult")

-- ========================================
-- Feature 19: Battle Pass
-- ========================================
local battlePassFolder = createRemoteFolder("BattlePass")
createRemoteEvent(battlePassFolder, "RequestBattlePass")
createRemoteEvent(battlePassFolder, "BattlePassResponse")
createRemoteEvent(battlePassFolder, "ClaimTierReward")
createRemoteEvent(battlePassFolder, "ClaimResult")
createRemoteEvent(battlePassFolder, "PurchasePremium")

-- ========================================
-- Feature 20: Trap
-- ========================================
local trapFolder = createRemoteFolder("Trap")
createRemoteEvent(trapFolder, "PlaceTrap")
createRemoteEvent(trapFolder, "TrapPlaced")
createRemoteEvent(trapFolder, "RequestTrapsOwned")
createRemoteEvent(trapFolder, "TrapsOwnedResponse")

-- ========================================
-- Feature 21: Sanity
-- ========================================
local sanityFolder = createRemoteFolder("Sanity")
createRemoteEvent(sanityFolder, "SanityUpdated")
createRemoteEvent(sanityFolder, "RequestSanity")
createRemoteEvent(sanityFolder, "SanityResponse")

-- ========================================
-- Feature 22: Skin
-- ========================================
local skinFolder = createRemoteFolder("Skin")
createRemoteEvent(skinFolder, "RequestSkins")
createRemoteEvent(skinFolder, "SkinsResponse")
createRemoteEvent(skinFolder, "EquipSkin")
createRemoteEvent(skinFolder, "SkinEquipped")

-- ========================================
-- Feature 23: Lucky Wheel
-- ========================================
local luckyWheelFolder = createRemoteFolder("LuckyWheel")
createRemoteEvent(luckyWheelFolder, "SpinWheel")
createRemoteEvent(luckyWheelFolder, "SpinResult")
createRemoteEvent(luckyWheelFolder, "RequestState")
createRemoteEvent(luckyWheelFolder, "StateResponse")

print("Semua RemoteEvent telah dicipta.")