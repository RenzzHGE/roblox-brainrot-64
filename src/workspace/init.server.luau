-- v1.6 ambient world script (runs in Workspace): lighting, post-processing,
-- waterfall mist, fountain spray, fireflies, sky lanterns, god-ray shimmer and
-- the TreeForest grove clones.
-- Original code for BRAINROT MEGA UNIVERSE v1.6.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Config = require(ReplicatedStorage.Shared.config)

-- Lighting (texture design section 6): golden-hour sunset.
Lighting.ClockTime = 17.5
Lighting.Brightness = 2.2
Lighting.ColorShift_Top = Color3.fromRGB(255, 190, 120)
Lighting.ColorShift_Bottom = Color3.fromRGB(80, 50, 90)
Lighting.Ambient = Color3.fromRGB(70, 60, 80)
Lighting.OutdoorAmbient = Color3.fromRGB(90, 75, 100)
Lighting.FogEnabled = true
Lighting.FogStart = 40
Lighting.FogEnd = 350
Lighting.FogColor = Color3.fromRGB(180, 140, 165)
Lighting.GlobalShadows = true
Lighting.Technology = Enum.Technology.ShadowMap

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.35
atmosphere.Offset = 0.25
atmosphere.Color = Color3.fromRGB(210, 160, 150)
atmosphere.Decay = Color3.fromRGB(70, 50, 80)
atmosphere.Glare = 0.4
atmosphere.Haze = 1.5
atmosphere.Parent = Lighting

local sunRays = Instance.new("SunRays")
sunRays.Intensity = 0.35
sunRays.Spread = 0.8
sunRays.Parent = Lighting

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.4
bloom.Size = 24
bloom.Threshold = 0.8
bloom.Parent = Lighting

-- Lake water colour.
local terrain = Workspace.Terrain
terrain.WaterColor = Color3.fromRGB(40, 90, 130)
terrain.WaterTransparency = 0.6
terrain.WaterReflectance = 0.3

local world = Workspace:WaitForChild("World", 30)
if not world then
	warn("[v1.6] World model not found — ambient script stopping")
	return
end

-- Clone the tree-forest asset into the grove spots (dense cone-pine forest).
local assets = ReplicatedStorage:FindFirstChild("AssetModels")
local forest = assets and assets:FindFirstChild("TreeForest")
if forest then
	local placed = 0
	for _, pos in ipairs(Config.Grove) do
		local ok = pcall(function()
			local clone = forest:Clone()
			clone:PivotTo(CFrame.new(pos))
			clone.Parent = world
			placed += 1
		end)
		if not ok then
			warn("[v1.6] TreeForest clone failed at " .. tostring(pos))
		end
	end
	print("[v1.6] TreeForest groves placed: " .. tostring(placed))
else
	warn("[v1.6] TreeForest asset missing — groves skipped")
end

-- A few park bushes from the embedded asset, along the main path.
local bush = assets and assets:FindFirstChild("Bush")
if bush then
	local spots = {
		Vector3.new(-6, 0, 22),
		Vector3.new(7, 0, 26),
		Vector3.new(-14, 0, -8),
		Vector3.new(14, 0, -14),
	}
	for _, pos in ipairs(spots) do
		pcall(function()
			local clone = bush:Clone()
			clone:PivotTo(CFrame.new(pos))
			clone.Parent = world
		end)
	end
end

-- Particle helper: an invisible anchored part carrying one emitter.
local function makeEmitter(name, position, rate, speed, lifetime, sizeMin, sizeMax, colorA, colorB)
	local anchor = Instance.new("Part")
	anchor.Name = name
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Position = position
	anchor.Parent = world
	local emitter = Instance.new("ParticleEmitter")
	emitter.Rate = rate
	emitter.Speed = NumberRange.new(speed)
	emitter.Lifetime = NumberRange.new(lifetime)
	emitter.Size = NumberSequence.new(sizeMin, sizeMax)
	emitter.Color = ColorSequence.new(colorA, colorB)
	emitter.Parent = anchor
	return emitter
end

-- Waterfall mist at the base of the falls.
local mist = makeEmitter(
	"WaterfallMist",
	Config.WaterfallBase + Vector3.new(0, 2, 4),
	150,
	8,
	1.2,
	2,
	8,
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(200, 220, 240)
)
mist.SpreadAngle = Vector2.new(45, 45)

-- Fountain spray jet, straight up.
local spray = makeEmitter(
	"FountainSpray",
	Config.FountainCenter + Vector3.new(0, 3, 0),
	200,
	25,
	0.6,
	0.4,
	1.2,
	Color3.fromRGB(220, 240, 255),
	Color3.fromRGB(160, 200, 240)
)
spray.SpreadAngle = Vector2.new(5, 5)
spray.VelocitySpread = 10

-- Fireflies drifting near the lake edge.
for _, spot in ipairs({
	Vector3.new(-18, 2, -38),
	Vector3.new(-2, 2, -52),
	Vector3.new(8, 2, -30),
}) do
	local flies = makeEmitter(
		"Fireflies",
		spot,
		30,
		2,
		3,
		0.15,
		0.15,
		Color3.fromRGB(255, 230, 100),
		Color3.fromRGB(255, 200, 60)
	)
	flies.SpreadAngle = Vector2.new(180, 180)
end

-- Sky lanterns rising into the evening sky.
for _, spot in ipairs({
	Vector3.new(-20, 30, -20),
	Vector3.new(25, 34, 10),
}) do
	local lanterns = makeEmitter(
		"SkyLanterns",
		spot,
		5,
		3,
		14,
		0.8,
		1.4,
		Color3.fromRGB(255, 140, 50),
		Color3.fromRGB(255, 190, 90)
	)
	lanterns.VelocityInheritance = 0
	lanterns.EmissionDirection = Enum.NormalId.Top
end

print("[v1.6] Ambient world ready")
