repeat wait() until game:IsLoaded()

if not LPH_OBFUSCATED then
    LPH_JIT_MAX = function(...) return(...) end;
    LPH_NO_VIRTUALIZE = function(...) return(...) end;
end

if not game.PlaceId == 6284583030 or not game.PlaceId == 10321372166 then wait(9e9) end

local S = [[

	This Script Was Made for the HugeGames Script.
	Loading This Script Before HugeGames may cause some issues.
	
	Due to us not being able to currently update HugeGames, as i do not have a way to get crypto rn (My bank is disabled atm and i don't keep money in crypto lol)
	I Am releasing this script publicly, open source, as recently some staff may have started going out of they way to start hunting yall down ;p
	
	
	Please make sure to run this script !!AFTER!! Loading Huge Games!!
	
	(Feel Free to use this in your own scripts if you want i guess? you can easily tweak a few things and make it work better, it wasn't finished but as i said, certain people hunting yall)

]]


local Lib = require(game.ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))
local ASConnections = {}
local CustomStaffOverrides = { -- THIS IS NOT IMPORTANT!!!
}

-- I Totally did not steal this server hopper and modify it i promise!!!
-- I Just don't feel like public releasing out personal hopper, feel free to call me a skid ahah

local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
function TPReturner(PlaceID, MaxPlayers)
	local Site;
	if foundAnything == "" then
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
	else
		Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
	end
	local ID = ""
	if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
		foundAnything = Site.nextPageCursor
	end
	local num = 0;
	for i,v in pairs(Site.data) do
		local Possible = true
		ID = tostring(v.id)
		local Pass = false

		local MaxPlrs = 999
		if MaxPlayers then MaxPlrs = MaxPlayers end

		if (PlaceID == 7722306047 or PlaceID == 11725212117 or PlaceID==12610002282) then
			if (tonumber(v.playing)>12) and (tonumber(v.Playing)<=MaxPlrs) then
				Pass=true
			end
		else
			Pass=true
		end

		if tonumber(v.maxPlayers) > tonumber(v.playing) and Pass then
			for _,Existing in pairs(AllIDs) do
				if num ~= 0 then
					if ID == tostring(Existing) then
						Possible = false
					end
				else
					if tonumber(actualHour) ~= tonumber(Existing) then
						local delFile = pcall(function()
							delfile("NotSameServers.json")
							AllIDs = {}
							table.insert(AllIDs, actualHour)
						end)
					end
				end
				num = num + 1
			end
			if Possible == true then
				table.insert(AllIDs, ID)
				wait()
				pcall(function()
					writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
					wait()
					game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
				end)
				wait(4)
			end
		end
	end
end

function Teleport(PlaceID)
	while wait() do
		pcall(function()
			TPReturner(PlaceID)
			if foundAnything ~= "" then
				TPReturner(PlaceID)
			end
		end)
	end
end

local function TimerToString(Num) -- DONT FUCKING JUDGE ME I WAS DRUNK AND SHIT WHEN I WROTE THIS D::::
	local Min = 0
	local Sec = 0
	local Hour = 0
	local S = tick()
	repeat
		if (Num-60)>=0 then
			Num = Num - 60
			Min = Min + 1
		end
	until (Num)<=60
	repeat
		if (Min-60)>=0 then
			Min = Min - 60
			Hour = Hour + 1
		end
	until (Min)<=60
	local S = (((Hour>0) and Hour.."h, ") or "")..(((Min>0) and Min.."m, ") or "")..math.floor(Num).."s"
	return S
end

local function CommitAntiStaffSuicideActions(Staff)

	local function Dip()
		if getgenv().AntiStaffConfig.ExitMode == "Kick" then
			game.Players.LocalPlayer:Kick("Saved by HugeGames OwO")
		else
			Teleport(game.PlaceId)
		end
	end

	pcall(function()
		local function DisableTable(Table)
			for i,v in pairs(Table) do
				if type(v) == "table" then
					DisableTable(v)
				end

				if type(v) == "boolean" then
					v = false
				end
			end
		end
		if getgenv().settings then
			DisableTable(getgenv().settings)
		end
	end)

	local Timer = math.random(10, 60)+math.random(10, 60);if Timer < 30 then Timer = Timer + 10 end
	if getgenv().AntiStaffConfig.InstantLeave then
		pcall(function() Lib.Message.New("A Staff Member Has Been Detected In Your Server! ("..Staff..")\n\nAll Features have (hopefully) been Disabled, and you will now be removed from the server.") end)
		Dip()
	else
		pcall(function() Lib.Message.New("A Staff Member Has Been Detected In Your Server! ("..Staff..")\n\nAll Features have (hopefully) been Disabled, and you will be removed from the server in "..TimerToString(Timer).."!") end)
		task.wait(Timer)
		Dip()
	end
end

local function CheckForStaff(Player)
	-- Check if the User is a Staff member
	-- there will be more checks put in place once this feature releases to the HugeGames main Script
	if table.find(CustomStaffOverrides, Player.Name) then
		return true, Player.Name
	end
	local IsInStaffGroup = Player:GetRankInGroup(5060810)>0

	return IsInStaffGroup, Player.Name
end

local function AntiStaffInit()
	if getgenv().AntiStaffConfig.Enabled then
		
		if not getgenv().AntiStaffConfig.DisableInitPopup then
			pcall(function() Lib.Message.New("Anti Staff Initialized") end)
		end

		table.insert(ASConnections, game.Players.PlayerAdded:Connect(function(Player)
			local IsStaff, StaffName = CheckForStaff(Player)
			if IsStaff then
				CommitAntiStaffSuicideActions(StaffName)
			end
		end))

		for i,v in pairs(game.Players:GetChildren()) do
			local IsStaff, StaffName = CheckForStaff(v)
			if IsStaff then
				CommitAntiStaffSuicideActions(StaffName)
			end
		end

	end
end

local function AntiStaffCleanup() -- Ignore, was for script lol
	for i,v in pairs(ASConnections) do
		v:Disconnect()
	end
end

-- ANTI STAFF PLACEHOLDERS

AntiStaffInit()
