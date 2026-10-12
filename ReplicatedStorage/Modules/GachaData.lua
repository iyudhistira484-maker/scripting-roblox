-- GachaData.lua
-- Modul data statik untuk Gacha system.
-- Letakkan di: ReplicatedStorage/Modules/GachaData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local GachaData = {}

-- Format: BannerId, Nama, Deskripsi, Item pool per rarity, Rate, Pity
GachaData.Banners = {
	{
		Id = "Standard",
		Name = "Gacha Standar",
		Description = "Peti hantu langka dengan item premium",
		Price = { Gems = 5 }, -- 1 pull
		PriceMulti = { Gems = 45 }, -- 10 pull
		Currency = "Gems",
		Icon = "🎁",
		IconImage = "rbxasset://textures/Gacha/BannerStandard.png",

		-- Pool item per rarity
		Pool = {
			Common = { Chance = 0.60, Items = {"Minom_Teh", "Buku_Kuno", "Guli_Kerbau"} },
			Uncommon = { Chance = 0.25, Items = {"Senter_Bambu", "Keris_Raja", "Garam_Seribu"} },
			Rare = { Chance = 0.10, Items = {"Kamera_Roh", "Jubah_Anyam", "Kemenyan_Kunyit"} },
			SSSR = { Chance = 0.04, Items = {"Pedang_Emas", "Lukisan_Arwah", "Permata_Nusantara"} },
			SSR = { Chance = 0.01, Items = {"Keris_Raja_Skin", "Jubah_Raja", "Emote_Taunt"} },
		},

		PityGuarantee = 90, -- GARANSI SSR setelah 90 pull tanpa SSR
		SoftPityStart = 74, -- Mulai meningkatkan rate setelah pull ke-74
	},
}

-- Rate display (bisa ditampilkan di UI)
GachaData.RATES = {
	Common = 60,
	Uncommon = 25,
	Rare = 10,
	SSSR = 4,
	SSR = 1,
}

-- Rarity colors
GachaData.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Uncommon = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Rare = { Name = "Langka", Color = Theme.COLORS.Gold, Icon = "◆◆◆" },
	SSSR = { Name = "Legendaris", Color = Theme.COLORS.Crimson, Icon = "◆◆◆◆" },
	SSR = { Name = "Mitos", Color = Theme.COLORS.GoldHi, Icon = "◆◆◆◆◆" },
}

-- Helper
function GachaData:GetBanner(bannerId)
	for _, banner in ipairs(self.Banners) do
		if banner.Id == bannerId then
			return banner
		end
	end
	return nil
end

function GachaData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

function GachaData:GetAll()
	return self.Banners
end

return GachaData