repeat wait(1) until game:IsLoaded()
local Lib = require(game.ReplicatedStorage.Library)

function xTab(TABLE)
    for i,v in pairs(TABLE) do
        if type(v) == "function" then
            TABLE[i] = function(...) return end
        end
        if type(v) == "table" then
            xTab(v)
        end
    end
end
xTab(Lib.WorldFX)
xTab(Lib.NotificationCmds.Item)

for i,v in pairs(game:GetDescendants()) do
    if v:IsA("MeshPart") then
        v.MeshId = ""
    end
    if v:IsA("BasePart") or v:IsA("MeshPart") then
        v.Transparency = 1
    end
    if v:IsA("Texture") or v:IsA("Decal") then
        v.Texture = ""
    end
    if v:IsA("ParticleEmitter") then
        v.Lifetime = NumberRange.new(0)
        v.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,0)})
        v.Enabled = false
    end
    if v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("Trail") or v:IsA("Beam") then
        v.Enabled = false
    end
    if v:IsA("Highlight") then
        v.OutlineTransparency = 1
        v.FillTransparency = 1
    end
end
