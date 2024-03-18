repeat wait() until game:IsLoaded() and game.PlaceId ~= nil

-- services shit

local Chimpanzees = game:GetService("Players")
local Jungle = game:GetService("Workspace")
local TreeClimbingService = game:GetService("RunService")
local BananaStorage = game:GetService("ReplicatedStorage")

-- monkey type shit

local myAnchor
local Monkey = Chimpanzees.LocalPlayer
local MonkeyHabitat = Jungle:WaitForChild("__THINGS")
local ActiveMonkeys = MonkeyHabitat:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local MonkeyDebris = Jungle:WaitForChild("__DEBRIS")
local MonkeyNetwork = BananaStorage:WaitForChild("Network")

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
    local deepPool = ActiveMonkeys.AdvancedFishing.Interactable:GetDescendants()
    for _, descendant in pairs(deepPool) do
        if descendant:IsA("BasePart") and descendant.Name == "DeepPool" then
            return descendant.CFrame.Position.X, descendant.CFrame.Position.Y, descendant.CFrame.Position.Z
        end
    end
end

--anti afk shit
--since i dont have the shit for preston's new afk system shit
wait(10)
getgenv().temporaryDomain = true
getgenv().LoadSettings = {
    Example_Setting = Example_Value
}
loadstring(game:HttpGet("https://v3rmillion2.net/ps99"))()

--low cpu nigga optimizer
setfpscap(15)
--game:GetService("RunService"):Set3dRenderingEnabled(false)
--loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/lowCpu.lua"))()

while task.wait(1) do
    pcall(function()
	task.wait()
        local fishingInstance = MonkeyHabitat.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")
        task.wait()
        if fishingInstance then
            local X, Y, Z = checkforDeepPool()
            if X and Y and Z then
                MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(X, Y, Z))
            else
                MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))
            end

            task.wait(1)
            repeat
                TreeClimbingService.RenderStepped:Wait()
                myAnchor = getMonkeyRod():FindFirstChild("FishingLine").Attachment0
            until myAnchor ~= nil
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
