local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

-- Clear old particles from terrain
if Workspace:FindFirstChildOfClass("Terrain") then
    for _, child in ipairs(Workspace.Terrain:GetChildren()) do
        if child.Name == "WeatherAttachment" then
            child:Destroy()
        end
    end
end

-- Setup Snow Particles
local weatherAttachment = Instance.new("Part")
weatherAttachment.Name = "WeatherAttachment"
weatherAttachment.Size = Vector3.new(60, 2, 60)
weatherAttachment.Transparency = 1
weatherAttachment.CanCollide = false
weatherAttachment.Anchored = true
weatherAttachment.Parent = Workspace.Terrain

-- Keep attachment above camera
local runService = game:GetService("RunService")
local conn
conn = runService.RenderStepped:Connect(function()
    if not weatherAttachment.Parent then
        conn:Disconnect()
        return
    end
    weatherAttachment.CFrame = CFrame.new(Camera.CFrame.Position + Vector3.new(0, 25, 0))
end)

local snowEmitter = Instance.new("ParticleEmitter")
snowEmitter.Name = "SnowEmitter"
-- snowEmitter.Texture = "rbxassetid://288001710"
snowEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
snowEmitter.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.2, 0.2),
    NumberSequenceKeypoint.new(0.8, 0.2),
    NumberSequenceKeypoint.new(1, 1)
})
snowEmitter.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(1, 0.5)
})
snowEmitter.EmissionDirection = Enum.NormalId.Bottom
snowEmitter.Lifetime = NumberRange.new(3, 5)
snowEmitter.Rate = 1000
snowEmitter.Speed = NumberRange.new(15, 25)
snowEmitter.SpreadAngle = Vector2.new(20, 20)
snowEmitter.Acceleration = Vector3.new(15, -10, 15)
snowEmitter.Rotation = NumberRange.new(0, 360)
snowEmitter.RotSpeed = NumberRange.new(-50, 50)
snowEmitter.Drag = 1
snowEmitter.LockedToPart = false
snowEmitter.Parent = weatherAttachment

-- Blizzard/Wind Sound
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://132149502"
sound.Looped = true
sound.Volume = 0.3
sound.Parent = weatherAttachment
sound:Play()

print("[Shaders] Snowfall particles applied successfully!")
