-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")

-- Constants
local TELEPORT_DELAY = 20
local FISHING_SITE = Workspace.__THINGS.Instances.AdvancedFishing.Teleports.Enter.CFrame
local FISHING_INSTANCE = "AdvancedFishing"
local SERVER_URL_FORMAT = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s"
local MAX_PLAYERS_PER_SERVER = 10

-- Monkey data
local LocalPlayer = Players.LocalPlayer
local MonkeyHabitat = Workspace.__THINGS
local ActiveMonkeys = MonkeyHabitat.__INSTANCE_CONTAINER.Active
local MonkeyDebris = Workspace.__DEBRIS
local MonkeyNetwork = ReplicatedStorage.Network

-- Monkey fishing game module
local MonkeyFishingGame = LocalPlayer.PlayerGui._INSTANCES.FishingGame.GameBar
local CurrentMonkeyFishingModule = require(MonkeyHabitat.Active.AdvancedFishing.ClientModule.FishingGame)
local OldMonkeyHooks = {}

-- Check if the game is loaded and place ID is available
repeat wait() until game:IsLoaded() and game.PlaceId ~= nil

-- Function to teleport the player to the fishing site
local function teleportToFishingSite()
    local TeleportService = ReplicatedStorage.Network.Teleports_RequestTeleport
    TeleportService:InvokeServer("Cloud Forest")
    wait(TELEPORT_DELAY)
    LocalPlayer.Character.HumanoidRootPart.CFrame = FISHING_SITE
end

-- Initial teleport if no active fishing instances
if #ActiveMonkeys:GetChildren() == 0 then
    teleportToFishingSite()
else
    print('nah')
end

-- Save old hooks and redefine functions
for i, v in pairs(CurrentMonkeyFishingModule) do
    OldMonkeyHooks[i] = v
end

CurrentMonkeyFishingModule.IsFishInBar = function()
    return math.random(1, 6) ~= 1
end

CurrentMonkeyFishingModule.StartGame = function(...)
    InGame = true
    return OldMonkeyHooks.StartGame(...)
end

CurrentMonkeyFishingModule.StopGame = function(...)
    InGame = false
    return OldMonkeyHooks.StopGame(...)
end

-- Functions
local function waitForMonkeyGameState(state)
    repeat
        RunService.RenderStepped:Wait()
    until InGame == state
end

local function getMonkeyRod()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Rod", true)
end

local function getMonkeyBubbles(anchor)
    local myBobber = nil
    local myBubbles = false
    local closestBobber = math.huge

    for _, v in pairs(ActiveMonkeys.AdvancedFishing.Bobbers:GetChildren()) do
        local distance = (v.Bobber.CFrame.Position - anchor.CFrame.Position).Magnitude

        if distance <= closestBobber then
            myBobber = v.Bobber
            closestBobber = distance
        end
    end

    if myBobber then
        for _, v in pairs(MonkeyDebris:GetChildren()) do
            if v.Name == "host" and v:FindFirstChild("Attachment") and (v.Attachment:FindFirstChild("Bubbles") or v.Attachment:FindFirstChild("Rare Bubbles")) and (v.CFrame.Position - myBobber.CFrame.Position).Magnitude <= 1 then
                myBubbles = true
                break
            end
        end
    end

    return myBubbles
end

local function jumpToServer()
    repeat
        local deep = math.random(1, 5)
        local url = string.format(SERVER_URL_FORMAT, game.PlaceId, "Asc", 100)
        local response = HttpService:GetAsync(url)
        local data = HttpService:JSONDecode(response)

        if deep > 1 then
            for i = 1, deep, 1 do
                response = HttpService:GetAsync(url .. "&cursor=" .. data.nextPageCursor)
                data = HttpService:JSONDecode(response)
                wait(0.1)
            end
        end

        local servers = {}
        if data and data.data then
            for i, v in ipairs(data.data) do
                if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < MAX_PLAYERS_PER_SERVER and v.id ~= game.JobId then
                    table.insert(servers, v.id)
                end
            end
        end

        local randomCount = #servers
        if not randomCount then
            randomCount = 2
        end

        local TeleportService = ReplicatedStorage.Network.ts
        TeleportService:TeleportToPlaceInstance(8737899170, servers[math.random(1, randomCount)], Players.LocalPlayer)
    until game.JobId ~= game.JobId
end

-- Anti-AFK
Players.LocalPlayer.Idled:Connect(function()
    game.VirtualUser:CaptureController()
    game.VirtualUser:ClickButton2(Vector2.new())
end)
Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

-- Low CPU optimizer
RunService:Set3dRenderingEnabled(false)
loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/lowCpu.lua"))()

-- Auto-reconnect
task.spawn(function()
    GuiService.ErrorMessageChanged:Connect(function()
        jumpToServer()
        Players.LocalPlayer:Kick("Found An Error, Reconnecting...")
        print("Found An Error, Reonnecting...")
        wait(0.1)
    end)
end)

-- Main loop
while true do
    pcall(function()
        local fishingInstance = MonkeyHabitat.__INSTANCE_CONTAINER.Active:FindFirstChild(FISHING_INSTANCE)
        if fishingInstance and not InGame then
            MonkeyNetwork.Instancing_FireCustomFromClient:FireServer(FISHING_INSTANCE, "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))

            local myAnchor = getMonkeyRod():WaitForChild("FishingLine").Attachment0
            repeat
                RunService.RenderStepped:Wait()
            until not ActiveMonkeys:FindFirstChild(FISHING_INSTANCE) or (myAnchor and getMonkeyBubbles(myAnchor)) or InGame

            if ActiveMonkeys:FindFirstChild(FISHING_INSTANCE) then
                repeat
                    wait()
                    MonkeyNetwork.Instancing_InvokeCustomFromClient:InvokeServer(FISHING_INSTANCE, "Clicked")
                    MonkeyNetwork.Instancing_FireCustomFromClient:FireServer(FISHING_INSTANCE, "RequestReel")
                until getMonkeyRod():FindFirstChild("FishingLine") == nil
            end

            repeat
                RunService.RenderStepped:Wait()
            until not ActiveMonkeys:FindFirstChild(FISHING_INSTANCE) or (getMonkeyRod() and getMonkeyRod().Parent.Bobber.Transparency <= 0)
        end
    end)
    wait(1)
end
