-- CurrencyConfig.lua
-- Konfigurasi mata uang: Rupiah & Gems.
-- Letakkan di: ReplicatedStorage/Modules/CurrencyConfig.lua

local Theme = require(script.Parent:WaitForChild("Theme.lua"))

local CurrencyConfig = {}

-- Definisi mata uang
CurrencyConfig.Currencies = {
	Rupiah = {
		Name = "Rupiah",
		Icon = "🪙",
		Color = Theme.COLORS.Gold,
		IconImage = "rbxasset://textures/Currency/Rupiah.png",
		Format = "IDR",
	},
	Gems = {
		Name = "Gems",
		Icon = "💎",
		Color = Theme.COLORS.JadeGlow,
		IconImage = "rbxasset://textures/Currency/Gems.png",
		Format = "GEM",
	},
}

-- Exchange rate (untuk developer products / top-up)
-- 100 Rupiah = 1 Gems (atau sesuaikan)
CurrencyConfig.EXCHANGE_RATE = {
	RupiahToGems = 100, -- 100 Rupiah = 1 Gems
}

-- Developer products untuk beli Gems (gunakan Robux)
CurrencyConfig.DeveloperProducts = {
	{
		ProductId = 1359815716, -- Ganti dengan Product ID yang sebenarnya
		Gems = 50,
		Name = "Kemasan 50 Berlian",
		Price = 5, -- USD
	},
	{
		ProductId = 1359815717,
		Gems = 120,
		Name = "Kemasan 120 Berlian",
		Price = 10,
	},
	{
		ProductId = 1359815718,
		Gems = 300,
		Name = "Kemasan 300 Berlian",
		Price = 20,
	},
	{
		ProductId = 1359815719,
		Gems = 650,
		Name = "Kemasan 650 Berlian",
		Price = 40,
	},
}

-- Helper
function CurrencyConfig:GetCurrencyInfo(currencyType)
	return self.Currencies[currencyType]
end

function CurrencyConfig:GetProductInfo(productId)
	for _, product in ipairs(self.DeveloperProducts) do
		if product.ProductId == productId then
			return product
		end
	end
	return nil
end

function CurrencyConfig:GetAll()
	return self.Currencies
end

return CurrencyConfig