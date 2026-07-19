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
            local origColor = getgenv().ORIGINAL_COLORS[part] or part.Color
            part.Color = origColor:Lerp(Color3.fromRGB(255, 200, 180), 0.85) -- 85% strength so it's obvious!
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
Lighting.Brightness = 2.5 -- Restored brightness so the world isn't flat
Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
Lighting.ColorShift_Top = Color3.fromRGB(255, 237, 219)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.1
Lighting.ClockTime = 17.5
Lighting.GeographicLatitude = 0
Lighting.ExposureCompensation = 0

-- Skybox 1
local Sky1 = Instance.new("Sky")
Sky1.Name = "Sky"
Sky1.MoonAngularSize = 11
Sky1.MoonTextureId = "rbxasset://sky/moon.jpg"
Sky1.SkyboxBk = "rbxassetid://600830446"
Sky1.SkyboxDn = "rbxassetid://600831635"
Sky1.SkyboxFt = "rbxassetid://600832720"
Sky1.SkyboxLf = "rbxassetid://600886090"
Sky1.SkyboxRt = "rbxassetid://600833862"
Sky1.SkyboxUp = "rbxassetid://600835177"
Sky1.StarCount = 3000
Sky1.SunAngularSize = 21
Sky1.SunTextureId = "rbxassetid://1084351190"
Sky1.CelestialBodiesShown = false
Sky1.Parent = Lighting

-- Atmosphere (Warm, soft vibe)
local Atmo1 = Instance.new("Atmosphere")
Atmo1.Name = "Atmosphere"
Atmo1.Density = 0.4
Atmo1.Offset = 0.25
Atmo1.Color = Color3.fromRGB(255, 170, 150)
Atmo1.Decay = Color3.fromRGB(255, 120, 100)
Atmo1.Glare = 0.3 -- Restored some glare for the sun glow
Atmo1.Haze = 0.5
Atmo1.Parent = Lighting

-- Bloom
local Bloom = Instance.new("BloomEffect")
Bloom.Enabled = true
Bloom.Intensity = 0.65 -- Brought back the glow, but lower than the original 0.8
Bloom.Size = 36
Bloom.Threshold = 0.85 -- Lowered threshold so normal light can glow again
Bloom.Parent = Lighting

-- Depth of Field (DSLR RTX focus)
local DepthOfField = Instance.new("DepthOfFieldEffect")
DepthOfField.Enabled = true
DepthOfField.FarIntensity = 0.15
DepthOfField.NearIntensity = 0.75
DepthOfField.FocusDistance = 0.05
DepthOfField.InFocusRadius = 30
DepthOfField.Parent = Lighting

-- Color Correction
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Enabled = true
ColorCorrection.Brightness = 0.05
ColorCorrection.Contrast = 0.35
ColorCorrection.Saturation = 0.2
ColorCorrection.TintColor = Color3.fromRGB(181, 168, 135)
ColorCorrection.Parent = Lighting

-- SunRays
local SunRays = Instance.new("SunRaysEffect")
SunRays.Enabled = true
SunRays.Intensity = 0.4
SunRays.Spread = 2
SunRays.Parent = Lighting

-- RTX Terrain & Volumetric Clouds
if Workspace:FindFirstChildOfClass("Terrain") then
    Workspace.Terrain.Decoration = true
    
    for _, c in ipairs(Workspace.Terrain:GetChildren()) do
        if c:IsA("Clouds") then c:Destroy() end
    end
    
    local Clouds = Instance.new("Clouds")
    Clouds.Name = "RTX_Clouds"
    Clouds.Cover = 0.9 -- Extremely high so it's obvious
    Clouds.Density = 1.0 -- Extremely high so it's obvious
    Clouds.Color = Color3.fromRGB(255, 220, 200)
    Clouds.Parent = Workspace.Terrain
end
