-- TrapService.lua
-- Logik pelayan untuk Trap/Ritual Pemburu (Fitur 20).
-- Letakkan di: ServerScriptService/TrapService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

-- Muat modul
local TrapData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("TrapData.lua"))
local PlayerDataService = require(game.ServerScriptService:WaitForChild("PlayerDataService.lua"))

-- Folder Remote
local remotesFolder = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Trap")
local placeTrapEvent = remotesFolder:WaitForChild("PlaceTrap")

-- Object template di ServerStorage
local trapFolder = ServerStorage:FindFirstChild("Traps")
if not trapFolder then
	trapFolder = Instance.new("Folder")
	trapFolder.Name = "Traps"
	trapFolder.Parent = ServerStorage
end

local TrapService = {}

-- State: active traps di world
local activeTraps = {}

-- Validasi posisi pemasangan
local function validatePlacement(position, radius)
	-- Cek tidak ada trap lain di area yang sama
	for _, trap in ipairs(activeTraps) do
		if trap.Position and (trap.Position - position).magnitude < radius + 3 then
			return false
		end
	end

	-- Cek di atas tanah / workspace
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace}
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

	local ray = workspace:Raycast(position, Vector3.new(0, -5, 0))
	if not ray then
		return false
	end

	return true
end

-- Handler: Tempatkan trap
local function handlePlaceTrap(player, trapId, position)
	local trap = TrapData:GetById(trapId)
	if not trap then return end

	-- Validasi kepemilikan
	local data = PlayerDataService:Get(player)
	if not table.find(data.TrapsOwned or {}, trapId) then
		return
	end

	-- Validasi cooldown
	local cooldowns = data.TrapCooldowns or {}
	local lastUsed = cooldowns[trapId] or 0
	if tick() - lastUsed < trap.Cooldown then
		return
	end

	-- Validasi posisi
	if not validatePlacement(position, trap.Stats.Radius) then
		return
	end

	-- Spawn trap di workspace
	local trapObject = trapFolder:FindFirstChild(trapId)
	if not trapObject then
		-- Buat primitive sebagai representasi trap
		trapObject = Instance.new("Part")
		trapObject.Name = trapId .. "_" .. player.Name
		trapObject.Size = Vector3.new(trap.Stats.Radius * 2, 1, trap.Stats.Radius * 2)
		trapObject.Anchored = true
		trapObject.Transparency = 0.7
		trapObject.CanCollide = false
		trapObject.BrickColor = BrickColor.new(247, 121, 121) -- crimson
		trapObject.Parent = workspace
		trapFolder:FindFirstChild(trapId) or trapObject.Clone -- biarkan di ServerStorage
	end

	-- Salin object
	local worldTrap = trapObject:Clone()
	worldTrap.Name = trapId .. "_" .. player.Name .. "_" .. tick()
	worldTrap.Position = position
	worldTrap.Parent = workspace

	-- Simpan state trap
	table.insert(activeTraps, {
		Id = worldTrap.Name,
		TrapId = trapId,
		OwnerId = player.UserId,
		Position = position,
		Object = worldTrap,
		ExpiresAt = tick() + trap.Stats.Duration,
	})

	-- Update cooldown
	cooldowns[trapId] = tick()
	data.TrapCooldowns = cooldowns
	PlayerDataService:Save(player)

	-- Kirim ke klien pemain pemasang
	local placedEvent = remotesFolder:FindFirstChild("TrapPlaced")
	if not placedEvent then
		placedEvent = Instance.new("RemoteEvent")
		placedEvent.Name = "TrapPlaced"
		placedEvent.Parent = remotesFolder
	end
	placedEvent:FireClient(player, trapId, position)
end

-- Update loop: cek collision & efek
coroutine.wrap(function()
	while true do
		for i = #activeTraps, 1, -1 do
			local trap = activeTraps[i]
			if not trap.Object or not trap.Object.Parent then
				-- Trap sudah dihapus
				table.remove(activeTraps, i)
			elseif tick() > trap.ExpiresAt then
				-- Trap kadaluarsa
				if trap.Object and trap.Object.Parent then
					trap.Object:Destroy()
				end
				table.remove(activeTraps, i)
			end
		end
		wait(2)
	end
end)()

-- Connect event
placeTrapEvent.OnServerEvent:Connect(handlePlaceTrap)

-- API publik
function TrapService:GetActiveTraps()
	return activeTraps
end

function TrapService:GetTrapInfo(trapId)
	return TrapData:GetById(trapId)
end

return TrapService