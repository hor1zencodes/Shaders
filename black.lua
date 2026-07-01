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
local Players = game:GetService("Players")

local function isCharacterPart(part)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and part:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function applyDarkGrey(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        if isCharacterPart(part) then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(60, 60, 60)
        else
            local c = part.Color
            local grey = (0.299 * c.R + 0.587 * c.G + 0.114 * c.B) * 0.4
            part.Color = Color3.new(grey, grey, grey)
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyDarkGrey(obj)
end

Workspace.DescendantAdded:Connect(applyDarkGrey)

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Terrain = Workspace:FindFirstChildOfClass("Terrain") or Instance.new("Terrain",Workspace)

getgenv().GI_SYSTEM = getgenv().GI_SYSTEM or {}
local GI = getgenv().GI_SYSTEM

for _,v in pairs(Lighting:GetChildren()) do
	if v:IsA("Sky") then v:Destroy() end
end

Lighting.Technology = Enum.Technology.Unified
Lighting.Ambient = Color3.fromRGB(65,61,86)
Lighting.Brightness = 3.6
Lighting.EnvironmentDiffuseScale = 0.1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.OutdoorAmbient = Color3.fromRGB(160,160,160)
Lighting.ShadowSoftness = 0.5
Lighting.GeographicLatitude = 41.733
Lighting.ExposureCompensation = 0.2
Lighting.FogColor = Color3.fromRGB(192,192,192)
Lighting.FogEnd = 100000
Lighting.ClockTime = 6.5

Terrain.WaterColor = Color3.fromRGB(12,81,89)
Terrain.WaterReflectance = 1
Terrain.WaterTransparency = 0.11
Terrain.WaterWaveSize = 0.45
Terrain.WaterWaveSpeed = 25

local sunrays = Instance.new("SunRaysEffect", Lighting)
sunrays.Intensity = 0.03
sunrays.Spread = 0.128

local atmosphere = Instance.new("Atmosphere", Lighting)
atmosphere.Density = 0.3
atmosphere.Decay = Color3.fromRGB(199,174,164)
atmosphere.Color = Color3.fromRGB(125,113,110)
atmosphere.Glare = 0.67
atmosphere.Haze = 0

local dof = Instance.new("DepthOfFieldEffect", Lighting)
dof.FarIntensity = 0.7
dof.FocusDistance = 0.05
dof.InFocusRadius = 50

local clouds = Instance.new("Clouds", Lighting)
clouds.Cover = 0.6
clouds.Density = 0.5
clouds.Color = Color3.fromRGB(225,246,217)

local sky = Instance.new("Sky")
sky.SkyboxBk = "rbxassetid://1618912481"
sky.SkyboxFt = "rbxassetid://1618913244"
sky.SkyboxLf = "rbxassetid://1618912849"
sky.SkyboxRt = "rbxassetid://1618911568"
sky.SkyboxUp = "rbxassetid://1618913654"
sky.SkyboxDn = "rbxassetid://1618913943"
sky.Parent = Lighting

spawn(function()
	while true do
		Terrain.WaterWaveSpeed = 25 + math.sin(tick()*0.5)*15
		Terrain.WaterWaveSize = 0.45 + math.sin(tick()*0.3)*0.2
		task.wait(0.1)
	end
end)

RunService.RenderStepped:Connect(function()
	if Workspace:FindFirstChildOfClass("Terrain") then
		clouds.Parent = Lighting
	else
		clouds.Parent = nil
	end
end)