-- EmoteData.lua
-- Modul data statik untuk semua emote.
-- Letakkan di: ReplicatedStorage/Modules/EmoteData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local EmoteData = {}

-- Format: Id, AnimationId, Nama, Cara Dapatkan (gratis/beli/gacha), IconImage
EmoteData.Emotes = {
	-- Emote gratis
	{
		Id = "Salam",
		AnimationId = "rbxassetid://123456789",
		Name = "Salam",
		Source = "gratis",
		Description = "Memberi salam hormat",
		Icon = "👋",
		IconImage = "rbxasset://textures/Emotes/Salam.png",
	},
	{
		Id = "Senyum",
		AnimationId = "rbxassetid://123456790",
		Name = "Senyum",
		Source = "gratis",
		Description = "Senyum sopan",
		Icon = "😊",
		IconImage = "rbxasset://textures/Emotes/Senyum.png",
	},
	{
		Id = "Melayang",
		AnimationId = "rbxassetid://123456791",
		Name = "Melayang",
		Source = "beli",
		Price = { Rupiah = 500, Gems = 0 },
		Description = "Terbang sejenak seperti arwah",
		Icon = "🕊️",
		IconImage = "rbxasset://textures/Emotes/Melayang.png",
		Rarity = "Langka",
	},
	{
		Id = "Tarian_Kemenangan",
		AnimationId = "rbxassetid://123456792",
		Name = "Tarian Kemenangan",
		Source = "gacha",
		Description = "Merayakan kemenangan",
		Icon = "🎉",
		IconImage = "rbxasset://textures/Emotes/TarianKemenangan.png",
		Rarity = "Epic",
	},
	{
		Id = "Doa",
		AnimationId = "rbxassetid://123456793",
		Name = "Doa",
		Source = "beli",
		Price = { Rupiah = 300, Gems = 0 },
		Description = "Doa restu kepada sesama",
		Icon = "🙏",
		IconImage = "rbxasset://textures/Emotes/Doa.png",
		Rarity = "Umum",
	},
	{
		Id = "Ghost_Pose",
		AnimationId = "rbxassetid://123456794",
		Name = "Pose Arwah",
		Source = "gacha",
		Description = "Menirukan penampilan arwah",
		Icon = "👻",
		IconImage = "rbxasset://textures/Emotes/GhostPose.png",
		Rarity = "Mythic",
	},
	{
		Id = "Mimpi_Buruk",
		AnimationId = "rbxassetid://123456795",
		Name = "Mimpi Buruk",
		Source = "beli",
		Price = { Rupiah = 0, Gems = 10 },
		Description = "Berdiri seperti ilusi di batas kematian",
		Icon = "💀",
		IconImage = "rbxasset://textures/Emotes/MimpiBuruk.png",
		Rarity = "Legendaris",
	},
}

-- Rarity colors
EmoteData.RARITIES = {
	Umum = { Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Langka = { Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Legendaris = { Color = Theme.COLORS.Gold, Icon = "◆◆◆" },
	Epic = { Color = Theme.COLORS.Crimson, Icon = "◆◆◆◆" },
	Mythic = { Color = Theme.COLORS.GoldHi, Icon = "◆◆◆◆◆" },
}

-- Helper: Dapatkan semua emote ID
function EmoteData:GetAllIds()
	local ids = {}
	for _, emote in ipairs(self.Emotes) do
		table.insert(ids, emote.Id)
	end
	return ids
end

-- Helper: Dapatkan emote berdasarkan ID
function EmoteData:GetById(id)
	for _, emote in ipairs(self.Emotes) do
		if emote.Id == id then
			return emote
		end
	end
	return nil
end

-- Helper: Dapatkan semua emote yang bisa dibeli
function EmoteData:GetBuyable()
	local result = {}
	for _, emote in ipairs(self.Emotes) do
		if emote.Source == "beli" and emote.Price then
			table.insert(result, emote)
		end
	end
	return result
end

-- Helper: Dapatkan rarity color
function EmoteData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

return EmoteData