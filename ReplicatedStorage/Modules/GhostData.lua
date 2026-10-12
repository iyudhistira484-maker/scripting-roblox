-- GhostData.lua
-- Modul data statik untuk semua jenis hantu dalam permainan.
-- Tempatkan di: ReplicatedStorage/Modules/GhostData.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local GhostData = {}

-- Definisi kemerahanakan
GhostData.RARITIES = {
	{
		Name = "Umum",
		Color = Theme.COLORS.BoneDim,
		Icon = "★",
		Weight = 50,
	},
	{
		Name = "Langka",
		Color = Theme.COLORS.JadeGlow,
		Icon = "★★",
		Weight = 30,
	},
	{
		Name = "Legendaris",
		Color = Theme.COLORS.Gold,
		Icon = "★★★",
		Weight = 15,
	},
	{
		Name = "Mitos",
		Color = Theme.COLORS.Crimson,
		Icon = "★★★★",
		Weight = 5,
	},
}

function GhostData:GetRarityByName(name)
	for _, rarity in ipairs(self.RARITIES) do
		if rarity.Name == name then
			return rarity
		end
	end
	return self.RARITIES[1]
end

-- Daftar semua hantu
-- Format: Id, Nama, Kemeraihan, Lore, Lokasi, Reward
GhostData.Ghosts = {
	-- === Umum ===
	{
		Id = "Pocong_Muda",
		Name = "Pocong Muda",
		Rarity = "Umum",
		Lore = "Seorang pemuda muda yang meninggal dunia secara mendadak di tengah perjalanan pulang. Kainnya yang putih kaku seperti kain saqaf tidak pernah pudar, menandakan rasa tidak nyaman yang belum selesai.",
		Location = "Perumahan Warga / Gua Hitam",
		IconImage = "rbxasset://textures/GhostIcons/PocongMuda.png",
		Reward = { Rupiah = 50, Gems = 0 },
	},
	{
		Id = "Kuntil_Anak",
		Name = "Kuntil Anak",
		Rarity = "Umum",
		Lore = "Bayangan seorang anak kecil yang hanyut di hutan belantara. Suaranya serak memanggil nama orang dewasa yang berlalu, lalu menghilangkan jejak langkahnya.",
		Location = "Hutan Belantara / Pekuburan Lama",
		IconImage = "rbxasset://textures/GhostIcons/KuntilAnak.png",
		Reward = { Rupiah = 75, Gems = 0 },
	},
	{
		Id = "Penunggu_Jalan",
		Name = "Penunggu Jalan",
		Rarity = "Umum",
		Lore = "Seorang penjaga jalan yang kehilangan ingatannya setelah musim hujan hebat. Ia tetap berdiri di tengah jalan, menunggu seseorang yang takkan pernah datang.",
		Location = "Jalan Raya Sepi / Jembatan Tua",
		IconImage = "rbxasset://textures/GhostIcons/PenungguJalan.png",
		Reward = { Rupiah = 60, Gems = 0 },
	},

	-- === Langka ===
	{
		Id = "Sundinang",
		Name = "Sundinang",
		Rarity = "Langka",
		Lore = "Bernama asli Nang, seorang ibu yang kehilangan anaknya dalam banjir rob. Suaranya terdengar serta dengan suap berulang, memicu banjir kecil di sekitar siapa saja yang mendekat.",
		Location = "Kampung Pinggiran / Sungai Rob",
		IconImage = "rbxasset://textures/GhostIcons/Sundinang.png",
		Reward = { Rupiah = 150, Gems = 1 },
	},
	{
		Id = "Penunggu_Pinaragan",
		Name = "Penunggu Pularagaan",
		Rarity = "Langka",
		Lore = "Arwah seorang tukang oal di sebuah warung kaki lima yang dulu ramai. Sekarang, ia menghantui area tempat dulu dia menjualan, siapapun yang makan tanpa bayar akan kesempatan kecil untuk tidak pernah kembali lama di sana.",
		Location = "Warung Kaki Lima / Pasar Malam",
		IconImage = "rbxasset://textures/GhostIcons/PenungguPularagaan.png",
		Reward = { Rupiah = 180, Gems = 2 },
	},
	{
		Id = "Mak_Tina",
		Name = "Mak Tina",
		Rarity = "Langka",
		Lore = "Seorang ibu tunggal yang meninggalkan anak-anaknya untuk mencari nelayan di laut, namun badai menerjang. Arwahnya mengelilingi pesisir, mencari anak-anaknya yang hilang.",
		Location = "Pantai / Pelabuhan Tua",
		IconImage = "rbxasset://textures/GhostIcons/MakTina.png",
		Reward = { Rupiah = 200, Gems = 2 },
	},

	-- === Legendaris ===
	{
		Id = "Mala_Lejana",
		Name = "Mala Lejana",
		Rarity = "Legendaris",
		Lore = "Seorang dayang yang dikutuai oleh malaikat jahat. Ia memakan bangkanya sendiri hingga tak lari kabur. Arwahnya kelihatan sebagai bayangan berlumur merah di saat gerimis.",
		Location = "Kuil Lama / Hutan Mistik",
		IconImage = "rbxasset://textures/GhostIcons/MalaLejana.png",
		Reward = { Rupiah = 500, Gems = 5 },
	},
	{
		Id = "Ratu_Keramat",
		Name = "Ratu Keramat",
		Rarity = "Legendaris",
		Lore = "Dikenal sebagai Ratu Keramat, seorang putri kerajaan yang mengorbankan dirinya demi mencincang jalan bagi para pengikutnya yang sedang kelapar. Sek sekarang, arwah putrinya menuntun mereka yang tersesat di padang pasir.",
		Location = "Padang Pasir / Kuil Tua",
		IconImage = "rbxasset://textures/GhostIcons/RatuKeramat.png",
		Reward = { Rupiah = 600, Gems = 6 },
	},
	{
		Id = "Penjahit_Roh",
		Name = "Penjahit Roh",
		Rarity = "Legendaris",
		Lore = "Seorang penjahit yang kegilaan karena kehilangan karyakannya yang indah dalam api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api api apa yang kamu ingatkan?",
		Location = "Peninggalan Lama / Gua Lumin",
		IconImage = "rbxasset://textures/GhostIcons/PenjahitRoh.png",
		Reward = { Rupiah = 550, Gems = 5 },
	},

	-- === Mitos ===
	{
		Id = "Hantu_Pintu_Tujuh",
		Name = "Hantu Pintu Tujuh",
		Rarity = "Mitos",
		Lore = "Mitos lokal tentang tujuh pintu roh yang harus dilewati. Siapa yang melewati ketujuh pintu tersebut, ia tidak akan pernah pulang ke tempat asalnya. Arwahnya melintas antara dimensi-dimensi itu.",
		Location = "Guas Kapur / Terowongan Tujuh Pintu",
		IconImage = "rbxasset://textures/GhostIcons/HantuPintuTujuh.png",
		Reward = { Rupiah = 1000, Gems = 15 },
	},
	{
		Id = "Mama_San",
		Name = "Mama San",
		Rarity = "Mitos",
		Lore = "Dikenal sebagai ibu yang sangat keras kepala dalam komunitas nelayan. Setelah dia meninggal karena malapu akibat kejahatan laut, arwahnya muncul di tengah badai, menuntuni mereka yang tersesat pulang melalui lautan.",
		Location = "Pelabuhan Laut / Kapal Tenggelam",
		IconImage = "rbxasset://textures/GhostIcons/MamaSan.png",
		Reward = { Rupiah = 1200, Gems = 20 },
	},
	{
		Id = "Penunggu_Ratu_Semeng",
		Name = "Penunggu Ratu Semeng",
		Rarity = "Mitos",
		Lore = "Ratu Semeng adalah seorang legenda dari kerajaan laut yang hilang. Menurut cerita, ia adalah seorang putri yang berjanji akan menunggu pasangannya yang akan kembali dari perang selamanya. Arwahnya muncul di puncak bukit, menunggu setia.",
		Location = "Puncak Bukit / Terowongan Laut",
		IconImage = "rbxasset://textures/GhostIcons/PenungguRatuSemeng.png",
		Reward = { Rupiah = 1500, Gems = 25 },
	},
}

-- Helper: dapatkan senarai semua ID hantu
function GhostData:GetAllGhostIds()
	local ids = {}
	for _, ghost in ipairs(self.Ghosts) do
		table.insert(ids, ghost.Id)
	end
	return ids
end

-- Helper: dapatkan data hantu berdasarkan ID
function GhostData:GetGhostById(id)
	for _, ghost in ipairs(self.Ghosts) do
		if ghost.Id == id then
			return ghost
		end
	end
	return nil
end

-- Helper: dapatkan jumlah total hantu
function GhostData:GetTotalCount()
	return #self.Ghosts
end

return GhostData