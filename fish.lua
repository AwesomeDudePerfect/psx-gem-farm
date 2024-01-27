-- Wait until the game is fully loaded and the PlaceId is not nil
repeat task.wait() until game:IsLoaded() and game.PlaceId ~= nil

-- Get essential Roblox services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Set up variables and constants
local InGame = false
local LocalPlayer = Players.LocalPlayer
local THINGS = Workspace:WaitForChild("__THINGS")
local ACTIVE = THINGS:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local DEBRIS = Workspace:WaitForChild("__DEBRIS")
local NETWORK = ReplicatedStorage:WaitForChild("Network")
local OldLocalPlayerHooks = {}
local LocalPlayerFishingGame = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar

-- Define a function to teleport the player to the fishing site
local function teleportToFishingSite()
    -- Teleport the player to the fishing site
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Teleports_RequestTeleport"):InvokeServer("Cloud Forest")
    wait(10)
    LocalPlayer.Character.HumanoidRootPart.CFrame = THINGS.Instances.AdvancedFishing.Teleports.Enter.CFrame
end

-- Check if there are active fishing instances; if not, teleport the player to the fishing site
if #ACTIVE:GetChildren() == 0 then
    teleportToFishingSite()
else
    print('nah')
end

-- Fetch the current fishing module
local CurrentLocalPlayerFishingModule = require(ACTIVE.AdvancedFishing.ClientModule.FishingGame)

-- Save existing hooks for later use
for i, v in pairs(CurrentLocalPlayerFishingModule) do
    OldLocalPlayerHooks[i] = v
end

-- Override the IsFishInBar function
CurrentLocalPlayerFishingModule.IsFishInBar = function()
    return math.random(1, 6) ~= 1
end

-- Override the StartGame function
CurrentLocalPlayerFishingModule.StartGame = function(...)
    InGame = true
    return OldLocalPlayerHooks.StartGame(...)
end

-- Override the StopGame function
CurrentLocalPlayerFishingModule.StopGame = function(...)
    InGame = false
    return OldLocalPlayerHooks.StopGame(...)
end

-- Function to wait for the local player game state
local function waitForLocalPlayerGameState(state)
    repeat
        RunService.RenderStepped:Wait()
    until InGame == state
end

-- Function to get the local player's rod
local function getLocalPlayerRod()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Rod", true)
end

-- Function to check for bubbles around the player's rod
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

-- Main loop
while task.wait(1) do
    pcall(function()
        local fishingInstance = THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")
        if fishingInstance and not InGame then
            -- Request to cast the fishing line
            NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))

            local myAnchor = getLocalPlayerRod():WaitForChild("FishingLine").Attachment0
            -- Wait for bubbles or game start
            repeat
                RunService.RenderStepped:Wait()
            until not ACTIVE:FindFirstChild("AdvancedFishing") or (myAnchor and getLocalPlayerBubbles(myAnchor)) or InGame

            if getLocalPlayerRod():WaitForChild("FishingLine") then
                -- Continuously reel in the fishing line until it disappears
                while getLocalPlayerRod():WaitForChild("FishingLine") do
                    NETWORK.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")
                    task.wait(0.2)  -- Adjust the wait time as needed
                end
            end

            -- Wait until the bobber becomes visible
            repeat
                RunService.RenderStepped:Wait()
            until getLocalPlayerRod() and getLocalPlayerRod().Parent.Bobber.Transparency <= 0
        end
    end)
end
