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
-- CUSTOM THEME: AURORA (RTX VIBES)
-- ==========================================

local function applyAurora(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        if isCharacterPart(part) then return end
        if part.Name == "ZenTile" then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(20, 100, 140)
            part.WaterReflectance = 1
        else
            local origColor = getgenv().ORIGINAL_COLORS[part] or part.Color
            part.Color = origColor:Lerp(Color3.fromRGB(40, 80, 120), 0.85) -- 85% strength so it's obvious!
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyAurora(obj)
end
Workspace.DescendantAdded:Connect(applyAurora)

Lighting:ClearAllChildren()

-- RTX Lighting settings
Lighting.Technology = Enum.Technology.Future
Lighting.Ambient = Color3.fromRGB(60, 70, 85)
Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 85)
Lighting.Brightness = 3
Lighting.ColorShift_Bottom = Color3.fromRGB(10, 20, 40)
Lighting.ColorShift_Top = Color3.fromRGB(150, 220, 255) -- Light blue light
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.1
Lighting.ClockTime = 14.0 -- Midday so the light isn't naturally orange
Lighting.GeographicLatitude = 80 -- Pushes the sun down to the horizon for long shadows!
Lighting.ExposureCompensation = 0

-- Skybox 1
local Sky1 = Instance.new("Sky")
Sky1.Name = "Sky"
Sky1.MoonAngularSize = 1.5
Sky1.MoonTextureId = "rbxassetid://1075087760"
Sky1.SkyboxBk = "rbxassetid://126146408999925"
Sky1.SkyboxDn = "rbxassetid://118112392224589"
Sky1.SkyboxFt = "rbxassetid://121253817183621"
Sky1.SkyboxLf = "rbxassetid://134105463289425"
Sky1.SkyboxRt = "rbxassetid://89099449712918"
Sky1.SkyboxUp = "rbxassetid://138429250948648"
Sky1.StarCount = 500
Sky1.SunAngularSize = 12
Sky1.SunTextureId = "rbxassetid://1084351190"
Sky1.CelestialBodiesShown = true
Sky1.Parent = Lighting

-- Atmosphere (Deep, rich magical fog for Aurora RTX vibe)
local Atmo1 = Instance.new("Atmosphere")
Atmo1.Name = "Atmosphere"
Atmo1.Density = 0.35
Atmo1.Offset = 0.2
Atmo1.Color = Color3.fromRGB(40, 80, 120)
Atmo1.Decay = Color3.fromRGB(20, 40, 80)
Atmo1.Glare = 0.4
Atmo1.Haze = 0.5
Atmo1.Parent = Lighting

-- Bloom (Subtle glow for the aurora)
local Bloom = Instance.new("BloomEffect")
Bloom.Enabled = true
Bloom.Intensity = 1.0
Bloom.Size = 30
Bloom.Threshold = 1.0
Bloom.Parent = Lighting

-- Depth of Field (DSLR RTX focus)
local DepthOfField = Instance.new("DepthOfFieldEffect")
DepthOfField.Enabled = true
DepthOfField.FarIntensity = 0.15
DepthOfField.NearIntensity = 0.75
DepthOfField.FocusDistance = 0.05
DepthOfField.InFocusRadius = 30
DepthOfField.Parent = Lighting

-- Color Correction (Cinematic contrast, boosted magical colors)
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Enabled = true
ColorCorrection.Brightness = 0.02
ColorCorrection.Contrast = 0.2
ColorCorrection.Saturation = 0.15
ColorCorrection.TintColor = Color3.fromRGB(200, 230, 255) -- Light blue tint for the whole scene
ColorCorrection.Parent = Lighting

-- SunRays (Reverted to subtle)
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
    Clouds.Cover = 0.9 -- Extremely high
    Clouds.Density = 0.8 -- Thicker
    Clouds.Color = Color3.fromRGB(150, 180, 200)
    Clouds.Parent = Workspace.Terrain
end
