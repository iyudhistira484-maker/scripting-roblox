-- EmoteService.lua
-- Logik pelayan untuk Emote.
-- Letakkan di: ServerScriptService/EmoteService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local EmoteData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("EmoteData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Emote")

-- RemoteEvents
local playEmoteEvent = remotesFolder:WaitForChild("PlayEmote")
local requestEmotesEvent = remotesFolder:WaitForChild("RequestEmotes")

-- RemoteEvent untuk broadcast ke pemain lain
local emotePlayedEvent = remotesFolder:FindFirstChild("EmotePlayed")
if not emotePlayedEvent then
	emotePlayedEvent = Instance.new("RemoteEvent")
	emotePlayedEvent.Name = "EmotePlayed"
	emotePlayedEvent.Parent = remotesFolder
end

local EmoteService = {}

-- Handler: Request daftar emote yang dimiliki
local function handleRequestEmotes(player)
	local data = PlayerDataService:Get(player)
	local ownedEmotes = data.OwnedEmotes or {}

	local responseEvent = remotesFolder:FindFirstChild("EmotesResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "EmotesResponse"
		responseEvent.Parent = remotesFolder
	end

	local emoteList = {}
	for _, emoteId in ipairs(ownedEmotes) do
		local emoteData = EmoteData:GetById(emoteId)
		if emoteData then
			table.insert(emoteList, {
				Id = emoteData.Id,
				Name = emoteData.Name,
				AnimationId = emoteData.AnimationId,
				Icon = emoteData.Icon,
				Description = emoteData.Description,
				Source = emoteData.Source,
			})
		end
	end

	-- Tambahkan emote gratis
	for _, emote in ipairs(EmoteData.Emotes) do
		if emote.Source == "gratis" then
			table.insert(emoteList, {
				Id = emote.Id,
				Name = emote.Name,
				AnimationId = emote.AnimationId,
				Icon = emote.Icon,
				Description = emote.Description,
				Source = emote.Source,
			})
		end
	end

	responseEvent:FireClient(player, emoteList)
end

-- Handler: Play emote
local function handlePlayEmote(player, emoteId)
	-- Validasi emote ada
	local emote = EmoteData:GetById(emoteId)
	if not emote then
		warn(("Pemain %s mencoba memainkan emote tidak sah: %s"):format(player.Name, tostring(emoteId)))
		return
	end

	-- Validasi kepemilikan
	local data = PlayerDataService:Get(player)
	local owned = data.OwnedEmotes or {}
	local hasEmote = false
	for _, id in ipairs(owned) do
		if id == emoteId then
			hasEmote = true
			break
		end
	end

	-- Emote gratis selalu bisa digunakan
	if emote.Source == "gratis" then
		hasEmote = true
	end

	if not hasEmote then
		warn(("Pemain %s mencoba memainkan emote yang tidak dimiliki: %s"):format(player.Name, emoteId))
		return
	end

	-- Broadcast ke semua pemain lain di server
	emotePlayedEvent:FireAllClients(player, emote.AnimationId)

	print(("Pemain %s memainkan emote: %s"):format(player.Name, emote.Name))
end

-- Handler: Beli emote
local function handlePurchaseEmote(player, emoteId)
	local emote = EmoteData:GetById(emoteId)
	if not emote or emote.Source ~= "beli" then
		return
	end

	-- Validasi sudah dimiliki
	local data = PlayerDataService:Get(player)
	for _, id in ipairs(data.OwnedEmotes or {}) do
		if id == emoteId then
			return
		end
	end

	-- Validasi saldo
	local price = emote.Price
	if price.Rupiah and price.Rupiah > 0 then
		local rupiah = PlayerDataService:GetCurrency(player, "Rupiah")
		if rupiah < price.Rupiah then
			return
		end
	end
	if price.Gems and price.Gems > 0 then
		local gems = PlayerDataService:GetCurrency(player, "Gems")
		if gems < price.Gems then
			return
		end
	end

	-- Kurangi mata uang
	if price.Rupiah and price.Rupiah > 0 then
		PlayerDataService:RemoveCurrency(player, "Rupiah", price.Rupiah)
	end
	if price.Gems and price.Gems > 0 then
		PlayerDataService:RemoveCurrency(player, "Gems", price.Gems)
	end

	-- Tambahkan ke inventory
	table.insert(data.OwnedEmotes, emoteId)
	PlayerDataService:Save(player)

	print(("Pemain %s membeli emote: %s"):format(player.Name, emote.Name))
end

-- Connect events
requestEmotesEvent.OnServerEvent:Connect(handleRequestEmotes)
playEmoteEvent.OnServerEvent:Connect(handlePlayEmote)

-- BindableEvent untuk pembelian (bisa dipanggil dari ShopService)
local function setupPurchaseHandler()
	local purchaseEvent = game.ServerScriptService:FindFirstChild("EmotePurchaseInternal")
	if not purchaseEvent then
		purchaseEvent = Instance.new("BindableEvent")
		purchaseEvent.Name = "EmotePurchaseInternal"
		purchaseEvent.Parent = game.ServerScriptService
	end
	purchaseEvent.Event:Connect(handlePurchaseEmote)
end

setupPurchaseHandler()

-- API publik
function EmoteService:PlayerOwnsEmote(player, emoteId)
	local data = PlayerDataService:Get(player)
	for _, id in ipairs(data.OwnedEmotes or {}) do
		if id == emoteId then
			return true
		end
	end
	-- Emote gratis selalu dimiliki
	local emote = EmoteData:GetById(emoteId)
	if emote and emote.Source == "gratis" then
		return true
	end
	return false
end

return EmoteService