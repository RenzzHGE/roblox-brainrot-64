-- v1.6 contextual prompts: ProximityPrompts on benches (sit), the signpost
-- (read directions) and market stalls (browse). Shows a small toast when used.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toast = Instance.new("TextLabel")
toast.Name = "PromptToast"
toast.AnchorPoint = Vector2.new(0.5, 1)
toast.Position = UDim2.new(0.5, 0, 1, -52)
toast.Size = UDim2.fromOffset(360, 30)
toast.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
toast.BackgroundTransparency = 0.3
toast.Text = ""
toast.Font = Enum.Font.Gotham
toast.TextSize = 14
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.Visible = false
toast.Parent = playerGui

local function showToast(message)
	toast.Text = message
	toast.Visible = true
	task.delay(3, function()
		toast.Visible = false
	end)
end

local function attachPrompt(part, actionText, holdSeconds, onTriggered)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.HoldDuration = holdSeconds
	prompt.MaxActivationDistance = 8
	prompt.Parent = part
	prompt.Triggered:Connect(onTriggered)
	return prompt
end

local world = Workspace:WaitForChild("World", 30)
if not world then
	warn("[v1.6] World not found — prompts skipped")
	return
end

-- Benches: sit down.
for _, descendant in ipairs(world:GetDescendants()) do
	if descendant:IsA("Seat") then
		attachPrompt(descendant, "Duduk", 0, function(triggeringPlayer)
			if triggeringPlayer ~= player then
				return
			end
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				descendant:Sit(humanoid)
				showToast("Duduk santai di hutan 🌲")
			end
		end)
	end
end

-- Signpost: read the directions.
local signpost = world:FindFirstChild("Signpost")
if signpost then
	attachPrompt(signpost, "Baca Papan", 0, function()
		showToast("Hutan • Air Terjun • Air Mancur • Karaoke Deck")
	end)
end

-- Market stalls: browse.
for _, descendant in ipairs(world:GetDescendants()) do
	if descendant:IsA("BasePart") and descendant.Name == "StallCounter" then
		attachPrompt(descendant, "Lihat Jualan", 0, function()
			showToast("Warung hutan: jus mangga, sate, dan kopi panas!")
		end)
	end
end

print("[v1.6] Prompts ready")
