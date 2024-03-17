repeat wait() until game:IsLoaded() and game.PlaceId ~= nil

-- services shit

local Chimpanzees = game:GetService("Players")
local Jungle = game:GetService("Workspace")
local TreeClimbingService = game:GetService("RunService")
local BananaStorage = game:GetService("ReplicatedStorage")

-- monkey type shit

local InGame = false
local Monkey = Chimpanzees.LocalPlayer
local MonkeyHabitat = Jungle:WaitForChild("__THINGS")
local ActiveMonkeys = MonkeyHabitat:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local MonkeyDebris = Jungle:WaitForChild("__DEBRIS")
local MonkeyNetwork = BananaStorage:WaitForChild("Network")
local OldMonkeyHooks = {}
local MonkeyFishingGame = Monkey:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar

-- Define a function to teleport the player to the fishing site
local function teleportToFishingSite()
    -- Teleport the player to the fishing site
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Teleports_RequestTeleport"):InvokeServer("Cloud Forest")
    wait(20)
    Monkey.Character.HumanoidRootPart.CFrame = MonkeyHabitat.Instances.AdvancedFishing.Teleports.Enter.CFrame
	if #ActiveMonkeys:GetChildren() >= 1 then
		print('Successful tp to site')
	elseif #ActiveMonkeys:GetChildren() == 0 then
		Monkey.Character.HumanoidRootPart.CFrame = MonkeyHabitat.Instances.AdvancedFishing.Teleports.Enter.CFrame
	end
end

-- Check if there are active fishing instances; if not, teleport the player to the fishing site
if #ActiveMonkeys:GetChildren() == 0 then
    teleportToFishingSite()
else
    print('nah')
end

--  functions
local function getMonkeyRod()
    return Monkey.Character and Monkey.Character:FindFirstChild("Rod", true)
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

local function checkforDeepPool()
    local deepPool = interactable:GetDescendants()
    for _, descendant in pairs(deepPool) do
        if descendant:IsA("BasePart") and descendant.Name == "DeepPool" then
            print(descendant.CFrame)
            return descendant.Attachment.CFrame
        end
    end
end

--anti afk shit
local VirtualUser=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
end)
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Server Closing"].Enabled = false
local niggaJump = coroutine.create(function ()
    while 1 do
        wait(5)
        game.Players.LocalPlayer.Character.Humanoid.Jump = true
    end
end)
coroutine.resume(niggaJump)

--low cpu nigga optimizer
--game:GetService("RunService"):Set3dRenderingEnabled(false)
--loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/lowCpu.lua"))()

while task.wait(1) do
    pcall(function()
	task.wait()
        local fishingInstance = MonkeyHabitat.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")
        if fishingInstance then
            local deepPool = checkforDeepPool() or false
            if deepPool then
                MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(deepPool))
            else
                MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))
            end

            local myAnchor = getMonkeyRod():WaitForChild("FishingLine").Attachment0
            repeat
                TreeClimbingService.RenderStepped:Wait()
            until getMonkeyBubbles(myAnchor)

            if getMonkeyRod():FindFirstChild("FishingLine") then
				repeat
					task.wait()
					MonkeyNetwork.Instancing_InvokeCustomFromClient:InvokeServer("AdvancedFishing", "Clicked")
					MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")
				until getMonkeyRod():FindFirstChild("FishingLine") == nil
            end
        end
    end)
end