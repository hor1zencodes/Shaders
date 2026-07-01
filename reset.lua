-- ================================================
--   STEP 2: FULL RESET (Glow + Fog Fix)
-- ================================================

local Players    = game:GetService("Players")
local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- ================================================
-- STEP 1: KILL ALL SHADER CONNECTIONS FIRST
-- ================================================
pcall(function() Workspace.DescendantAdded:DisconnectAll() end)
pcall(function() RunService.RenderStepped:DisconnectAll() end)
pcall(function() getgenv().GI_SYSTEM = nil end)

-- ================================================
-- STEP 2: DISABLE + DESTROY EVERY EFFECT
-- Disable first, then destroy — belt and suspenders
-- ================================================
for _, child in ipairs(Lighting:GetChildren()) do
    pcall(function()
        -- Disable before destroying so effect stops instantly
        if child:FindFirstProperty("Enabled") then
            child.Enabled = false
        end
        child:Destroy()
    end)
end

-- Double-check — destroy anything that survived
task.wait(0.05)
for _, child in ipairs(Lighting:GetChildren()) do
    pcall(function() child:Destroy() end)
end

-- ================================================
-- STEP 3: RESTORE LIGHTING PROPERTIES
-- ================================================
local L = getgenv().ORIGINAL_LIGHTING

if L and next(L) then
    Lighting.Technology               = L.Technology
    Lighting.Ambient                  = L.Ambient
    Lighting.OutdoorAmbient           = L.OutdoorAmbient
    Lighting.Brightness               = L.Brightness
    Lighting.ColorShift_Bottom        = L.ColorShift_Bottom
    Lighting.ColorShift_Top           = L.ColorShift_Top
    Lighting.FogColor                 = L.FogColor
    Lighting.FogEnd                   = L.FogEnd
    Lighting.FogStart                 = L.FogStart
    Lighting.GlobalShadows            = L.GlobalShadows
    Lighting.ShadowSoftness           = L.ShadowSoftness
    Lighting.EnvironmentDiffuseScale  = L.EnvironmentDiffuseScale
    Lighting.EnvironmentSpecularScale = L.EnvironmentSpecularScale
    Lighting.ExposureCompensation     = L.ExposureCompensation
    Lighting.ClockTime                = L.ClockTime
    Lighting.GeographicLatitude       = L.GeographicLatitude
    print("[Reset] Lighting restored from snapshot.")
else
    Lighting.Technology               = Enum.Technology.Compatibility
    Lighting.Ambient                  = Color3.fromRGB(127, 127, 127)
    Lighting.OutdoorAmbient           = Color3.fromRGB(127, 127, 127)
    Lighting.Brightness               = 2.0
    Lighting.ColorShift_Bottom        = Color3.fromRGB(0, 0, 0)
    Lighting.ColorShift_Top           = Color3.fromRGB(0, 0, 0)
    Lighting.FogColor                 = Color3.fromRGB(191, 191, 191)
    Lighting.FogEnd                   = 100000
    Lighting.FogStart                 = 0
    Lighting.GlobalShadows            = true
    Lighting.ShadowSoftness           = 0.2
    Lighting.EnvironmentDiffuseScale  = 1
    Lighting.EnvironmentSpecularScale = 1
    Lighting.ExposureCompensation     = 0
    Lighting.ClockTime                = 14
    Lighting.GeographicLatitude       = 41.733
    print("[Reset] No snapshot — Roblox defaults applied.")
end

-- ================================================
-- STEP 4: RESTORE SKY
-- ================================================
local skyData = getgenv().ORIGINAL_SKY
local Sky = Instance.new("Sky")
if skyData then
    Sky.SkyboxBk             = skyData.SkyboxBk
    Sky.SkyboxDn             = skyData.SkyboxDn
    Sky.SkyboxFt             = skyData.SkyboxFt
    Sky.SkyboxLf             = skyData.SkyboxLf
    Sky.SkyboxRt             = skyData.SkyboxRt
    Sky.SkyboxUp             = skyData.SkyboxUp
    Sky.CelestialBodiesShown = skyData.CelestialBodiesShown
    Sky.StarCount            = skyData.StarCount
else
    Sky.SkyboxBk = "rbxasset://sky/sky512_bk.tex"
    Sky.SkyboxDn = "rbxasset://sky/sky512_dn.tex"
    Sky.SkyboxFt = "rbxasset://sky/sky512_ft.tex"
    Sky.SkyboxLf = "rbxasset://sky/sky512_lf.tex"
    Sky.SkyboxRt = "rbxasset://sky/sky512_rt.tex"
    Sky.SkyboxUp = "rbxasset://sky/sky512_up.tex"
    Sky.CelestialBodiesShown = true
    Sky.StarCount = 3000
end
Sky.Parent = Lighting

-- ================================================
-- STEP 5: RESTORE ATMOSPHERE — NO HAZE, NO GLARE
-- This is what fixes the fog/haze still visible.
-- If snapshot exists use it, otherwise use
-- fully neutral values (zero haze, zero glare).
-- ================================================
local atmoData = getgenv().ORIGINAL_ATMO
local Atmo = Instance.new("Atmosphere")
if atmoData then
    Atmo.Density = atmoData.Density
    Atmo.Offset  = atmoData.Offset
    Atmo.Color   = atmoData.Color
    Atmo.Decay   = atmoData.Decay
    Atmo.Glare   = atmoData.Glare
    Atmo.Haze    = atmoData.Haze
    print("[Reset] Atmosphere restored from snapshot.")
else
    -- Fully neutral — zero haze, zero glare, no tint
    Atmo.Density = 0
    Atmo.Offset  = 0
    Atmo.Color   = Color3.fromRGB(199, 199, 199)
    Atmo.Decay   = Color3.fromRGB(106, 127, 153)
    Atmo.Glare   = 0
    Atmo.Haze    = 0
    print("[Reset] No snapshot — clean zero atmosphere applied.")
end
Atmo.Parent = Lighting

-- Explicit extra kill on bloom just in case anything re-added it
task.wait(0.05)
for _, child in ipairs(Lighting:GetChildren()) do
    if child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect")
    or child:IsA("SunRaysEffect") or child:IsA("DepthOfFieldEffect")
    or child:IsA("BlurEffect") then
        child.Enabled = false
        child:Destroy()
    end
end

-- ================================================
-- STEP 6: RESTORE TERRAIN WATER + REMOVE CLOUDS
-- ================================================
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    local W = getgenv().ORIGINAL_WATER
    if W then
        Terrain.WaterColor        = W.WaterColor
        Terrain.WaterReflectance  = W.WaterReflectance
        Terrain.WaterTransparency = W.WaterTransparency
        Terrain.WaterWaveSize     = W.WaterWaveSize
        Terrain.WaterWaveSpeed    = W.WaterWaveSpeed
    else
        Terrain.WaterColor        = Color3.fromRGB(16, 150, 203)
        Terrain.WaterReflectance  = 1
        Terrain.WaterTransparency = 0.3
        Terrain.WaterWaveSize     = 0.15
        Terrain.WaterWaveSpeed    = 10
    end
    for _, child in ipairs(Terrain:GetChildren()) do
        if child:IsA("Clouds") then child:Destroy() end
    end
end

-- ================================================
-- STEP 7: RESTORE PART COLORS FROM SNAPSHOT
-- ================================================
local function isCharacterPart(part)
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and part:IsDescendantOf(char) then return true end
    end
    return false
end

local snapshot = getgenv().ORIGINAL_COLORS
local restored, skipped = 0, 0

for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and not isCharacterPart(obj) then
        pcall(function()
            if snapshot and snapshot[obj] then
                obj.Color = snapshot[obj]
                restored += 1
            else
                skipped += 1
            end
        end)
    end
end

-- ================================================
-- STEP 8: CLEAR ALL SNAPSHOT MEMORY
-- ================================================
getgenv().ORIGINAL_COLORS   = nil
getgenv().ORIGINAL_LIGHTING = nil
getgenv().ORIGINAL_WATER    = nil
getgenv().ORIGINAL_SKY      = nil
getgenv().ORIGINAL_ATMO     = nil

print(string.format("[Reset] DONE. %d parts restored, %d skipped. Glow and fog removed.", restored, skipped))