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

-- Setup Rain Particles
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

local rainEmitter = Instance.new("ParticleEmitter")
rainEmitter.Name = "RainEmitter"
-- rainEmitter.Texture = "rbxassetid://6078332152"
rainEmitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
rainEmitter.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.1, 0.5),
    NumberSequenceKeypoint.new(0.9, 0.5),
    NumberSequenceKeypoint.new(1, 1)
})
rainEmitter.Size = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(1, 0.4)
})
rainEmitter.EmissionDirection = Enum.NormalId.Bottom
rainEmitter.Lifetime = NumberRange.new(1, 1.5)
rainEmitter.Rate = 2000
rainEmitter.Speed = NumberRange.new(80, 100)
rainEmitter.SpreadAngle = Vector2.new(5, 5)
rainEmitter.Acceleration = Vector3.new(0, -150, 0)
rainEmitter.LockedToPart = false
rainEmitter.Parent = weatherAttachment

-- Rain Sound
local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://1516791621"
sound.Looped = true
sound.Volume = 0.08
sound.Parent = weatherAttachment
sound:Play()

print("[Shaders] Rain particles applied successfully!")
