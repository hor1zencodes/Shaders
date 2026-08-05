import os
import glob

# The exact old strings
old_colors = 'getgenv().ORIGINAL_COLORS   = {}'
new_colors = 'getgenv().ORIGINAL_COLORS   = setmetatable({}, {__mode = "k"})'

old_ischar = '''local function isCharacterPart(part)
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char and part:IsDescendantOf(char) then return true end
    end
    return false
end'''

new_ischar = '''local function isCharacterPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    return model and model:FindFirstChildOfClass("Humanoid") ~= nil
end'''

# task.defer wrapper
old_defer = '''Workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        if obj:IsA("BasePart") and not isCharacterPart(obj) then
            pcall(function()
                if not getgenv().ORIGINAL_COLORS[obj] then
                    getgenv().ORIGINAL_COLORS[obj] = obj.Color
                end
            end)
        end
    end)
end)'''

new_defer = '''Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and not isCharacterPart(obj) then
        pcall(function()
            if not getgenv().ORIGINAL_COLORS[obj] then
                getgenv().ORIGINAL_COLORS[obj] = obj.Color
            end
        end)
    end
end)'''


files = glob.glob(r'C:\Users\Serenity\Downloads\Shaders-main\*.lua')

for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    modified = False
    
    if old_colors in content:
        content = content.replace(old_colors, new_colors)
        modified = True
        
    if old_ischar in content:
        content = content.replace(old_ischar, new_ischar)
        modified = True
        
    if old_defer in content:
        content = content.replace(old_defer, new_defer)
        modified = True
        
    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Optimized {os.path.basename(filepath)}")
    else:
        print(f"Skipped {os.path.basename(filepath)}")
