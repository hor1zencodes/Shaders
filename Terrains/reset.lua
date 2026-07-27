pcall(function()
    workspace.Terrain:Clear()
    local function isBaseplate(part)
        local name = string.lower(part.Name)
        local isFloorName = string.find(name, "baseplate") or string.find(name, "floor") or string.find(name, "ground")
        return ((part.Size.X > 100 and part.Size.Z > 100) or isFloorName) and part.Size.Y < 20
    end
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and isBaseplate(part) then
            part.Transparency = 0
            part.CanCollide = true
        end
    end
end)
