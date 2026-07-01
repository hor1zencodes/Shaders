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

-- Also snapshot colors of parts that load in later
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
-- Snapshot existing Sky if present
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

-- ------------------------------------------------
-- Snapshot existing Atmosphere if present
-- ------------------------------------------------
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

-- LocalScript in StarterPlayerScripts

local Workspace = game:GetService("Workspace")

local function applyLightPink(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        local char = game.Players.LocalPlayer.Character
        if char and part:IsDescendantOf(char) then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(255, 200, 220)
        else
            local c = part.Color
            local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
            part.Color = Color3.new(
                0.85 + lum * 0.15,  -- R: very high
                0.65 + lum * 0.15,  -- G: medium-high
                0.70 + lum * 0.15   -- B: medium-high
            )
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyLightPink(obj)
end

Workspace.DescendantAdded:Connect(applyLightPink)

-- PINK SHADER WITH RTX LIGHTING V2 (from Empty Tools)

local Lighting = game:GetService("Lighting")

-- Clear old lighting
Lighting:ClearAllChildren()

-- Lighting Properties
Lighting.Ambient = Color3.fromRGB(100, 65, 115)
Lighting.OutdoorAmbient = Color3.fromRGB(160, 110, 180)
Lighting.Brightness = 2.4  -- slightly dimmed from 3
Lighting.ColorShift_Bottom = Color3.fromRGB(255, 160, 210)
Lighting.ColorShift_Top = Color3.fromRGB(200, 130, 240)
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.25
Lighting.ClockTime = 14
Lighting.GeographicLatitude = 25
Lighting.ExposureCompensation = -0.2  -- subtle exposure pull-down

-- Skybox
local Skybox = Instance.new("Sky")
Skybox.SkyboxBk = "http://www.roblox.com/asset/?id=271042516"
Skybox.SkyboxDn = "http://www.roblox.com/asset/?id=271077243"
Skybox.SkyboxFt = "http://www.roblox.com/asset/?id=271042556"
Skybox.SkyboxLf = "http://www.roblox.com/asset/?id=271042310"
Skybox.SkyboxRt = "http://www.roblox.com/asset/?id=271042467"
Skybox.SkyboxUp = "http://www.roblox.com/asset/?id=271077958"
Skybox.CelestialBodiesShown = true
Skybox.StarCount = 5000
Skybox.Parent = Lighting

-- Atmosphere (RTX-style haze & scatter)
local Atmosphere = Instance.new("Atmosphere")
Atmosphere.Density = 0.45
Atmosphere.Offset = 0.3
Atmosphere.Color = Color3.fromRGB(255, 170, 215)
Atmosphere.Decay = Color3.fromRGB(160, 85, 145)
Atmosphere.Glare = 0.55
Atmosphere.Haze = 2.4
Atmosphere.Parent = Lighting

-- Bloom (punchy glow)
local Bloom = Instance.new("BloomEffect")
Bloom.Enabled = true
Bloom.Intensity = 1.6
Bloom.Size = 28
Bloom.Threshold = 0.85
Bloom.Parent = Lighting

-- Color Correction
local ColorCorrection = Instance.new("ColorCorrectionEffect")
ColorCorrection.Contrast = 0.05
ColorCorrection.TintColor = Color3.fromRGB(245, 220, 255)
ColorCorrection.Saturation = 0.35
ColorCorrection.Brightness = 0.02
ColorCorrection.Enabled = true
ColorCorrection.Parent = Lighting

-- Sun Rays (volumetric light shafts)
local SunRays = Instance.new("SunRaysEffect")
SunRays.Enabled = true
SunRays.Intensity = 0.35
SunRays.Spread = 0.75
SunRays.Parent = Lighting

-- Depth of Field (cinematic blur)
local DepthOfField = Instance.new("DepthOfFieldEffect")
DepthOfField.Enabled = true
DepthOfField.FarIntensity = 0.55
DepthOfField.NearIntensity = 0.15
DepthOfField.FocusDistance = 45
DepthOfField.InFocusRadius = 30
DepthOfField.Parent = Lighting

-- Motion Blur (movement feel)
local MotionBlur = Instance.new("BlurEffect")
MotionBlur.Enabled = true
MotionBlur.Size = 6
MotionBlur.Parent = Lighting

-- Film Grain (cinematic texture)
-- Simulated via a subtle ColorCorrectionEffect layered on top
local FilmGrain = Instance.new("ColorCorrectionEffect")
FilmGrain.Contrast = 0.08
FilmGrain.Saturation = 0.1
FilmGrain.TintColor = Color3.fromRGB(255, 235, 255)
FilmGrain.Enabled = true
FilmGrain.Parent = Lighting

-- Optional Clouds
if not workspace.Terrain:FindFirstChildOfClass("Clouds") then
	local Clouds = Instance.new("Clouds")
	Clouds.Cover = 0.72
	Clouds.Density = 0.62
	Clouds.Color = Color3.fromRGB(255, 140, 200)
	Clouds.Parent = workspace.Terrain
end