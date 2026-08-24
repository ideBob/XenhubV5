--[[
    XenhubV5 Combined GUI - Cleaned, Optimized & Mobile Ready
    Smaller panels for mobile • Full drag support • Working toggles/sliders/buttons
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats            = game:GetService("Stats")
local TeleportService  = game:GetService("TeleportService")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ═══════════════════════════════════════════════════════════════
-- THEME
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    Background     = Color3.fromRGB(12, 12, 18),
    Surface        = Color3.fromRGB(40, 40, 50),
    Accent         = Color3.fromRGB(99, 102, 241),
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
-- STATE
-- ═══════════════════════════════════════════════════════════════
local State = {
    InvisSteal = false,
    Float = false,
    Walkspeed = false,
    Unwalk = false,
    AutoWalk = false,
    StealHighest = false,
    StealPriority = false,
    StealNearest = false,
    AutoTurret = false,
    AutoBuy = false,
    AutoKick = true,
    ClickToAP = false,
    Proximity = false,
    AutoTP = false,
    Desync = false,
    Rotation = 180,
    Depth = 5.0,
    Speed = 27,
    ProxDistance = 15,
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITIES
-- ═══════════════════════════════════════════════════════════════
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Corner(parent, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 6), Parent = parent })
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
-- DRAGGABLE (Mouse + Touch)
-- ═══════════════════════════════════════════════════════════════
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE FACTORY (Working Switch)
-- ═══════════════════════════════════════════════════════════════
local function CreateToggle(parent, labelText, defaultOn, key, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, isMobile and 30 or 34),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        Parent = parent
    })
    Corner(row, 6)

    Create("TextLabel", {
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontMedium,
        Text = labelText,
        TextColor3 = Theme.TextPrimary,
        TextSize = isMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -42, 0.5, -9),
        Size = UDim2.new(0, 34, 0, 18),
        BackgroundColor3 = defaultOn and Theme.Success or Color3.fromRGB(60, 60, 60),
        Text = "",
        AutoButtonColor = false,
        Parent = row
    })
    Corner(btn, 99)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Theme.TextPrimary,
        Position = defaultOn and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Parent = btn
    })
    Corner(knob, 99)

    local state = defaultOn
    if key then State[key] = state end

    local function setState(v)
        state = v
        if key then State[key] = v end
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(60, 60, 60)
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end

    btn.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return row, function() return state end, setState
end

-- ═══════════════════════════════════════════════════════════════
-- SLIDER FACTORY (Working + Mobile)
-- ═══════════════════════════════════════════════════════════════
local function CreateSlider(parent, label, min, max, default, format, key, onChanged)
    local wrap = Create("Frame", {
        Size = UDim2.new(1, 0, 0, isMobile and 36 or 42),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = label .. ": " .. (format == "float" and string.format("%.1f", default) or tostring(math.round(default))),
        TextColor3 = Theme.TextPrimary,
        TextSize = isMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap
    })

    local track = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 18),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.Surface,
        Parent = wrap
    })
    Corner(track, 99)

    local pct = math.clamp((default - min) / (max - min), 0, 1)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        Parent = track
    })
    Corner(fill, 99)

    local knob = Create("Frame", {
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, isMobile and 16 or 14, 0, isMobile and 16 or 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.TextPrimary,
        Parent = track
    })
    Corner(knob, 99)
    Stroke(knob, Theme.Accent, 0.3, 1.5)

    local dragging = false

    local function update(p)
        p = math.clamp(p, 0, 1)
        local val = min + (max - min) * p
        if format == "int" then val = math.round(val)
        elseif format == "float" then val = math.floor(val * 10 + 0.5) / 10 end

        fill.Size = UDim2.new(p, 0, 1, 0)
        knob.Position = UDim2.new(p, 0, 0.5, 0)
        lbl.Text = label .. ": " .. (format == "float" and string.format("%.1f", val) or tostring(math.round(val)))

        if key then State[key] = val end
        if onChanged then onChanged(val) end
    end

    local function begin(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(rel)

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    conn:Disconnect()
                end
            end)
        end
    end

    track.InputBegan:Connect(begin)
    knob.InputBegan:Connect(begin)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            update(rel)
        end
    end)

    return wrap
end

-- ═══════════════════════════════════════════════════════════════
-- ACTION BUTTON
-- ═══════════════════════════════════════════════════════════════
local function CreateActionButton(parent, text, color, layoutOrder, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, isMobile and 28 or 30),
        BackgroundColor3 = color or Theme.Surface,
        BackgroundTransparency = 0.25,
        LayoutOrder = layoutOrder or 0,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        TextSize = isMobile and 12 or 13,
        AutoButtonColor = true,
        Parent = parent
    })
    Corner(btn, 6)
    Stroke(btn)

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- ROOT GUI
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Create("ScreenGui", {
    Name = "XenhubV5",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = game:GetService("CoreGui")
})

-- Size helpers for mobile
local function PSize(w, h)
    if isMobile then
        return UDim2.new(0, math.floor(w * 0.72), 0, math.floor(h * 0.72))
    end
    return UDim2.new(0, w, 0, h)
end

-- ═══════════════════════════════════════════════════════════════
-- SETTINGS PANEL (smaller on mobile)
-- ═══════════════════════════════════════════════════════════════
local SettingsPanel = Create("Frame", {
    Name = "XenhubV5",
    Position = isMobile and UDim2.new(0.5, -140, 0.5, -190) or UDim2.new(1, -400, 0.5, -250),
    Size = PSize(385, 480),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.06,
    BorderSizePixel = 0,
    ZIndex = 100,
    Visible = false,
    Parent = ScreenGui
})
Corner(SettingsPanel, 10)

local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, isMobile and 36 or 42),
    BackgroundTransparency = 1,
    ZIndex = 101,
    Parent = SettingsPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 10, 0, isMobile and 8 or 10),
    Size = UDim2.new(0, 140, 0, 22),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = isMobile and 15 or 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 101,
    Parent = Header
})

local CloseBtn = Create("TextButton", {
    Name = "CloseBtn",
    Position = UDim2.new(1, -34, 0, isMobile and 6 or 8),
    Size = UDim2.new(0, 26, 0, 26),
    BackgroundColor3 = Theme.Danger,
    BackgroundTransparency = 0.6,
    FontFace = Theme.FontBold,
    Text = "×",
    TextColor3 = Theme.TextPrimary,
    TextSize = 18,
    ZIndex = 101,
    Parent = Header
})
Corner(CloseBtn, 5)
CloseBtn.MouseButton1Click:Connect(function()
    SettingsPanel.Visible = false
end)

Create("Frame", {
    Position = UDim2.new(0, 10, 0, isMobile and 36 or 44),
    Size = UDim2.new(1, -20, 0, 1),
    BackgroundColor3 = Color3.new(1,1,1),
    BackgroundTransparency = 0.9,
    ZIndex = 101,
    Parent = SettingsPanel
})

-- Nav
local NavFrame = Create("Frame", {
    Name = "NavFrame",
    Position = UDim2.new(0, 6, 0, isMobile and 42 or 50),
    Size = UDim2.new(1, -12, 0, isMobile and 24 or 26),
    BackgroundTransparency = 1,
    ZIndex = 102,
    Parent = SettingsPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 2),
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = NavFrame
})

local ContentFrame = Create("Frame", {
    Name = "ContentFrame",
    Position = UDim2.new(0, 8, 0, isMobile and 70 or 82),
    Size = UDim2.new(1, -16, 1, isMobile and -78 or -90),
    BackgroundTransparency = 1,
    ZIndex = 101,
    Parent = SettingsPanel
})

local Tabs = {"Keybinds", "Auto TP", "ESP", "UI", "Misc", "Priority", "Performance"}
local TabFrames, TabButtons = {}, {}

for i, name in ipairs(Tabs) do
    local active = (name == "UI")
    local btn = Create("TextButton", {
        Size = UDim2.new(1/#Tabs, -2, 1, 0),
        LayoutOrder = i,
        BackgroundColor3 = active and Theme.Accent or Theme.Surface,
        BackgroundTransparency = active and 0.25 or 0.65,
        FontFace = Theme.FontBold,
        Text = name,
        TextColor3 = active and Theme.TextPrimary or Theme.TextMuted,
        TextScaled = true,
        TextWrapped = true,
        ZIndex = 103,
        Parent = NavFrame
    })
    Corner(btn, 4)
    TabButtons[name] = btn

    local scroll = Create("ScrollingFrame", {
        Name = name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = active,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarImageColor3 = Theme.Accent,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 101,
        Parent = ContentFrame
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroll
    })
    TabFrames[name] = scroll
end

local function SwitchTab(name)
    for n, frame in pairs(TabFrames) do
        frame.Visible = (n == name)
        local b = TabButtons[n]
        if b then
            local a = (n == name)
            b.BackgroundColor3 = a and Theme.Accent or Theme.Surface
            b.BackgroundTransparency = a and 0.25 or 0.65
            b.TextColor3 = a and Theme.TextPrimary or Theme.TextMuted
        end
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- Keybinds
local KeybindData = {
    {"Kick","Y"}, {"Rejoin Job ID","J"}, {"Clone","F"}, {"Manual TP","T"},
    {"Invisible Steal","U"}, {"Job ID","K"}, {"Proximity","P"}, {"Carpet Boost","Q"},
    {"Walkspeed","V"}, {"Open Menu","LeftControl"}, {"Ragdoll Self","R"},
    {"Body Swap TP","Y"}, {"Auto Turret","G"}, {"Float","B"}, {"Reset Character","X"},
    {"Click to AP","Z"}, {"Desync","LeftShift"}, {"Auto Buy Carpet","N"}
}

for i, d in ipairs(KeybindData) do
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, isMobile and 28 or 32),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.85,
        LayoutOrder = i,
        Parent = TabFrames["Keybinds"]
    })
    Corner(row, 5)

    Create("TextLabel", {
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontMedium,
        Text = d[1],
        TextColor3 = Theme.TextPrimary,
        TextSize = isMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local kb = Create("TextButton", {
        Position = UDim2.new(1, -64, 0.5, -10),
        Size = UDim2.new(0, 56, 0, 20),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0.45,
        FontFace = Theme.FontBold,
        Text = d[2],
        TextColor3 = Theme.TextPrimary,
        TextSize = 10,
        Parent = row
    })
    Corner(kb, 4)
end

-- UI Toggles
local UIToggles = {
    {"Player List", true},
    {"Command Cooldown", true},
    {"Steal Panel", true},
    {"Steal Target", true},
    {"Movement Panel", true},
    {"Admin Command Panel", true},
    {"Unlock Doors", true},
    {"Steal Progress Bar", true},
    {"Clear Error Popups", true},
}

for i, d in ipairs(UIToggles) do
    local r = CreateToggle(TabFrames["UI"], d[1], d[2])
    r.LayoutOrder = i
end

-- Performance
local PerfToggles = {
    {"FPS Boost", false},
    {"Dark Mode", false},
    {"Disable Object Animations", true},
    {"Remove Player Accessories", true},
    {"Remove Tool Textures", false},
}
for i, d in ipairs(PerfToggles) do
    local r = CreateToggle(TabFrames["Performance"], d[1], d[2])
    r.LayoutOrder = i
end

-- ═══════════════════════════════════════════════════════════════
-- MOVEMENT PANEL
-- ═══════════════════════════════════════════════════════════════
local MovementPanel = Create("Frame", {
    Name = "WalkspeedFrame",
    Position = isMobile and UDim2.new(0, 8, 0.15, 0) or UDim2.new(0, 16, 0.5, -200),
    Size = PSize(210, 360),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 20,
    Parent = ScreenGui
})
Corner(MovementPanel, 10)

local movTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    Name = "TitleBar",
    Parent = MovementPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 4),
    Size = UDim2.new(1, 0, 0, 13),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = movTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 16),
    Size = UDim2.new(1, 0, 0, 11),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Movement",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = movTitle
})

Create("Frame", {
    Position = UDim2.new(0.08, 0, 0, 32),
    Size = UDim2.new(0.84, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = MovementPanel
})

local movContent = Create("Frame", {
    Position = UDim2.new(0, 8, 0, 40),
    Size = UDim2.new(1, -16, 1, -48),
    BackgroundTransparency = 1,
    Parent = MovementPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = movContent
})

-- Movement toggles
local function MovToggle(text, key, order)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = movContent
    })

    Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = isMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -58, 0, 0),
        Size = UDim2.new(0, 56, 0, 24),
        BackgroundColor3 = Color3.fromRGB(50, 50, 65),
        BackgroundTransparency = 0.1,
        FontFace = Theme.FontBold,
        Text = "OFF",
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        Parent = row
    })
    Corner(btn, 5)
    Stroke(btn)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        State[key] = state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 65)
        btn.BackgroundTransparency = state and 0 or 0.1

        -- Apply basic walkspeed logic
        if key == "Walkspeed" then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
            if hum then
                hum.WalkSpeed = state and State.Speed or 16
            end
        end
    end)
end

MovToggle("Invis Steal (U)", "InvisSteal", 1)
MovToggle("Float (B)", "Float", 2)
MovToggle("Walkspeed (V)", "Walkspeed", 3)
MovToggle("Unwalk", "Unwalk", 4)
MovToggle("Auto Walk", "AutoWalk", 5)

-- Sliders
CreateSlider(movContent, "Rotation", 0, 360, 180, "int", "Rotation")
CreateSlider(movContent, "Depth", 0.5, 10.5, 5.0, "float", "Depth")
CreateSlider(movContent, "Speed", 16, 100, 27, "int", "Speed", function(v)
    if State.Walkspeed then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- ACTIONS PANEL
-- ═══════════════════════════════════════════════════════════════
local ActionsPanel = Create("Frame", {
    Name = "V5ActionsPanel",
    Position = isMobile and UDim2.new(1, -150, 1, -280) or UDim2.new(1, -230, 1, -310),
    Size = PSize(200, 280),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
Corner(ActionsPanel, 10)

local actTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 34),
    BackgroundTransparency = 1,
    Name = "TitleBar",
    Parent = ActionsPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 5),
    Size = UDim2.new(1, 0, 0, 13),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = actTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 17),
    Size = UDim2.new(1, 0, 0, 11),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Actions",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = actTitle
})

Create("Frame", {
    Position = UDim2.new(0.08, 0, 0, 34),
    Size = UDim2.new(0.84, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = ActionsPanel
})

local btnsFrame = Create("Frame", {
    Position = UDim2.new(0, 6, 0, 42),
    Size = UDim2.new(1, -12, 1, -48),
    BackgroundTransparency = 1,
    Name = "Buttons",
    Parent = ActionsPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = btnsFrame
})

CreateActionButton(btnsFrame, "Teleport (T)", Theme.Surface, 1, function()
    -- Placeholder: teleport to mouse or selected target
    print("[Xenhub] Teleport triggered")
end)

CreateActionButton(btnsFrame, "Ragdoll Self (R)", Theme.Surface, 2, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v:SetNetworkOwner(LocalPlayer)
                end
            end
        end
    end
end)

CreateActionButton(btnsFrame, "Rejoin PS", Theme.Surface, 3, function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateActionButton(btnsFrame, "Rejoin Job ID (J)", Theme.Surface, 4, function()
    print("[Xenhub] Job ID Rejoin - open Job ID panel")
end)

CreateActionButton(btnsFrame, "Kick (Y)", Theme.Surface, 5, function()
    print("[Xenhub] Kick triggered")
end)

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
    Position = isMobile and UDim2.new(1, -150, 1, -520) or UDim2.new(1, -230, 1, -580),
    Size = PSize(200, 250),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 20,
    Parent = ScreenGui
})
Corner(StealPanel, 10)

local stealTitle = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 32),
    BackgroundTransparency = 1,
    Name = "V5TitleBar",
    Parent = StealPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 4),
    Size = UDim2.new(1, 0, 0, 13),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 11,
    Parent = stealTitle
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 16),
    Size = UDim2.new(1, 0, 0, 11),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Steal Panel",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = stealTitle
})

Create("Frame", {
    Position = UDim2.new(0.08, 0, 0, 32),
    Size = UDim2.new(0.84, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = StealPanel
})

local stealContent = Create("Frame", {
    Position = UDim2.new(0, 8, 0, 40),
    Size = UDim2.new(1, -16, 1, -48),
    BackgroundTransparency = 1,
    Parent = StealPanel
})

Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = stealContent
})

local function StealToggle(text, key, default, order)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = stealContent
    })

    Create("TextLabel", {
        Size = UDim2.new(0.58, 0, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = isMobile and 11 or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local btn = Create("TextButton", {
        Position = UDim2.new(1, -58, 0, 0),
        Size = UDim2.new(0, 56, 0, 24),
        BackgroundColor3 = default and Theme.Success or Color3.fromRGB(50, 50, 65),
        BackgroundTransparency = default and 0 or 0.1,
        FontFace = Theme.FontBold,
        Text = default and "ON" or "OFF",
        TextColor3 = Theme.TextPrimary,
        TextSize = 11,
        Parent = row
    })
    Corner(btn, 5)
    Stroke(btn)

    local state = default
    State[key] = state
    btn.MouseButton1Click:Connect(function()
        state = not state
        State[key] = state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(50, 50, 65)
        btn.BackgroundTransparency = state and 0 or 0.1
    end)
end

StealToggle("Steal Highest", "StealHighest", false, 1)
StealToggle("Steal Priority", "StealPriority", false, 2)
StealToggle("Steal Nearest", "StealNearest", false, 3)
StealToggle("Auto Turret (G)", "AutoTurret", false, 4)
StealToggle("Auto Buy (N)", "AutoBuy", false, 5)
StealToggle("Auto Kick", "AutoKick", true, 6)

-- ═══════════════════════════════════════════════════════════════
-- PROXIMITY PANEL
-- ═══════════════════════════════════════════════════════════════
local ProxPanel = Create("Frame", {
    Name = "ProximityFrame",
    Position = isMobile and UDim2.new(0, 8, 1, -210) or UDim2.new(1, -400, 1, -480),
    Size = PSize(170, 180),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    Parent = ScreenGui
})
Corner(ProxPanel, 10)

local proxHdr = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = ProxPanel
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 4),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = 10,
    Parent = proxHdr
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 15),
    Size = UDim2.new(1, 0, 0, 11),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "Admin Panel",
    TextColor3 = Theme.TextSecondary,
    TextSize = 9,
    Parent = proxHdr
})

Create("Frame", {
    Position = UDim2.new(0.08, 0, 0, 30),
    Size = UDim2.new(0.84, 0, 0, 1),
    BackgroundColor3 = Theme.Accent,
    BackgroundTransparency = 0.5,
    Parent = ProxPanel
})

local function MakeProxBtn(y, text, key)
    local btn = Create("TextButton", {
        Position = UDim2.new(0.06, 0, 0, y),
        Size = UDim2.new(0.88, 0, 0, 26),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.25,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = isMobile and 11 or 12,
        Parent = ProxPanel
    })
    Corner(btn, 5)
    Stroke(btn)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if key then State[key] = state end
        btn.Text = state and text:gsub("OFF", "ON") or text:gsub("ON", "OFF")
        if not text:find("ON") and not text:find("OFF") then
            -- static button
        else
            btn.BackgroundColor3 = state and Theme.Success or Theme.Surface
            btn.BackgroundTransparency = state and 0 or 0.25
        end
    end)
    return btn
end

MakeProxBtn(38, "Spam Base Owner")
MakeProxBtn(68, "Click to AP: OFF", "ClickToAP")
MakeProxBtn(98, "Proximity: OFF", "Proximity")

local distWrap = Create("Frame", {
    Position = UDim2.new(0.06, 0, 0, 132),
    Size = UDim2.new(0.88, 0, 0, 36),
    BackgroundTransparency = 1,
    Parent = ProxPanel
})
CreateSlider(distWrap, "Distance", 5, 100, 15, "int", "ProxDistance")

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM BAR (smaller on mobile)
-- ═══════════════════════════════════════════════════════════════
local BottomBar = Create("Frame", {
    Name = "XenhubV5Bar",
    Position = isMobile and UDim2.new(0.5, -145, 1, -70) or UDim2.new(0.5, -270, 1, -80),
    Size = isMobile and UDim2.new(0, 290, 0, 48) or UDim2.new(0, 540, 0, 54),
    BackgroundColor3 = Theme.Background,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 1000,
    Parent = ScreenGui
})
Corner(BottomBar, 12)

local logo = Create("Frame", {
    Position = UDim2.new(0, 8, 0.5, -15),
    Size = UDim2.new(0, 30, 0, 30),
    BackgroundColor3 = Color3.fromRGB(30, 30, 40),
    BackgroundTransparency = 0.3,
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

local titleLbl = Create("TextLabel", {
    Position = UDim2.new(0, 44, 0, 6),
    Size = UDim2.new(0, isMobile and 90 or 130, 0, 20),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "XENHUB V5",
    TextColor3 = Theme.TextPrimary,
    TextSize = isMobile and 14 or 18,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BottomBar
})
Gradient(titleLbl, ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 140, 255)),
    ColorSequenceKeypoint.new(0.5, Theme.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 74, 210)),
}))

if not isMobile then
    Create("TextLabel", {
        Position = UDim2.new(0, 180, 0, 6),
        Size = UDim2.new(0, 160, 0, 20),
        BackgroundTransparency = 1,
        FontFace = Theme.FontHeavy,
        Text = "discord.gg/xenhub",
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = BottomBar
    })
end

Create("TextLabel", {
    Position = UDim2.new(0, 44, 0, isMobile and 26 or 28),
    Size = UDim2.new(0, 200, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "by @themr4pf, @xendless & @ttttt1",
    TextColor3 = Theme.TextSecondary,
    TextSize = isMobile and 9 or 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = BottomBar
})

-- Stats
local statsBox = Create("Frame", {
    Position = UDim2.new(1, isMobile and -90 or -120, 0.5, -18),
    Size = UDim2.new(0, isMobile and 85 or 110, 0, 36),
    BackgroundTransparency = 1,
    Parent = BottomBar
})

local fpsLabel = Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "FPS: 60",
    TextColor3 = Theme.Success,
    TextSize = isMobile and 10 or 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsBox
})

local pingLabel = Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "PING: 0ms",
    TextColor3 = Theme.Success,
    TextSize = isMobile and 10 or 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = statsBox
})

Create("TextLabel", {
    Position = UDim2.new(0, 0, 0, 24),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "Desync: OFF",
    TextColor3 = Theme.Danger,
    TextSize = isMobile and 10 or 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "DesyncLabel",
    Parent = statsBox
})

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM RIGHT BUTTONS (mobile friendly)
-- ═══════════════════════════════════════════════════════════════
local BRFrame = Create("Frame", {
    Name = "BottomRightButtonsFrame",
    Position = UDim2.new(1, -12, 1, -12),
    Size = UDim2.new(0, isMobile and 120 or 140, 0, 100),
    AnchorPoint = Vector2.new(1, 1),
    BackgroundTransparency = 1,
    Parent = ScreenGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 5),
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = BRFrame
})

local function MakeBRBtn(name, text, order)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, isMobile and 32 or 36),
        BackgroundColor3 = Color3.new(0, 0, 0),
        LayoutOrder = order,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = isMobile and 13 or 15,
        Name = name,
        Parent = BRFrame
    })
    Corner(btn, 6)
    Stroke(btn, Color3.new(1,1,1), 0.4, 1.2)
    return btn
end

local autoTP = MakeBRBtn("AutoTPButton", "Auto TP [OFF]", 1)
local autoTurret = MakeBRBtn("AutoTurretBtn", "Auto Turret: OFF", 2)

autoTP.MouseButton1Click:Connect(function()
    State.AutoTP = not State.AutoTP
    autoTP.Text = State.AutoTP and "Auto TP [ON]" or "Auto TP [OFF]"
    autoTP.BackgroundColor3 = State.AutoTP and Theme.Success or Color3.new(0,0,0)
end)

autoTurret.MouseButton1Click:Connect(function()
    State.AutoTurret = not State.AutoTurret
    autoTurret.Text = State.AutoTurret and "Auto Turret: ON" or "Auto Turret: OFF"
    autoTurret.BackgroundColor3 = State.AutoTurret and Theme.Success or Color3.new(0,0,0)
end)

-- ═══════════════════════════════════════════════════════════════
-- UNLOCK BUTTONS
-- ═══════════════════════════════════════════════════════════════
local UnlockContainer = Create("Frame", {
    Name = "UnlockBtnContainer",
    Position = isMobile and UDim2.new(0.5, -80, 1, -130) or UDim2.new(0.5, -95, 1, -160),
    Size = isMobile and UDim2.new(0, 160, 0, 42) or UDim2.new(0, 190, 0, 48),
    BackgroundColor3 = Color3.fromRGB(10, 10, 16),
    BackgroundTransparency = 0.08,
    ZIndex = 50,
    Parent = ScreenGui
})
Corner(UnlockContainer, 10)
Stroke(UnlockContainer, Color3.fromRGB(47, 60, 255), 0.5, 1.5)

for i, xOff in ipairs(isMobile and {4, 54, 104} or {6, 66, 126}) do
    local btn = Create("TextButton", {
        Position = UDim2.new(0, xOff, 0, 4),
        Size = UDim2.new(0, isMobile and 46 or 54, 0, isMobile and 34 or 40),
        BackgroundColor3 = Color3.fromRGB(14, 17, 23),
        BackgroundTransparency = 0.05,
        FontFace = Theme.FontBold,
        Text = tostring(i),
        TextColor3 = Color3.fromRGB(217, 225, 255),
        TextSize = isMobile and 13 or 14,
        Name = "UnlockFloor" .. i,
        Parent = UnlockContainer
    })
    Corner(btn, 10)
    Stroke(btn, Color3.fromRGB(47, 60, 255), 0.3, 1.5)

    btn.MouseButton1Click:Connect(function()
        print("[Xenhub] Unlock Floor " .. i)
        -- Add your unlock logic here
    end)
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

-- UI Visibility + Keybinds
local uiVisible = true
local managed = {
    SettingsPanel, MovementPanel, ActionsPanel, StealPanel,
    ProxPanel, BottomBar, BRFrame, UnlockContainer
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
    elseif input.KeyCode == Enum.KeyCode.V then
        -- Toggle walkspeed via key
        State.Walkspeed = not State.Walkspeed
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum.WalkSpeed = State.Walkspeed and State.Speed or 16
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

-- Dragging (all panels)
MakeDraggable(BottomBar)
MakeDraggable(SettingsPanel, Header)
MakeDraggable(MovementPanel, movTitle)
MakeDraggable(ActionsPanel, actTitle)
MakeDraggable(StealPanel, stealTitle)
MakeDraggable(ProxPanel)
MakeDraggable(UnlockContainer)

print("[XenhubV5] Mobile-optimized + fully interactive GUI loaded.")
print("[XenhubV5] RightShift = Toggle UI | LeftControl = Settings")
