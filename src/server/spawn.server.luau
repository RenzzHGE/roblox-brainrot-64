-- v1.6 spawn safety: guarantees every player gets a character AND solid ground.
--
-- v1.5 failed in Studio Play even though its model ground looked right on paper:
-- the character spawned, fell through empty sky, respawned, fell again, forever.
-- v1.6 defends in three independent layers so that can never happen again:
--   1. A CODE-CREATED spawn platform (40 x 2 x 40, top at y=1) built by this
--      script at server start, independent of the model.json ground.
--   2. A fall safety net: every 0.5 s any character below y=0.5 is teleported
--      back onto the spawn, with its velocity zeroed.
--   3. CharacterAutoLoads = true plus a LoadCharacter safety call per player.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Config = require(game:GetService("ReplicatedStorage").Shared.config)

Players.CharacterAutoLoads = true

local SPAWN_POSITION = Config.SPAWN_POSITION
local PLATFORM_CENTER = Config.PLATFORM_CENTER
local PLATFORM_SIZE = Config.PLATFORM_SIZE
local FALL_LIMIT_Y = Config.FALL_LIMIT_Y
local RESCUE_INTERVAL = Config.RESCUE_INTERVAL

-- Layer 1: code-created spawn platform. Warm light-wood plaza deck, clearly
-- visible, with a stone border trim so the player can see where safe ground is.
local function createSpawnPlatform()
	local platform = Instance.new("Part")
	platform.Name = "SpawnPlatform"
	platform.Anchored = true
	platform.CanCollide = true
	platform.CanQuery = true
	platform.CanTouch = true
	platform.Size = PLATFORM_SIZE
	platform.Position = PLATFORM_CENTER
	platform.Material = Enum.Material.WoodPlanks
	platform.Color = Color3.fromRGB(150, 105, 60)
	platform.TopSurface = Enum.SurfaceType.Smooth
	platform.BottomSurface = Enum.SurfaceType.Smooth
	platform.Parent = Workspace

	-- Stone border trim around the plaza edge.
	local trimSize = Vector3.new(PLATFORM_SIZE.X + 1, 0.6, 1)
	for _, zEdge in ipairs({ -PLATFORM_SIZE.Z / 2 - 0.5, PLATFORM_SIZE.Z / 2 + 0.5 }) do
		local trim = Instance.new("Part")
		trim.Name = "SpawnTrim"
		trim.Anchored = true
		trim.CanCollide = true
		trim.Size = trimSize
		trim.Position = Vector3.new(PLATFORM_CENTER.X, Config.PLATFORM_TOP_Y + 0.3, PLATFORM_CENTER.Z + zEdge)
		trim.Material = Enum.Material.Cobblestone
		trim.Color = Color3.fromRGB(110, 115, 120)
		trim.Parent = Workspace
	end
	local trimSide = Vector3.new(1, 0.6, PLATFORM_SIZE.Z + 1)
	for _, xEdge in ipairs({ -PLATFORM_SIZE.X / 2 - 0.5, PLATFORM_SIZE.X / 2 + 0.5 }) do
		local trim = Instance.new("Part")
		trim.Name = "SpawnTrim"
		trim.Anchored = true
		trim.CanCollide = true
		trim.Size = trimSide
		trim.Position = Vector3.new(PLATFORM_CENTER.X + xEdge, Config.PLATFORM_TOP_Y + 0.3, PLATFORM_CENTER.Z)
		trim.Material = Enum.Material.Cobblestone
		trim.Color = Color3.fromRGB(110, 115, 120)
		trim.Parent = Workspace
	end

	print("[v1.6] Spawn platform created at " .. tostring(PLATFORM_CENTER) .. " top y=" .. tostring(Config.PLATFORM_TOP_Y))
	return platform
end

-- The SpawnLocation the model ships with, or a code-created one if it is missing.
local function ensureSpawnLocation()
	local world = Workspace:FindFirstChild("World")
	local spawn = world and world:FindFirstChild("SpawnLocation")
	if spawn and spawn:IsA("SpawnLocation") then
		print("[v1.6] SpawnLocation at " .. tostring(spawn.Position))
		return spawn
	end
	local created = Instance.new("SpawnLocation")
	created.Name = "SpawnLocation"
	created.Size = Vector3.new(6, 1, 6)
	created.CFrame = CFrame.new(SPAWN_POSITION)
	created.Anchored = true
	created.Neutral = true
	created.Material = Enum.Material.Slate
	created.Color = Color3.fromRGB(110, 115, 120)
	created.Parent = Workspace
	print("[v1.6] SpawnLocation created in code at " .. tostring(SPAWN_POSITION))
	return created
end

local spawnLocation = ensureSpawnLocation()
createSpawnPlatform()

-- Layer 2: fall safety net. No character may ever fall forever.
local function rescueIfFalling(player: Player)
	local character = player.Character
	if not character then
		return
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return
	end
	if root.Position.Y < FALL_LIMIT_Y then
		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.AssemblyLinearVelocity = Vector3.zero
				descendant.AssemblyAngularVelocity = Vector3.zero
			end
		end
		local target = CFrame.new(spawnLocation.Position + Vector3.new(0, 3, 0))
		character:PivotTo(target)
		print("[v1.6] Rescued " .. player.Name)
	end
end

task.spawn(function()
	while true do
		task.wait(RESCUE_INTERVAL)
		for _, player in ipairs(Players:GetPlayers()) do
			local ok, err = pcall(rescueIfFalling, player)
			if not ok then
				warn("[v1.6] Rescue check failed for " .. player.Name .. ": " .. tostring(err))
			end
		end
	end
end)

-- Layer 3: character loading safety net.
local function ensureCharacter(player: Player)
	task.delay(5, function()
		if player.Parent == nil then
			return
		end
		if not player.Character then
			player:LoadCharacter()
		end
	end)
end

local function onPlayerAdded(player: Player)
	ensureCharacter(player)
	player.CharacterAdded:Connect(function(character: Model)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root then
			print("[v1.6] Spawned " .. player.Name .. " at " .. tostring(root.Position))
		end
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
