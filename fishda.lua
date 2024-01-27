local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InGame = false
local LocalPlayer = Players.LocalPlayer
local THINGS = Workspace:WaitForChild("__THINGS")
local ACTIVE = THINGS:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local DEBRIS = Workspace:WaitForChild("__DEBRIS")
local NETWORK = ReplicatedStorage:WaitForChild("Network")
local OldLocalPlayerHooks = {}
local LocalPlayerFishingGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar
local CurrentLocalPlayerFishingModule = require(ACTIVE:WaitForChild("Fishing", 99999999999).ClientModule.FishingGame)

--  functions

for i, v in pairs(CurrentLocalPlayerFishingModule) do
    OldLocalPlayerHooks[i] = v
end

CurrentLocalPlayerFishingModule.IsFishInBar = function()
    return math.random(1, 6) ~= 1
end

CurrentLocalPlayerFishingModule.StartGame = function(...)
    InGame = true
    return OldLocalPlayerHooks.StartGame(...)
end

CurrentLocalPlayerFishingModule.StopGame = function(...)
    InGame = false
    return OldLocalPlayerHooks.StopGame(...)
end

local function waitForLocalPlayerGameState(state)
    repeat
        RunService.RenderStepped:Wait()
    until InGame == state
end

local function getLocalPlayerRod()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Rod", true)
end

local function getLocalPlayerBubbles(anchor)
    local myBobber = nil
    local myBubbles = false
    local closestBobber = math.huge

    for _, v in pairs(ACTIVE.Fishing.Bobbers:GetChildren()) do
        local distance = (v.Bobber.CFrame.Position - anchor.CFrame.Position).Magnitude

        if distance <= closestBobber then
            myBobber = v.Bobber
            closestBobber = distance
        end
    end

    if myBobber then
        for _, v in pairs(DEBRIS:GetChildren()) do
            if v.Name == "host" and v:FindFirstChild("Attachment") and (v.Attachment:FindFirstChild("Bubbles") or v.Attachment:FindFirstChild("Rare Bubbles")) and (v.CFrame.Position - myBobber.CFrame.Position).Magnitude <= 1 then
                myBubbles = true
                break
            end
        end
    end

    return myBubbles
end

while task.wait(1) do
    pcall(function()
        local fishingInstance = THINGS.__INSTANCE_CONTAINER.ACTIVE:FindFirstChild("Fishing")
        if fishingInstance and not InGame then
            NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1448 + math.random(10), 61, -4451 + math.random(10)))

            local myAnchor = getLocalPlayerRod():WaitForChild("FishingLine").Attachment0
            repeat
                RunService.RenderStepped:Wait()
            until not ACTIVE:FindFirstChild("Fishing") or (myAnchor and getLocalPlayerBubbles(myAnchor)) or InGame

            if ACTIVE:FindFirstChild("Fishing") then
                NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")
                waitForLocalPlayerGameState(true)
                waitForLocalPlayerGameState(false)
            end

            repeat
                RunService.RenderStepped:Wait()
            until not ACTIVE:FindFirstChild("Fishing") or (getLocalPlayerRod() and getLocalPlayerRod().Parent.Bobber.Transparency <= 0)
        end
    end)
end
