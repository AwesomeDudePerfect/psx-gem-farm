repeat wait() until game:IsLoaded()
wait(20)
getgenv().AuthKey = "HUGE_gmqREZqn7kKB"
getgenv().LoadSettings = {
    Example_Setting = Example_Value
}
local success, error = loadstring(game:HttpGet("https://HugeGames.io/ps99"))()
wait(15)
if success then
    print('executed')
else
    loadstring(game:HttpGet("https://HugeGames.io/ps99"))()
end