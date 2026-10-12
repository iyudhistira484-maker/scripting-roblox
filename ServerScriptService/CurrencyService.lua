-- CurrencyService.lua
-- Logik pelayan untuk Currency (Mata Uang Rupiah & Gems).
-- Letakkan di: ServerScriptService/CurrencyService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local CurrencyConfig = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("CurrencyConfig.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Currency")
local currencyUpdatedEvent = remotesFolder:WaitForChild("CurrencyUpdated")
local requestBalanceEvent = remotesFolder:WaitForChild("RequestBalance")
local buyGemsEvent = remotesFolder:WaitForChild("BuyGems")

local CurrencyService = {}

-- Handler: Request balance dari klien
local function handleRequestBalance(player)
	local responseEvent = remotesFolder:FindFirstChild("BalanceResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "BalanceResponse"
		responseEvent.Parent = remotesFolder
	end

	local data = PlayerDataService:Get(player)
	local balance = {
		Rupiah = data.Currency.Rupiah,
		Gems = data.Currency.Gems,
	}

	responseEvent:FireClient(player, balance)
end

local MarketplaceService = game:GetService("MarketplaceService")

-- Handler: Beli Gems dengan Developers Products
local function handleBuyGems(player, productId)
	local product = CurrencyConfig:GetProductInfo(productId)
	if not product then
		warn(("Produk tidak ditemukan: %d"):format(productId))
		return
	end

	-- NOTE: Developer Products pakai Robux. Ini mock untuk mencegah crash.
	MarketplaceService:PromptProductPurchase(player, productId)
end

-- ProcessReceipt: di-set sekali, bukan di dalam handler
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local product = CurrencyConfig:GetProductInfo(receiptInfo.ProductId)
	if product then
		local plr = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if plr then
			PlayerDataService:AddCurrency(plr, "Gems", product.Gems)
			PlayerDataService:Save(plr)

			local data = PlayerDataService:Get(plr)
			currencyUpdatedEvent:FireClient(plr, "Gems", data.Currency.Gems)
		end
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- Helper: Tambah mata uang ke pemain
function CurrencyService:AddCurrency(player, currencyType, amount)
	-- Validasi type mata uang
	if not CurrencyConfig:GetCurrencyInfo(currencyType) then
		return 0
	end

	local newAmount = PlayerDataService:AddCurrency(player, currencyType, amount)
	PlayerDataService:Save(player)

	-- Broadcast update ke klien
	local data = PlayerDataService:Get(player)
	currencyUpdatedEvent:FireClient(player, currencyType, data.Currency[currencyType])

	return newAmount
end

-- Helper: Kurang mata uang
function CurrencyService:RemoveCurrency(player, currencyType, amount)
	-- Validasi type mata uang
	if not CurrencyConfig:GetCurrencyInfo(currencyType) then
		return false
	end

	local success, newAmount = PlayerDataService:RemoveCurrency(player, currencyType, amount)
	PlayerDataService:Save(player)

	-- Broadcast update ke klien
	local data = PlayerDataService:Get(player)
	currencyUpdatedEvent:FireClient(player, currencyType, data.Currency[currencyType])

	return success, newAmount
end

-- Helper: Dapatkan balance
function CurrencyService:GetCurrency(player, currencyType)
	return PlayerDataService:GetCurrency(player, currencyType)
end

-- Helper: Cek bisa beli
function CurrencyService:CanAfford(player, currencyType, amount)
	local current = PlayerDataService:GetCurrency(player, currencyType)
	return current >= amount
end

-- Connect events
requestBalanceEvent.OnServerEvent:Connect(handleRequestBalance)
buyGemsEvent.OnServerEvent:Connect(handleBuyGems)

-- API publik
function CurrencyService:GetAllCurrencies()
	return CurrencyConfig:GetAll()
end

function CurrencyService:GetCurrencyInfo(currencyType)
	return CurrencyConfig:GetCurrencyInfo(currencyType)
end

return CurrencyService