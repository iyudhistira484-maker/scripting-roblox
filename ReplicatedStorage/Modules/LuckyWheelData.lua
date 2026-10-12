-- LuckyWheelData.lua
-- Modul data statik untuk Lucky Wheel (Fitur 23).
-- Letakkan di: ReplicatedStorage/Modules/LuckyWheelData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local LuckyWheelData = {}

-- Daftar hadiah di roda dengan bobot
LuckyWheelData.Prizes = {
	{ Id = "Rupiah_1000", Prize = "1000 Rupiah", Type = "Currency", CurrencyType = "Rupiah", Amount = 1000, Weight = 25, Rarity = "Common" },
	{ Id = "Rupiah_500", Prize = "500 Rupiah", Type = "Currency", CurrencyType = "Rupiah", Amount = 500, Weight = 30, Rarity = "Common" },
	{ Id = "Rupiah_250", Prize = "250 Rupiah", Type = "Currency", CurrencyType = "Rupiah", Amount = 250, Weight = 35, Rarity = "Common" },
	{ Id = "Gems_5", Prize = "5 Gems", Type = "Currency", CurrencyType = "Gems", Amount = 5, Weight = 15, Rarity = "Uncommon" },
	{ Id = "Gems_10", Prize = "10 Gems", Type = "Currency", CurrencyType = "Gems", Amount = 10, Weight = 10, Rarity = "Rare" },
	{ Id = "Garam_Khusus", Prize = "Garam Khusus", Type = "Item", ItemId = "Garam_Seribu", Amount = 3, Weight = 5, Rarity = "Rare" },
	{ Id = "Minyak_Pelita_Bulk", Prize = "5x Minyak Pelita", Type = "Item", ItemId = "Minyak_Pelita", Amount = 5, Weight = 3, Rarity = "Epic" },
	{ Id = "Gems_50", Prize = "50 Gems", Type = "Currency", CurrencyType = "Gems", Amount = 50, Weight = 1, Rarity = "Legend" },
	{ Id = "Pedang_Emas", Prize = "Pedang Emas", Type = "Item", ItemId = "Pedang_Emas", Amount = 1, Weight = 0.5, Rarity = "Mythic" },
	{ Id = "Title_Rajabulan", Prize = "Title Rajabulan", Type = "Title", ItemId = "Title_Rajabulan", Amount = 1, Weight = 0.1, Rarity = "Mythic" },
}

LuckyWheelData.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Uncommon = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Rare = { Name = "Langka", Color = Theme.COLORS.Gold, Icon = "◆◆◆" },
	Epic = { Name = "Epik", Color = Theme.COLORS.Crimson, Icon = "◆◆◆◆" },
	Legend = { Name = "Legendaris", Color = Theme.COLORS.Gold, Icon = "◆◆◆◆◆" },
	Mythic = { Name = "Mitos", Color = Theme.COLORS.GoldHi, Icon = "◆◆◆◆◆" },
}

-- Harga tambahan untuk putaran tambahan
LuckyWheelData.EXTRA_SPIN_PRICE = 20 -- Gems per extra spin

-- Helper: Dapatkan total weight semua hadiah
function LuckyWheelData:GetTotalWeight()
	local total = 0
	for _, prize in ipairs(self.Prizes) do
		total = total + prize.Weight
	end
	return total
end

-- Helper: Dapatkan hadiah berdasarkan ID
function LuckyWheelData:GetPrizeById(id)
	for _, prize in ipairs(self.Prizes) do
		if prize.Id == id then
			return prize
		end
	end
	return nil
end

function LuckyWheelData:GetAll()
	return self.Prizes
end

function LuckyWheelData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

return LuckyWheelData