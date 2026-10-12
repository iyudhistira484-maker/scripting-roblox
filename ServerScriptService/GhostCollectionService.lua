-- GhostCollectionService.lua
-- Logik pelayan untuk Koleksi Hantu ("Jurnal Arwah").
-- Tempatkan di: ServerScriptService/GhostCollectionService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Muat modul
local GhostData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GhostData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("GhostCollection")
local captureGhostEvent = RemotesFolder:WaitForChild("CaptureGhost")

-- GhostCollectionService sebagai namespace
local GhostCollectionService = {}

-- RemoteEvent untuk menghantar notifikasi ke klien
local ghostCapturedEvent = RemotesFolder:FindFirstChild("GhostCaptured")
if not ghostCapturedEvent then
	ghostCapturedEvent = Instance.new("RemoteEvent")
	ghostCapturedEvent.Name = "GhostCaptured"
	ghostCapturedEvent.Parent = RemotesFolder
end

-- Internal BindableEvent untuk notifikasi ke sistem lain (seperti AchievementService)
local ghostCaughtInternal
if not game.ServerScriptService:FindFirstChild("GhostCaughtInternal") then
	ghostCaughtInternal = Instance.new("BindableEvent")
	ghostCaughtInternal.Name = "GhostCaughtInternal"
	ghostCaughtInternal.Parent = game.ServerScriptService
end

-- Validasi penangkapan hantu
local function handleCaptureRequest(player, ghostId, location)
	-- Pastikan ID hantu sah
	local ghostInfo = GhostData:GetGhostById(ghostId)
	if not ghostInfo then
		warn(("Pemain %s mencuba menangkap hantu dengan ID tidak sah: %s"):format(player.Name, tostring(ghostId)))
		return
	end

	-- Cegah klaim ganda
	if PlayerDataService:HasCaughtGhost(player, ghostId) then
		-- Sudah pernah ditangkap, abaikan
		return
	end

	-- Rekod penangkapan berjaya
	local success = PlayerDataService:AddCaughtGhost(player, ghostId, location or "Tidak diketahui")

	if success then
		-- Beri ganjaran
		local reward = ghostInfo.Reward
		if reward.Rupiah and reward.Rupiah > 0 then
			PlayerDataService:AddCurrency(player, "Rupiah", reward.Rupiah)
		end
		if reward.Gems and reward.Gems > 0 then
			PlayerDataService:AddCurrency(player, "Gems", reward.Gems)
		end

		-- Simpan perubahan
		PlayerDataService:Save(player)

		-- Beritahu klien untuk efek
		ghostCapturedEvent:FireClient(player, ghostId, reward)

		-- Beritahu sistem lain (contohnya AchievementService)
		ghostCaughtInternal:Fire(player, ghostId, ghostInfo)

		print(("Berhasil! %s berhasil menangkap %s"):format(player.Name, ghostInfo.Name))
	else
		-- Ini seharusnya tidak pernah terjadi kerana sudah dicek di atas
		warn(("Gagal menyimpan tangkapan hantu untuk %s"):format(player.Name))
	end
end

-- Dengar permintaan dari klien
captureGhostEvent.OnServerEvent:Connect(handleCaptureRequest)

-- API untuk sistem lain yang ingin memaksa penangkapan (mis. dari server)
function GhostCollectionService:ForceCapture(player, ghostId, location)
	handleCaptureRequest(player, ghostId, location)
end

-- API untuk mendapatkan senarai hantu yang ditangkap (untuk klien)
local requestCaughtEvent = RemotesFolder:FindFirstChild("RequestCaughtGhosts")
if not requestCaughtEvent then
	requestCaughtEvent = Instance.new("RemoteEvent")
	requestCaughtEvent.Name = "RequestCaughtGhosts"
	requestCaughtEvent.Parent = RemotesFolder
end

requestCaughtEvent.OnServerEvent:Connect(function(player)
	local data = PlayerDataService:Get(player)
	local caughtList = {}
	for ghostId, info in pairs(data.CaughtGhosts or {}) do
		table.insert(caughtList, {
			Id = ghostId,
			CaughtAt = info.CaughtAt,
			Location = info.Location,
		})
	end

	-- Gunakan RemoteEvent untuk menghantar data kembali
	local responseEvent = RemotesFolder:FindFirstChild("CaughtGhostsResponse")
	if not responseEvent then
		responseEvent = Instance.new("RemoteEvent")
		responseEvent.Name = "CaughtGhostsResponse"
		responseEvent.Parent = RemotesFolder
	end

	responseEvent:FireClient(player, caughtList)
end)

return GhostCollectionService