--[[
    XenhubV5 Combined GUI - Cleaned & Optimized
    Smart modular structure • Theme-driven • Easy to extend
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")
local TeleportService  = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    Background     = Color3.fromRGB(12, 12, 18),
    Surface        = Color3.fromRGB(40, 40, 50),
    SurfaceDark    = Color3.fromRGB(25, 25, 35),
    Accent         = Color3.fromRGB(99, 102, 241),
    AccentSoft     = Color3.fromRGB(130, 140, 255),
    Success        = Color3.fromRGB(74, 222, 128),
    Danger         = Color3.fromRGB(248, 113, 113),
    TextPrimary    = Color3.fromRGB(255, 255, 255),
    TextSecondary  = Color3.fromRGB(160, 160, 170),
    TextMuted      = Color3.fromRGB(115, 115, 130),
    FontHeavy      = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy),
    FontBold       = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    FontMedium     = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = parent
    })
end

local function Stroke(parent, color, transparency, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Accent,
        Transparency = transparency or 0.7,
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function Gradient(parent, colors)
    local g = Create("UIGradient", { Parent = parent })
    if colors then g.Color = colors end
    return g
end

-- ═══════════════════════════════════════════════════════════════
-- FACTORIES
-- ═══════════════════════════════════════════════════════════════
local function CreateToggle(parent, labelText, defaultOn, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Parent = parent
    })
    Corner(row, 6)

    Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -55, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontMedium,
        Text = labelText,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -48, 0.5, -10),
        Size = UDim2.new(0, 38, 0, 20),
        BackgroundColor3 = defaultOn and Theme.Success or Color3.fromRGB(60, 60, 60),
        Text = "",
        Parent = row
    })
    Corner(btn, 99)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Theme.TextPrimary,
        Position = defaultOn and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        Parent = btn
    })
    Corner(knob, 99)

    local state = defaultOn
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(60, 60, 60)
        knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        if callback then callback(state) end
    end)

    return row, function() return state end, function(v)
        state = v
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(60, 60, 60)
        knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    end
end

local function CreateActionButton(parent, text, color, layoutOrder, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = color or Theme.Surface,
        BackgroundTransparency = 0.3,
        LayoutOrder = layoutOrder or 0,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Parent = parent
    })
    Corner(btn, 6)
    Stroke(btn)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

local function CreateSlider(parent, label, min, max, default, format, onChanged)
    local wrap = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 40),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = label .. ": " .. (format == "float" and string.format("%.1f", default) or tostring(math.round(default))),
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap
    })

    local track = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.Surface,
        Parent = wrap
    })
    Corner(track, 99)

    local pct = (default - min) / (max - min)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = track
    })
    Corner(fill, 99)

    local knob = Create("Frame", {
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Parent = track
    })
    Corner(knob, 99)

    local dragging = false
    local function update(p)
        p = math.clamp(p, 0, 1)
        local val = min + (max - min) * p
        if format == "int" then val = math.round(val)
        elseif format == "float" then val = math.floor(val * 10 + 0.5) / 10 end

        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        lbl.Text = label .. ": " .. (format == "float" and string.format("%.1f", val) or tostring(math.round(val)))
        if onChanged then onChanged(val) end
    end

    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(rel)
        end
    end

    track.InputBegan:Connect(beginDrag)
    knob.InputBegan:Connect(beginDrag)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(rel)
        end
    end)

    return wrap
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- ROOT GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Create("ScreenGui", {
    Name = "XenhubV5",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = game:GetService("CoreGui")
})

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS PANEL
-- ═══════════════════════════════════════════════════════════════
local SettingsPanel = Create("Frame", {
    Name = "XenhubV5",
    Position = UDim2.new(1, -968, 0.5, -247),
    Size = UDim2.new(0, 385, 0, 520),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    ZIndex = 100,
    Parent = ScreenGui
})
Corner(SettingsPanel, 12)

-- Header
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundTransparency = 1,
    ZIndex = 101,
    Parent = SettingsPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 12, 0, 14),
    Size = UDim2.new(0, 150, 0, 24),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 101,
    Parent = Header
})

local CloseBtn = Create("TextButton", {
    Name = "CloseBtn",
    Position = UDim2.new(1, -40, 0, 10),
    Size = UDim2.new(0, 30, 0, 30),
    BackgroundColor3 = Theme.Danger,
    BackgroundTransparency = 0.7,
    FontFace = Theme.FontBold,
    Text = "×",
    TextColor3 = Theme.TextPrimary,
    TextSize = 20,
    ZIndex = 101,
    Parent = Header
})
Corner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = false
end)

-- Divider
Create("Frame", {
    Position = UDim2.new(0, 12, 0, 52),
    Size = UDim2.new(1, -24, 0, 1),
    BackgroundColor3 = Color3.new(1, 1, 1),
    BackgroundTransparency = 0.9,
    ZIndex = 101,
    Parent = SettingsPanel
})

-- Navigation
local NavFrame = Create("Frame", {
    Name = "NavFrame",
    Position = UDim2.new(0, 5, 0, 56),
    Size = UDim2.new(1, -10, 0, 28),
    BackgroundTransparency = 1,
    ZIndex = 102,
    Parent = SettingsPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 3),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NavFrame
})

local ContentFrame = Create("Frame", {
    Name = "ContentFrame",
    Position = UDim2.new(0, 10, 0, 86),
    Size = UDim2.new(1, -20, 1, -90),
    BackgroundTransparency = 1,
    ZIndex = 101,
    Parent = SettingsPanel
})

-- Tab system
local Tabs = {
    { Name = "Keybinds",    Active = false },
    { Name = "Auto TP",     Active = false },
    { Name = "ESP",         Active = false },
    { Name = "UI",          Active = true  },
    { Name = "Misc",        Active = false },
    { Name = "Priority",    Active = false },
    { Name = "Performance", Active = false },
}

local TabFrames = {}
local TabButtons = {}

for i, tab in ipairs(Tabs) do
    local btn = Create("TextButton", {
        Size = UDim2.new(1 / #Tabs, -3, 1, 0),
        LayoutOrder = i,
        BackgroundColor3 = tab.Active and Theme.Accent or Theme.Surface,
        BackgroundTransparency = tab.Active and 0.3 or 0.7,
        FontFace = Theme.FontBold,
        Text = tab.Name,
        TextColor3 = tab.Active and Theme.TextPrimary or Theme.TextMuted,
        TextScaled = true,
        TextWrapped = true,
        ZIndex = 103,
        Parent = NavFrame
    })
    Corner(btn, 5)
    TabButtons[tab.Name] = btn

    local scroll = Create("ScrollingFrame", {
        Name = tab.Name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = tab.Active,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 101,
        Parent = ContentFrame
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroll
    })
    TabFrames[tab.Name] = scroll
end

local function SwitchTab(name)
    for tabName, frame in pairs(TabFrames) do
        frame.Visible = (tabName == name)
        local btn = TabButtons[tabName]
        if btn then
            local active = tabName == name
            btn.BackgroundColor3 = active and Theme.Accent or Theme.Surface
            btn.BackgroundTransparency = active and 0.3 or 0.7
            btn.TextColor3 = active and Theme.TextPrimary or Theme.TextMuted
        end
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        SwitchTab(name)
    end)
end

-- ── Keybinds Tab Content ─────────────────────────────────────
local KeybindData = {
    { "Kick", "Y" },
    { "Rejoin Job ID", "J" },
    { "Clone", "F" },
    { "Manual TP", "T" },
    { "Invisible Steal", "U" },
    { "Job ID", "K" },
    { "Proximity", "P" },
    { "Carpet Boost", "Q" },
    { "Walkspeed", "V" },
    { "Open Menu", "LeftControl" },
    { "Ragdoll Self", "R" },
    { "Body Swap TP", "Y" },
    { "Auto Turret", "G" },
    { "Float", "B" },
    { "Reset Character", "X" },
    { "Click to AP", "Z" },
    { "Desync (Synapse Z only)", "LeftShift" },
    { "Auto Buy Carpet", "N" },
}

for i, data in ipairs(KeybindData) do
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.85,
        LayoutOrder = i,
        Parent = TabFrames["Keybinds"]
    })
    Corner(row, 6)

    Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontMedium,
        Text = data[1],
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local keyBtn = Create("TextButton", {
        Position = UDim2.new(1, -72, 0.5, -11),
        Size = UDim2.new(0, 65, 0, 22),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.5,
        FontFace = Theme.FontBold,
        Text = data[2],
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        Parent = row
    })
    Corner(keyBtn, 4)
end

-- ── UI Tab Content ───────────────────────────────────────────
local UIToggles = {
    { "Player List", true },
    { "Command Cooldown", true },
    { "Steal Panel", true },
    { "Steal Target", true },
    { "Movement Panel", true },
    { "Admin Command Panel", true },
    { "Unlock Doors", true },
    { "Steal Progress Bar", true },
    { "Clear Error Popups", true },
}

for i, data in ipairs(UIToggles) do
    local row = CreateToggle(TabFrames["UI"], data[1], data[2])
    row.LayoutOrder = i
end

-- Vertical Buttons row
local vertRow = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50),
    BackgroundTransparency = 0.7,
    LayoutOrder = 10,
    Parent = TabFrames["UI"]
})
Corner(vertRow, 6)

Create("TextLabel", {
    Position = UDim2.new(0, 20, 0, 0),
    Size = UDim2.new(1, -55, 1, 0),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Vertical Buttons",
    TextColor3 = Color3.fromRGB(180, 180, 200),
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = vertRow
})

-- Reset / Lock UI buttons
local actionRow = Create("Frame", {
    Size = UDim2.new(1, -20, 0, 32),
    BackgroundTransparency = 1,
    LayoutOrder = 11,
    Parent = TabFrames["UI"]
})

local resetUI = Create("TextButton", {
    Position = UDim2.new(0.015, 0, 0, 0),
    Size = UDim2.new(0.47, 0, 1, 0),
    BackgroundColor3 = Theme.Surface,
    FontFace = Theme.FontBold,
    Text = "Reset UI",
    TextColor3 = Theme.TextPrimary,
    TextSize = 12,
    Parent = actionRow
})
Corner(resetUI, 6)
Stroke(resetUI, Theme.Accent, 0.5)

local lockUI = Create("TextButton", {
    Position = UDim2.new(0.515, 0, 0, 0),
    Size = UDim2.new(0.47, 0, 1, 0),
    BackgroundColor3 = Theme.Success,
    FontFace = Theme.FontBold,
    Text = "🔒 Locked UI",
    TextColor3 = Theme.TextPrimary,
    TextSize = 12,
    Parent = actionRow
})
Corner(lockUI, 6)
Stroke(lockUI, Theme.Accent, 0.5)

-- ── Performance Tab ──────────────────────────────────────────
local PerfToggles = {
    { "FPS Boost", false },
    { "Dark Mode", false },
    { "Disable Object Animations", true },
    { "Remove Player Accessories (Rejoin)", true },
    { "Remove Tool Textures", false },
}

for i, data in ipairs(PerfToggles) do
    local row = CreateToggle(TabFrames["Performance"], data[1], data[2])
    row.LayoutOrder = i
end

-- Priority & Misc tabs left intentionally clean for future features

-- ═══════════════════════════════════════════════════════════════
-- MOVEMENT PANEL
-- ═══════════════════════════════════════════════════════════════
local MovementPanel = Create("Frame", {
    Name = "WalkspeedFrame",
    Position = UDim2.new(0, 20, 0.5, -365),
    Size = UDim2.new(0, 220, 0, 398),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 10,
    Parent = ScreenGui
})
Corner(MovementPanel, 12)

local movTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Name = "TitleBar",
    Parent = MovementPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = movTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 18),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Movement Panel",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = movTitle
})

Create("Frame", {
    Position = UDim2.new(0.075, 0, 0, 35),
    Size = UDim2.new(0.85, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = MovementPanel
})

local movVars = { rotation = 180, depth = 5.0, speed = 27 }

local MovToggles = {
    { "Invis Steal (U):", 45 },
    { "Float (B):", 79 },
    { "Walkspeed (V):", 113 },
    { "Unwalk:", 147 },
    { "Auto Walk to Base:", 181 },
}

for _, data in ipairs(MovToggles) do
    Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, data[2]),
        Size = UDim2.new(0, 110, 0, 28),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = data[1],
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = MovementPanel
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -80, 0, data[2]),
        Size = UDim2.new(0, 75, 0, 28),
        BackgroundColor3 = Color3.fromRGB(50, 50, 65),
        BackgroundTransparency = 0.15,
        FontFace = Theme.FontBold,
        Text = "OFF",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Parent = MovementPanel
    })
    Corner(btn, 6)
    Stroke(btn)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 65)
        btn.BackgroundTransparency = state and 0 or 0.15
    end)
end

-- Sliders
local rotWrap = Create("Frame", {
    Position = UDim2.new(0, 8, 0, 223),
    Size = UDim2.new(1, -16, 0, 58),
    BackgroundTransparency = 1,
    Parent = MovementPanel
})
CreateSlider(rotWrap, "Rotation", 0, 360, 180, "int", function(v) movVars.rotation = v end)

local depWrap = Create("Frame", {
    Position = UDim2.new(0, 8, 0, 291),
    Size = UDim2.new(1, -16, 0, 36),
    BackgroundTransparency = 1,
    Parent = MovementPanel
})
CreateSlider(depWrap, "Depth", 0.5, 10.5, 5.0, "float", function(v) movVars.depth = v end)

local spdWrap = Create("Frame", {
    Position = UDim2.new(0, 8, 0, 346),
    Size = UDim2.new(1, -16, 0, 36),
    BackgroundTransparency = 1,
    Parent = MovementPanel
})
CreateSlider(spdWrap, "Speed", 16, 100, 27, "int", function(v)
    movVars.speed = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

-- ═══════════════════════════════════════════════════════════════
-- ACTIONS PANEL
-- ═══════════════════════════════════════════════════════════════
local ActionsPanel = Create("Frame", {
    Name = "V5ActionsPanel",
    Position = UDim2.new(1, -230, 1, -325),
    Size = UDim2.new(0, 220, 0, 310),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
Corner(ActionsPanel, 12)

local actTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 40),
    BackgroundTransparency = 1,
    Name = "TitleBar",
    Parent = ActionsPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 6),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 12,
    Parent = actTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 20),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Actions",
    TextColor3 = Theme.TextSecondary,
    TextSize = 10,
    Parent = actTitle
})

Create("Frame", {
    Position = UDim2.new(0.075, 0, 0, 40),
    Size = UDim2.new(0.85, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = ActionsPanel
})

local btnsFrame = Create("Frame", {
    Position = UDim2.new(0, 6, 0, 48),
    Size = UDim2.new(1, -12, 0, 255),
    BackgroundTransparency = 1,
    Name = "Buttons",
    Parent = ActionsPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = btnsFrame
})

CreateActionButton(btnsFrame, "Teleport (T)", Theme.Surface, 1)
CreateActionButton(btnsFrame, "Ragdoll Self (R)", Theme.Surface, 2)
CreateActionButton(btnsFrame, "Rejoin PS", Theme.Surface, 3, function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
CreateActionButton(btnsFrame, "Rejoin Job ID (J)", Theme.Surface, 4)
CreateActionButton(btnsFrame, "Kick (Y)", Theme.Surface, 5)
CreateActionButton(btnsFrame, "Reset (X)", Color3.fromRGB(200, 80, 80), 6, function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.Health = 0 end
end)
CreateActionButton(btnsFrame, "⚙ Settings", Theme.Accent, 7, function()
    SettingsPanel.Visible = not SettingsPanel.Visible
end)

-- ═══════════════════════════════════════════════════════════════
-- STEAL PANEL
-- ═══════════════════════════════════════════════════════════════
local StealPanel = Create("Frame", {
    Name = "StealPanel",
    Position = UDim2.new(1, -230, 1, -611),
    Size = UDim2.new(0, 220, 0, 272),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 100,
    Parent = ScreenGui
})
Corner(StealPanel, 12)

local stealTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 35),
    BackgroundTransparency = 1,
    Name = "V5TitleBar",
    Parent = StealPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = stealTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 18),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Steal Panel",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = stealTitle
})

Create("Frame", {
    Position = UDim2.new(0.075, 0, 0, 35),
    Size = UDim2.new(0.85, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = StealPanel
})

local StealToggles = {
    { "Steal Highest:", 43, false },
    { "Steal Priority:", 81, false },
    { "Steal Nearest:", 119, false },
    { "Auto Turret (G):", 157, false },
    { "Auto Buy (N):", 195, false },
    { "Auto Kick:", 233, true },
}

for _, data in ipairs(StealToggles) do
    Create("TextLabel", {
        Position = UDim2.new(0, 10, 0, data[2]),
        Size = UDim2.new(0, 110, 0, 28),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = data[1],
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = StealPanel
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -80, 0, data[2]),
        Size = UDim2.new(0, 75, 0, 28),
        BackgroundColor3 = data[3] and Theme.Success or Color3.fromRGB(50, 50, 65),
        BackgroundTransparency = data[3] and 0 or 0.15,
        FontFace = Theme.FontBold,
        Text = data[3] and "ON" or "OFF",
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        Parent = StealPanel
    })
    Corner(btn, 6)
    Stroke(btn)

    local state = data[3]
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 65)
        btn.BackgroundTransparency = state and 0 or 0.15
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- PROXIMITY / ADMIN PANEL
-- ═══════════════════════════════════════════════════════════════
local ProxPanel = Create("Frame", {
    Name = "ProximityFrame",
    Position = UDim2.new(1, -420, 1, -510),
    Size = UDim2.new(0, 180, 0, 200),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    Parent = ScreenGui
})
Corner(ProxPanel, 14)

local proxHdr = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Parent = ProxPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = proxHdr
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 18),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Admin Command Panel",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = proxHdr
})

Create("Frame", {
    Position = UDim2.new(0.075, 0, 1, -1),
    Size = UDim2.new(0.85, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = proxHdr
})

local function MakeProxBtn(y, text, name)
    local btn = Create("TextButton", {
        Position = UDim2.new(0.05, 0, 0, y),
        Size = UDim2.new(0.9, 0, 0, 30),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 12,
        Name = name,
        Parent = ProxPanel
    })
    Corner(btn, 6)
    Stroke(btn)
    return btn
end

MakeProxBtn(40, "Spam Base Owner", "SpamBaseOwnerBtn")

local ctap = MakeProxBtn(75, "Click to AP: OFF", "ClickToAPBtn")
local ctapState = false
ctap.MouseButton1Click:Connect(function()
    ctapState = not ctapState
    ctap.Text = ctapState and "Click to AP: ON" or "Click to AP: OFF"
    ctap.BackgroundColor3 = ctapState and Theme.Success or Theme.Surface
    ctap.BackgroundTransparency = ctapState and 0 or 0.3
end)

local prox = MakeProxBtn(110, "Proximity: OFF", "ProxToggleBtn")
local proxState = false
prox.MouseButton1Click:Connect(function()
    proxState = not proxState
    prox.Text = proxState and "Proximity: ON" or "Proximity: OFF"
    prox.BackgroundColor3 = proxState and Theme.Success or Theme.Surface
    prox.BackgroundTransparency = proxState and 0 or 0.3
end)

-- Distance slider
local distWrap = Create("Frame", {
    Position = UDim2.new(0.05, 0, 0, 150),
    Size = UDim2.new(0.9, 0, 0, 38),
    BackgroundTransparency = 1,
    Parent = ProxPanel
})
CreateSlider(distWrap, "Distance", 5, 100, 15, "int")

-- ═══════════════════════════════════════════════════════════════
-- COOLDOWN PANEL
-- ═══════════════════════════════════════════════════════════════
local CooldownPanel = Create("Frame", {
    Name = "CooldownPanel",
    Position = UDim2.new(1, -430, 1, -302),
    Size = UDim2.new(0, 195, 0, 290),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    Parent = ScreenGui
})
Corner(CooldownPanel, 12)

local cdHdr = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundTransparency = 1,
    Parent = CooldownPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = cdHdr
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 18),
    Size = UDim2.new(1, 0, 0, 10),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Command Cooldowns",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = cdHdr
})

Create("Frame", {
    Position = UDim2.new(0.075, 0, 1, -1),
    Size = UDim2.new(0.85, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = cdHdr
})

local cdContent = Create("Frame", {
    Position = UDim2.new(0, 6, 0, 40),
    Size = UDim2.new(1, -12, 1, -44),
    BackgroundTransparency = 1,
    Parent = CooldownPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 2),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = cdContent
})

local CooldownItems = { "Jail", "Rocket", "Inverse", "Ragdoll", "Jumpscare", "Tiny", "Balloon", "Morph", "Nightvision" }

for i, name in ipairs(CooldownItems) do
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        LayoutOrder = i,
        Parent = cdContent
    })

    Create("TextLabel", {
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    Create("TextLabel", {
        Position = UDim2.new(1, -65, 0.5, -10),
        Size = UDim2.new(0, 58, 0, 20),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = "READY",
        TextColor3 = Theme.Success,
        TextSize = 11,
        Name = "ReadyLabel",
        Parent = row
    })
end

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM BAR
-- ═══════════════════════════════════════════════════════════════
local BottomBar = Create("Frame", {
    Name = "XenhubV5Bar",
    Position = UDim2.new(0.5, -285, 1, -135),
    Size = UDim2.new(0, 570, 0, 60),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 1000,
    Parent = ScreenGui
})
Corner(BottomBar, 14)

-- Logo
local logo = Create("Frame", {
    Position = UDim2.new(0, 11, 0.5, -19),
    Size = UDim2.new(0, 38, 0, 38),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BackgroundTransparency = 0.3,
    Name = "V5Logo",
    Parent = BottomBar
})
Corner(logo)

Create("ImageLabel", {
    Position = UDim2.new(0, 2, 0, 2),
    Size = UDim2.new(1, -4, 1, -4),
    BackgroundTransparency = 1,
    Image = "rbxassetid://71386570532846",
    ScaleType = Enum.ScaleType.Fit,
    Parent = logo
})

-- Title with gradient
local titleLbl = Create("TextLabel", {
    Position = UDim2.new(0, 60, 0, 8),
    Size = UDim2.new(0, 150, 0, 26),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 22,
    TextStrokeTransparency = 0.6,
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "XenhubTitle",
    Parent = BottomBar
})
Gradient(titleLbl, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 140, 255)),
    ColorSequenceKeypoint.new(0.5, Theme.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 74, 210)),
}))

Create("TextLabel", {
    Position = UDim2.new(0, 222, 0, 8),
    Size = UDim2.new(0, 200, 0, 26),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "discord.gg/xenhub",
    TextColor3 = Theme.TextPrimary,
    TextSize = 22,
    TextStrokeTransparency = 0.6,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BottomBar
})

Create("TextLabel", {
    Position = UDim2.new(0, 60, 0, 32),
    Size = UDim2.new(0, 350, 0, 28),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "by @themr4pf, @xendless & @ttttt1",
    TextColor3 = Theme.TextSecondary,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BottomBar
})

-- Stats
local statsBox = Create("Frame", {
    Position = UDim2.new(1, -130, 0.5, -26),
    Size = UDim2.new(0, 125, 0, 52),
    BackgroundTransparency = 1,
    Name = "StatsBox",
    Parent = BottomBar
})

local fpsLabel = Create("TextLabel", {
    Position = UDim2.new(0, 5, 0, 0),
    Size = UDim2.new(1, 0, 0, 17),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "FPS: 60",
    TextColor3 = Theme.Success,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "FPSLabel",
    Parent = statsBox
})

local pingLabel = Create("TextLabel", {
    Position = UDim2.new(0, 5, 0, 17),
    Size = UDim2.new(1, 0, 0, 17),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "PING: 0ms",
    TextColor3 = Theme.Success,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "PINGLabel",
    Parent = statsBox
})

Create("TextLabel", {
    Position = UDim2.new(0, 5, 0, 34),
    Size = UDim2.new(1, 0, 0, 17),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "Desync: OFF",
    TextColor3 = Theme.Danger,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "DesyncLabel",
    Parent = statsBox
})

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM RIGHT BUTTONS
-- ═══════════════════════════════════════════════════════════════
local BRFrame = Create("Frame", {
    Name = "BottomRightButtonsFrame",
    Position = UDim2.new(1, -20, 1, -25),
    Size = UDim2.new(0, 160, 0, 360),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Parent = ScreenGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = BRFrame
})

local function MakeBRBtn(name, text, order)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.new(0, 0, 0),
        LayoutOrder = order,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 18,
        Name = name,
        Parent = BRFrame
    })
    Corner(btn, 6)
    Stroke(btn, Color3.new(1, 1, 1), 0.4, 1.2)
    return btn
end

local autoTP = MakeBRBtn("AutoTPButton", "Auto TP [OFF]", 1)
local autoTurret = MakeBRBtn("AutoTurretBtn", "Auto Turret: OFF", 4)

local atpState, aturState = false, false
autoTP.MouseButton1Click:Connect(function()
    atpState = not atpState
    autoTP.Text = atpState and "Auto TP [ON]" or "Auto TP [OFF]"
    autoTP.BackgroundColor3 = atpState and Theme.Success or Color3.new(0, 0, 0)
end)
autoTurret.MouseButton1Click:Connect(function()
    aturState = not aturState
    autoTurret.Text = aturState and "Auto Turret: ON" or "Auto Turret: OFF"
    autoTurret.BackgroundColor3 = aturState and Theme.Success or Color3.new(0, 0, 0)
end)

-- ═══════════════════════════════════════════════════════════════
-- UNLOCK BUTTONS
-- ═══════════════════════════════════════════════════════════════
local UnlockContainer = Create("Frame", {
    Name = "UnlockBtnContainer",
    Position = UDim2.new(0.5, -100, 1, -200),
    Size = UDim2.new(0, 200, 0, 51),
    BackgroundColor3 = Color3.fromRGB(10, 10, 16),
    BackgroundTransparency = 0.08,
    ZIndex = 101,
    Parent = ScreenGui
})
Corner(UnlockContainer, 12)
Stroke(UnlockContainer, Color3.fromRGB(47, 60, 255), 0.5, 1.5)

for i, xOff in ipairs({4, 70, 136}) do
    local btn = Create("TextButton", {
        Position = UDim2.new(0, xOff, 0, 4),
        Size = UDim2.new(0, 60, 0, 43),
        BackgroundColor3 = Color3.fromRGB(14, 17, 23),
        BackgroundTransparency = 0.05,
        FontFace = Theme.FontBold,
        Text = tostring(i),
        TextColor3 = Color3.fromRGB(217, 225, 255),
        TextSize = 14,
        Name = "UnlockFloor" .. i,
        Parent = UnlockContainer
    })
    Corner(btn, 14)
    Stroke(btn, Color3.fromRGB(47, 60, 255), 0.3, 1.5)
end

-- ═══════════════════════════════════════════════════════════════
-- FUNCTIONAL LOGIC
-- ═══════════════════════════════════════════════════════════════

-- FPS + Ping
local frameCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.round(frameCount / (now - lastTime))
        frameCount = 0
        lastTime = now

        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = fps >= 55 and Theme.Success or fps >= 30 and Color3.fromRGB(250, 200, 50) or Theme.Danger

        local ok, ping = pcall(function()
            return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok then
            pingLabel.Text = "PING: " .. ping .. "ms"
            pingLabel.TextColor3 = ping <= 80 and Theme.Success or ping <= 150 and Color3.fromRGB(250, 200, 50) or Theme.Danger
        end
    end
end)

-- Global UI toggle (RightShift)
local uiVisible = true
local managed = {
    SettingsPanel, MovementPanel, ActionsPanel, StealPanel,
    ProxPanel, CooldownPanel, BottomBar, BRFrame, UnlockContainer
}

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        for _, p in ipairs(managed) do
            p.Visible = uiVisible
        end
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        SettingsPanel.Visible = not SettingsPanel.Visible
    end
end)

-- Dragging
MakeDraggable(BottomBar)
MakeDraggable(SettingsPanel, Header)
MakeDraggable(MovementPanel, movTitle)
MakeDraggable(ActionsPanel, actTitle)
MakeDraggable(StealPanel, stealTitle)
MakeDraggable(ProxPanel)
MakeDraggable(CooldownPanel)

print("[XenhubV5] Clean optimized GUI loaded.")
