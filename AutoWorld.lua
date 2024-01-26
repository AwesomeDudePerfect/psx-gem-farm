wait(10)
print(executed)
-- MADE BY MLGWARFARE ON DISCORD
local savemodule = require(game:GetService("ReplicatedStorage").Library.Client.Save)
local SaveFile = savemodule.Get(game.Players.LocalPlayer)
local UnlockedAreas = SaveFile.UnlockedZones

local lplr = game:GetService("Players").LocalPlayer
local Character = lplr.Character or lplr.CharacterAdded:Wait()
local HRP = Character:WaitForChild("HumanoidRootPart")
local Enabled = true
local Mouse = lplr:GetMouse()
local MapContainer = workspace:WaitForChild("Map")
local AreaModules = game:GetService("ReplicatedStorage"):WaitForChild("__DIRECTORY"):WaitForChild("Zones", 99999999999)
local AreaUnlocker = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Zones_RequestPurchase")
local CurrentArea = 0 -- index to get next area
local AreaToUnlock = ""
local FieldPart = nil -- instance
local AreaList = {}

-- grab new hrp
local c,c2
-- enable/disable
c2 = Mouse.KeyDown:Connect(function(Key)
	if Key == "p" then Enabled = not Enabled end
end)

-- get list of areas
for _,v in pairs(AreaModules:GetDescendants()) do
	wait(0.2)
	if not v:IsA("ModuleScript") then continue end
	local Info = string.split(v.Name, " | ")
	AreaList[tonumber(Info[1])] = Info[2]
end

------ AUTO GET ORBS/LOOTBAGS
local OrbRemote = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Orbs: Collect")
local LootbagRemote = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Lootbags_Claim")
local OrbFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Orbs")
local LootbagFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Lootbags")
local autoOrbConnection, autoLootBagConnection

autoOrbConnection = OrbFolder.ChildAdded:Connect(function(v)
    OrbRemote:FireServer({tonumber(v.Name)})
    task.wait()
    v:Destroy()
end)

autoLootBagConnection = LootbagFolder.ChildAdded:Connect(function(v)
    LootbagRemote:FireServer({v.Name})
    task.wait()
    v:Destroy()
end)
print('autolootbags done')
-------------------

c = lplr.CharacterAdded:Connect(function(Char)
	Character = Char
	HRP = Character:WaitForChild("HumanoidRootPart")
end)

local function Unlock()
	return AreaUnlocker:InvokeServer(AreaToUnlock)
end

-- find current area
for Area,_ in next, UnlockedAreas do
	local AreaNum = table.find(AreaList,Area)
	if AreaNum > CurrentArea then
		CurrentArea = AreaNum
		AreaToUnlock = AreaList[AreaNum+1]
		FieldPart = MapContainer:WaitForChild(AreaNum.." | "..Area, 9999999999):WaitForChild("INTERACT", 9999999999):WaitForChild("BREAK_ZONES", 9999999999):WaitForChild("BREAK_ZONE", 9999999999)
		HRP.CFrame = FieldPart.CFrame
		task.wait(.2) -- wait for the game to load in everything
		--print("new greatest area",CurrentArea,AreaToUnlock)
	end
end

print("area to unlock:",AreaToUnlock)

while true do
	if Enabled then
		-- attempt buy new area
		if Unlock() then -- unlock succeeded
			task.wait(3)
			CurrentArea += 1
			AreaToUnlock = AreaList[CurrentArea+1]
			FieldPart = MapContainer:WaitForChild(CurrentArea.." | "..AreaList[CurrentArea]):WaitForChild("INTERACT"):WaitForChild("BREAK_ZONES"):WaitForChild("BREAK_ZONE")
			HRP.CFrame = FieldPart.CFrame
			
			-- FOR TO DAYCARE ONLY
			--if CurrentArea == 20 then
				--print("DAYCARE UNLOCKED STOPPING SCRIPT")
				--break
			--end
		else
			HRP.CFrame = FieldPart.CFrame
		end
	else
		break
	end
	task.wait(15)
end

c:Disconnect()
c2:Disconnect()
