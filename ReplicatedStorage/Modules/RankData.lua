-- RankData.lua
-- Modul data statik untuk semua title/pangkat pemain.
-- Letakkan di: ReplicatedStorage/Modules/RankData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local RankData = {}

-- Daftar rank berdasarkan level
-- Format: MinLevel, Nama, Warna, Ikon, Deskripsi
RankData.Ranks = {
	{
		Id = "Pemburu_Pemula",
		Name = "Pemburu Pemula",
		Description = "Yang baru memulai perburuan arwah",
		MinLevel = 1,
		Color = Theme.COLORS.BoneDim,
		Icon = "◆",
		IconImage = "rbxasset://textures/Ranks/PemburuPemula.png",
	},
	{
		Id = "Pemburu_Dasar",
		Name = "Pemburu Dasar",
		Description = "Menguasai teknik dasar berburu",
		MinLevel = 5,
		Color = Theme.COLORS.JadeGlow,
		Icon = "◆◆",
		IconImage = "rbxasset://textures/Ranks/PemburuDasar.png",
	},
	{
		Id = "Penjelajah_Arwah",
		Name = "Penjelajah Arwah",
		Description = "Ahli menguak misteri arwah",
		MinLevel = 10,
		Color = Theme.COLORS.Gold,
		Icon = "◆◆◆",
		IconImage = "rbxasset://textures/Ranks/PenjelajahArwah.png",
	},
	{
		Id = "Penjaga_Gerbang",
		Name = "Penjaga Gerbang Arwah",
		Description = "Pemburu yang menjaga batas antara dunia",
		MinLevel = 20,
		Color = Theme.COLORS.Crimson,
		Icon = "◆◆◆◆",
		IconImage = "rbxasset://textures/Ranks/PenjagaGerbang.png",
	},
	{
		Id = "Legenda_Nusantara",
		Name = "Legenda Nusantara",
		Description = "Legenda yang tak terkalahkan",
		MinLevel = 35,
		Color = Theme.COLORS.GoldHi,
		Icon = "◆◆◆◆◆",
		IconImage = "rbxasset://textures/Ranks/LegendaNusantara.png",
	},
}

-- Helper: Dapatkan semua rank ID
function RankData:GetAllIds()
	local ids = {}
	for _, rank in ipairs(self.Ranks) do
		table.insert(ids, rank.Id)
	end
	return ids
end

-- Helper: Dapatkan rank berdasarkan ID
function RankData:GetById(id)
	for _, rank in ipairs(self.Ranks) do
		if rank.Id == id then
			return rank
		end
	end
	return nil
end

-- Helper: Dapatkan rank berdasarkan level pemain
function RankData:GetByLevel(level)
	local result = nil
	for _, rank in ipairs(self.Ranks) do
		if level >= rank.MinLevel then
			result = rank
		end
	end
	return result or self.Ranks[1]
end

-- Helper: Dapatkan semua rank yang harus sudah terbuka
function RankData:GetUnlockedRanks(level)
	local unlocked = {}
	for _, rank in ipairs(self.Ranks) do
		if level >= rank.MinLevel then
			table.insert(unlocked, rank)
		end
	end
	return unlocked
end

-- Helper: Dapatkan rarity color (menggunakan Theme)
function RankData:GetRankColor(id)
	local rank = self:GetById(id)
	if rank then
		return rank.Color
	end
	return Theme.COLORS.Bone
end

return RankData