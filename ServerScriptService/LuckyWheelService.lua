-- LuckyWheelService.lua
-- Logik pelayan untuk Lucky Wheel (Fitur 23).
-- Letakkan di: ServerScriptService/LuckyWheelService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Muat modul
local LuckyWheelData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("LuckyWheelData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("LuckyWheel")
local spinWheelEvent = remotesFolder:WaitForChild("SpinWheel")
local stateRequestEvent = remotesFolder:WaitForChild("RequestState")

local LuckyWheelService = {}

-- Helper: Hitung slot yang kapal berdasarkan weight
local function weightedRandom()
	local totalWeight = 0
	for _, prize in ipairs(LuckyWheelData.Prizes) do
		totalWeight = totalWeight + prize.Weight
	end

	local roll = math.random() * totalWeight
	local currentWeight = 0

	for i, prize in ipairs(LuckyWheelData.Prizes) do
		currentWeight = currentWeight + prize.Weight
		if roll <= currentWeight then
			return prize, i
		end
	end

	return LuckyWheelData.Prizes[1], 1
end

-- Handler: Spin roda
local function handleSpinWheel(player)
	local data = PlayerDataService:Get(player)

	-- Cek jatah gratis hari ini
	if data.LuckyWheelSpunToday then
		-- Bisa beli spin tambahan dengan Gems
		-- Biarkan klien kirim request dengan flag tambahan
		return
	end

	-- Roll di server
	local prize, slotIndex = weightedRandom()

	-- Beri reward ke pemain
	if prize.Type == "Currency" then
		PlayerDataService:AddCurrency(player, prize.CurrencyType, prize.Amount)
	elseif prize.Type == "Item" then
		for i = 1, prize.Amount do
			PlayerDataService:AddItemToInventory(player, prize.ItemId)
		end
	elseif prize.Type == "Title" then
		-- Bisa tambahke PlayerDataService field Title
	end

	-- Update jatah gratis
	data.LuckyWheelSpunToday = true
	PlayerDataService:Save(player)

	-- Kirim hasil ke klien
	local resultEvent = remotesFolder:FindFirstChild("SpinResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "SpinResult"
		resultEvent.Parent = remotesFolder
	end

	resultEvent:FireClient(player, prize, slotIndex)
end

-- Handler: Beli spin tambahan
local function handleBuyExtraSpin(player)
	local data = PlayerDataService:Get(player)

	-- Cek sudah pakai gratis
	if not data.LuckyWheelSpunToday then
		-- Wajib pakai gratis dulu
		return
	end

	-- Cek saldo Gems
	local gems = PlayerDataService:GetCurrency(player, "Gems")
	local price = LuckyWheelData.EXTRA_SPIN_PRICE

	if gems < price then
		return
	end

	PlayerDataService:RemoveCurrency(player, "Gems", price)

	-- Roll
	local prize, slotIndex = weightedRandom()

	if prize.Type == "Currency" then
		PlayerDataService:AddCurrency(player, prize.CurrencyType, prize.Amount)
	elseif prize.Type == "Item" then
		for i = 1, prize.Amount do
			PlayerDataService:AddItemToInventory(player, prize.ItemId)
		end
	end

	PlayerDataService:Save(player)

	local resultEvent = remotesFolder:FindFirstChild("SpinResult")
	if not resultEvent then
		resultEvent = Instance.new("RemoteEvent")
		resultEvent.Name = "SpinResult"
		resultEvent.Parent = remotesFolder
	end

	resultEvent:FireClient(player, prize, slotIndex, true) -- true = paid spin
end

-- Handler: Request state
local function handleRequestState(player)
	local data = PlayerDataService:Get(player)
	local responseEvent = remotesFolder:FindFirstChild("StateResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "StateResponse"
		responseEvent.Parent = remotesFolder
	end

	responseEvent:FireClient(player, {
		SpunToday = data.LuckyWheelSpunToday,
		ExtraSpinPrice = LuckyWheelData.EXTRA_SPIN_PRICE,
		Prizes = LuckyWheelData.Prizes,
	})
end

-- Connect events
spinWheelEvent.OnServerEvent:Connect(handleSpinWheel)
stateRequestEvent.OnServerEvent:Connect(handleRequestState)

-- Reset spin gratis setiap hari
coroutine.wrap(function()
	while true do
		wait(60) -- cek tiap menit
		-- Reset pada jam 00:00 UTC
		local now = os.date("!*t")
		if now.hour == 0 and now.min < 1 then
			for _, player in ipairs(game.Players:GetPlayers()) do
				local data = PlayerDataService:Get(player)
				data.LuckyWheelSpunToday = false
				PlayerDataService:Save(player)
			end
		end
	end
end)()

-- API publik
function LuckyWheelService:CanSpin(player)
	local data = PlayerDataService:Get(player)
	return not data.LuckyWheelSpunToday
end

function LuckyWheelService:GetPrizes()
	return LuckyWheelData.Prizes
end

return LuckyWheelService