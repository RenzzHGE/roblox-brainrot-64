-- v1.6 shared configuration: every constant the server, client and world
-- scripts agree on. Colours, zone coordinates and tuning values follow the
-- Gemini texture design (v1.5-design/texture-design.md) for the NGOBROL-style
-- forest hangout by the lake.

local Config = {}

Config.GAME_NAME = "BRAINROT MEGA UNIVERSE"
Config.GAME_VERSION = "1.6"
Config.GAME_TAGLINE = "Ngobrol di hutan, karaoke di tepi danau"

-- Spawn (bulletproof spawn lives in server/spawn.server.luau).
Config.SPAWN_POSITION = Vector3.new(0, 2, 15)
Config.SPAWN_FACING = Vector3.new(0, 0, 0) -- fountain plaza
Config.PLATFORM_CENTER = Vector3.new(0, 0, 15)
Config.PLATFORM_SIZE = Vector3.new(40, 2, 40)
Config.PLATFORM_TOP_Y = 1
Config.FALL_LIMIT_Y = 0.5
Config.RESCUE_INTERVAL = 0.5

-- Ground palette (texture design section 1).
Config.GroundBrown = Color3.fromRGB(80, 65, 45)
Config.DirtBrown = Color3.fromRGB(115, 85, 55)
Config.RockGrey = Color3.fromRGB(90, 85, 75)
Config.StoneGrey = Color3.fromRGB(110, 115, 120)
Config.SlateDark = Color3.fromRGB(75, 80, 85)

-- Grass palette (texture design section 2).
Config.GrassDeep = Color3.fromRGB(34, 68, 34)
Config.GrassMid = Color3.fromRGB(70, 130, 50)
Config.GrassSun = Color3.fromRGB(140, 185, 50)
Config.FlowerWhite = Color3.fromRGB(240, 240, 240)
Config.FlowerPink = Color3.fromRGB(230, 140, 160)
Config.FlowerYellow = Color3.fromRGB(240, 210, 80)

-- Tree palette (texture design section 3).
Config.TrunkBrown = Color3.fromRGB(65, 45, 30)
Config.CanopyDeep = Color3.fromRGB(20, 50, 30)
Config.CanopyMid = Color3.fromRGB(45, 95, 50)
Config.CanopySun = Color3.fromRGB(90, 140, 60)

-- Water palette (texture design section 4).
Config.LakeBlue = Color3.fromRGB(35, 95, 140)
Config.FountainBlue = Color3.fromRGB(50, 120, 170)
Config.FallSheet = Color3.fromRGB(200, 220, 240)
Config.RainbowPink = Color3.fromRGB(255, 120, 200)

-- Wood palette (texture design section 5).
Config.CabinBrown = Color3.fromRGB(95, 55, 35)
Config.MortarDark = Color3.fromRGB(45, 25, 15)
Config.PlankBrown = Color3.fromRGB(120, 80, 50)
Config.BenchBrown = Color3.fromRGB(110, 70, 45)
Config.WindowGlow = Color3.fromRGB(255, 170, 60)
Config.AwningRed = Color3.fromRGB(210, 70, 70)
Config.AwningWhite = Color3.fromRGB(240, 240, 240)
Config.RopeDark = Color3.fromRGB(60, 45, 30)

-- World zones (builder brief section 3).
Config.FountainCenter = Vector3.new(0, 0, 0)
Config.LakeCenter = Vector3.new(-10, -1, -45)
Config.WaterfallBase = Vector3.new(-40, 2, -68)
Config.WaterfallTop = Vector3.new(-40, 26, -72)
Config.RainbowPosition = Vector3.new(-36, 8, -64)
Config.KaraokeDeck = Vector3.new(15, 1, -40)
Config.CabinPosition = Vector3.new(35, 2, -10)
Config.SignpostPosition = Vector3.new(8, 0, 8)
Config.BridgeStart = Vector3.new(-10, 2, -20)
Config.BridgeEnd = Vector3.new(-10, 2, -45)
Config.TreehousePosition = Vector3.new(-40, 22, 25)

-- TreeForest grove spots: the dense cone-pine asset is cloned here at runtime.
Config.Grove = {
	Vector3.new(-55, 0, 20),
	Vector3.new(55, 0, 30),
	Vector3.new(-62, 0, -30),
	Vector3.new(45, 0, -55),
	Vector3.new(0, 0, 60),
}

-- Karaoke (builder brief section 4).
Config.KaraokeMaxQueue = 10
Config.KaraokeSongSeconds = 30

-- Cover-shot camera (texture design section 7).
Config.CoverCameraPosition = Vector3.new(-45, 18, 55)
Config.CoverCameraTarget = Vector3.new(0, 10, -20)

return Config
