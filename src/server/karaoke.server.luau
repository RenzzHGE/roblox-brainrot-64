-- v1.6 karaoke queue (lake deck). Server authority; clients sync via RemoteEvents.
-- Up to 10 songs in the queue; the current song runs 30 seconds, then the next
-- singer takes the deck. The singer's name and song show on the deck screen.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.config)

local stateEvent = Instance.new("RemoteEvent")
stateEvent.Name = "KaraokeState"
stateEvent.Parent = ReplicatedStorage

local submitEvent = Instance.new("RemoteEvent")
submitEvent.Name = "KaraokeSubmit"
submitEvent.Parent = ReplicatedStorage

local queue = {} -- array of QueueSong tables
local current = nil -- QueueSong currently singing
local currentExpiresAt = 0 -- os.clock() time when the current song ends

local screenLabel = nil -- TextLabel on the deck screen, found at startup

local function broadcast()
	stateEvent:FireAllClients({ current = current, queue = queue })
end

local function cleanTitle(title)
	if typeof(title) ~= "string" then
		return nil
	end
	local trimmed = string.gsub(title, "^%s+", "")
	trimmed = string.gsub(trimmed, "%s+$", "")
	if #trimmed == 0 or #trimmed > 60 then
		return nil
	end
	return trimmed
end

local function findScreenLabel()
	local world = Workspace:FindFirstChild("World")
	local screen = world and world:FindFirstChild("KaraokeScreen")
	if not screen then
		return nil
	end
	local gui = screen:FindFirstChildOfClass("SurfaceGui")
	if not gui then
		return nil
	end
	return gui:FindFirstChildOfClass("TextLabel")
end

local function updateScreen()
	if not screenLabel then
		screenLabel = findScreenLabel()
	end
	if not screenLabel then
		return
	end
	if current then
		screenLabel.Text = "♪ SEKARANG: " .. current.userName .. " — " .. current.songTitle
	else
		screenLabel.Text = "♪ KARAOKE — antrean kosong, ayo nyanyi!"
	end
end

local function advanceQueue()
	if #queue == 0 then
		current = nil
		currentExpiresAt = 0
	else
		current = table.remove(queue, 1)
		currentExpiresAt = os.clock() + Config.KaraokeSongSeconds
	end
	updateScreen()
	broadcast()
	if current then
		print("[v1.6] Karaoke: " .. current.userName .. " sings " .. current.songTitle)
	end
end

submitEvent.OnServerEvent:Connect(function(player: Player, songTitle)
	local title = cleanTitle(songTitle)
	if not title then
		return
	end
	if #queue >= Config.KaraokeMaxQueue then
		return
	end
	table.insert(queue, {
		userId = player.UserId,
		userName = player.Name,
		songTitle = title,
		queuedAt = os.clock(),
	})
	if not current then
		advanceQueue()
	else
		broadcast()
	end
end)

Players.PlayerRemoving:Connect(function(player: Player)
	local changed = false
	for index = #queue, 1, -1 do
		if queue[index].userId == player.UserId then
			table.remove(queue, index)
			changed = true
		end
	end
	if current and current.userId == player.UserId then
		advanceQueue()
		return
	end
	if changed then
		broadcast()
	end
end)

task.spawn(function()
	while true do
		task.wait(1)
		if current and os.clock() >= currentExpiresAt then
			advanceQueue()
		end
	end
end)

updateScreen()
broadcast()
print("[v1.6] Karaoke server ready")
