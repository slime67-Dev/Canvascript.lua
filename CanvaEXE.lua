-- ==============================================
-- 🎨 Noob Canvas — MOVIE v2: "THE BULLY STORY"
-- By Phan11zz
-- Scene 1: Title Card
-- Scene 2: 5 People Walking to School
-- Scene 3: Guy Walks → Gangster Hits Him → Bully Begins
-- Scene 4: Guy Takes REVENGE on Bully
-- Scene 5: ENDING Title
-- ==============================================
-- UPDATED: Text + Decal + PNG scanner/picker + selection + online-only targets

local repoUrls = {
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua",
    "https://raw.githubusercontent.com/7GrandDadPGN/Venyx-Ware/main/Obsidian/Library.lua"
}

local Library
for _, url in ipairs(repoUrls) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then Library = result break end
end
if not Library then warn("❌ Obsidian failed to load") return end

local Window = Library:CreateWindow({
    Title = "🎨 Noob Canvas",
    Footer = "The Bully Story — By Phan11zz",
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl,
})

local Tab = Window:AddTab("Main", "paintbrush")
local Box = Tab:AddLeftGroupbox("Controls")
local PlayerBox = Tab:AddRightGroupbox("Target Player")

Box:AddToggle("MovingLine", { Name = "➖ Moving Line",    Default = false })
Box:AddToggle("WalkNoob",   { Name = "🧍 Walk Noob",      Default = false })
Box:AddToggle("FightNoob",  { Name = "👊 2 Noob Fight",   Default = false })
Box:AddToggle("WaveNoob",   { Name = "👋 Noob Wave Bye",  Default = false })
Box:AddToggle("CryEmoji",   { Name = "😭 Cry Emoji",      Default = false })
Box:AddToggle("MarioGame",  { Name = "🎮 Super Mario",    Default = false })

local currentText = ""
local currentTextColor = "Yellow"
local customColorStr = ""

Box:AddInput("TextInput", {
    Name = "✏️ Paint Text", Default = "", Placeholder = "Type text here...",
    Numeric = false, Finished = false,
    Callback = function(val) currentText = val end
})

Box:AddDropdown("TextColor", {
    Name = "🎨 Text Color",
    Values = {
        "Yellow", "Red", "Blue", "Green", "White", "Black",
        "Orange", "Purple", "Pink", "Cyan", "Lime", "Brown",
        "Gray", "Magenta", "Gold", "Sky", "Navy", "Maroon"
    },
    Default = 1,
    Callback = function(val) currentTextColor = val end
})

Box:AddInput("CustomColor", {
    Name = "🌈 Custom RGB (optional)",
    Default = "",
    Placeholder = "e.g. 255,0,128  (leave empty = use dropdown)",
    Numeric = false,
    Finished = false,
    Callback = function(val) customColorStr = val end
})

local currentDecalId = ""
Box:AddInput("DecalId", {
    Name = "🖼 Decal / Image ID",
    Default = "",
    Placeholder = "Paste asset ID (numbers only)",
    Numeric = false,
    Finished = false,
    Callback = function(val) currentDecalId = val end
})

local currentImagePath = ""
Box:AddInput("ImageFileOrUrl", {
    Name = "📁 Image URL / File path",
    Default = "",
    Placeholder = "https://...png  or optional manual path",
    Numeric = false,
    Finished = false,
    Callback = function(val) currentImagePath = val end
})

-- PNG file searcher (no copy/paste needed)
local foundPngPaths = {} -- full paths
local foundPngLabels = {"(scan first)"} -- shown in dropdown
local selectedPngLabel = "(scan first)"
local customScanFolder = ""

Box:AddInput("ScanFolder", {
    Name = "📂 Extra folder to scan (optional)",
    Default = "",
    Placeholder = "e.g. /storage/emulated/0/Pictures",
    Numeric = false,
    Finished = false,
    Callback = function(val) customScanFolder = val end
})

Box:AddDropdown("PngPicker", {
    Name = "🖼 Found PNG files",
    Values = foundPngLabels,
    Default = 1,
    Searchable = true,
    Callback = function(val)
        selectedPngLabel = val
        -- map label back to full path
        for i, label in ipairs(foundPngLabels) do
            if label == val and foundPngPaths[i] then
                currentImagePath = foundPngPaths[i]
                break
            end
        end
    end
})

Box:AddButton({
    Name = "🔍 Scan for PNG files",
    Callback = function()
        task.spawn(function()
            scanForPngFiles()
        end)
    end
})

Box:AddButton({
    Name = "🔤 Paint Text on Bricks",
    Callback = function()
        if currentText == "" then Library:Notify({Title="No Text",Content="Type something first!",Duration=2}) return end
        local colorLabel = (customColorStr ~= "" and customColorStr ~= nil) and ("Custom "..customColorStr) or currentTextColor
        Library:Notify({Title="Painting...",Content='Drawing: "'..currentText..'"  ('..colorLabel..')',Duration=2})
        task.spawn(function() paintTextOnBricks(currentText) end)
    end
})

Box:AddButton({
    Name = "🖼 Paint Decal Image",
    Callback = function()
        if not currentDecalId or currentDecalId == "" then
            Library:Notify({Title="No Decal ID",Content="Paste a Decal / Image asset ID first!",Duration=2})
            return
        end
        Library:Notify({Title="Painting Image...",Content="Decal ID: "..currentDecalId,Duration=2})
        task.spawn(function() paintDecalOnBricks(currentDecalId) end)
    end
})

Box:AddButton({
    Name = "📷 Paint Selected / URL / Path",
    Callback = function()
        -- prefer dropdown selection path
        local path = currentImagePath
        if (not path or path == "") and selectedPngLabel and selectedPngLabel ~= "(scan first)" and selectedPngLabel ~= "(none found)" then
            for i, label in ipairs(foundPngLabels) do
                if label == selectedPngLabel and foundPngPaths[i] then
                    path = foundPngPaths[i]
                    break
                end
            end
        end
        if not path or path == "" then
            Library:Notify({Title="No Image",Content="Scan PNGs and pick one, or paste a URL/path",Duration=3})
            return
        end
        Library:Notify({Title="Loading Image...",Content=tostring(path):sub(1, 60),Duration=2})
        task.spawn(function() paintImageFromSource(path) end)
    end
})

Box:AddButton({
    Name = "🎬 THE BULLY STORY (Movie)",
    Callback = function()
        Library:Notify({Title="🎬 Movie Starting!",Content="The Bully Story by Phan11zz",Duration=3})
        task.spawn(function() playMovie() end)
    end
})

-- ================= SELECTION (Corner A / B) =================
local SelectBox = Tab:AddLeftGroupbox("Selection")

local pickMode = nil -- "A" | "B" | nil
local cornerA = nil  -- BasePart
local cornerB = nil  -- BasePart
local highlightBoxes = {}

SelectBox:AddButton({
    Name = "📍 Pick Corner A",
    Callback = function()
        pickMode = "A"
        Library:Notify({Title="Pick Corner A",Content="Click a brick to set Corner A",Duration=3})
    end
})

SelectBox:AddButton({
    Name = "📍 Pick Corner B",
    Callback = function()
        pickMode = "B"
        Library:Notify({Title="Pick Corner B",Content="Click a brick to set Corner B",Duration=3})
    end
})

SelectBox:AddButton({
    Name = "🧹 Clear Selection",
    Callback = function()
        pickMode = nil
        cornerA = nil
        cornerB = nil
        for _, sb in ipairs(highlightBoxes) do
            pcall(function() sb:Destroy() end)
        end
        highlightBoxes = {}
        Library:Notify({Title="Selection Cleared",Content="Painting will use ALL bricks again",Duration=2})
    end
})

SelectBox:AddButton({
    Name = "🎨 Fill Selection (color)",
    Callback = function()
        if not cornerA or not cornerB then
            Library:Notify({Title="No Selection",Content="Pick Corner A and Corner B first!",Duration=2})
            return
        end
        task.spawn(function() fillSelection() end)
    end
})

-- ================= PLAYER PICKER =================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local mouse = LocalPlayer:GetMouse()

local MAX_TARGETS = 20
local selectedTargets = {} -- list of player names (max 20)
local pickPlayerName = ""

-- Only players currently in the server
local function getTargetNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    table.sort(names)
    return names
end

local function isInSelected(name)
    for _, n in ipairs(selectedTargets) do
        if n == name then return true end
    end
    return false
end

local function refreshSelectedDropdown()
    local labels = {}
    if #selectedTargets == 0 then
        labels = {"(none — using you)"}
    else
        for i, n in ipairs(selectedTargets) do
            table.insert(labels, i .. ". " .. n)
        end
    end
    if Library.Options and Library.Options.SelectedTargets then
        pcall(function()
            Library.Options.SelectedTargets:SetValues(labels)
            Library.Options.SelectedTargets:SetValue(labels[1])
        end)
    end
end

PlayerBox:AddDropdown("TargetPlayer", {
    Name = "Player in server",
    Values = getTargetNames(),
    Default = 1,
    Searchable = true,
    Callback = function(val)
        pickPlayerName = val
    end
})

PlayerBox:AddDropdown("SelectedTargets", {
    Name = "Selected targets (max 20)",
    Values = {"(none — using you)"},
    Default = 1,
    Searchable = true
})

PlayerBox:AddButton({Name="➕ Add Player",Callback=function()
    local name = pickPlayerName
    if not name or name == "" then
        local val = Library.Options.TargetPlayer and Library.Options.TargetPlayer.Value
        name = (typeof(val) == "string" and val ~= "") and val or nil
    end
    if not name or name == "" then
        Library:Notify({Title="No Player",Content="Pick a player in the dropdown first",Duration=2})
        return
    end
    if isInSelected(name) then
        Library:Notify({Title="Already Added",Content=name.." is already selected",Duration=2})
        return
    end
    if #selectedTargets >= MAX_TARGETS then
        Library:Notify({Title="Limit",Content="Max "..MAX_TARGETS.." players",Duration=2})
        return
    end
    table.insert(selectedTargets, name)
    refreshSelectedDropdown()
    Library:Notify({Title="Added",Content=name.." ("..#selectedTargets.."/"..MAX_TARGETS..")",Duration=2})
end})

PlayerBox:AddButton({Name="➖ Remove Last",Callback=function()
    if #selectedTargets == 0 then
        Library:Notify({Title="Empty",Content="No targets to remove",Duration=2})
        return
    end
    local removed = table.remove(selectedTargets)
    refreshSelectedDropdown()
    Library:Notify({Title="Removed",Content=tostring(removed),Duration=2})
end})

PlayerBox:AddButton({Name="🧹 Clear All Targets",Callback=function()
    selectedTargets = {}
    refreshSelectedDropdown()
    Library:Notify({Title="Cleared",Content="Targets cleared — will use you",Duration=2})
end})

PlayerBox:AddButton({Name="➕ Add All in Server",Callback=function()
    local names = getTargetNames()
    local added = 0
    for _, name in ipairs(names) do
        if #selectedTargets >= MAX_TARGETS then break end
        if not isInSelected(name) then
            table.insert(selectedTargets, name)
            added = added + 1
        end
    end
    refreshSelectedDropdown()
    Library:Notify({
        Title = "Batch Add",
        Content = "Added "..added.." → total "..#selectedTargets.."/"..MAX_TARGETS,
        Duration = 3
    })
end})

PlayerBox:AddButton({Name="🔄 Refresh List",Callback=function()
    local names = getTargetNames()
    if Library.Options and Library.Options.TargetPlayer then
        Library.Options.TargetPlayer:SetValues(names)
    end
    -- drop selected who left
    local online = {}
    for _, n in ipairs(names) do online[n] = true end
    local kept = {}
    for _, n in ipairs(selectedTargets) do
        if online[n] then table.insert(kept, n) end
    end
    selectedTargets = kept
    refreshSelectedDropdown()
    Library:Notify({
        Title = "Updated",
        Content = #names .. " in server | " .. #selectedTargets .. " selected",
        Duration = 2
    })
end})

PlayerBox:AddButton({Name="🎯 Use Me Only",Callback=function()
    selectedTargets = {LocalPlayer.Name}
    pickPlayerName = LocalPlayer.Name
    if Library.Options and Library.Options.TargetPlayer then
        pcall(function() Library.Options.TargetPlayer:SetValue(LocalPlayer.Name) end)
    end
    refreshSelectedDropdown()
    Library:Notify({Title="Target Set",Content="Only YOU selected",Duration=2})
end})

-- Primary name (for corner click / single ops). Multi-paint uses full list.
local function getTargetName()
    if #selectedTargets > 0 then
        return selectedTargets[1]
    end
    local val = Library.Options.TargetPlayer and Library.Options.TargetPlayer.Value
    if typeof(val) == "string" and val ~= "" then return val end
    return LocalPlayer.Name
end

-- All targets to paint (1–20). If empty → just local player.
local function getSelectedTargetNames()
    if #selectedTargets > 0 then
        local list = {}
        for i = 1, math.min(#selectedTargets, MAX_TARGETS) do
            table.insert(list, selectedTargets[i])
        end
        return list
    end
    return {getTargetName()}
end

local event = nil
local function getEvent()
    if event and event.Parent then return event end
    for _, src in ipairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
        if src then
            local tool = src:FindFirstChild("PaintBucket")
            if tool then
                local remotes = tool:FindFirstChild("Remotes")
                if remotes then
                    event = remotes:FindFirstChild("ServerControls")
                    if event then return event end
                end
            end
        end
    end
    return nil
end

local function getBricks(targetName)
    targetName = targetName or getTargetName()
    local folder = workspace:FindFirstChild("Bricks")
    if not folder then return {} end
    local mine = folder:FindFirstChild(targetName)
    if not mine then return {} end
    local list = {}
    for _, v in ipairs(mine:GetChildren()) do
        if v:IsA("BasePart") then table.insert(list, v) end
    end
    return list
end

local function paint(part, color)
    task.spawn(function()
        pcall(function()
            local ev = getEvent()
            if ev then ev:InvokeServer("PaintPart", {Part=part, Color=color}) end
        end)
    end)
end

local function clearHighlights()
    for _, sb in ipairs(highlightBoxes) do
        pcall(function() sb:Destroy() end)
    end
    highlightBoxes = {}
end

local function addHighlight(part, color)
    if not part then return end
    local sb = Instance.new("SelectionBox")
    sb.Name = "NoobCanvasSelect"
    sb.Adornee = part
    sb.Color3 = color or Color3.fromRGB(0, 255, 120)
    sb.LineThickness = 0.06
    sb.Transparency = 0.2
    sb.Parent = part
    table.insert(highlightBoxes, sb)
end

-- Bricks inside the Corner A → Corner B rectangle (uses X/Y like the grid)
-- Owner folder name under workspace.Bricks (works after rejoin / other players)
local function getBrickOwnerName(part)
    if not part then return nil end
    local folder = workspace:FindFirstChild("Bricks")
    if not folder then return nil end
    local cur = part
    while cur and cur ~= folder do
        if cur.Parent == folder then
            return cur.Name
        end
        cur = cur.Parent
    end
    return nil
end

-- Every BasePart under workspace.Bricks (any owner)
local function getAllWorldBricks()
    local folder = workspace:FindFirstChild("Bricks")
    if not folder then return {} end
    local list = {}
    for _, owner in ipairs(folder:GetChildren()) do
        if owner:IsA("BasePart") then
            table.insert(list, owner)
        else
            for _, v in ipairs(owner:GetDescendants()) do
                if v:IsA("BasePart") then
                    table.insert(list, v)
                end
            end
        end
    end
    return list
end

local function getSelectedBricks(targetName)
    -- Corner A+B: rectangle on whatever wall you clicked (any owner / after rejoin)
    if cornerA and cornerB then
        local ax, ay = math.round(cornerA.Position.X), math.round(cornerA.Position.Y)
        local bx, by = math.round(cornerB.Position.X), math.round(cornerB.Position.Y)
        local minX, maxX = math.min(ax, bx), math.max(ax, bx)
        local minY, maxY = math.min(ay, by), math.max(ay, by)

        local ownerA = getBrickOwnerName(cornerA)
        local ownerB = getBrickOwnerName(cornerB)
        local pool
        if ownerA and ownerA == ownerB then
            pool = getBricks(ownerA)
            if #pool < 1 then
                pool = getAllWorldBricks()
            end
        else
            pool = getAllWorldBricks()
        end

        local list = {}
        for _, p in ipairs(pool) do
            local rx = math.round(p.Position.X)
            local ry = math.round(p.Position.Y)
            if rx >= minX and rx <= maxX and ry >= minY and ry <= maxY then
                table.insert(list, p)
            end
        end
        return list
    end

    -- No corners → that player's full wall
    return getBricks(targetName)
end

local function hasSelection()
    return cornerA ~= nil and cornerB ~= nil
end

local function refreshSelectionHighlight()
    clearHighlights()
    if cornerA then addHighlight(cornerA, Color3.fromRGB(0, 255, 100)) end -- green = A
    if cornerB then addHighlight(cornerB, Color3.fromRGB(255, 80, 80)) end   -- red = B
    if cornerA and cornerB then
        local selected = getSelectedBricks()
        for _, p in ipairs(selected) do
            if p ~= cornerA and p ~= cornerB then
                addHighlight(p, Color3.fromRGB(80, 180, 255)) -- blue = area
            end
        end
        Library:Notify({
            Title = "Selection Ready",
            Content = #selected .. " bricks selected — paint will use this area",
            Duration = 3
        })
    end
end

-- Any brick under workspace.Bricks (yours, others, leftover after rejoin)
local function isAnyBrick(part)
    if not part or not part:IsA("BasePart") then return false end
    local folder = workspace:FindFirstChild("Bricks")
    if not folder then return false end
    return part:IsDescendantOf(folder)
end

-- Click to pick corners — works on ANY bricks
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not pickMode then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local target = mouse.Target
    if not isAnyBrick(target) then
        Library:Notify({Title="Not a brick",Content="Click any brick under workspace.Bricks",Duration=2})
        return
    end

    if pickMode == "A" then
        cornerA = target
        pickMode = nil
        local owner = getBrickOwnerName(target) or "?"
        Library:Notify({Title="Corner A Set",Content="Owner: "..owner.." — now pick Corner B",Duration=3})
        refreshSelectionHighlight()
    elseif pickMode == "B" then
        cornerB = target
        pickMode = nil
        local owner = getBrickOwnerName(target) or "?"
        Library:Notify({Title="Corner B Set",Content="Owner: "..owner.." — selection ready",Duration=3})
        refreshSelectionHighlight()
    end
end)

function fillSelection()
    local col = resolveTextColor()
    if hasSelection() then
        local bricks = getSelectedBricks()
        Library:Notify({Title="Filling...",Content=#bricks.." bricks in selection",Duration=2})
        for _, p in ipairs(bricks) do
            paint(p, col)
        end
        Library:Notify({Title="Done!",Content="Filled selection",Duration=2})
        return
    end
    local targets = getSelectedTargetNames()
    local total = 0
    Library:Notify({Title="Filling...",Content=#targets.." player(s)",Duration=2})
    for _, na