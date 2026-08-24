--[[
    LINEAGE HUB
    Clean Glassmorphism Design • Black + White Glow
    Centered • Fixed Layout • No overlapping
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
-- THEME  (Glassmorphism - Black + White Glow)
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    Glass          = Color3.fromRGB(8, 8, 10),
    GlassTrans     = 0.18,
    Surface        = Color3.fromRGB(18, 18, 22),
    SurfaceTrans   = 0.35,
    Accent         = Color3.fromRGB(255, 255, 255),
    Success        = Color3.fromRGB(80, 220, 140),
    Danger         = Color3.fromRGB(255, 90, 90),
    TextPrimary    = Color3.fromRGB(245, 245, 250),
    TextSecondary  = Color3.fromRGB(160, 160, 175),
    TextMuted      = Color3.fromRGB(100, 100, 115),
    Stroke         = Color3.fromRGB(255, 255, 255),
    StrokeTrans    = 0.82,
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

local function Corner(parent, r)
    return Create("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = parent })
end

local function Glow(parent, thickness)
    return Create("UIStroke", {
        Color = Theme.Stroke,
        Transparency = Theme.StrokeTrans,
        Thickness = thickness or 1.2,
        Parent = parent
    })
end

local function SoftStroke(parent)
    return Create("UIStroke", {
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 0.88,
        Thickness = 1,
        Parent = parent
    })
end

-- ═══════════════════════════════════════════════════════════════
-- DRAGGABLE
-- ═══════════════════════════════════════════════════════════════
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE
-- ═══════════════════════════════════════════════════════════════
local function CreateToggle(parent, text, default, key, callback)
    local row = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = parent
    })

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        FontFace = Theme.FontMedium,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row
    })

    local track = Create("TextButton", {
        Position = UDim2.new(1, -42, 0.5, -9),
        Size = UDim2.new(0, 38, 0, 18),
        BackgroundColor3 = default and Theme.Success or Color3.fromRGB(40, 40, 48),
        Text = "",
        AutoButtonColor = false,
        Parent = row
    })
    Corner(track, 99)
    SoftStroke(track)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        Parent = track
    })
    Corner(knob, 99)

    local state = default
    if key then State[key] = state end

    local function set(v)
        state = v
        if key then State[key] = v end
        track.BackgroundColor3 = state and Theme.Success or Color3.fromRGB(40, 40, 48)
        TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end

    track.MouseButton1Click:Connect(function() set(not state) end)
    return row, set
end

-- ═══════════════════════════════════════════════════════════════
-- SLIDER
-- ═══════════════════════════════════════════════════════════════
local function CreateSlider(parent, label, min, max, default, format, key, onChanged)
    local wrap = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent = parent
    })

    local lbl = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        FontFace = Theme.FontBold,
        Text = label .. ": " .. (format == "float" and string.format("%.1f", default) or tostring(math.round(default))),
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = wrap
    })

    local track = Create("Frame", {
        Position = UDim2.new(0, 0, 0, 22),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        Parent = wrap
    })
    Corner(track, 99)

    local pct = math.clamp((default - min) / (max - min), 0, 1)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(220, 220, 230),
        Parent = track
    })
    Corner(fill, 99)

    local knob = Create("Frame", {
        Position = UDim2.new(pct, 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = track
    })
    Corner(knob, 99)
    SoftStroke(knob)

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
            local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
            update(rel)
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end

    track.InputBegan:Connect(begin)
    knob.InputBegan:Connect(begin)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local rel = (input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1)
            update(rel)
        end
    end)

    return wrap
end

-- ═══════════════════════════════════════════════════════════════
-- ACTION BUTTON
-- ═══════════════════════════════════════════════════════════════
local function CreateButton(parent, text, color, order, callback)
    local btn = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = color or Theme.Surface,
        BackgroundTransparency = 0.25,
        LayoutOrder = order or 0,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        TextSize = 13,
        AutoButtonColor = true,
        Parent = parent
    })
    Corner(btn, 8)
    SoftStroke(btn)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

-- ═══════════════════════════════════════════════════════════════
-- ROOT
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Create("ScreenGui", {
    Name = "LineageHub",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = game:GetService("CoreGui")
})

-- ═══════════════════════════════════════════════════════════════
-- MAIN HUB (Centered)
-- ═══════════════════════════════════════════════════════════════
local Main = Create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = isMobile and UDim2.new(0, 340, 0, 420) or UDim2.new(0, 520, 0, 460),
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = Theme.GlassTrans,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
Corner(Main, 14)
Glow(Main, 1.4)

-- Header
local Header = Create("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    Parent = Main
})

Create("TextLabel", {
    Position = UDim2.new(0, 16, 0, 10),
    Size = UDim2.new(0, 200, 0, 28),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "LINEAGE HUB",
    TextColor3 = Theme.TextPrimary,
    TextSize = 20,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header
})

local CloseBtn = Create("TextButton", {
    Position = UDim2.new(1, -40, 0, 10),
    Size = UDim2.new(0, 28, 0, 28),
    BackgroundColor3 = Color3.fromRGB(40, 40, 48),
    BackgroundTransparency = 0.3,
    FontFace = Theme.FontBold,
    Text = "×",
    TextColor3 = Theme.TextPrimary,
    TextSize = 18,
    Parent = Header
})
Corner(CloseBtn, 7)
SoftStroke(CloseBtn)
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- Divider under header
Create("Frame", {
    Position = UDim2.new(0, 16, 0, 48),
    Size = UDim2.new(1, -32, 0, 1),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 0.9,
    Parent = Main
})

-- Tabs
local TabBar = Create("Frame", {
    Position = UDim2.new(0, 12, 0, 56),
    Size = UDim2.new(1, -24, 0, 28),
    BackgroundTransparency = 1,
    Parent = Main
})

Create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = TabBar
})

local Content = Create("Frame", {
    Position = UDim2.new(0, 14, 0, 92),
    Size = UDim2.new(1, -28, 1, -108),
    BackgroundTransparency = 1,
    Parent = Main
})

local TabNames = {"Movement", "Steal", "Actions", "Settings"}
local TabFrames = {}
local TabButtons = {}

for i, name in ipairs(TabNames) do
    local active = (i == 1)
    local btn = Create("TextButton", {
        Size = UDim2.new(1 / #TabNames, -4, 1, 0),
        LayoutOrder = i,
        BackgroundColor3 = active and Color3.fromRGB(255, 255, 255) or Theme.Surface,
        BackgroundTransparency = active and 0.85 or 0.4,
        FontFace = Theme.FontBold,
        Text = name,
        TextColor3 = active and Theme.TextPrimary or Theme.TextMuted,
        TextSize = 12,
        Parent = TabBar
    })
    Corner(btn, 6)
    SoftStroke(btn)
    TabButtons[name] = btn

    local page = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = active,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(200, 200, 210),
        Parent = Content
    })
    Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page
    })
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 8),
        Parent = page
    })
    TabFrames[name] = page
end

local function SwitchTab(name)
    for n, page in pairs(TabFrames) do
        page.Visible = (n == name)
        local b = TabButtons[n]
        if b then
            local a = (n == name)
            b.BackgroundColor3 = a and Color3.fromRGB(255, 255, 255) or Theme.Surface
            b.BackgroundTransparency = a and 0.85 or 0.4
            b.TextColor3 = a and Theme.TextPrimary or Theme.TextMuted
        end
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function() SwitchTab(name) end)
end

-- ── Movement Page ────────────────────────────────────────────
local movPage = TabFrames["Movement"]

CreateToggle(movPage, "Invis Steal (U)", false, "InvisSteal")
CreateToggle(movPage, "Float (B)", false, "Float")
CreateToggle(movPage, "Walkspeed (V)", false, "Walkspeed", function(on)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.WalkSpeed = on and State.Speed or 16 end
end)
CreateToggle(movPage, "Unwalk", false, "Unwalk")
CreateToggle(movPage, "Auto Walk", false, "AutoWalk")

CreateSlider(movPage, "Rotation", 0, 360, 180, "int", "Rotation")
CreateSlider(movPage, "Depth", 0.5, 10.5, 5.0, "float", "Depth")
CreateSlider(movPage, "Speed", 16, 100, 27, "int", "Speed", function(v)
    if State.Walkspeed then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
end)

-- ── Steal Page ───────────────────────────────────────────────
local stealPage = TabFrames["Steal"]

CreateToggle(stealPage, "Steal Highest", false, "StealHighest")
CreateToggle(stealPage, "Steal Priority", false, "StealPriority")
CreateToggle(stealPage, "Steal Nearest", false, "StealNearest")
CreateToggle(stealPage, "Auto Turret (G)", false, "AutoTurret")
CreateToggle(stealPage, "Auto Buy (N)", false, "AutoBuy")
CreateToggle(stealPage, "Auto Kick", true, "AutoKick")

-- ── Actions Page ─────────────────────────────────────────────
local actPage = TabFrames["Actions"]

CreateButton(actPage, "Teleport (T)", Theme.Surface, 1, function()
    print("[Lineage] Teleport")
end)

CreateButton(actPage, "Ragdoll Self (R)", Theme.Surface, 2, function()
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        end
    end
end)

CreateButton(actPage, "Rejoin PS", Theme.Surface, 3, function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(actPage, "Rejoin Job ID (J)", Theme.Surface, 4, function()
    print("[Lineage] Job ID Rejoin")
end)

CreateButton(actPage, "Kick (Y)", Theme.Surface, 5, function()
    print("[Lineage] Kick")
end)

CreateButton(actPage, "Reset Character (X)", Color3.fromRGB(80, 30, 30), 6, function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    if hum then hum.Health = 0 end
end)

-- ── Settings Page ────────────────────────────────────────────
local setPage = TabFrames["Settings"]

CreateToggle(setPage, "Click to AP", false, "ClickToAP")
CreateToggle(setPage, "Proximity", false, "Proximity")
CreateSlider(setPage, "Prox Distance", 5, 100, 15, "int", "ProxDistance")

CreateButton(setPage, "Unlock Floor 1", Theme.Surface, 10, function() print("[Lineage] Unlock 1") end)
CreateButton(setPage, "Unlock Floor 2", Theme.Surface, 11, function() print("[Lineage] Unlock 2") end)
CreateButton(setPage, "Unlock Floor 3", Theme.Surface, 12, function() print("[Lineage] Unlock 3") end)

-- ═══════════════════════════════════════════════════════════════
-- BOTTOM BAR (Clean)
-- ═══════════════════════════════════════════════════════════════
local Bar = Create("Frame", {
    Name = "Bar",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 1, -18),
    Size = isMobile and UDim2.new(0, 300, 0, 44) or UDim2.new(0, 420, 0, 48),
    BackgroundColor3 = Theme.Glass,
    BackgroundTransparency = Theme.GlassTrans,
    Parent = ScreenGui
})
Corner(Bar, 12)
Glow(Bar, 1.2)

Create("TextLabel", {
    Position = UDim2.new(0, 14, 0, 6),
    Size = UDim2.new(0, 140, 0, 18),
    BackgroundTransparency = 1,
    FontFace = Theme.FontHeavy,
    Text = "LINEAGE HUB",
    TextColor3 = Theme.TextPrimary,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Bar
})

Create("TextLabel", {
    Position = UDim2.new(0, 14, 0, 24),
    Size = UDim2.new(0, 180, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontMedium,
    Text = "discord.gg/lineage",
    TextColor3 = Theme.TextSecondary,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Bar
})

local fpsLabel = Create("TextLabel", {
    Position = UDim2.new(1, -110, 0, 6),
    Size = UDim2.new(0, 100, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "FPS: 60",
    TextColor3 = Theme.Success,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = Bar
})

local pingLabel = Create("TextLabel", {
    Position = UDim2.new(1, -110, 0, 22),
    Size = UDim2.new(0, 100, 0, 14),
    BackgroundTransparency = 1,
    FontFace = Theme.FontBold,
    Text = "PING: 0ms",
    TextColor3 = Theme.Success,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Right,
    Parent = Bar
})

-- ═══════════════════════════════════════════════════════════════
-- QUICK BUTTONS (Bottom Right)
-- ═══════════════════════════════════════════════════════════════
local Quick = Create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -70),
    Size = UDim2.new(0, 130, 0, 80),
    BackgroundTransparency = 1,
    Parent = ScreenGui
})

Create("UIListLayout", {
    Padding = UDim.new(0, 6),
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Quick
})

local function QuickBtn(text, order)
    local b = Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.Glass,
        BackgroundTransparency = 0.15,
        LayoutOrder = order,
        FontFace = Theme.FontBold,
        Text = text,
        TextColor3 = Theme.TextPrimary,
        TextSize = 12,
        Parent = Quick
    })
    Corner(b, 8)
    SoftStroke(b)
    return b
end

local atpBtn = QuickBtn("Auto TP [OFF]", 1)
local aturBtn = QuickBtn("Auto Turret: OFF", 2)

atpBtn.MouseButton1Click:Connect(function()
    State.AutoTP = not State.AutoTP
    atpBtn.Text = State.AutoTP and "Auto TP [ON]" or "Auto TP [OFF]"
    atpBtn.BackgroundColor3 = State.AutoTP and Color3.fromRGB(20, 60, 40) or Theme.Glass
end)

aturBtn.MouseButton1Click:Connect(function()
    State.AutoTurret = not State.AutoTurret
    aturBtn.Text = State.AutoTurret and "Auto Turret: ON" or "Auto Turret: OFF"
    aturBtn.BackgroundColor3 = State.AutoTurret and Color3.fromRGB(20, 60, 40) or Theme.Glass
end)

-- ═══════════════════════════════════════════════════════════════
-- LOGIC
-- ═══════════════════════════════════════════════════════════════
local frameCount, lastTime = 0, tick()
RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    if now - lastTime >= 0.5 then
        local fps = math.round(frameCount / (now - lastTime))
        frameCount = 0
        lastTime = now
        fpsLabel.Text = "FPS: " .. fps
        fpsLabel.TextColor3 = fps >= 55 and Theme.Success or fps >= 30 and Color3.fromRGB(240, 200, 60) or Theme.Danger

        local ok, ping = pcall(function()
            return math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        if ok then
            pingLabel.Text = "PING: " .. ping .. "ms"
            pingLabel.TextColor3 = ping <= 80 and Theme.Success or ping <= 150 and Color3.fromRGB(240, 200, 60) or Theme.Danger
        end
    end
end)

-- Keys
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
        Bar.Visible = Main.Visible
        Quick.Visible = Main.Visible
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        Main.Visible = not Main.Visible
    elseif input.KeyCode == Enum.KeyCode.V then
        State.Walkspeed = not State.Walkspeed
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.WalkSpeed = State.Walkspeed and State.Speed or 16 end
    elseif input.KeyCode == Enum.KeyCode.X then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

-- Drag
MakeDraggable(Main, Header)
MakeDraggable(Bar)

print("[Lineage Hub] Loaded • Glassmorphism • Centered")
print("RightShift / LeftControl = Toggle UI")
