-- v1.6 client bootstrap: hangout HUD (title + version label, menu button,
-- chat hint). The "v1.6" label sits next to the title so the player can confirm
-- on screen which version is running.

local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage").Shared.config)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "HangoutGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

-- Title, top centre, with the version label right beside it.
local title = Instance.new("TextLabel")
title.Name = "Title"
title.AnchorPoint = Vector2.new(0.5, 0)
title.Position = UDim2.new(0.5, 0, 0, 12)
title.Size = UDim2.fromOffset(420, 44)
title.BackgroundTransparency = 1
title.Text = Config.GAME_NAME
title.Font = Enum.Font.FredokaOne
title.TextSize = 30
title.TextColor3 = Color3.fromRGB(255, 240, 200)
title.TextStrokeTransparency = 0.2
title.TextStrokeColor3 = Color3.fromRGB(60, 20, 60)
title.Parent = gui

local version = Instance.new("TextLabel")
version.Name = "VersionLabel"
version.AnchorPoint = Vector2.new(0, 0.5)
version.Position = UDim2.new(0, 428, 0, 0)
version.Size = UDim2.fromOffset(56, 28)
version.BackgroundColor3 = Color3.fromRGB(255, 120, 200)
version.BackgroundTransparency = 0.15
version.Text = "v" .. Config.GAME_VERSION
version.Font = Enum.Font.FredokaOne
version.TextSize = 20
version.TextColor3 = Color3.fromRGB(255, 255, 255)
version.Parent = title

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.AnchorPoint = Vector2.new(0.5, 0)
subtitle.Position = UDim2.new(0.5, 0, 0, 54)
subtitle.Size = UDim2.fromOffset(420, 22)
subtitle.BackgroundTransparency = 1
subtitle.Text = Config.GAME_TAGLINE
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 15
subtitle.TextColor3 = Color3.fromRGB(255, 220, 240)
subtitle.TextStrokeTransparency = 0.4
subtitle.Parent = gui

-- Coins chip, top right (kept clear of the top-left Roblox menu buttons).
local coins = Instance.new("TextLabel")
coins.Name = "CoinsChip"
coins.AnchorPoint = Vector2.new(1, 0)
coins.Position = UDim2.new(1, -12, 0, 12)
coins.Size = UDim2.fromOffset(150, 34)
coins.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
coins.BackgroundTransparency = 0.25
coins.Text = "Coins: 12,480"
coins.Font = Enum.Font.FredokaOne
coins.TextSize = 18
coins.TextColor3 = Color3.fromRGB(255, 220, 90)
coins.Parent = gui

-- Menu button, bottom right.
local menu = Instance.new("TextButton")
menu.Name = "MenuButton"
menu.AnchorPoint = Vector2.new(1, 1)
menu.Position = UDim2.new(1, -12, 1, -12)
menu.Size = UDim2.fromOffset(96, 40)
menu.BackgroundColor3 = Color3.fromRGB(60, 40, 90)
menu.BackgroundTransparency = 0.15
menu.Text = "MENU"
menu.Font = Enum.Font.FredokaOne
menu.TextSize = 18
menu.TextColor3 = Color3.fromRGB(255, 255, 255)
menu.Parent = gui

-- Chat hint bar, bottom centre.
local chatHint = Instance.new("TextLabel")
chatHint.Name = "ChatHint"
chatHint.AnchorPoint = Vector2.new(0.5, 1)
chatHint.Position = UDim2.new(0.5, 0, 1, -12)
chatHint.Size = UDim2.fromOffset(360, 30)
chatHint.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
chatHint.BackgroundTransparency = 0.35
chatHint.Text = "Say something to the forest..."
chatHint.Font = Enum.Font.Gotham
chatHint.TextSize = 14
chatHint.TextColor3 = Color3.fromRGB(230, 220, 255)
chatHint.Parent = gui

menu.MouseButton1Click:Connect(function()
	print("[v1.6] Menu opened by " .. player.Name)
end)

print("[v1.6] Client HUD ready")
