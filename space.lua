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

local Players = game:GetService('Players')
local Lighting = game:GetService('Lighting')
local localPlayer = Players.LocalPlayer

local function toGray(c)
    local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
    return Color3.new(lum, lum, lum)
end


local function isAvatarPart(part)
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and part:IsDescendantOf(char) then
            return true
        end
    end
    return false
end

local grayCache = {}

local function makeGray(part)
    if not part:IsA('BasePart') then return end
    if grayCache[part] then return end
    if isAvatarPart(part) then return end

    grayCache[part] = true
    part.Color = toGray(part.Color)
end

for _, obj in ipairs(workspace:GetDescendants()) do
    pcall(makeGray, obj)
end

workspace.DescendantAdded:Connect(function(inst)
    task.defer(function()
        pcall(makeGray, inst)
    end)
end)


local function protectAvatar(char)
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        pcall(function()
            if part:IsA('BasePart') and grayCache[part] then
                grayCache[part] = nil
            end
        end)
    end

    char.DescendantAdded:Connect(function(inst)
        task.defer(function()
            pcall(function()
                if inst:IsA('BasePart') then
                    grayCache[inst] = nil
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


Lighting:ClearAllChildren()

local sky = Instance.new('Sky')
sky.SkyboxBk = 'http://www.roblox.com/asset/?id=16262356578'
sky.SkyboxDn = 'http://www.roblox.com/asset/?id=16262358026'
sky.SkyboxFt = 'http://www.roblox.com/asset/?id=16262360469'
sky.SkyboxLf = 'http://www.roblox.com/asset/?id=16262362003'
sky.SkyboxRt = 'http://www.roblox.com/asset/?id=16262363873'
sky.SkyboxUp = 'http://www.roblox.com/asset/?id=16262366016'
sky.StarCount = 6000
sky.Parent = Lighting

local atmo = Instance.new('Atmosphere')
atmo.Density = 0.7
atmo.Offset = 0.1
atmo.Color = Color3.fromRGB(130, 130, 130)
atmo.Decay = Color3.fromRGB(40, 40, 40)
atmo.Glare = 0
atmo.Haze = 1
atmo.Parent = Lighting

Lighting.Ambient = Color3.fromRGB(90, 90, 90)
Lighting.OutdoorAmbient = Color3.fromRGB(90, 90, 90)
Lighting.ColorShift_Top = Color3.fromRGB(160, 160, 160)
Lighting.ColorShift_Bottom = Color3.fromRGB(160, 160, 160)
Lighting.FogColor = Color3.fromRGB(20, 20, 20)
Lighting.FogEnd = 100000
Lighting.Brightness = 2.0


local bloom = Instance.new('BloomEffect')
bloom.Enabled = true
bloom.Intensity = 1.5
bloom.Size = 64
bloom.Threshold = 0.75
bloom.Parent = Lighting

local sunrays = Instance.new('SunRaysEffect')
sunrays.Enabled = true
sunrays.Intensity = 0.35
sunrays.Spread = 1.0
sunrays.Parent = Lighting

local colorCorrection = Instance.new('ColorCorrectionEffect')
colorCorrection.Saturation = 0
colorCorrection.Brightness = 0.05
colorCorrection.Contrast = 0.25
colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
colorCorrection.Enabled = true
colorCorrection.Parent = Lighting

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

local function applyLightGrey(part)
    if part:IsA("BasePart") or part:IsA("Terrain") then
        if isCharacterPart(part) then return end

        if part:IsA("Terrain") then
            part.WaterColor = Color3.fromRGB(200, 200, 200)
        else
            local c = part.Color
            local grey = 0.6 + (0.299 * c.R + 0.587 * c.G + 0.114 * c.B) * 0.4
            part.Color = Color3.new(grey, grey, grey)
        end
    end
end

for _, obj in ipairs(Workspace:GetDescendants()) do
    applyLightGrey(obj)
end

Workspace.DescendantAdded:Connect(applyLightGrey)