repeat task.wait() until game:IsLoaded() and game.PlaceId ~= nil

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- LocalPlayer type shit

local InGame = false
local LocalPlayer = Players.LocalPlayer
local c
local THINGS = game:GetService("Workspace"):WaitForChild("__THINGS")
local ACTIVE = THINGS:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local DEBRIS = Workspace:WaitForChild("__DEBRIS")
local NETWORK = ReplicatedStorage:WaitForChild("Network")
local OldLocalPlayerHooks = {}
local LocalPlayerFishingGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar

--  functions

c = LocalPlayer.CharacterAdded:Connect(function(Char)
	Character = Char
	HRP = Character:WaitForChild("HumanoidRootPart")
end)

local function teleportToFishingSite()
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Teleports_RequestTeleport"):InvokeServer(unpack({[1] = "Cloud Forest"}))
    wait(10)
    local tpAdvancedFishing = game:GetService("Workspace"):WaitForChild("__THINGS"):WaitForChild("Instances"):WaitForChild("AdvancedFishing").Teleports.Enter
    LocalPlayer.Character.HumanoidRootPart.CFrame = tpAdvancedFishing.CFrame
end

if #ACTIVE:GetChildren() == 0 then
    teleportToFishingSite()
else
    print('nah')
end

local CurrentLocalPlayerFishingModule = require(ACTIVE:WaitForChild("AdvancedFishing", 99999999999).ClientModule.FishingGame)

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

    for _, v in pairs(ACTIVE.AdvancedFishing.Bobbers:GetChildren()) do
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
        local fishingInstance = THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")
        if fishingInstance and not InGame then
            NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))

            local myAnchor = getLocalPlayerRod():WaitForChild("FishingLine").Attachment0
            repeat
                RunService.RenderStepped:Wait()
            until not ACTIVE:FindFirstChild("AdvancedFishing") or (myAnchor and getLocalPlayerBubbles(myAnchor)) or InGame

            if getLocalPlayerRod():WaitForChild("FishingLine") then
                NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")
                waitForLocalPlayerGameState(true)
                waitForLocalPlayerGameState(false)
            end

            repeat
                RunService.RenderStepped:Wait()
            until getLocalPlayerRod() and getLocalPlayerRod().Parent.Bobber.Transparency <= 0
        end
    end)
end
