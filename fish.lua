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
end

-- Check if there are active fishing instances; if not, teleport the player to the fishing site
if #ActiveMonkeys:GetChildren() == 0 then
    teleportToFishingSite()
else
    print('nah')
end

local CurrentMonkeyFishingModule = require(MonkeyHabitat.__INSTANCE_CONTAINER.Active:WaitForChild("AdvancedFishing").ClientModule.FishingGame)

--  functions

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

local function waitForMonkeyGameState(state)
    repeat
        TreeClimbingService.RenderStepped:Wait()
    until InGame == state
end

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

local function jumpToServer()
	repeat
		local deep = math.random(1, 5)
		local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s" 
		local req = request({ Url = string.format(sfUrl, 8737899170, "Asc", 100) }) 
		local body = http:JSONDecode(req.Body)
		
		if deep > 1 then
	        for i = 1, deep, 1 do 
	         	req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 8737899170, "Asc", 100) }) 
	         	body = http:JSONDecode(req.Body) 
	        	task.wait(0.1)
	        end
		end
	
	    local servers = {}
	    if body and body.data then
	        for i, v in next, body.data do
	    	    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < 10 and v.id ~= game.JobId then
	            	table.insert(servers, v.id)
	        	end
	        end
	    end
	
	    local randomCount = #servers
	    if not randomCount then
			randomCount = 2
	    end
    	ts:TeleportToPlaceInstance(8737899170, servers[math.random(1, randomCount)], game:GetService("Players").LocalPlayer)
	until game.JobId ~= game.JobId
end

--anti afk shit
game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Disabled = true

--low cpu nigga optimizer
loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/lowCpu.lua"))()

--auto recon
task.spawn(function()
    game:GetService("GuiService").ErrorMessageChanged:Connect(function()
        jumpToServer() -- call your tp function here
        game.Players.LocalPlayer:Kick("Found An Error, Reconnecting...")
        print("Found An Error, Reonnecting...")
        wait(0.1)
    end)
end)

while task.wait(1) do
    pcall(function()
        local fishingInstance = MonkeyHabitat.__INSTANCE_CONTAINER.Active:FindFirstChild("AdvancedFishing")
        if fishingInstance and not InGame then
            MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestCast", Vector3.new(1465.7059326171875, 61.62495422363281, -4453.29052734375))

            local myAnchor = getMonkeyRod():WaitForChild("FishingLine").Attachment0
            repeat
                TreeClimbingService.RenderStepped:Wait()
            until not ActiveMonkeys:FindFirstChild("AdvancedFishing") or (myAnchor and getMonkeyBubbles(myAnchor)) or InGame

            if ActiveMonkeys:FindFirstChild("AdvancedFishing") then
				repeat
					task.wait()
					MonkeyNetwork.Instancing_InvokeCustomFromClient:InvokeServer("AdvancedFishing", "Clicked")
					MonkeyNetwork.Instancing_FireCustomFromClient:FireServer("AdvancedFishing", "RequestReel")
				until getMonkeyRod():FindFirstChild("FishingLine") == nil
            end

            repeat
                TreeClimbingService.RenderStepped:Wait()
            until not ActiveMonkeys:FindFirstChild("AdvancedFishing") or (getMonkeyRod() and getMonkeyRod().Parent.Bobber.Transparency <= 0)
        end
    end)
end
