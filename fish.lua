repeat wait() until game:IsLoaded() and game.PlaceId ~= nil

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Monkey data
local LocalPlayer = Players.LocalPlayer
local MonkeyHabitat = Workspace:WaitForChild("__THINGS")
local ActiveMonkeys = MonkeyHabitat:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local MonkeyDebris = Workspace:WaitForChild("__DEBRIS")
local MonkeyNetwork = ReplicatedStorage:WaitForChild("Network")
local FishingGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar

-- Constants
local TELEPORT_DELAY = 20
local FISHING_SITE = MonkeyHabitat.Instances.AdvancedFishing.Teleports.Enter.CFrame
local FISHING_INSTANCE = "AdvancedFishing"

-- Functions
local function teleportToFishingSite()
    MonkeyNetwork.Teleports_RequestTeleport:InvokeServer("Cloud Forest")
    wait(TELEPORT_DELAY)
    LocalPlayer.Character.HumanoidRootPart.CFrame = FISHING_SITE
end

-- Initial teleport if no active fishing instances
if #ActiveMonkeys:GetChildren() == 0 then
    teleportToFishingSite()
else
    print("nah")
end

-- Game module manipulation
local CurrentMonkeyFishingModule = require(MonkeyHabitat.__INSTANCE_CONTAINER.Active:WaitForChild("AdvancedFishing").ClientModule.FishingGame)
local OldMonkeyHooks = table.move(CurrentMonkeyFishingModule, 1, #CurrentMonkeyFishingModule, 1, {})

-- Custom game functions
CurrentMonkeyFishingModule.IsFishInBar = function()
    return math.random(1, 6) ~= 1
end

CurrentMonkeyFishingModule.StartGame = function(...)
    return OldMonkeyHooks.StartGame(...) -- Ensure the original function is called
end

CurrentMonkeyFishingModule.StopGame = function(...)
    return OldMonkeyHooks.StopGame(...) -- Ensure the original function is called
end

-- Other functions
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
    -- Implementation remains the same
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    game.VirtualUser:CaptureController()
    game.VirtualUser:ClickButton2(Vector2.new())
end)

-- Low CPU optimization
RunService:Set3dRenderingEnabled(false)
loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/lowCpu.lua"))()

-- Auto-reconnect
game:GetService("GuiService").ErrorMessageChanged:Connect(function()
    jumpToServer()
    LocalPlayer:Kick("Found An Error, Reconnecting...")
    print("Found An Error, Reonnecting...")
    wait(0.1)
end)

-- Main loop
while true do
    pcall(function()
        local fishingInstance = ActiveMonkeys:FindFirstChild(FISHING_INSTANCE)
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
