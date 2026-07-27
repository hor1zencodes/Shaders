-- Grass Terrain Converter
workspace.Terrain:Clear()

-- Disconnect any old terrain auto-converter to prevent lag/fighting
if getgenv().TerrainAutoConverter then
    getgenv().TerrainAutoConverter:Disconnect()
end

local function isBaseplate(part)
    local name = string.lower(part.Name)
    local isFloorName = string.find(name, "baseplate") or string.find(name, "floor") or string.find(name, "ground")
    return ((part.Size.X > 100 and part.Size.Z > 100) or isFloorName) and part.Size.Y < 20
end

local function processPart(part)
    pcall(function()
        if not part:IsA("BasePart") then return end
        
        if isBaseplate(part) then
            -- Lower the terrain visually by 0.8 studs so it doesn't clip above the floor
            workspace.Terrain:FillBlock(part.CFrame * CFrame.new(0, -0.8, 0), part.Size, Enum.Material.Grass)
            
            -- Make the original baseplate invisible, but KEEP IT SOLID!
            -- This forces players to walk on the original floor, keeping height 100% accurate.
            part.Transparency = 1
            part.CanCollide = true
        end
    end)
end

local foundAny = false
for _, part in ipairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") and isBaseplate(part) then foundAny = true end
    processPart(part)
end

if not foundAny then
    workspace.Terrain:FillBlock(CFrame.new(0,-2,0), Vector3.new(2000, 4, 2000), Enum.Material.Grass)
end

-- Watch for newly loaded parts (StreamingEnabled fix!)
getgenv().TerrainAutoConverter = workspace.DescendantAdded:Connect(function(part)
    task.defer(function() processPart(part) end)
end)

workspace.Terrain.Decoration = true
workspace.Terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(90, 130, 60)) 

print("[Terrain] Successfully applied Grass terrain (StreamingEnabled supported)!")
