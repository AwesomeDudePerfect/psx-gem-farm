repeat wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Root1527/personal/main/lowcpu.lua"))()

game:GetService("RunService"):Set3dRenderingEnabled(false)
local Players = game:GetService('Players')
local Player = Players.LocalPlayer.Name
local getPlayers = Players:GetPlayers()
local http = game:GetService("HttpService")
local ts = game:GetService("TeleportService")
local NiggasToAvoid = {
	"ShwaDev",
	"ShwaDevZ",
	"ShwaDevW",
	"ShwaDevY",
	"historianaverage"
}

local function jumpToServer()
	repeat
		local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
		local req = request({ Url = string.format(sfUrl, 8737899170, "Asc", 100) })
		local body = http:JSONDecode(req.Body)
	
	    local servers = {}
	    if body and body.data then
	        for i, v in next, body.data do
	    	    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing >= 1 and v.id ~= game.JobId then
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

for i, v in pairs(game:GetService("Players"):GetChildren()) do
    print(v.Name)

    for _, username in ipairs(NiggasToAvoid) do
        if v.Name == username and Player ~= username then
            jumpToServer()
            wait(60)
        end
    end
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/AwesomeDudePerfect/psx-gem-farm/main/main.lua"))()
print('executed')

task.spawn(function()
	game:GetService("GuiService").ErrorMessageChanged:Connect(function()
		game.Players.LocalPlayer:Kick("Found An Error, Reconnecting...")
		print("Found An Error, Reonnecting...")
		wait(0.1)
		jumpToServer()
	end)
end)
