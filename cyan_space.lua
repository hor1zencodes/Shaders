local Players   = game:GetService("Players")
local Lighting  = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Wipe any old snapshot first
getgenv().ORIGINAL_COLORS   = {}
getgenv().ORIGINAL_LIGHTING = {}
getgenv().ORIGINAL_WATER    = nil
getgenv().ORIGINAL_SKY      = nil
getgenv().ORIGINAL_ATMO     = nil

local function isCharacterPart(part)
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and part:IsDescendantOf(char) then return true end
    end
    return false
end

-- ------------------------------------------------
-- Snapshot every BasePart color in the workspace
-- ------------------------------------------------
local colorCount = 0
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and not isCharacterPart(obj) then
        pcall(function()
            getgenv().ORIGINAL_COLORS[obj] = obj.Color
            colorCount += 1
        end)
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if obj:IsA("BasePart") and not isCharacterPart(obj) then
            pcall(function()
                if not getgenv().ORIGINAL_COLORS[obj] then
                    getgenv().ORIGINAL_COLORS[obj] = obj.Color
                end
            end)
        end
    end)
end)

-- ------------------------------------------------
-- Snapshot all Lighting properties
-- ------------------------------------------------
local L = getgenv().ORIGINAL_LIGHTING
L.Technology               = Lighting.Technology
L.Ambient                  = Lighting.Ambient
L.OutdoorAmbient           = Lighting.OutdoorAmbient
L.Brightness               = Lighting.Brightness
L.ColorShift_Bottom        = Lighting.ColorShift_Bottom
L.ColorShift_Top           = Lighting.ColorShift_Top
L.FogColor                 = Lighting.FogColor
L.FogEnd                   = Lighting.FogEnd
L.FogStart                 = Lighting.FogStart
L.GlobalShadows            = Lighting.GlobalShadows
L.ShadowSoftness           = Lighting.ShadowSoftness
L.EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale
L.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
L.ExposureCompensation     = Lighting.ExposureCompensation
L.ClockTime                = Lighting.ClockTime
L.GeographicLatitude       = Lighting.GeographicLatitude

-- ------------------------------------------------
-- Snapshot existing Sky & Atmo
-- ------------------------------------------------
local existingSky = Lighting:FindFirstChildOfClass("Sky")
if existingSky then
    getgenv().ORIGINAL_SKY = {
        SkyboxBk             = existingSky.SkyboxBk,
        SkyboxDn             = existingSky.SkyboxDn,
        SkyboxFt             = existingSky.SkyboxFt,
        SkyboxLf             = existingSky.SkyboxLf,
        SkyboxRt             = existingSky.SkyboxRt,
        SkyboxUp             = existingSky.SkyboxUp,
        CelestialBodiesShown = existingSky.CelestialBodiesShown,
        StarCount            = existingSky.StarCount,
    }
end

local existingAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
if existingAtmo then
    getgenv().ORIGINAL_ATMO = {
        Density = existingAtmo.Density,
        Offset  = existingAtmo.Offset,
        Color   = existingAtmo.Color,
        Decay   = existingAtmo.Decay,
        Glare   = existingAtmo.Glare,
        Haze    = existingAtmo.Haze,
    }
end

-- ------------------------------------------------
-- Snapshot Terrain water
-- ------------------------------------------------
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    getgenv().ORIGINAL_WATER = {
        WaterColor        = Terrain.WaterColor,
        WaterReflectance  = Terrain.WaterReflectance,
        WaterTransparency = Terrain.WaterTransparency,
        WaterWaveSize     = Terrain.WaterWaveSize,
        WaterWaveSpeed    = Terrain.WaterWaveSpeed,
    }
end

print(string.format("[Snapshot] Ready. Saved %d part colors, lighting, sky, atmosphere & water. Safe to run shaders.", colorCount))

-- ------------------------------------------------
-- Apply Cyan Space Colors
-- ------------------------------------------------
local function toCyanTint(c)
    local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
    -- Keep it mostly gray but with a distinct cyan/blue tint
    return Color3.new(lum * 0.7, lum * 0.9, lum * 1.0)
end

local colorCache = {}

local function applyTint(part)
    if not part:IsA('BasePart') and not part:IsA('Terrain') then return end
    if part.Name == "ZenTile" then return end
    if colorCache[part] then return end
    if isCharacterPart(part) then return end

    colorCache[part] = true
    
    if part:IsA("Terrain") then
        part.WaterColor = Color3.fromRGB(0, 150, 255)
    else
        part.Color = toCyanTint(part.Color)
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    pcall(applyTint, obj)
end

workspace.DescendantAdded:Connect(function(inst)
    task.defer(function()
        pcall(applyTint, inst)
    end)
end)

local function protectAvatar(char)
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        pcall(function()
            if part:IsA('BasePart') and colorCache[part] then
                colorCache[part] = nil
            end
        end)
    end

    char.DescendantAdded:Connect(function(inst)
        task.defer(function()
            pcall(function()
                if inst:IsA('BasePart') then
                    colorCache[inst] = nil
                end
            end)
        end)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    protectAvatar(plr.Character)
    plr.CharacterAdded:Connect(protectAvatar)
end

Players.PlayerAdded:Connect(function(plr)
    protectAvatar(plr.Character)
    plr.CharacterAdded:Connect(protectAvatar)
end)

-- ------------------------------------------------
-- Apply Cyan Space Lighting & Skybox
-- ------------------------------------------------
Lighting:ClearAllChildren()

local sky = Instance.new('Sky')
sky.SkyboxBk = 'http://www.roblox.com/asset/?id=16888989874'
sky.SkyboxDn = 'http://www.roblox.com/asset/?id=16888991855'
sky.SkyboxFt = 'http://www.roblox.com/asset/?id=16888995219'
sky.SkyboxLf = 'http://www.roblox.com/asset/?id=16888998994'
sky.SkyboxRt = 'http://www.roblox.com/asset/?id=16889000916'
sky.SkyboxUp = 'http://www.roblox.com/asset/?id=16889004122'
sky.StarCount = 8000
sky.Parent = Lighting

local atmo = Instance.new('Atmosphere')
atmo.Density = 0.65
atmo.Offset = 0.15
atmo.Color = Color3.fromRGB(0, 180, 255)
atmo.Decay = Color3.fromRGB(0, 50, 100)
atmo.Glare = 0.05
atmo.Haze = 0.3
atmo.Parent = Lighting

Lighting.Ambient = Color3.fromRGB(0, 60, 100)
Lighting.OutdoorAmbient = Color3.fromRGB(0, 80, 120)
Lighting.ColorShift_Top = Color3.fromRGB(100, 180, 255)
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 30, 60)
Lighting.FogColor = Color3.fromRGB(0, 15, 30)
Lighting.FogEnd = 80000
Lighting.Brightness = 0.8
Lighting.GlobalShadows = true
Lighting.ClockTime = 15 -- Afternoon angle for nice long shadows
Lighting.ShadowSoftness = 0.2
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1

local bloom = Instance.new('BloomEffect')
bloom.Enabled = true
bloom.Intensity = 0.35
bloom.Size = 42
bloom.Threshold = 0.15
bloom.Parent = Lighting

local sunrays = Instance.new('SunRaysEffect')
sunrays.Enabled = true
sunrays.Intensity = 0.1
sunrays.Spread = 0.5
sunrays.Parent = Lighting

local colorCorrection = Instance.new('ColorCorrectionEffect')
colorCorrection.Saturation = 0.2
colorCorrection.Brightness = 0.05
colorCorrection.Contrast = 0.15
colorCorrection.TintColor = Color3.fromRGB(220, 240, 255)
colorCorrection.Enabled = true
colorCorrection.Parent = Lighting

print("[Cyan Space] Shader successfully applied!")
