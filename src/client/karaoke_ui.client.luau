-- v1.6 karaoke UI: queue panel, now-playing label, song submit box.
-- Listens to the KaraokeState RemoteEvent and submits via KaraokeSubmit.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local stateEvent = ReplicatedStorage:WaitForChild("KaraokeState", 30)
local submitEvent = ReplicatedStorage:WaitForChild("KaraokeSubmit", 30)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "KaraokeGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "QueuePanel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 60)
panel.Size = UDim2.fromOffset(240, 300)
panel.BackgroundColor3 = Color3.fromRGB(25, 18, 40)
panel.BackgroundTransparency = 0.15
panel.Parent = gui

local header = Instance.new("TextLabel")
header.Name = "Header"
header.Position = UDim2.new(0, 0, 0, 0)
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundTransparency = 1
header.Text = "♪ KARAOKE QUEUE"
header.Font = Enum.Font.FredokaOne
header.TextSize = 18
header.TextColor3 = Color3.fromRGB(255, 200, 240)
header.Parent = panel

local nowPlaying = Instance.new("TextLabel")
nowPlaying.Name = "NowPlaying"
nowPlaying.Position = UDim2.new(0, 8, 0, 36)
nowPlaying.Size = UDim2.new(1, -16, 0, 40)
nowPlaying.BackgroundTransparency = 1
nowPlaying.Text = "Antrean kosong — ayo nyanyi!"
nowPlaying.Font = Enum.Font.Gotham
nowPlaying.TextSize = 13
nowPlaying.TextColor3 = Color3.fromRGB(255, 230, 120)
nowPlaying.TextWrapped = true
nowPlaying.TextXAlignment = Enum.TextXAlignment.Left
nowPlaying.Parent = panel

local list = Instance.new("TextLabel")
list.Name = "QueueList"
list.Position = UDim2.new(0, 8, 0, 80)
list.Size = UDim2.new(1, -16, 0, 150)
list.BackgroundTransparency = 1
list.Text = ""
list.Font = Enum.Font.Gotham
list.TextSize = 13
list.TextColor3 = Color3.fromRGB(235, 230, 255)
list.TextWrapped = true
list.TextXAlignment = Enum.TextXAlignment.Left
list.TextYAlignment = Enum.TextYAlignment.Top
list.Parent = panel

local input = Instance.new("TextBox")
input.Name = "SongInput"
input.Position = UDim2.new(0, 8, 0, 236)
input.Size = UDim2.new(1, -16, 0, 28)
input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
input.BackgroundTransparency = 0.1
input.PlaceholderText = "Judul lagu..."
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.TextColor3 = Color3.fromRGB(20, 20, 30)
input.Parent = panel

local submit = Instance.new("TextButton")
submit.Name = "SubmitButton"
submit.Position = UDim2.new(0, 8, 0, 270)
submit.Size = UDim2.new(1, -16, 0, 24)
submit.BackgroundColor3 = Color3.fromRGB(255, 120, 200)
submit.Text = "MASUK ANTREAN"
submit.Font = Enum.Font.FredokaOne
submit.TextSize = 14
submit.TextColor3 = Color3.fromRGB(255, 255, 255)
submit.Parent = panel

local function updateDisplay(state)
	if state.current then
		nowPlaying.Text = "♪ " .. state.current.userName .. ": " .. state.current.songTitle
	else
		nowPlaying.Text = "Antrean kosong — ayo nyanyi!"
	end
	local lines = {}
	for index, song in ipairs(state.queue) do
		table.insert(lines, tostring(index) .. ". " .. song.userName .. " — " .. song.songTitle)
	end
	if #lines == 0 then
		list.Text = "Belum ada antrean."
	else
		list.Text = table.concat(lines, "\n")
	end
end

submit.MouseButton1Click:Connect(function()
	local title = input.Text
	if title and #title > 0 then
		submitEvent:FireServer(title)
		input.Text = ""
	end
end)

if stateEvent then
	stateEvent.OnClientEvent:Connect(updateDisplay)
end

print("[v1.6] Karaoke UI ready")
