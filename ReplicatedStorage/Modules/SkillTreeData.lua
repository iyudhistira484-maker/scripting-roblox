-- SkillTreeData.lua
-- Modul data statik untuk Skill Tree (Fitur 18).
-- Letakkan di: ReplicatedStorage/Modules/SkillTreeData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local SkillTreeData = {}

SkillTreeData.Nodes = {
	-- === Branch: Detection ===
	{
		Id = "Ghost_Eye",
		Name = "Mata Arwah",
		Description = "Meningkatkan jarak deteksi arwah",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Detection",
		Prerequisite = nil,
		Cost = 1,
		Icon = "👁️",
		IconImage = "rbxasset://textures/Skills/GhostEye.png",
		Effect = { Stat = "GhostDetectionRadius", Value = 10 },
		Rarity = "Common",
	},
	{
		Id = "Arwah_Sight",
		Name = "Penglihat Arwah",
		Description = "Deteksi arwah lebih jauh lagi",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Detection",
		Prerequisite = "Ghost_Eye",
		Cost = 2,
		Icon = "🔍",
		IconImage = "rbxasset://textures/Skills/ArwahSight.png",
		Effect = { Stat = "GhostDetectionRadius", Value = 20 },
		Rarity = "Rare",
	},
	-- === Branch: Movement ===
	{
		Id = "Swift_Foot",
		Name = "Kaki Cepat",
		Description = "Kecepatan gerak meningkat",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Movement",
		Prerequisite = nil,
		Cost = 1,
		Icon = "👟",
		IconImage = "rbxasset://textures/Skills/SwiftFoot.png",
		Effect = { Stat = "MoveSpeed", Value = 5 },
		Rarity = "Common",
	},
	{
		Id = "Shadow_Step",
		Name = "Langkah Kelam",
		Description = "Bergerak lebih cepat di area gelap",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Movement",
		Prerequisite = "Swift_Foot",
		Cost = 3,
		Icon = "🌑",
		IconImage = "rbxasset://textures/Skills/ShadowStep.png",
		Effect = { Stat = "NightMoveSpeed", Value = 10 },
		Rarity = "Epic",
	},
	-- === Branch: Combat ===
	{
		Id = "Sharp_Edge",
		Name = "Seni Memotong",
		Description = "Damage senjata meningkat",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Combat",
		Prerequisite = nil,
		Cost = 1,
		Icon = "🔪",
		IconImage = "rbxasset://textures/Skills/SharpEdge.png",
		Effect = { Stat = "DamageMultiplier", Value = 1.1 },
		Rarity = "Common",
	},
	{
		Id = "Sacred_Strike",
		Name = "Serangan Suci",
		Description = "Damage lebih besar ke arwah",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Combat",
		Prerequisite = "Sharp_Edge",
		Cost = 3,
		Icon = "⚔️",
		IconImage = "rbxasset://textures/Skills/SacredStrike.png",
		Effect = { Stat = "GhostDamageBonus", Value = 15 },
		Rarity = "Legend",
	},
	-- === Branch: Utility ===
	{
		Id = "Durability_Master",
		Name = "Penguasa Daya Tahan",
		Description = "Alat lebih tahan lama",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Utility",
		Prerequisite = nil,
		Cost = 1,
		Icon = "🔧",
		IconImage = "rbxasset://textures/Skills/DurabilityMaster.png",
		Effect = { Stat = "DurabilityBonus", Value = 20 },
		Rarity = "Uncommon",
	},
	{
		Id = "Arwah_Whisper",
		Name = "Desah Arwah",
		Description = "Dapatkan informasi dari arwah yang ditangkap",
		Position = UDim2.new(0, 0, 0, 0),
		Category = "Utility",
		Prerequisite = "Durability_Master",
		Cost = 2,
		Icon = "👂",
		IconImage = "rbxasset://textures/Skills/ArwahWhisper.png",
		Effect = { Stat = "GhostHintReveal", Value = true },
		Rarity = "Rare",
	},
}

-- Helper
function SkillTreeData:GetById(id)
	for _, node in ipairs(self.Nodes) do
		if node.Id == id then
			return node
		end
	end
	return nil
end

function SkillTreeData:GetByCategory(category)
	local result = {}
	for _, node in ipairs(self.Nodes) do
		if node.Category == category then
			table.insert(result, node)
		end
	end
	return result
end

return SkillTreeData