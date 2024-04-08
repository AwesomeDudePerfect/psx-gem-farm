local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Library = require(game.ReplicatedStorage:WaitForChild('Library'))
local Things = workspace:WaitForChild("__THINGS")
local Player = game.Players.LocalPlayer
local character = Player.Character
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
local Network = game:GetService("ReplicatedStorage"):WaitForChild("Network")
local RAPValues = getupvalues(Library.DevRAPCmds.Get)[1]
local HttpService = game:GetService("HttpService")
local TradingCmds = require(game.ReplicatedStorage.Library.Client.TradingCmds)

-- CONSTANTS
local World1UpgradeCoordinates = {
    ["Colorful Forest"] = { CFrame = CFrame.new(438, 17, -236), ZoneID = 2, UpgradeID = "Walkspeed", UpgradeTier = 1 },
    ["Castle"] = { CFrame = CFrame.new(596, 17, -237), ZoneID = 3, UpgradeID = "Magnet", UpgradeTier = 1 },
    ["Green Forest"] = { CFrame = CFrame.new(756, 17, -237), ZoneID = 4, UpgradeID = "Diamonds", UpgradeTier = 1 },
    ["Cherry Blossom"] = { CFrame = CFrame.new(792, 17, 57), ZoneID = 6, UpgradeID = "Walkspeed", UpgradeTier = 2 },
    ["Backyard"] = { CFrame = CFrame.new(467, 17, 59), ZoneID = 8, UpgradeID = "Tap Damage", UpgradeTier = 1 },
    ["Mine"] = { CFrame = CFrame.new(245, 17, 136), ZoneID = 10, UpgradeID = "Diamonds", UpgradeTier = 2 },
    ["Dead Forest"] = { CFrame = CFrame.new(442, 17, 233), ZoneID = 12, UpgradeID = "Pet Speed", UpgradeTier = 1 },
    ["Mushroom Field"] = { CFrame = CFrame.new(759, 17, 233), ZoneID = 14, UpgradeID = "Magnet", UpgradeTier = 3 },
    ["Crimson Forest"] = { CFrame = CFrame.new(794, 17, 531), ZoneID = 16, UpgradeID = "Drops", UpgradeTier = 1 },
    ["Jungle Temple"] = { CFrame = CFrame.new(468, 17, 529), ZoneID = 18, UpgradeID = "Pet Damage", UpgradeTier = 1 },
    ["Beach"] = { CFrame = CFrame.new(251, 17, 555), ZoneID = 20, UpgradeID = "Diamonds", UpgradeTier = 3 },
    ["Shipwreck"] = { CFrame = CFrame.new(438, -30, 752), ZoneID = 22, UpgradeID = "Luck", UpgradeTier = 1 },
    ["Palm Beach"] = { CFrame = CFrame.new(877, 17, 753), ZoneID = 24, UpgradeID = "Magnet", UpgradeTier = 4 },
    ["Pirate Cove"] = { CFrame = CFrame.new(915, 16, 1050), ZoneID = 26, UpgradeID = "Coins", UpgradeTier = 1 },
    ["Shanty Town"] = { CFrame = CFrame.new(602, 17, 1049), ZoneID = 28, UpgradeID = "Tap Damage", UpgradeTier = 2 },
    ["Fossil Digsite"] = { CFrame = CFrame.new(390, 17, 1123), ZoneID = 30, UpgradeID = "Pet Speed", UpgradeTier = 2 },
    ["Wild West"] = { CFrame = CFrame.new(729, 16, 1225), ZoneID = 33, UpgradeID = "Diamonds", UpgradeTier = 4 },
    ["Mountains"] = { CFrame = CFrame.new(1152, 17, 1362), ZoneID = 36, UpgradeID = "Pet Damage", UpgradeTier = 2 },
    ["Ski Town"] = { CFrame = CFrame.new(695, 17, 1599), ZoneID = 40, UpgradeID = "Coins", UpgradeTier = 2 },
    ["Obsidian Cave"] = { CFrame = CFrame.new(1180, 17, 1702), ZoneID = 44, UpgradeID = "Drops", UpgradeTier = 2 },
    ["Underworld Bridge"] = { CFrame = CFrame.new(1450, 17, 1995), ZoneID = 47, UpgradeID = "Magnet", UpgradeTier = 5 },
    ["Metal Dojo"] = { CFrame = CFrame.new(1192, 17, 2152), ZoneID = 49, UpgradeID = "Luck", UpgradeTier = 2 },
    ["Samurai Village"] = { CFrame = CFrame.new(667, 17, 2151), ZoneID = 51, UpgradeID = "Pet Damage", UpgradeTier = 3 },
    ["Zen Garden"] = { CFrame = CFrame.new(349, 17, 2151), ZoneID = 53, UpgradeID = "Tap Damage", UpgradeTier = 3 },
    ["Fairytale Castle"] = { CFrame = CFrame.new(289, 16, 2539), ZoneID = 56, UpgradeID = "Pet Speed", UpgradeTier = 3 },
    ["Fairy Castle"] = { CFrame = CFrame.new(482, 17, 2634), ZoneID = 58, UpgradeID = "Luck", UpgradeTier = 3 },
    ["Rainbow River"] = { CFrame = CFrame.new(801, 17, 2633), ZoneID = 60, UpgradeID = "Coins", UpgradeTier = 3 },
    ["Frost Mountains"] = { CFrame = CFrame.new(1241, 17, 2769), ZoneID = 63, UpgradeID = "Magnet", UpgradeTier = 6 },
    ["Ice Castle"] = { CFrame = CFrame.new(1154, 17, 3247), ZoneID = 66, UpgradeID = "Diamonds", UpgradeTier = 5 },
    ["Firefly Cold Forest"] = { CFrame = CFrame.new(824, 17, 3248), ZoneID = 68, UpgradeID = "Drops", UpgradeTier = 3 },
    ["Witch Marsh"] = { CFrame = CFrame.new(289, 17, 3634), ZoneID = 74, UpgradeID = "Tap Damage", UpgradeTier = 4 },
    ["Haunted Mansion"] = { CFrame = CFrame.new(640, 17, 3711), ZoneID = 77, UpgradeID = "Luck", UpgradeTier = 4 },
    ["Treasure Dungeon"] = { CFrame = CFrame.new(1099, -33, 4003), ZoneID = 80, UpgradeID = "Magnet", UpgradeTier = 7 },
    ["Gummy Forest"] = { CFrame = CFrame.new(511, 17, 4321), ZoneID = 84, UpgradeID = "Coins", UpgradeTier = 4 },
    ["Carnival"] = { CFrame = CFrame.new(-35, 17, 4397), ZoneID = 88, UpgradeID = "Pet Speed", UpgradeTier = 5 },
    ["Cloud Houses"] = { CFrame = CFrame.new(-36, 117, 5393), ZoneID = 93, UpgradeID = "Pet Damage", UpgradeTier = 4 },
    ["Colorful Clouds"] = { CFrame = CFrame.new(-37, 117, 6185), ZoneID = 98, UpgradeID = "Diamonds", UpgradeTier = 6 },
}

local PetUpgradeRankMax = {3, 6, 12, 20, 28}

local PetUpgradeCost = {
    250, 500, 750,
    1000, 1250, 1500,
    1750, 2000, 2250, 2500, 2750, 3000,
    3250, 3500, 3750, 4000, 4250, 4500, 4750, 5000,
    5250, 5500, 5750, 6000, 6250, 7000, 8500, 10000,
}

-- MORE LOW GRAPHICS
local g = game
local w = g.Workspace
local l = g.Lighting
local t = w.Terrain
sethiddenproperty(l,"Technology",2)
sethiddenproperty(t,"Decoration",false)
t.WaterWaveSize = 0
t.WaterWaveSpeed = 0
t.WaterReflectance = 0
t.WaterTransparency = 0
l.GlobalShadows = 0
l.FogEnd = 9e9
l.Brightness = 0
for i, v in pairs(w:GetDescendants()) do
    if v:IsA("BasePart") and not v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif (v:IsA("Decal") or v:IsA("Texture")) then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("MeshPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
        v.TextureID = 10385902758728957
    elseif v:IsA("SpecialMesh") then
        v.TextureId=0
    elseif v:IsA("ShirtGraphic") then
        v.Graphic=1
    elseif (v:IsA("Shirt") or v:IsA("Pants")) then
        v[v.ClassName.."Template"] = 1
    end
end
for i = 1,#l:GetChildren() do
    local e=l:GetChildren()[i]
    if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
        e.Enabled = false
    end
end
-- Low Graphics
pcall(function()
    Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass('Terrain')
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for i,v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        end
    end
    for i,v in pairs(Lighting:GetDescendants()) do
        if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
            v.Enabled = false
        end
    end
    workspace.DescendantAdded:Connect(function(v)
        spawn(function()
            if v:IsA('ForceField') then
                game.RunService.Heartbeat:Wait()
                v:Destroy()
            elseif v:IsA('Sparkles') then
                game.RunService.Heartbeat:Wait()
                v:Destroy()
            elseif v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") or v:IsA("BasePart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            elseif v:IsA("SpecialMesh") then
                v.TextureId=0
            elseif v:IsA("ShirtGraphic") then
                v.ShirtGraphic=1
            elseif (v:IsA("Shirt") or v:IsA("Pants")) then
                v[v.ClassName.."Template"]=1
            end
        end)
    end)
end)

-- Low Processing
for i, v in pairs(Things:GetChildren()) do
    pcall(function()
        if v.Name == "Sounds" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "RandomEvents" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "Flags" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "Hoverboards" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "Booths" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "ExclusiveEggs" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "ExclusiveEggPets" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "BalloonGifts" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "Sprinklers" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "Eggs" then
            v.Parent = game.ReplicatedStorage
        end
    end)
    pcall(function()
        if v.Name == "ShinyRelics" then
            v.Parent = game.ReplicatedStorage
        end
    end)
end

-- Delete other player characters for less processing
spawn(function()
    while true do
        task.wait(30)
        for i, v in game.Players:GetPlayers() do
            if v ~= game.Players.LocalPlayer then
                pcall(function()
                    local Character = v.Character
                    Character:Destroy()
                end)
            end
        end
    end
end)

workspace.Gravity = 0

for i, v in workspace.__THINGS:GetChildren() do
    if not (v.Name == "Orbs" or v.Name == "Lootbags" or v.Name == "Breakables") then
        v.Parent = game.ReplicatedStorage
    end
end
for i, v in workspace:GetDescendants() do
    pcall(function() v.CanCollide = false end)
    pcall(function() v.CanTouch = false end)
    pcall(function() v.CastShadow = false end)
    pcall(function() 
        if not v:IsDescendantOf(character) then
            v.Anchored = true
        end
    end)
end

workspace.DescendantAdded:Connect(function(v)
    pcall(function() v.CanCollide = false end)
    pcall(function() v.CanTouch = false end)
    pcall(function() v.CastShadow = false end)
    pcall(function() 
        if not v:IsDescendantOf(character) then
            v.Anchored = true 
        end
    end)
end)

local Player = game.Players.LocalPlayer
for i, v in Player.PlayerGui:GetDescendants() do
    pcall(function() v.Enabled = false end)
end

local entities = {
    "Stats", 
    "Chat", 
    "Debris",
    "CoreGui",
}
for _, entity in entities do
    pcall(function()
        for i, v in game[entity]:GetDescendants() do
            pcall(function() v:Destroy() end)
        end
    end)
end

-- Set humanoidRootPart everytime player dies
Player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- PLAYER LIST
local Player = game.Players.LocalPlayer
local sortedPlayers = game.Players:GetPlayers()
table.sort(sortedPlayers, function(a, b)
    return a.Name:lower() < b.Name:lower()
end)
game.Players.PlayerAdded:Connect(function(player)
    table.sort(sortedPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
end)

local function findItem(Id)
    local save = Library.Save.Get().Inventory
    for Type, List in save do
        for i, v in pairs(List) do
            if v.id == Id then
                local AM = (v._am) or 1
                return i, AM, Type
            end
        end
    end
end

local function findEnchant(Id, tn)
    local save = Library.Save.Get().Inventory
    for i, v in pairs(save["Enchant"]) do
        if v.id == Id and v.tn == tn then
            local AM = (v._am) or 1
            return i, AM
        end
    end
end

local function getRAP(Type, Item)
    if RAPValues[Type] then
        for i,v in pairs(RAPValues[Type]) do
            local itemTable = HttpService:JSONDecode(i)
            if itemTable.id == Item.id and itemTable.tn == Item.tn and itemTable.sh == Item.sh and itemTable.pt == Item.pt then
                return v
            end
        end
    end
end

local Window = Fluent:CreateWindow({
    Title = "Ani's script PS99",
    SubTitle = "by Ani",
    TabWidth = 120,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,                  -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Delete -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Farming = Window:AddTab({ Title = "AutoWorld", Icon = "" }),
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ELEMENTS
local AutoClickToggle = Tabs.Farming:AddToggle("AutoClick", { Title = "Auto Click", Default = true })
Tabs.Farming:AddSlider("AutoClickRadius", {
    Title = "Auto Click Radius",
    Description = "Recommended: 80",
    Default = 80,
    Min = 1,
    Max = 200,
    Rounding = 0
})
local AutoWorldToggle = Tabs.Farming:AddToggle("AutoWorld", { Title = "Auto World", Default = true })
local AutoBuyUpgradeToggle = Tabs.Farming:AddToggle("AutoBuyUpgrade", { Title = "Auto Buy Upgrade", Default = true })
local AutoLootToggle = Tabs.Farming:AddToggle("AutoLoot", { Title = "Auto Loot", Default = true })
local AutoTradeToggle = Tabs.Farming:AddToggle("AutoTrade", { Title = "Auto Trade", Default = true })
local AutoEquipEnchantToggle = Tabs.Farming:AddToggle("AutoEquipEnchant", { Title = "Auto Equip Enchant", Default = true })
local AutoUltimateToggle = Tabs.Farming:AddToggle("AutoUltimate", { Title = "Auto Use Ultimate", Default = true })
local AutoPotionsToggle = Tabs.Farming:AddToggle("AutoPotions", { Title = "Auto Use Potions", Default = true })
local AutoFruitsToggle = Tabs.Farming:AddToggle("AutoFruits", { Title = "Auto Use Banana", Default = true })
local AutoClaimMailToggle = Tabs.Farming:AddToggle("AutoClaimMail", { Title = "Auto Claim Mail", Default = true })
Tabs.Misc:AddSection("Auto Send Mail")

local PlayerState = "Farming"
local gui = nil
local guitexts = {"AREA", "REBIRTH", "RANK", "DIAMONDS", "UPGRADES", "PETS"}
local guilabels = {}
local enchanttexts = {"NO", "NO", "NO"}
local enchantlabels = {}

-- FARMING AUTO CLAIM MAIL
AutoClaimMailToggle:OnChanged(function()
    AutoClaimMailToggle = Options.AutoClaimMail.Value
    spawn(function()
        while AutoClaimMailToggle do
            task.wait(60)
            pcall(function()
                Network:WaitForChild("Mailbox: Claim All"):InvokeServer()
            end)
        end
    end)
end)

-- AUTO ULTIMATE
AutoUltimateToggle:OnChanged(function()
    spawn(function()
        while Options.AutoUltimate do
            task.wait(60)
            pcall(function()
                local save = Library.Save.Get()
                if save.EquippedUltimateId ~= "Ground Pound" and save.Rebirths >= 4 then
                    local success = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Ultimates: Equip"):InvokeServer("Ground Pound")
                    if success then return end
                end
            end)
        end
    end)
    spawn(function()
        while Options.AutoUltimate do
            task.wait(1)
            pcall(function()
                local save = Library.Save.Get()
                if save.EquippedUltimateId == "Ground Pound" and save.UltimateCooldowns["Ground Pound"] >= 100 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Ultimates: Activate"):InvokeServer("Ground Pound")
                end
            end)
        end
    end)
end)

-- FARMING PART [AUTO CLICK CURRENT ZONE] --
local Breakables = game.workspace['__THINGS'].Breakables
AutoClickToggle:OnChanged(function()
    local BreakablesConn = nil
    local BreakablesTempFolder = game.ReplicatedStorage:FindFirstChild("BreakablesTempFolder") or Instance.new("Folder")
    BreakablesTempFolder.Name = "BreakablesTempFolder"
    BreakablesTempFolder.Parent = game.ReplicatedStorage
    if Options.AutoClick.Value then
        for i, v in Breakables:GetChildren() do
            v.Parent = BreakablesTempFolder
        end
        BreakablesConn = Breakables.ChildAdded:Connect(function(v)
            task.wait()
            v.Parent = BreakablesTempFolder
        end)
    elseif BreakablesConn then
        BreakablesConn:Disconnect()
        BreakablesConn = nil
    end
    spawn(function()
        while(Options.AutoClick.Value) do
            local MaxZone, MaxZoneInfo = Library["ZoneCmds"].GetMaxOwnedZone()
            for i, Target in BreakablesTempFolder:GetChildren() do
                pcall(function()
                    if MaxZone == Target:GetAttribute("ParentID") then
                        Network.Breakables_PlayerDealDamage:FireServer(Target.Name)
                        task.wait()
                        MaxZone, MaxZoneInfo = Library["ZoneCmds"].GetMaxOwnedZone()
                    end
                end)
            end
            task.wait()
        end
    end)
end)

-- AUTO USE POTIONS
AutoPotionsToggle:OnChanged(function()
    AutoPotionsToggle = Options.AutoPotions.Value
    spawn(function()
        while AutoPotionsToggle do
            task.wait(10)
            pcall(function()
                local potion = Library.Save.Get().Inventory["Potion"]
                for i, v in pairs(potion) do
                    if v.id == "Coins" then
                        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Potions: Consume"):FireServer(i)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end)
end)

-- AUTO USE BANANA AND RAINBOW
AutoFruitsToggle:OnChanged(function()
    AutoFruitsToggle = Options.AutoFruits.Value
    spawn(function()
        while AutoFruitsToggle do
            task.wait(10)
            pcall(function()
                local fruit = Library.Save.Get().Inventory["Fruit"]
                for i, v in pairs(fruit) do
                    if v.id == "Banana" or v.id == "Rainbow" then
                        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Fruits: Consume"):FireServer(i, 1)
                        task.wait(0.5)
                    end
                end
            end)
        end
    end)
end)

-- BUYING UPGRADES
local GetUpgradeCount

local function UpdateUpgradeGUI()
    pcall(function() 
        local upgrades = GetUpgradeCount() 
        guilabels[5].Text = "UPGRADES: " .. upgrades
        if upgrades >= 37 then
            guilabels[5].BackgroundColor3 = Color3.new(0, 1, 0)
        else
            guilabels[5].BackgroundColor3 = Color3.new(1, 0, 0)
        end 
    end)
end

local function UpdatePetsGUI()
    pcall(function() 
        local save = Library.Save.Get()
        guilabels[6].Text = "PETS: " .. tostring(save.PetSlotsPurchased + 4)
    end)
end

local function BuyUpgrades()
    pcall(function()
        local save = Library.Save.Get()
        local OwnedUpgrades = save.UpgradesOwned
        local Coordinates = World1UpgradeCoordinates
        local MaxZone, MaxZoneInfo = Library["ZoneCmds"].GetMaxOwnedZone()
        if game.PlaceId ~= 8737899170 then Coordinates = {} end
        for Zone, ZoneInfo in World1UpgradeCoordinates do
            local Owned = false
            if OwnedUpgrades[ZoneInfo.UpgradeID] then
                for i, UpgradeTier in OwnedUpgrades[ZoneInfo.UpgradeID] do
                    if UpgradeTier == ZoneInfo.UpgradeTier then
                        Owned = true
                        break
                    end
                end
            end
            if not Owned then
                local cost = Library.Directory.Upgrades[ZoneInfo.UpgradeID].TierCosts[ZoneInfo.UpgradeTier]
                if Player.leaderstats["💎 Diamonds"].Value >= cost * 2 and MaxZoneInfo.ZoneNumber >= ZoneInfo.ZoneID then
                    local success = false
                    while not success do
                        task.wait()
                        humanoidRootPart.CFrame = ZoneInfo.CFrame
                        success = game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Upgrades_Purchase"):InvokeServer(ZoneInfo.UpgradeID, Zone)
                    end
                    UpdateUpgradeGUI()
                else
                    break
                end
            end
        end            
    end)
end

GetUpgradeCount = function()
    local save = Library.Save.Get()
    local slots = save.PetSlotsPurchased
    local OwnedUpgrades = save.UpgradesOwned
    local count = 0
    for i, UpgradeTier in OwnedUpgrades do
        for ii, tier in UpgradeTier do
            count = count + 1
        end
    end
    return count, slots
end

AutoBuyUpgradeToggle:OnChanged(function()
    local count, slots = GetUpgradeCount()
    spawn(function()
        UpdateUpgradeGUI()
        while Options.AutoBuyUpgrade.Value and game.PlaceId == 8737899170 do
            task.wait(60)
            if slots < 28 then
                UpdatePetsGUI()
                PlayerState = "Upgrading"
                local save = Library.Save.Get()
                while Player.leaderstats["💎 Diamonds"].Value >= PetUpgradeCost[slots + 1] and slots < PetUpgradeRankMax[save.Rank] do
                    character:MoveTo(Vector3.new(693, 17, -267))
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("EquipSlotsMachine_RequestPurchase"):InvokeServer(slots + 1)
                    local save = Library.Save.Get()
                    slots = save.PetSlotsPurchased
                    UpdatePetsGUI()
                    task.wait(1)
                end
            end
            if count < 37 then
                UpdateUpgradeGUI()
                PlayerState = "Upgrading"
                BuyUpgrades()
                UpdateUpgradeGUI()                    
            end
            PlayerState = "Farming"
            count, slots = GetUpgradeCount()
        end        
        while Options.AutoBuyUpgrade.Value and game.PlaceId == 16498369169 do
            task.wait(10)
            count, slots = GetUpgradeCount()
            if slots < 28 then
                UpdatePetsGUI()
                PlayerState = "Upgrading"
                local save = Library.Save.Get()
                while Player.leaderstats["💎 Diamonds"].Value >= PetUpgradeCost[slots + 1] and slots < PetUpgradeRankMax[save.Rank] do
                    character:MoveTo(Vector3.new(-9907, 18, -572))
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("EquipSlotsMachine_RequestPurchase"):InvokeServer(slots + 1)
                    save = Library.Save.Get()
                    slots = save.PetSlotsPurchased
                    UpdatePetsGUI()
                    task.wait(1)
                end
            else
                break
            end
            PlayerState = "Farming"
        end        
    end)
end)

-- FARMING PART [AUTO WORLD]
local Unlock = function(MaxZone, MaxZoneInfo)
    local NextZone, NextZoneInfo = Library["ZoneCmds"].GetNextZone()
    if MaxZoneInfo.ZoneNumber < 174 then 
        return Network:WaitForChild("Zones_RequestPurchase"):InvokeServer(NextZoneInfo.ZoneName), NextZoneInfo
    end
end

local teleportToZone = function(ZoneFolder)
    if ZoneFolder:FindFirstChild("INTERACT") then
        local Max, BreakZone;
        for i,v in pairs(ZoneFolder.INTERACT.BREAK_ZONES:GetChildren()) do
            if not Max then Max = v.Size.X * v.Size.Y * v.Size.Z; end
            if not BreakZone then BreakZone = v end

            if Max < v.Size.X * v.Size.Y * v.Size.Z then
                BreakZone = v
            end
        end
        humanoidRootPart.CFrame = BreakZone.CFrame * CFrame.new(0, 10, 0)
    else
        humanoidRootPart.CFrame = ZoneFolder.PERSISTENT.Teleport.CFrame
    end                    
end

AutoWorldToggle:OnChanged(function()
    AutoWorldToggle = Options.AutoWorld.Value

    local camera = workspace.CurrentCamera
    camera.CFrame = CFrame.new(0, 0, 0) * CFrame.fromEulerAngles(math.rad(-90), 0, 0)
    Player.CameraMinZoomDistance = 150
    Player.CameraMaxZoomDistance = 150
    
    local MaxZone, MaxZoneInfo = Library["ZoneCmds"].GetMaxOwnedZone()
    local save = Library.Save.Get()
    -- Create a ScreenGui
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Parent = game.Players.LocalPlayer.PlayerGui
        gui.DisplayOrder = 999

        -- Create TextLabels for each text
        for i, text in ipairs(guitexts) do
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = gui
            textLabel.Text = text
            textLabel.Font = Enum.Font.SourceSans
            textLabel.TextSize = 24
            textLabel.Size = UDim2.new(0.24, 0, 0.1, 0) -- Adjust as needed
            textLabel.Position = UDim2.new(0, 0, 0.5 + (i - 6) * 0.1, 0) -- Center text vertically
            textLabel.AnchorPoint = Vector2.new(0, 0)
            textLabel.BackgroundColor3 = Color3.new(1, 1, 1)
            guilabels[i] = textLabel
        end

        -- Create TextLabels for each enchant
        for i, text in ipairs(enchanttexts) do
            local textLabel = Instance.new("TextLabel")
            textLabel.Parent = gui
            textLabel.Text = text
            textLabel.Font = Enum.Font.SourceSans
            textLabel.TextSize = 24
            textLabel.Size = UDim2.new(0.08, 0, 0.1, 0) -- Adjust as needed
            textLabel.Position = UDim2.new((i - 1) * 0.08, 0, 0.5 + 0.1, 0) -- Center text vertically
            textLabel.AnchorPoint = Vector2.new(0, 0)
            textLabel.BackgroundColor3 = Color3.new(1, 0, 0)
            textLabel.TextColor3 = Color3.new(1, 1, 1)
            enchantlabels[i] = textLabel
        end

        guilabels[4].Text = "DIAMONDS: " .. Player.leaderstats["💎 Diamonds"].Value
        Player.leaderstats["💎 Diamonds"].Changed:Connect(function(val)
            guilabels[4].Text = "DIAMONDS: " .. val
        end)
    end

    -- CLAIM RANK
    spawn(function()
        while(AutoWorldToggle) do
            task.wait(60)
            pcall(function()
                guilabels[3].Text = "RANK: " .. Library.Save.Get().Rank
                local allRewardsReady = require(game.ReplicatedStorage.Library.Client.RankCmds).AllRewardsReady()
                local allRewardsRedeemed = require(game.ReplicatedStorage.Library.Client.RankCmds).AllRewardsRedeemed()
                if allRewardsReady then
                    local rewardNum = 1
                    while not allRewardsRedeemed do
                        task.wait(1)
                        allRewardsRedeemed = require(game.ReplicatedStorage.Library.Client.RankCmds).AllRewardsRedeemed()
                        Network.Ranks_ClaimReward:FireServer(rewardNum)
                        rewardNum = (rewardNum + 1) % 50
                    end
                end
            end)
        end
    end)

    -- LOOP UNLOCK
    spawn(function()
        while(AutoWorldToggle) do
            task.wait()
            pcall(function()
                Unlock(MaxZone, MaxZoneInfo)
                if MaxZoneInfo.ZoneNumber >= 174 then
                    return
                end
            end)
        end
    end)

    -- LOOP TELEPORT
    spawn(function()
        while(AutoWorldToggle) do
            task.wait()
            pcall(function()
                if PlayerState == "Farming" then
                    if game.PlaceId == 8737899170 and save.Rebirths >= 4 and MaxZoneInfo.ZoneNumber >= 99 and MaxZoneInfo.ZoneNumber < 174 then
                        game.ReplicatedStorage.Network.World2Teleport:InvokeServer()
                    end
                    if game.PlaceId ~= 8737899170 and save.Rebirths >= 5 and MaxZoneInfo.ZoneNumber >= 174 then
                        repeat game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) task.wait(3) until not game.PlaceId
                    end
                    MaxZone, MaxZoneInfo = Library["ZoneCmds"].GetMaxOwnedZone()
                    guilabels[1].Text = "AREA: " .. MaxZoneInfo.ZoneNumber
                    save = Library.Save.Get()
                    if MaxZone == "Spawn" then
                        humanoidRootPart.CFrame = CFrame.new(218.907, 18.919, -205.798)
                    else
                        teleportToZone(MaxZoneInfo.ZoneFolder)
                    end
                end
            end)
        end
    end)
    -- LOOP REBIRTH
    spawn(function()
        while(AutoWorldToggle) do
            task.wait()
            pcall(function()
                local rb = Library.RebirthCmds.GetNextRebirth()
                if rb then
                    guilabels[2].Text = "REBIRTH: " .. (rb.RebirthNumber - 1)
                    if MaxZoneInfo.ZoneNumber >= rb.ZoneNumberRequired then
                        Network.Rebirth_Request:InvokeServer(tostring(rb.RebirthNumber))
                    end
                else
                    guilabels[2].Text = "REBIRTH: MAX"
                    return
                end
            end)
        end
    end)
    if AutoWorldToggle then
        gui.Enabled = true

        -- DELETE MAP
        pcall(function()
            workspace.Map.Parent = game.ReplicatedStorage
        end)
        pcall(function()
            workspace.Map2.Parent = game.ReplicatedStorage
        end)
        pcall(function()
            workspace.MAP.Parent = game.ReplicatedStorage
        end)
        pcall(function()
            workspace.ALWAYS_RENDERING.Parent = game.ReplicatedStorage
        end)
        pcall(function()
            workspace.ALWAYS_RENDERING_2.Parent = game.ReplicatedStorage
        end)
        pcall(function()
            local DebrisTempFolder = game.ReplicatedStorage:FindFirstChild("DebrisTempFolder") or Instance.new("Folder")
            DebrisTempFolder.Name = "DebrisTempFolder"
            DebrisTempFolder.Parent = game.ReplicatedStorage
            for i, v in workspace.__DEBRIS:GetChildren() do
                v.Parent = DebrisTempFolder
            end
            workspace.__DEBRIS.ChildAdded:Connect(function(v)
                v.Parent = DebrisTempFolder            
            end)
        end)
        
        -- DELETE USELESS SCRIPTS
        for i, v in Player.PlayerScripts:GetChildren() do
            print(i, v)
            if v.Name ~= "Scripts" then
                v:Destroy()
            end
        end
        for i, v in Player.PlayerScripts.Scripts:GetChildren() do
            print(i, v)
            if not (v.Name == "Game" or v.Name == "Core") then
                v:Destroy()
            end
        end
        for i, v in Player.PlayerScripts.Scripts.Game:GetChildren() do
            pcall(function()
                if not string.find(v.Name, "Breakables") then
                    v:Destroy()
                end
            end)
        end
    else
        gui.Enabled = false
    end
end)

-- FARMING AUTO EQUIP FARM ENCHANT
AutoEquipEnchantToggle:OnChanged(function()
    AutoEquipEnchantToggle = Options.AutoEquipEnchant.Value
    spawn(function()
        while AutoEquipEnchantToggle do
            task.wait(60)
            pcall(function()
                local save = Library.Save.Get()
                local maxEnchants = save.MaxEnchantsEquipped
                local SuperLightning = findItem("Super Lightning")
                local TapPower = findEnchant("Tap Power", 7)
                pcall(function()
                    if SuperLightning == save.EquippedEnchants['1'] then
                        enchantlabels[1].Text = "Yes"
                        enchantlabels[1].BackgroundColor3 = Color3.new(0, 1, 0)                            
                    end
                    if TapPower == save.EquippedEnchants['2'] then
                        enchantlabels[2].Text = "Yes"
                        enchantlabels[2].BackgroundColor3 = Color3.new(0, 1, 0)                            
                    end
                end)
                if (SuperLightning and SuperLightning ~= save.EquippedEnchants['1']) then
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Enchants_ClearSlot"):FireServer(1)
                    task.wait()
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Enchants_Equip"):FireServer(SuperLightning)
                end
                if (maxEnchants >= 2 and TapPower and TapPower ~= save.EquippedEnchants['2']) then
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Enchants_ClearSlot"):FireServer(2)
                    task.wait()
                    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Enchants_Equip"):FireServer(TapPower)
                end
            end)
        end
    end)
end)

-- FARMING PART [AUTO LOOT] --
local autoOrbConnection = nil
local autoLootBagConnection = nil
AutoLootToggle:OnChanged(function()
    AutoLootToggle = Options.AutoLoot.Value
    if AutoLootToggle then
        for i, v in workspace.__THINGS.Orbs:GetChildren() do
            Network["Orbs: Collect"]:FireServer({ tonumber(v.Name) })
            Network["Orbs_ClaimMultiple"]:FireServer({ [1] = { [1] = v.Name } })
            v:Destroy()
        end
        for i, v in workspace.__THINGS.Lootbags:GetChildren() do
            Network.Lootbags_Claim:FireServer({ v.Name })
            v:Destroy()
        end
        autoOrbConnection = workspace.__THINGS.Orbs.ChildAdded:Connect(function(v)
            task.wait()
            Network["Orbs: Collect"]:FireServer({ tonumber(v.Name) })
            Network["Orbs_ClaimMultiple"]:FireServer({ [1] = { [1] = v.Name } })
            v:Destroy()
        end)
        autoLootBagConnection = workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
            task.wait()
            Network.Lootbags_Claim:FireServer({ v.Name })
            v:Destroy()
        end)
    else
        if autoOrbConnection then
            autoOrbConnection:Disconnect(); autoOrbConnection = nil;
        end
        if autoLootBagConnection then
            autoLootBagConnection:Disconnect(); autoLootBagConnection = nil;
        end
    end
end)

-- AUTO TRADE TOGGLE
AutoTradeToggle:OnChanged(function()
    while Options.AutoTrade.Value do
        task.wait(1)
        pcall(function()
            local currentState = TradingCmds.GetState()
            if currentState then
                local localIndex = table.find(TradingCmds.GetState()._players, game.Players.LocalPlayer)
                while currentState do
                    if TradingCmds.GetState()._ready[localIndex] == false then
                        repeat local readySuccess, readyReason = Library.Network.Invoke("Server: Trading: Set Ready", TradingCmds.GetState()._id, true, TradingCmds.GetState()._counter) until readySuccess
                    end
                    task.wait(1)
                end
            else
                for Player, Table in pairs(TradingCmds.GetAllRequests()) do
                    if Player.Name == "zeniqeu" then
                        for Local, Time in pairs(Table) do
                            if Local and Local == game.Players.LocalPlayer then
                                Library.Network.Invoke("Server: Trading: Request", Player)
                            end
                        end
                    end
                end                    
            end
        end)
    end
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AniHub")
SaveManager:SetFolder("AniHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
