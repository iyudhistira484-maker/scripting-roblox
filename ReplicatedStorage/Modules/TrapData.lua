-- TrapData.lua
-- Modul data statik untuk Trap/Ritual Pemburu (Fitur 20).
-- Letakkan di: ReplicatedStorage/Modules/TrapData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local TrapData = {}

TrapData.Traps = {
	{
		Id = "Garam_Pembatas",
		Name = "Garam Pembatas",
		Description = "Membuat gilasangan garam yang menahan arwah",
		Category = "Trap",
		Rarity = "Common",
		Stats = { Slow = 0.5, Duration = 30, Radius = 10 },
		Price = { Rupiah = 500, Gems = 0 },
		Cooldown = 60,
		Icon = "🧂",
		IconImage = "rbxasset://textures/Traps/GaramPembatas.png",
		Effect = "Slow",
	},
	{
		Id = "Sesajen_Raja",
		Name = "Sesajen Raja",
		Description = "Menantarkan arwah dari dimensi lain",
		Category = "Trap",
		Rarity = "Rare",
		Stats = { Damage = 50, Duration = 20, Radius = 8 },
		Price = { Rupiah = 1200, Gems = 5 },
		Cooldown = 120,
		Icon = "🕯️",
		IconImage = "rbxasset://textures/Traps/SesajenRaja.png",
		Effect = "Damage",
	},
	{
		Id = "Jerat_Bambu",
		Name = "Jerat Bambu",
		Description = "Jerat bambu yang bisa menjerat arwah",
		Category = "Trap",
		Rarity = "Uncommon",
		Stats = { Stun = 5, Duration = 15, Radius = 6 },
		Price = { Rupiah = 800, Gems = 3 },
		Cooldown = 90,
		Icon = "🎋",
		IconImage = "rbxasset://textures/Traps/JeratBambu.png",
		Effect = "Stun",
	},
	{
		Id = "Gawang_Antara",
		Name = "Gawang Antara",
		Description = "Membuka gerbang ke ranah arwah, memancing arwah langka",
		Category = "Trap",
		Rarity = "Legend",
		Stats = { RarityBoost = 30, Duration = 60, Radius = 15 },
		Price = { Rupiah = 0, Gems = 25 },
		Cooldown = 300,
		Icon = "🌀",
		IconImage = "rbxasset://textures/Traps/GawangAntara.png",
		Effect = "RarityBoost",
	},
}

TrapData.RARITIES = {
	Common = { Name = "Umum", Color = Theme.COLORS.BoneDim, Icon = "◆" },
	Uncommon = { Name = "Langka", Color = Theme.COLORS.JadeGlow, Icon = "◆◆" },
	Rare = { Name = "Langka", Color = Theme.COLORS.Gold, Icon = "◆◆◆" },
	Legend = { Name = "Legendaris", Color = Theme.COLORS.Crimson, Icon = "◆◆◆◆" },
}

function TrapData:GetById(id)
	for _, trap in ipairs(self.Traps) do
		if trap.Id == id then
			return trap
		end
	end
	return nil
end

function TrapData:GetRarityColor(rarity)
	local r = self.RARITIES[rarity]
	return r and r.Color or Theme.COLORS.Bone
end

function TrapData:GetAll()
	return self.Traps
end

return TrapData