-- Grass Terrain Converter
workspace.Terrain:Clear()

-- Disconnect any old terrain auto-converter to prevent lag/fighting
if getgenv().TerrainAutoConverter then
    getgenv().TerrainAutoConverter:Disconnect()
end

local function isBaseplate(part)
    if not part.CanCollide and part.Transparency == 1 then return false end
    local name = string.lower(part.Name)
    local isFloorName = string.find(name, "baseplate") or string.find(name, "floor") or string.find(name, "ground")
    local isFlat = math.abs(part.CFrame.UpVector.Y) > 0.9
    return ((part.Size.X > 100 and part.Size.Z > 100) or isFloorName) and part.Size.Y < 20 and isFlat
end

local function processPart(part)
    pcall(function()
        if not part:IsA("BasePart") then return end
        
        if isBaseplate(part) then
            -- Lower the terrain visually by 2.5 studs so it doesn't clip above the floor
            workspace.Terrain:FillBlock(part.CFrame * CFrame.new(0, -2.5, 0), part.Size, Enum.Material.Grass)
            
            -- Make the original baseplate invisible, but KEEP IT SOLID!
            -- This forces players to walk on the original floor, keeping height 100% accurate.
            part.Transparency = 1
            part.CanCollide = true
        end
    end)
end

local function reapplyTerrain()
    workspace.Terrain:Clear()
    local foundAny = false
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and isBaseplate(p) then
            foundAny = true
            processPart(p)
        end
    end
    if not foundAny then
        workspace.Terrain:FillBlock(CFrame.new(0,-2,0), Vector3.new(2000, 4, 2000), Enum.Material.Grass)
    end
end

reapplyTerrain()

local reapplyDebounce = false
getgenv().TerrainAutoConverter = workspace.DescendantAdded:Connect(function(part)
    if part:IsA("BasePart") then
        if not reapplyDebounce then
            reapplyDebounce = true
            task.spawn(function()
                task.wait(1.5)
                reapplyTerrain()
                reapplyDebounce = false
            end)
        end
    end
end)

workspace.Terrain.Decoration = true
workspace.Terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(90, 130, 60)) 

print("[Terrain] Successfully applied Grass terrain (StreamingEnabled supported)!")




