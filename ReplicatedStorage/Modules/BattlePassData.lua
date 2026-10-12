-- BattlePassData.lua
-- Modul data statik untuk Battle Pass (Fitur 19).
-- Letakkan di: ReplicatedStorage/Modules/BattlePassData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local BattlePassData = {}

-- Konfigurasi season
BattlePassData.Season = {
	Id = "Season_1",
	Name = "Musim Pertama: Arwah Bangun",
	StartDate = "2024-01-01",
	EndDate = "2024-02-28",
	TotalTiers = 50,
	PremiumPrice = 50, -- Gems
	ResetType = "Monthly",
}

-- Reward per tier (Free vs Premium)
BattlePassData.Tiers = {}

-- Generate tiers
for i = 1, 50 do
	local tier = {
		Id = "Tier_" .. i,
		Level = i,
		FreeReward = {},
		PremiumReward = {},
	}

	-- Free rewards (setiap 5 tier dapat reward)
	if i % 5 == 0 then
		tier.FreeReward = { Rupiah = 500 * (i / 5) }
	end
	if i % 3 == 0 then
		tier.FreeReward = tier.FreeReward or {}
		table.insert(tier.FreeReward, { Type = "EmoteFragment", Amount = i })
	end

	-- Premium rewards (lebih banyak)
	if i % 2 == 0 then
		tier.PremiumReward = { Gems = 3 * (i / 2) }
	end
	if i % 5 == 0 then
		tier.PremiumReward = tier.PremiumReward or {}
		table.insert(tier.PremiumReward, { Type = "Rupiah", Amount = 1000 * (i / 5) })
	end
	if i == 10 or i == 25 or i == 40 then
		table.insert(tier.PremiumReward, { Type = "Skin", ItemId = "Premium_" .. i })
	end
	if i == 50 then
		tier.PremiumReward[#tier.PremiumReward + 1] = { Type = "Title", Name = "Penakluk Arwah" }
	end

	BattlePassData.Tiers[i] = tier
end

-- EXP yang dibutuhkan per tier
BattlePassData.XP_PER_TIER = 200

return BattlePassData