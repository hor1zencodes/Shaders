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

-- Snapshot every BasePart color in the workspace
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

-- ==========================================
-- CUSTOM THEME: AESTHETIC
-- ==========================================

local function applyAesthetic(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        if isCharacterPart(part) then return end
        if part.Name == "ZenTile" then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(20, 100, 140)
            part.WaterReflectance = 1
        else
            part.Color = part.Color
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyAesthetic(obj)
end
Workspace.DescendantAdded:Connect(applyAesthetic)

Lighting:ClearAllChildren()

-- Lighting settings
Lighting.Technology = Enum.Technology.Future
Lighting.Ambient = Color3.fromRGB(70, 70, 70)
Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
Lighting.Brightness = 3
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ClockTime = 14.5
Lighting.GeographicLatitude = 0
Lighting.ExposureCompensation = 0

-- Sky
local Sky = Instance.new("Sky")
Sky.Name = "Sky"
Sky.MoonAngularSize = 11
Sky.MoonTextureId = "rbxasset://sky/moon.jpg"
Sky.SkyboxBk = "rbxassetid://600830446"
Sky.SkyboxDn = "rbxassetid://600831635"
Sky.SkyboxFt = "rbxassetid://600832720"
Sky.SkyboxLf = "rbxassetid://600886090"
Sky.SkyboxRt = "rbxassetid://600833862"
Sky.SkyboxUp = "rbxassetid://600835177"
Sky.StarCount = 3000
Sky.SunAngularSize = 21
Sky.SunTextureId = "rbxasset://sky/sun.jpg"
Sky.CelestialBodiesShown = false
Sky.Parent = Lighting

-- Bloom
local Bloom = Instance.new("BloomEffect")
Bloom.Enabled = true
Bloom.Intensity = 0.053
Bloom.Size = 56
Bloom.Threshold = 0.5
Bloom.Parent = Lighting

-- Color Correction
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Enabled = true
ColorCorrection.Brightness = 0
ColorCorrection.Contrast = 0.3
ColorCorrection.Saturation = 0.1
ColorCorrection.TintColor = Color3.fromRGB(181, 168, 135)
ColorCorrection.Parent = Lighting

-- SunRays
local SunRays = Instance.new("SunRaysEffect")
SunRays.Enabled = true
SunRays.Intensity = 0.5
SunRays.Spread = 2
SunRays.Parent = Lighting
