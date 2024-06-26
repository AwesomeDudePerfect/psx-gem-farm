-- Define the numbers to choose from
local numbers = {1, 2, 3, 4, 5, 6}

local MINIMUM_PLAYERS = numbers[math.random(1, #numbers)]

--// Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local CurrentWorld = ""
local CurrentPosition = nil

--// Variables
local PlaceId = game.PlaceId
local fileName = string.format("%s_servers.json", tostring(PlaceId))
local ServerHopData = { 
    CheckedServers = {},
    LastTimeHop = nil,
    CreatedAt = os.time() -- We can use it later to clear the checked servers
    -- TODO: Save the cursor? Prob this can help on fast-hops
}

-- Load data from disk/workspace
if isfile(fileName) then
    local fileContent = readfile(fileName)
    ServerHopData = HttpService:JSONDecode(fileContent)
end

-- Optional log feature
if ServerHopData.LastTimeHop then
    print("Took", os.time() - ServerHopData.LastTimeHop, "seconds to server hop")
end

local ServerTypes = { ["Normal"] = "desc", ["Low"] = "asc" }

function Jump(serverType)
    serverType = serverType or "Normal" -- Default parameter
    if not ServerTypes[serverType] then serverType = "Normal" end
    
    local function GetServerList(cursor)
        cursor = cursor and "&cursor=" .. cursor or ""
        local API_URL = string.format('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100', tostring(PlaceId), ServerTypes[serverType])
        return HttpService:JSONDecode(game:HttpGet(API_URL .. cursor))
    end

    local currentPageCursor = nil
    while true do 
        local serverList = GetServerList(currentPageCursor)
        currentPageCursor = serverList.nextPageCursor
           
        for _, server in ipairs(serverList.data) do
            if server.playing and tonumber(server.playing) >= 1 and tonumber(server.playing) < Players.MaxPlayers and tonumber(server.ping) <= 100 and not table.find(ServerHopData.CheckedServers, tostring(server.id)) then     
                -- Save current data to disk/workspace
                ServerHopData.LastTimeHop = os.time() -- Last time that tried to hop
                table.insert(ServerHopData.CheckedServers, server.id) -- Insert on our list
                writefile(fileName, HttpService:JSONEncode(ServerHopData)) -- Save our data
                TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer) -- Actually teleport the player
                -- Change the wait time if you take long times to hop (or it will add more than 1 server in the file)
                wait(0.25)
            end
        end
        
        if not currentPageCursor then break else wait(0.25) end
    end  
end
Jump("Low")
