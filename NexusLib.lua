local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Windows  = {}
Library.Flags    = {}

Library.Theme = {

    Background      = Color3.fromRGB(14, 14, 18),
    SecondaryBG     = Color3.fromRGB(20, 20, 26),
    TertiaryBG      = Color3.fromRGB(26, 26, 34),
    ElementBG       = Color3.fromRGB(30, 30, 40),
    ElementHover    = Color3.fromRGB(38, 38, 52),

    Accent          = Color3.fromRGB(99, 102, 241),
    AccentHover     = Color3.fromRGB(118, 121, 255),
    AccentDark      = Color3.fromRGB(67, 70, 180),

    TextPrimary     = Color3.fromRGB(240, 240, 255),
    TextSecondary   = Color3.fromRGB(160, 160, 185),
    TextMuted       = Color3.fromRGB(90, 90, 115),

    Border          = Color3.fromRGB(40, 40, 55),
    Divider         = Color3.fromRGB(35, 35, 48),
    Success         = Color3.fromRGB(52, 211, 153),
    Warning         = Color3.fromRGB(251, 191, 36),
    Danger          = Color3.fromRGB(248, 113, 113),

    ToggleOff       = Color3.fromRGB(55, 55, 72),
    ToggleOn        = Color3.fromRGB(99, 102, 241),

    SliderTrack     = Color3.fromRGB(40, 40, 55),
    SliderFill      = Color3.fromRGB(99, 102, 241),
    SliderThumb     = Color3.fromRGB(255, 255, 255),
}

local Util = {}

function Util.Tween(instance, props, duration, style, direction)
    duration  = duration  or 0.2
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    return TweenService:Create(instance, TweenInfo.new(duration, style, direction), props)
end

function Util.TweenPlay(instance, props, duration, style, direction)
    Util.Tween(instance, props, duration, style, direction):Play()
end

function Util.RoundFrame(parent, size, pos, color, radius)
    local f = Instance.new("Frame")
    f.Size            = size or UDim2.new(1, 0, 0, 36)
    f.Position        = pos  or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or Library.Theme.ElementBG
    f.BorderSizePixel  = 0
    f.Parent           = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = f

    return f
end

function Util.Label(parent, text, size, color, font, pos)
    local l = Instance.new("TextLabel")
    l.Text              = text or ""
    l.TextSize          = size or 13
    l.TextColor3        = color or Library.Theme.TextPrimary
    l.Font              = font or Enum.Font.GothamMedium
    l.BackgroundTransparency = 1
    l.TextXAlignment    = Enum.TextXAlignment.Left
    l.Position          = pos or UDim2.new(0, 0, 0, 0)
    l.Size              = UDim2.new(1, 0, 1, 0)
    l.Parent            = parent
    return l
end

function Util.Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color or Library.Theme.Border
    s.Thickness    = thickness or 1
    s.Transparency = transparency or 0
    s.Parent       = parent
    return s
end

function Util.Padding(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top    or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft   = UDim.new(0, left   or 0)
    p.PaddingRight  = UDim.new(0, right  or 0)
    p.Parent = parent
    return p
end

function Util.ListLayout(parent, padding, direction, halign, valign)
    local l = Instance.new("UIListLayout")
    l.Padding          = UDim.new(0, padding or 4)
    l.FillDirection    = direction or Enum.FillDirection.Vertical
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.Parent           = parent

    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if parent:IsA("ScrollingFrame") then
            parent.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 12)
        end
    end)

    return l
end

function Util.MakeDraggable(dragHandle, dragTarget)
    local dragging    = false
    local dragInput   = nil
    local startMouse  = Vector2.new()
    local startPos    = UDim2.new()

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging   = true
            startMouse = Vector2.new(input.Position.X, input.Position.Y)
            startPos   = dragTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = Vector2.new(input.Position.X - startMouse.X, input.Position.Y - startMouse.Y)
            Util.TweenPlay(dragTarget, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.08, Enum.EasingStyle.Linear)
        end
    end)
end

function Util.Ripple(button)
    button.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Size  = UDim2.new(0, 0, 0, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position    = UDim2.new(0.5, 0, 0.5, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.85
        ripple.BorderSizePixel = 0
        ripple.ZIndex = button.ZIndex + 1
        ripple.Parent = button
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = ripple

        Util.TweenPlay(ripple, { Size = UDim2.new(2, 0, 2, 0), BackgroundTransparency = 1 }, 0.4)
        task.delay(0.4, function() ripple:Destroy() end)
    end)
end

local NotifHolder = nil

local function EnsureNotifHolder()
    if NotifHolder and NotifHolder.Parent then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusNotifications"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999
    sg.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game.CoreGui

    NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "Holder"
    NotifHolder.Size = UDim2.new(0, 280, 1, 0)
    NotifHolder.Position = UDim2.new(1, -295, 0, 0)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.BorderSizePixel = 0
    NotifHolder.Parent = sg

    local layout = Instance.new("UIListLayout")
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Padding = UDim.new(0, 8)
    layout.Parent = NotifHolder

    Util.Padding(NotifHolder, 0, 16, 0, 0)
end

function Library:Notify(options)
    options = options or {}
    local title    = options.Title    or "Notification"
    local content  = options.Content  or ""
    local duration = options.Duration or 3
    local ntype    = options.Type     or "info"

    EnsureNotifHolder()

    local typeColors = {
        info    = Library.Theme.Accent,
        success = Library.Theme.Success,
        warning = Library.Theme.Warning,
        danger  = Library.Theme.Danger,
    }
    local accentColor = typeColors[ntype] or Library.Theme.Accent

    local card = Instance.new("Frame")
    card.Name = "Notification"
    card.Size = UDim2.new(1, 0, 0, 70)
    card.BackgroundColor3 = Library.Theme.SecondaryBG
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = NotifHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = card

    Util.Stroke(card, Library.Theme.Border, 1)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.Position = UDim2.new(0, 0, 0, 0)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.Parent = card
    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 8)
    bc.Parent = bar

    local inner = Instance.new("Frame")
    inner.Size = UDim2.new(1, -16, 1, 0)
    inner.Position = UDim2.new(0, 12, 0, 0)
    inner.BackgroundTransparency = 1
    inner.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.TextSize = 13
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Library.Theme.TextPrimary
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.Parent = inner

    local contentLabel = Instance.new("TextLabel")
    contentLabel.Text = content
    contentLabel.TextSize = 11
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextColor3 = Library.Theme.TextSecondary
    contentLabel.BackgroundTransparency = 1
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextWrapped = true
    contentLabel.Size = UDim2.new(1, 0, 0, 30)
    contentLabel.Position = UDim2.new(0, 0, 0, 32)
    contentLabel.Parent = inner

    local progress = Instance.new("Frame")
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.Position = UDim2.new(0, 0, 1, -2)
    progress.BackgroundColor3 = accentColor
    progress.BorderSizePixel = 0
    progress.Parent = card

    card.Position = UDim2.new(1.2, 0, 0, 0)
    Util.TweenPlay(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    Util.TweenPlay(progress, { Size = UDim2.new(0, 0, 0, 2) }, duration, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        Util.TweenPlay(card, { Position = UDim2.new(1.2, 0, 0, 0) }, 0.3)
        task.delay(0.3, function()
            card:Destroy()
        end)
    end)
end

function Library:CreateWindow(options)
    options = options or {}
    local title     = options.Title     or "NexusLib"
    local subtitle  = options.Subtitle  or "v1.0"
    local keybind   = options.Keybind   or Enum.KeyCode.RightShift
    local size      = options.Size      or Vector2.new(560, 380)
    local theme     = options.Theme

    if theme then
        for k, v in pairs(theme) do
            Library.Theme[k] = v
        end
    end

    local T = Library.Theme

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NexusLib_" .. title
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = (RunService:IsStudio() and LocalPlayer.PlayerGui) or game.CoreGui

    local Shadow = Instance.new("ImageLabel")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.Size = UDim2.new(0, size.X + 40, 0, size.Y + 40)
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.Parent = ScreenGui

    local Main = Instance.new("Frame")
    Main.Name = "MainWindow"
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(0, size.X, 0, size.Y)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = T.Background
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = Main

    Util.Stroke(Main, T.Border, 1)

    Main:GetPropertyChangedSignal("Position"):Connect(function()
        Shadow.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset,
            Main.Position.Y.Scale, Main.Position.Y.Offset + 4)
    end)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 148, 1, 0)
    Sidebar.BackgroundColor3 = T.SecondaryBG
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    local LogoArea = Instance.new("Frame")
    LogoArea.Size = UDim2.new(1, 0, 0, 60)
    LogoArea.BackgroundTransparency = 1
    LogoArea.Parent = Sidebar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Text = title
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextColor3 = T.TextPrimary
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Size = UDim2.new(1, -16, 0, 20)
    TitleLabel.Position = UDim2.new(0, 14, 0, 14)
    TitleLabel.Parent = LogoArea

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Text = subtitle
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextColor3 = T.Accent
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Size = UDim2.new(1, -16, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 14, 0, 36)
    SubtitleLabel.Parent = LogoArea

    local logoDivider = Instance.new("Frame")
    logoDivider.Size = UDim2.new(1, -16, 0, 1)
    logoDivider.Position = UDim2.new(0, 8, 0, 60)
    logoDivider.BackgroundColor3 = T.Divider
    logoDivider.BorderSizePixel = 0
    logoDivider.Parent = Sidebar

    local TabButtons = Instance.new("ScrollingFrame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 1, -72)
    TabButtons.Position = UDim2.new(0, 0, 0, 70)
    TabButtons.BackgroundTransparency = 1
    TabButtons.BorderSizePixel = 0
    TabButtons.ScrollBarThickness = 0
    TabButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabButtons.Parent = Sidebar

    Util.ListLayout(TabButtons, 3)
    Util.Padding(TabButtons, 8, 8, 8, 8)

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -148, 1, 0)
    ContentArea.Position = UDim2.new(0, 148, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ClipsDescendants = true
    ContentArea.Parent = Main

    local ContentHeader = Instance.new("Frame")
    ContentHeader.Size = UDim2.new(1, 0, 0, 42)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.BorderSizePixel = 0
    ContentHeader.Parent = ContentArea

    local TabTitleLabel = Instance.new("TextLabel")
    TabTitleLabel.Name = "TabTitle"
    TabTitleLabel.Text = ""
    TabTitleLabel.TextSize = 14
    TabTitleLabel.Font = Enum.Font.GothamBold
    TabTitleLabel.TextColor3 = T.TextPrimary
    TabTitleLabel.BackgroundTransparency = 1
    TabTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TabTitleLabel.Size = UDim2.new(1, -16, 1, 0)
    TabTitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TabTitleLabel.Parent = ContentHeader

    local headerDivider = Instance.new("Frame")
    headerDivider.Size = UDim2.new(1, -16, 0, 1)
    headerDivider.Position = UDim2.new(0, 8, 0, 42)
    headerDivider.BackgroundColor3 = T.Divider
    headerDivider.BorderSizePixel = 0
    headerDivider.Parent = ContentArea

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -38, 0, 7)
    CloseBtn.BackgroundColor3 = T.TertiaryBG
    CloseBtn.Text = "✕"
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextColor3 = T.TextSecondary
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = ContentHeader

    local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0, 6) cc.Parent = CloseBtn

    CloseBtn.MouseEnter:Connect(function()
        Util.TweenPlay(CloseBtn, { BackgroundColor3 = T.Danger, TextColor3 = T.TextPrimary }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Util.TweenPlay(CloseBtn, { BackgroundColor3 = T.TertiaryBG, TextColor3 = T.TextSecondary }, 0.15)
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(1, -70, 0, 7)
    MinBtn.BackgroundColor3 = T.TertiaryBG
    MinBtn.Text = "─"
    MinBtn.TextSize = 11
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextColor3 = T.TextSecondary
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = ContentHeader

    local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 6) mc.Parent = MinBtn

    MinBtn.MouseEnter:Connect(function()
        Util.TweenPlay(MinBtn, { BackgroundColor3 = T.Warning, TextColor3 = T.TextPrimary }, 0.15)
    end)
    MinBtn.MouseLeave:Connect(function()
        Util.TweenPlay(MinBtn, { BackgroundColor3 = T.TertiaryBG, TextColor3 = T.TextSecondary }, 0.15)
    end)

    Util.MakeDraggable(ContentHeader, Main)

    local visible     = true
    local minimised   = false
    local normalSize  = UDim2.new(0, size.X, 0, size.Y)
    local miniSize    = UDim2.new(0, size.X, 0, 42)

    CloseBtn.MouseButton1Click:Connect(function()
        visible = false
        Util.TweenPlay(Main, { Size = UDim2.new(0, size.X, 0, 0) }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.delay(0.32, function() ScreenGui.Enabled = false end)
    end)

    MinBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            Util.TweenPlay(Main, { Size = miniSize }, 0.25, Enum.EasingStyle.Quart)
        else
            Util.TweenPlay(Main, { Size = normalSize }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == keybind then
            visible = not visible
            ScreenGui.Enabled = visible
            if visible then
                Main.Size = UDim2.new(0, size.X, 0, 0)
                Util.TweenPlay(Main, { Size = normalSize }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
        end
    end)

    Main.Size = UDim2.new(0, size.X, 0, 0)
    Main.BackgroundTransparency = 0.5
    task.defer(function()
        Util.TweenPlay(Main, { Size = normalSize, BackgroundTransparency = 0 }, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)

    local Window = {}
    Window._tabs       = {}
    Window._activeTab  = nil
    Window._gui        = ScreenGui
    Window._main       = Main

    local function SetActiveTab(tabObj)

        for _, t in ipairs(Window._tabs) do
            t._content.Visible = false
            Util.TweenPlay(t._button, {
                BackgroundColor3 = Color3.fromRGB(0,0,0),
                BackgroundTransparency = 1,
                TextColor3 = T.TextSecondary
            }, 0.15)
            if t._indicator then
                Util.TweenPlay(t._indicator, { BackgroundTransparency = 1 }, 0.15)
            end
        end

        tabObj._content.Visible = true
        Util.TweenPlay(tabObj._button, {
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 0,
            TextColor3 = T.TextPrimary
        }, 0.2)
        if tabObj._indicator then
            Util.TweenPlay(tabObj._indicator, { BackgroundTransparency = 0 }, 0.2)
        end
        TabTitleLabel.Text = tabObj._name
        Window._activeTab = tabObj
    end

    function Window:CreateTab(name, icon)
        local Tab = {}
        Tab._name = name

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = "Tab_" .. name
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = T.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = (icon and icon ~= "") and ("  " .. name) or name
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextColor3 = T.TextSecondary
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = TabButtons

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 6)
        tc.Parent = TabBtn

        Util.Padding(TabBtn, 0, 0, 10, 0)

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0.6, 0)
        indicator.AnchorPoint = Vector2.new(0, 0.5)
        indicator.Position = UDim2.new(0, -1, 0.5, 0)
        indicator.BackgroundColor3 = T.TextPrimary
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = TabBtn
        local ic = Instance.new("UICorner") ic.CornerRadius = UDim.new(1, 0) ic.Parent = indicator
        Tab._indicator = indicator

        TabBtn.MouseEnter:Connect(function()
            if Window._activeTab ~= Tab then
                Util.TweenPlay(TabBtn, { BackgroundTransparency = 0.85, TextColor3 = T.TextPrimary }, 0.15)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window._activeTab ~= Tab then
                Util.TweenPlay(TabBtn, { BackgroundTransparency = 1, TextColor3 = T.TextSecondary }, 0.15)
            end
        end)

        TabBtn.MouseButton1Click:Connect(function()
            SetActiveTab(Tab)
        end)

        Tab._button = TabBtn

        local ContentScroll = Instance.new("ScrollingFrame")
        ContentScroll.Name = "Content_" .. name
        ContentScroll.Size = UDim2.new(1, 0, 1, -52)
        ContentScroll.Position = UDim2.new(0, 0, 0, 52)
        ContentScroll.BackgroundTransparency = 1
        ContentScroll.BorderSizePixel = 0
        ContentScroll.ScrollBarThickness = 3
        ContentScroll.ScrollBarImageColor3 = T.Accent
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        ContentScroll.Visible = false
        ContentScroll.Parent = ContentArea

        Util.ListLayout(ContentScroll, 5)
        Util.Padding(ContentScroll, 10, 10, 12, 12)

        Tab._content = ContentScroll

        if #Window._tabs == 0 then
            task.defer(function() SetActiveTab(Tab) end)
        end

        table.insert(Window._tabs, Tab)

        function Tab:CreateButton(options)
            options = options or {}
            local text     = options.Text or "Button"
            local callback = options.Callback or function() end
            local desc     = options.Description

            local container = Util.RoundFrame(ContentScroll, UDim2.new(1, 0, 0, desc and 52 or 36), nil, T.ElementBG)
            Util.Stroke(container, T.Border)

            local inner = Instance.new("TextButton")
            inner.Size = UDim2.new(1, 0, 1, 0)
            inner.BackgroundTransparency = 1
            inner.Text = ""
            inner.BorderSizePixel = 0
            inner.Parent = container

            local label = Util.Label(inner, text, 13, T.TextPrimary, Enum.Font.GothamMedium)
            Util.Padding(inner, 0, 0, 14, 0)

            if desc then
                label.Size = UDim2.new(1, 0, 0, 20)
                label.Position = UDim2.new(0, 0, 0, 8)
                local descLabel = Util.Label(inner, desc, 11, T.TextSecondary, Enum.Font.Gotham)
                descLabel.Position = UDim2.new(0, 0, 0, 30)
                descLabel.Size = UDim2.new(1, -40, 0, 16)
            end

            local arrow = Instance.new("TextLabel")
            arrow.Text = "›"
            arrow.TextSize = 18
            arrow.Font = Enum.Font.GothamBold
            arrow.TextColor3 = T.Accent
            arrow.BackgroundTransparency = 1
            arrow.Size = UDim2.new(0, 20, 1, 0)
            arrow.Position = UDim2.new(1, -28, 0, 0)
            arrow.TextXAlignment = Enum.TextXAlignment.Center
            arrow.Parent = inner

            inner.MouseEnter:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementHover }, 0.15)
                Util.TweenPlay(arrow, { TextColor3 = T.AccentHover }, 0.15)
            end)
            inner.MouseLeave:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementBG }, 0.15)
                Util.TweenPlay(arrow, { TextColor3 = T.Accent }, 0.15)
            end)

            inner.MouseButton1Down:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.AccentDark }, 0.1)
            end)
            inner.MouseButton1Up:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementHover }, 0.1)
            end)

            Util.Ripple(inner)

            inner.MouseButton1Click:Connect(function()
                local ok, err = pcall(callback)
                if not err then return end
                Library:Notify({ Title = "Error", Content = tostring(err), Type = "danger" })
            end)

            return { Button = inner }
        end

        function Tab:CreateToggle(options)
            options = options or {}
            local text     = options.Text     or "Toggle"
            local flag     = options.Flag
            local default  = options.Default  or false
            local callback = options.Callback or function() end
            local desc     = options.Description

            local state = default

            local container = Util.RoundFrame(ContentScroll, UDim2.new(1, 0, 0, desc and 52 or 36), nil, T.ElementBG)
            Util.Stroke(container, T.Border)

            local label = Instance.new("TextLabel")
            label.Text = text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextColor3 = T.TextPrimary
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -70, 0, 20)
            label.Position = UDim2.new(0, 14, 0, desc and 8 or 8)
            label.Parent = container

            if desc then
                local descLabel = Instance.new("TextLabel")
                descLabel.Text = desc
                descLabel.TextSize = 11
                descLabel.Font = Enum.Font.Gotham
                descLabel.TextColor3 = T.TextSecondary
                descLabel.BackgroundTransparency = 1
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.Size = UDim2.new(1, -70, 0, 16)
                descLabel.Position = UDim2.new(0, 14, 0, 30)
                descLabel.Parent = container
            end

            local trackW, trackH = 38, 20
            local track = Instance.new("Frame")
            track.Size = UDim2.new(0, trackW, 0, trackH)
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -14, 0.5, 0)
            track.BackgroundColor3 = state and T.ToggleOn or T.ToggleOff
            track.BorderSizePixel = 0
            track.Parent = container

            local tkc = Instance.new("UICorner")
            tkc.CornerRadius = UDim.new(1, 0)
            tkc.Parent = track

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.Parent = track

            local kc = Instance.new("UICorner")
            kc.CornerRadius = UDim.new(1, 0)
            kc.Parent = knob

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.Parent = container

            local function UpdateToggle()
                Util.TweenPlay(track, { BackgroundColor3 = state and T.ToggleOn or T.ToggleOff }, 0.2)
                Util.TweenPlay(knob, {
                    Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                }, 0.2, Enum.EasingStyle.Back)
            end

            btn.MouseEnter:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementHover }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementBG }, 0.15)
            end)

            btn.MouseButton1Click:Connect(function()
                state = not state
                UpdateToggle()
                if flag then Library.Flags[flag] = state end
                local ok, err = pcall(callback, state)
                if err then Library:Notify({ Title = "Error", Content = tostring(err), Type = "danger" }) end
            end)

            if flag then Library.Flags[flag] = state end

            local ToggleObj = {}
            function ToggleObj:Set(val)
                state = val
                UpdateToggle()
                if flag then Library.Flags[flag] = state end
                pcall(callback, state)
            end
            function ToggleObj:Get() return state end

            return ToggleObj
        end

        function Tab:CreateSlider(options)
            options = options or {}
            local text     = options.Text     or "Slider"
            local min      = options.Min      or 0
            local max      = options.Max      or 100
            local default  = options.Default  or min
            local suffix   = options.Suffix   or ""
            local flag     = options.Flag
            local step     = options.Step     or 1
            local callback = options.Callback or function() end

            local value = default

            local container = Util.RoundFrame(ContentScroll, UDim2.new(1, 0, 0, 54), nil, T.ElementBG)
            Util.Stroke(container, T.Border)

            local label = Instance.new("TextLabel")
            label.Text = text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextColor3 = T.TextPrimary
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(0.7, 0, 0, 18)
            label.Position = UDim2.new(0, 14, 0, 8)
            label.Parent = container

            local valueLabel = Instance.new("TextLabel")
            valueLabel.Text = tostring(value) .. suffix
            valueLabel.TextSize = 12
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextColor3 = T.Accent
            valueLabel.BackgroundTransparency = 1
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Size = UDim2.new(0.3, -14, 0, 18)
            valueLabel.Position = UDim2.new(0.7, 0, 0, 8)
            valueLabel.Parent = container

            local trackFrame = Instance.new("Frame")
            trackFrame.Size = UDim2.new(1, -28, 0, 6)
            trackFrame.Position = UDim2.new(0, 14, 0, 34)
            trackFrame.BackgroundColor3 = T.SliderTrack
            trackFrame.BorderSizePixel = 0
            trackFrame.Parent = container

            local tfc = Instance.new("UICorner")
            tfc.CornerRadius = UDim.new(1, 0)
            tfc.Parent = trackFrame

            local fill = Instance.new("Frame")
            fill.BackgroundColor3 = T.SliderFill
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
            fill.Parent = trackFrame

            local ffc = Instance.new("UICorner")
            ffc.CornerRadius = UDim.new(1, 0)
            ffc.Parent = fill

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 14, 0, 14)
            thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            thumb.Position = UDim2.new((value - min)/(max - min), 0, 0.5, 0)
            thumb.BackgroundColor3 = T.SliderThumb
            thumb.BorderSizePixel = 0
            thumb.ZIndex = 2
            thumb.Parent = trackFrame

            local thc = Instance.new("UICorner")
            thc.CornerRadius = UDim.new(1, 0)
            thc.Parent = thumb

            Util.Stroke(thumb, T.Accent, 2)

            local sliding = false

            local function UpdateSlider(inputX)
                local absPos  = trackFrame.AbsolutePosition.X
                local absSize = trackFrame.AbsoluteSize.X
                local pct     = math.clamp((inputX - absPos) / absSize, 0, 1)
                local raw     = min + pct * (max - min)

                local snapped = math.round(raw / step) * step
                snapped = math.clamp(snapped, min, max)

                local newPct = (snapped - min) / (max - min)
                value = snapped
                valueLabel.Text = tostring(value) .. suffix

                Util.TweenPlay(fill,  { Size = UDim2.new(newPct, 0, 1, 0) }, 0.08, Enum.EasingStyle.Linear)
                Util.TweenPlay(thumb, { Position = UDim2.new(newPct, 0, 0.5, 0) }, 0.08, Enum.EasingStyle.Linear)

                if flag then Library.Flags[flag] = value end
                pcall(callback, value)
            end

            trackFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    UpdateSlider(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement) then
                    UpdateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)

            if flag then Library.Flags[flag] = value end

            local SliderObj = {}
            function SliderObj:Set(val)
                value = math.clamp(val, min, max)
                local pct = (value - min) / (max - min)
                valueLabel.Text = tostring(value) .. suffix
                Util.TweenPlay(fill,  { Size = UDim2.new(pct, 0, 1, 0) }, 0.15)
                Util.TweenPlay(thumb, { Position = UDim2.new(pct, 0, 0.5, 0) }, 0.15)
                if flag then Library.Flags[flag] = value end
                pcall(callback, value)
            end
            function SliderObj:Get() return value end

            return SliderObj
        end

        function Tab:CreateDropdown(options)
            options = options or {}
            local text     = options.Text     or "Dropdown"
            local opts     = options.Options  or {}
            local default  = options.Default  or opts[1]
            local flag     = options.Flag
            local multi    = options.Multi    or false
            local callback = options.Callback or function() end

            local selected = multi and {} or default
            if multi and default then selected = { default } end

            local open = false

            local container = Util.RoundFrame(ContentScroll, UDim2.new(1, 0, 0, 36), nil, T.ElementBG)
            container.ClipsDescendants = false
            Util.Stroke(container, T.Border)

            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 36)
            header.BackgroundTransparency = 1
            header.Text = ""
            header.Parent = container

            local headerLabel = Instance.new("TextLabel")
            headerLabel.Text = text
            headerLabel.TextSize = 13
            headerLabel.Font = Enum.Font.GothamMedium
            headerLabel.TextColor3 = T.TextPrimary
            headerLabel.BackgroundTransparency = 1
            headerLabel.TextXAlignment = Enum.TextXAlignment.Left
            headerLabel.Size = UDim2.new(0.5, 0, 1, 0)
            headerLabel.Position = UDim2.new(0, 14, 0, 0)
            headerLabel.Parent = header

            local selectedLabel = Instance.new("TextLabel")
            selectedLabel.Text = multi and "Select..." or (selected or "Select...")
            selectedLabel.TextSize = 12
            selectedLabel.Font = Enum.Font.Gotham
            selectedLabel.TextColor3 = T.TextSecondary
            selectedLabel.BackgroundTransparency = 1
            selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
            selectedLabel.Size = UDim2.new(0.4, 0, 1, 0)
            selectedLabel.Position = UDim2.new(0.5, 0, 0, 0)
            selectedLabel.Parent = header

            local chevron = Instance.new("TextLabel")
            chevron.Text = "⌄"
            chevron.TextSize = 14
            chevron.Font = Enum.Font.GothamBold
            chevron.TextColor3 = T.Accent
            chevron.BackgroundTransparency = 1
            chevron.Size = UDim2.new(0, 20, 1, 0)
            chevron.Position = UDim2.new(1, -28, 0, 0)
            chevron.TextXAlignment = Enum.TextXAlignment.Center
            chevron.Parent = header

            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(1, 0, 0, 0)
            listFrame.Position = UDim2.new(0, 0, 1, 4)
            listFrame.BackgroundColor3 = T.TertiaryBG
            listFrame.BorderSizePixel = 0
            listFrame.ClipsDescendants = true
            listFrame.ZIndex = 10
            listFrame.Visible = false
            listFrame.Parent = container

            local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 6) lc.Parent = listFrame
            Util.Stroke(listFrame, T.Border)

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = listFrame
            Util.Padding(listFrame, 4, 4, 4, 4)

            local itemHeight = 28
            local totalHeight = #opts * (itemHeight + 2) + 8

            local function UpdateSelectedLabel()
                if multi then
                    if #selected == 0 then
                        selectedLabel.Text = "None"
                    elseif #selected == 1 then
                        selectedLabel.Text = selected[1]
                    else
                        selectedLabel.Text = selected[1] .. " +" .. (#selected-1)
                    end
                else
                    selectedLabel.Text = selected or "Select..."
                end
            end

            for _, opt in ipairs(opts) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, itemHeight)
                item.BackgroundColor3 = T.TertiaryBG
                item.Text = ""
                item.BorderSizePixel = 0
                item.ZIndex = 11
                item.Parent = listFrame

                local ic2 = Instance.new("UICorner") ic2.CornerRadius = UDim.new(0, 4) ic2.Parent = item

                local itemLabel = Instance.new("TextLabel")
                itemLabel.Text = opt
                itemLabel.TextSize = 12
                itemLabel.Font = Enum.Font.GothamMedium
                itemLabel.TextColor3 = T.TextSecondary
                itemLabel.BackgroundTransparency = 1
                itemLabel.TextXAlignment = Enum.TextXAlignment.Left
                itemLabel.Size = UDim2.new(1, -10, 1, 0)
                itemLabel.Position = UDim2.new(0, 10, 0, 0)
                itemLabel.ZIndex = 12
                itemLabel.Parent = item

                item.MouseEnter:Connect(function()
                    Util.TweenPlay(item, { BackgroundColor3 = T.ElementHover }, 0.1)
                    Util.TweenPlay(itemLabel, { TextColor3 = T.TextPrimary }, 0.1)
                end)
                item.MouseLeave:Connect(function()
                    local isSelected = (not multi and selected == opt) or
                        (multi and table.find(selected, opt))
                    local col = isSelected and T.AccentDark or T.TertiaryBG
                    Util.TweenPlay(item, { BackgroundColor3 = col }, 0.1)
                    Util.TweenPlay(itemLabel, { TextColor3 = isSelected and T.TextPrimary or T.TextSecondary }, 0.1)
                end)

                item.MouseButton1Click:Connect(function()
                    if multi then
                        local idx = table.find(selected, opt)
                        if idx then
                            table.remove(selected, idx)
                            Util.TweenPlay(item, { BackgroundColor3 = T.TertiaryBG }, 0.1)
                        else
                            table.insert(selected, opt)
                            Util.TweenPlay(item, { BackgroundColor3 = T.AccentDark }, 0.1)
                        end
                        UpdateSelectedLabel()
                        if flag then Library.Flags[flag] = selected end
                        pcall(callback, selected)
                    else
                        selected = opt
                        UpdateSelectedLabel()
                        if flag then Library.Flags[flag] = selected end
                        pcall(callback, selected)

                        open = false
                        Util.TweenPlay(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                        Util.TweenPlay(chevron, { Rotation = 0 }, 0.2)
                        task.delay(0.2, function() listFrame.Visible = false end)
                    end
                end)
            end

            header.MouseEnter:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementHover }, 0.15)
            end)
            header.MouseLeave:Connect(function()
                Util.TweenPlay(container, { BackgroundColor3 = T.ElementBG }, 0.15)
            end)

            header.MouseButton1Click:Connect(function()
                open = not open
                listFrame.Visible = true
                if open then
                    Util.TweenPlay(listFrame, { Size = UDim2.new(1, 0, 0, totalHeight) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    Util.TweenPlay(chevron, { Rotation = 180 }, 0.2)
                else
                    Util.TweenPlay(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
                    Util.TweenPlay(chevron, { Rotation = 0 }, 0.2)
                    task.delay(0.2, function() listFrame.Visible = false end)
                end
            end)

            if flag then Library.Flags[flag] = selected end
            UpdateSelectedLabel()

            local DropdownObj = {}
            function DropdownObj:Set(val)
                selected = val
                UpdateSelectedLabel()
                if flag then Library.Flags[flag] = selected end
                pcall(callback, selected)
            end
            function DropdownObj:Get() return selected end

            return DropdownObj
        end

        function Tab:CreateInput(options)
            options = options or {}
            local text        = options.Text        or "Input"
            local placeholder = options.Placeholder or "Type here..."
            local flag        = options.Flag
            local numeric     = options.Numeric     or false
            local callback    = options.Callback    or function() end

            local container = Util.RoundFrame(ContentScroll, UDim2.new(1, 0, 0, 36), nil, T.ElementBG)
            Util.Stroke(container, T.Border)

            local label = Instance.new("TextLabel")
            label.Text = text
            label.TextSize = 13
            label.Font = Enum.Font.GothamMedium
            label.TextColor3 = T.TextPrimary
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(0.35, 0, 1, 0)
            label.Position = UDim2.new(0, 14, 0, 0)
            label.Parent = container

            local inputBG = Util.RoundFrame(container, UDim2.new(0.58, 0, 0, 22), UDim2.new(0.35, 8, 0.5, -11), T.TertiaryBG, 4)
            Util.Stroke(inputBG, T.Border)

            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -16, 1, 0)
            textBox.Position = UDim2.new(0, 8, 0, 0)
            textBox.BackgroundTransparency = 1
            textBox.Text = ""
            textBox.PlaceholderText = placeholder
            textBox.TextSize = 12
            textBox.Font = Enum.Font.Gotham
            textBox.TextColor3 = T.TextPrimary
            textBox.PlaceholderColor3 = T.TextMuted
            textBox.TextXAlignment = Enum.TextXAlignment.Left
            textBox.BorderSizePixel = 0
            textBox.ClearTextOnFocus = false
            textBox.Parent = inputBG

            textBox.Focused:Connect(function()
                Util.TweenPlay(inputBG, { BackgroundColor3 = T.ElementBG }, 0.15)
                Util.Stroke(inputBG, T.Accent, 1)
            end)
            textBox.FocusLost:Connect(function(enterPressed)
                Util.TweenPlay(inputBG, { BackgroundColor3 = T.TertiaryBG }, 0.15)
                if enterPressed then
                    local val = textBox.Text
                    if numeric then val = tonumber(val) or 0 end
                    if flag then Library.Flags[flag] = val end
                    pcall(callback, val)
                end
            end)

            if flag then Library.Flags[flag] = "" end

            local InputObj = {}
            function InputObj:Set(val)
                textBox.Text = tostring(val)
                if flag then Library.Flags[flag] = val end
            end
            function InputObj:Get() return textBox.Text end

            return InputObj
        end

        function Tab:CreateLabel(text, color)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 24)
            container.BackgroundTransparency = 1
            container.BorderSizePixel = 0
            container.Parent = ContentScroll

            local label = Instance.new("TextLabel")
            label.Text = text or ""
            label.TextSize = 12
            label.Font = Enum.Font.Gotham
            label.TextColor3 = color or T.TextSecondary
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -14, 1, 0)
            label.Position = UDim2.new(0, 14, 0, 0)
            label.TextWrapped = true
            label.Parent = container

            local LabelObj = {}
            function LabelObj:Set(t) label.Text = t end
            function LabelObj:Get() return label.Text end

            return LabelObj
        end

        function Tab:CreateDivider(labelText)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 20)
            container.BackgroundTransparency = 1
            container.BorderSizePixel = 0
            container.Parent = ContentScroll

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -28, 0, 1)
            line.AnchorPoint = Vector2.new(0.5, 0.5)
            line.Position = UDim2.new(0.5, 0, 0.5, 0)
            line.BackgroundColor3 = T.Divider
            line.BorderSizePixel = 0
            line.Parent = container

            if labelText then
                local bg = Instance.new("Frame")
                bg.Size = UDim2.new(0, #labelText * 7 + 16, 0, 16)
                bg.AnchorPoint = Vector2.new(0.5, 0.5)
                bg.Position = UDim2.new(0.5, 0, 0.5, 0)
                bg.BackgroundColor3 = T.Background
                bg.BorderSizePixel = 0
                bg.Parent = container

                local lbl = Instance.new("TextLabel")
                lbl.Text = labelText
                lbl.TextSize = 10
                lbl.Font = Enum.Font.GothamBold
                lbl.TextColor3 = T.TextMuted
                lbl.BackgroundTransparency = 1
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                lbl.Parent = bg
            end
        end

        function Tab:CreateSection(name)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 26)
            container.BackgroundTransparency = 1
            container.BorderSizePixel = 0
            container.Parent = ContentScroll

            local label = Instance.new("TextLabel")
            label.Text = string.upper(name or "")
            label.TextSize = 10
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = T.Accent
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -14, 1, 0)
            label.Position = UDim2.new(0, 14, 0, 0)
            label.Parent = container
        end

        return Tab
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    table.insert(Library.Windows, Window)
    return Window
end

function Library:SaveConfig(name)
    if not pcall(function()
        local folder = "NexusLib"
        if not isfolder(folder) then makefolder(folder) end
        local path = folder .. "/" .. (name or "config") .. ".json"
        writefile(path, game:GetService("HttpService"):JSONEncode(Library.Flags))
    end) then
        warn("[NexusLib] SaveConfig failed — writefile may not be available")
    end
end

function Library:LoadConfig(name)
    pcall(function()
        local path = "NexusLib/" .. (name or "config") .. ".json"
        if isfile(path) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(path))
            for k, v in pairs(data) do
                Library.Flags[k] = v
            end
        end
    end)
end

return Library
