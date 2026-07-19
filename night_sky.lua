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
-- CUSTOM THEME: NIGHT SKY
-- ==========================================

local function applyNightSky(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        if isCharacterPart(part) then return end
        if part.Name == "ZenTile" then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(20, 100, 140)
            part.WaterReflectance = 1
        else
            local origColor = getgenv().ORIGINAL_COLORS[part] or part.Color
            part.Color = origColor:Lerp(Color3.fromRGB(40, 50, 70), 0.40) -- Lighter tint so it's not pitch black
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyNightSky(obj)
end
Workspace.DescendantAdded:Connect(applyNightSky)

Lighting:ClearAllChildren()

-- RTX Lighting settings
-- RTX Lighting settings
Lighting.Technology = Enum.Technology.Future
Lighting.Ambient = Color3.fromRGB(50, 50, 60)
Lighting.OutdoorAmbient = Color3.fromRGB(50, 50, 60)
Lighting.Brightness = 3
Lighting.ColorShift_Bottom = Color3.fromRGB(5, 10, 20)
Lighting.ColorShift_Top = Color3.fromRGB(80, 120, 200) -- Dark blue typish light
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.1
Lighting.ClockTime = 14.0 -- Midday so the custom skybox is actually visible!
Lighting.GeographicLatitude = 80 -- Pushes the hidden sun down to the horizon for long shadows!
Lighting.ExposureCompensation = 0

-- Sky "NIGHT"
local Sky1 = Instance.new("Sky")
Sky1.Name = "NIGHT"
Sky1.MoonAngularSize = 11
Sky1.MoonTextureId = "rbxasset://sky/moon.jpg"
Sky1.SkyboxBk = "rbxassetid://12064107"
Sky1.SkyboxDn = "rbxassetid://12064152"
Sky1.SkyboxFt = "rbxassetid://12064121"
Sky1.SkyboxLf = "rbxassetid://12063984"
Sky1.SkyboxRt = "rbxassetid://12064115"
Sky1.SkyboxUp = "rbxassetid://12064131"
Sky1.StarCount = 1000
Sky1.SunAngularSize = 0
Sky1.SunTextureId = "rbxasset://sky/moon.jpg"
Sky1.CelestialBodiesShown = true
Sky1.Parent = Lighting

-- Atmosphere (Thick, moody cinematic night fog for RTX vibe)
local Atmo1 = Instance.new("Atmosphere")
Atmo1.Name = "Atmosphere"
Atmo1.Density = 0.25
Atmo1.Offset = 0.25
Atmo1.Color = Color3.fromRGB(30, 30, 40)
Atmo1.Decay = Color3.fromRGB(15, 15, 25)
Atmo1.Glare = 0.1
Atmo1.Haze = 0.2
Atmo1.Parent = Lighting

-- Bloom (Sharp and crisp for stars and lights)
local Bloom = Instance.new("BloomEffect")
Bloom.Enabled = true
Bloom.Intensity = 1.0
Bloom.Size = 16
Bloom.Threshold = 1.5
Bloom.Parent = Lighting

-- Depth of Field (DSLR RTX focus)
local DepthOfField = Instance.new("DepthOfFieldEffect")
DepthOfField.Enabled = true
DepthOfField.FarIntensity = 0.1
DepthOfField.NearIntensity = 0.75
DepthOfField.FocusDistance = 0.05
DepthOfField.InFocusRadius = 30
DepthOfField.Parent = Lighting

-- Color Correction (Desaturated, cinematic night)
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Enabled = true
ColorCorrection.Brightness = 0.02
ColorCorrection.Contrast = 0.1
ColorCorrection.Saturation = -0.1
ColorCorrection.TintColor = Color3.fromRGB(200, 220, 255) -- Dark blue typish tint for the whole scene
ColorCorrection.Parent = Lighting

-- SunRays (Very subtle for moon rays)
local SunRays = Instance.new("SunRaysEffect")
SunRays.Enabled = true
SunRays.Intensity = 0.05
SunRays.Spread = 0.5
SunRays.Parent = Lighting

-- RTX Terrain & Volumetric Clouds
if Workspace:FindFirstChildOfClass("Terrain") then
    Workspace.Terrain.Decoration = true
    
    for _, c in ipairs(Workspace.Terrain:GetChildren()) do
        if c:IsA("Clouds") then c:Destroy() end
    end
    
    local Clouds = Instance.new("Clouds")
    Clouds.Name = "RTX_Clouds"
    Clouds.Cover = 1.0 -- Extremely high
    Clouds.Density = 1.0 -- Thicker
    Clouds.Color = Color3.fromRGB(80, 90, 110)
    Clouds.Parent = Workspace.Terrain
end
