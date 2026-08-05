local Workspace = game:GetService("Workspace")

-- 1. Clear Custom Weather Particles
if Workspace:FindFirstChildOfClass("Terrain") then
    for _, child in ipairs(Workspace.Terrain:GetChildren()) do
        if child.Name == "WeatherAttachment" then
            child:Destroy()
        end
    end
end

print("[Shaders] Weather particles cleared successfully!")
