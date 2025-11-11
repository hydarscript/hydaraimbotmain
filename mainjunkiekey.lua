Config = {
    api = "b28acab6-623e-49ba-8d42-c61f0304e266",
    service = "daddy hydar",
    provider = "key"
}

local function main()
    -- PROTECTION: Prevent double execution
    if getgenv().MainScriptLoaded then
        warn("[KEY SYSTEM] Main script already loaded!")
        return
    end
    getgenv().MainScriptLoaded = true

    -- Main script here
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hydarscript/hydaraimbot/refs/heads/main/pvpbykimito.lua"))()
end

-- PROTECTION: Prevent multiple instances of key system
if getgenv().RedExecutorKeySys then
    warn("[KEY SYSTEM] Already running!")
    return
end
getgenv().RedExecutorKeySys = true

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- Enhanced Configuration with Rainbow Theme
local KeySystemData = {
    Name = "Daddy Hydar",
    Colors = {
        Background = Color3.fromRGB(15, 15, 20),
        Title = Color3.fromRGB(255, 255, 255),
        InputField = Color3.fromRGB(20, 20, 25),
        InputFieldBorder = Color3.fromRGB(100, 100, 120),
        Button = Color3.fromRGB(25, 25, 35),
        ButtonHover = Color3.fromRGB(40, 40, 50),
        Error = Color3.fromRGB(255, 80, 80),
        Success = Color3.fromRGB(80, 255, 120),
        Discord = Color3.fromRGB(88, 101, 242),
        RainbowSpeed = 2
    },
    Service = "redexecutor",
    SilentMode = false,
    DiscordInvite = "enterdiscordinvite",
    WebsiteURL = "https://yourwebsite.com/",
    FileName = "redexecutor/key.txt"
}

local function CreateObject(class, props)
    local obj = Instance.new(class)
    for prop, value in pairs(props) do
        if prop ~= "Parent" then
            obj[prop] = value
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function SmoothTween(obj, time, properties)
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

-- Rainbow Color Generator
local function GetRainbowColor(offset)
    local hue = (tick() * KeySystemData.Colors.RainbowSpeed + (offset or 0)) % 255
    return Color3.fromHSV(hue / 255, 1, 1)
end

-- ===== Subtle Text Glow Helper (no white borders) ============================
-- Creates a behind-the-text clone that gently pulses and (optionally) follows
-- the rainbow hue. Removes any white outline from the main text.
local function ApplyTextGlow(txt, opts)
    if not txt or not txt.Parent then return end
    opts = opts or {}
    local strength = opts.strength or 2      -- pixel-ish expand
    local minAlpha = opts.minAlpha or 0.70   -- more opaque edge of glow
    local maxAlpha = opts.maxAlpha or 0.45   -- more transparent edge while pulsing
    local rainbow  = (opts.rainbow == nil) and true or opts.rainbow
    local color    = opts.color or Color3.fromRGB(255, 255, 255)

    -- nuke any outline on the original text
    pcall(function()
        txt.TextStrokeTransparency = 1
        txt.TextStrokeColor3 = txt.TextColor3
    end)

    -- make a glow clone that sits behind
    local glow = txt:Clone()
    glow.Name = (txt.Name .. "_Glow")
    glow.TextStrokeTransparency = 1
    glow.TextTransparency = minAlpha
    glow.TextColor3 = rainbow and GetRainbowColor(0) or color
    glow.ZIndex = (txt.ZIndex or 1) - 1
    glow.BackgroundTransparency = 1
    glow.Size = txt.Size + UDim2.new(0, strength, 0, strength)
    glow.Position = txt.Position
    glow.AnchorPoint = txt.AnchorPoint
    glow.Parent = txt.Parent

    -- keep glow synced
    txt:GetPropertyChangedSignal("Text"):Connect(function() glow.Text = txt.Text end)
    txt:GetPropertyChangedSignal("Visible"):Connect(function() glow.Visible = txt.Visible end)
    txt:GetPropertyChangedSignal("Position"):Connect(function() glow.Position = txt.Position end)
    txt:GetPropertyChangedSignal("Size"):Connect(function()
        glow.Size = txt.Size + UDim2.new(0, strength, 0, strength)
    end)
    txt:GetPropertyChangedSignal("TextColor3"):Connect(function()
        if not rainbow then glow.TextColor3 = color end
    end)

    -- gentle pulse + optional rainbow hue follow
    local pulse
    pulse = RunService.RenderStepped:Connect(function()
        if not txt.Parent or not glow.Parent then
            if pulse then pulse:Disconnect() end
            return
        end
        local t = tick()
        local a = maxAlpha + (minAlpha - maxAlpha) * (0.5 + 0.5 * math.sin(t * 1.5))
        glow.TextTransparency = a
        if rainbow then
            glow.TextColor3 = GetRainbowColor(0)
        end
    end)

    -- auto-cleanup if either is destroyed
    txt.AncestryChanged:Connect(function(_, parent)
        if not parent and pulse then
            pulse:Disconnect()
        end
    end)
    glow.AncestryChanged:Connect(function(_, parent)
        if not parent and pulse then
            pulse:Disconnect()
        end
    end)

    return glow
end
-- ============================================================================

local ScreenGui = CreateObject("ScreenGui", {
    Name = "RedExecutorKeySystem",
    Parent = CoreGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999
})

local MainFrame = CreateObject("Frame", {
    Name = "MainFrame",
    Parent = ScreenGui,
    BackgroundColor3 = KeySystemData.Colors.Background,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 380, 0, 280),
    ClipsDescendants = true
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 12), Parent = MainFrame })

-- Rainbow Border
local RainbowBorder = CreateObject("UIStroke", {
    Parent = MainFrame,
    Color = Color3.fromRGB(255, 0, 0),
    Thickness = 3,
    Transparency = 0
})

-- Animated Rainbow Border
local rainbowConnection
rainbowConnection = RunService.RenderStepped:Connect(function()
    if not MainFrame or not MainFrame.Parent then
        rainbowConnection:Disconnect()
        return
    end
    RainbowBorder.Color = GetRainbowColor(0)
end)

-- Gradient Background
local Gradient = CreateObject("UIGradient", {
    Parent = MainFrame,
    Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
    },
    Rotation = 45
})

local TitleBar = CreateObject("Frame", {
    Name = "TitleBar",
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    Size = UDim2.new(1, 0, 0, 40),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0, 0)
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 12), Parent = TitleBar })

-- Title with Rainbow Text Effect
local Title = CreateObject("TextLabel", {
    Name = "Title",
    Parent = TitleBar,
    BackgroundTransparency = 1,
    Text = KeySystemData.Name .. " Key System",
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Size = UDim2.new(0, 250, 0, 25),
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    TextXAlignment = Enum.TextXAlignment.Center,
    AnchorPoint = Vector2.new(0.5, 0.5),
    TextStrokeTransparency = 1 -- no outline
})

-- Rainbow Title Gradient
local TitleGradient = CreateObject("UIGradient", {
    Parent = Title,
    Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    }
})

-- Animate Title Gradient
local titleConnection
titleConnection = RunService.RenderStepped:Connect(function()
    if not Title or not Title.Parent then
        titleConnection:Disconnect()
        return
    end
    TitleGradient.Rotation = (tick() * 50) % 360
end)

-- Decorative Line under Title
local TitleLine = CreateObject("Frame", {
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    Position = UDim2.new(0.1, 0, 0.16, 0),
    Size = UDim2.new(0.8, 0, 0, 2)
})
local TitleLineGradient = CreateObject("UIGradient", {
    Parent = TitleLine,
    Color = ColorSequence.new {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 255))
    }
})

local KeyInput = CreateObject("TextBox", {
    Name = "KeyInput",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.InputField,
    Text = "",
    PlaceholderText = "Enter your key here...",
    Position = UDim2.new(0.5, 0, 0.32, 0),
    Size = UDim2.new(0, 300, 0, 40),
    Font = Enum.Font.GothamMedium,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    PlaceholderColor3 = Color3.fromRGB(140, 140, 140),
    TextXAlignment = Enum.TextXAlignment.Left,
    AnchorPoint = Vector2.new(0.5, 0),
    ClipsDescendants = true,
    ClearTextOnFocus = false,
    TextStrokeTransparency = 1 -- no outline
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 8), Parent = KeyInput })
local KeyInputStroke = CreateObject("UIStroke", {
    Parent = KeyInput,
    Color = KeySystemData.Colors.InputFieldBorder,
    Thickness = 2,
    Transparency = 0.5
})
CreateObject("UIPadding", {
    Parent = KeyInput,
    PaddingLeft = UDim.new(0, 12)
})

local SubmitButton = CreateObject("TextButton", {
    Name = "ValidateButton",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Button,
    BorderSizePixel = 0,
    Position = UDim2.new(0.3, 0, 0.58, 0),
    Size = UDim2.new(0, 120, 0, 38),
    Text = "✓ Verify Key",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0),
    TextStrokeTransparency = 1 -- no outline
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 8), Parent = SubmitButton })
local SubmitStroke = CreateObject("UIStroke", {
    Parent = SubmitButton,
    Color = Color3.fromRGB(255, 0, 0),
    Thickness = 2,
    Transparency = 0
})

local GetKeyButton = CreateObject("TextButton", {
    Name = "GetKeyButton",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Button,
    BorderSizePixel = 0,
    Position = UDim2.new(0.7, 0, 0.58, 0),
    Size = UDim2.new(0, 120, 0, 38),
    Text = "🔑 Get Key",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0),
    TextStrokeTransparency = 1 -- no outline
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 8), Parent = GetKeyButton })
local GetKeyStroke = CreateObject("UIStroke", {
    Parent = GetKeyButton,
    Color = Color3.fromRGB(0, 255, 0),
    Thickness = 2,
    Transparency = 0
})

local DiscordButton = CreateObject("TextButton", {
    Name = "DiscordButton",
    Parent = MainFrame,
    BackgroundColor3 = KeySystemData.Colors.Discord,
    Position = UDim2.new(0.5, 0, 0.78, 0),
    Size = UDim2.new(0, 240, 0, 38),
    Text = "💬 Join Discord",
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    AutoButtonColor = false,
    AnchorPoint = Vector2.new(0.5, 0),
    TextStrokeTransparency = 1 -- no outline
})
CreateObject("UICorner", { CornerRadius = UDim.new(0, 8), Parent = DiscordButton })
local DiscordStroke = CreateObject("UIStroke", {
    Parent = DiscordButton,
    Color = Color3.fromRGB(114, 137, 218),
    Thickness = 2,
    Transparency = 0.5
})

-- Animate Button Borders (renamed to avoid collision with click connections)
local submitBorderConnection, getKeyBorderConnection
submitBorderConnection = RunService.RenderStepped:Connect(function()
    if not SubmitButton or not SubmitButton.Parent then
        if submitBorderConnection then submitBorderConnection:Disconnect() end
        return
    end
    SubmitStroke.Color = GetRainbowColor(0)
end)

getKeyBorderConnection = RunService.RenderStepped:Connect(function()
    if not GetKeyButton or not GetKeyButton.Parent then
        if getKeyBorderConnection then getKeyBorderConnection:Disconnect() end
        return
    end
    GetKeyStroke.Color = GetRainbowColor(100)
end)

local StatusLabel = CreateObject("TextLabel", {
    Name = "StatusLabel",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 0.93, 0),
    Size = UDim2.new(0, 300, 0, 20),
    Font = Enum.Font.GothamMedium,
    Text = "",
    TextColor3 = KeySystemData.Colors.Error,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Center,
    AnchorPoint = Vector2.new(0.5, 0),
    TextTransparency = 1,
    TextStrokeTransparency = 1 -- no outline
})

-- Apply the glow to text elements (subtle)
ApplyTextGlow(Title,        { strength = 3, minAlpha = 0.70, maxAlpha = 0.45, rainbow = true })
ApplyTextGlow(StatusLabel,  { strength = 2, minAlpha = 0.80, maxAlpha = 0.55, rainbow = false, color = Color3.fromRGB(220, 220, 255) })
ApplyTextGlow(SubmitButton, { strength = 2, minAlpha = 0.75, maxAlpha = 0.5,  rainbow = true })
ApplyTextGlow(GetKeyButton, { strength = 2, minAlpha = 0.75, maxAlpha = 0.5,  rainbow = true })
ApplyTextGlow(DiscordButton,{ strength = 2, minAlpha = 0.78, maxAlpha = 0.52, rainbow = false, color = Color3.fromRGB(190, 200, 255) })
ApplyTextGlow(KeyInput,     { strength = 2, minAlpha = 0.82, maxAlpha = 0.6,  rainbow = false, color = Color3.fromRGB(220, 220, 255) })

local function ShowStatusMessage(text, color)
    StatusLabel.Text = text
    StatusLabel.TextColor3 = color
    StatusLabel.TextTransparency = 0
    SmoothTween(StatusLabel, 0.3, { TextTransparency = 0 })

    task.spawn(function()
        task.wait(3)
        if StatusLabel.Text == text then
            SmoothTween(StatusLabel, 0.5, { TextTransparency = 1 })
        end
    end)
end

local function AddHoverEffect(button)
    button.MouseEnter:Connect(function()
        SmoothTween(button, 0.2, {
            BackgroundColor3 = KeySystemData.Colors.ButtonHover,
            Size = button.Size + UDim2.new(0, 4, 0, 2)
        })
    end)

    button.MouseLeave:Connect(function()
        SmoothTween(button, 0.2, {
            BackgroundColor3 = KeySystemData.Colors.Button,
            Size = button.Size - UDim2.new(0, 4, 0, 2)
        })
    end)
end

AddHoverEffect(SubmitButton)
AddHoverEffect(GetKeyButton)

KeyInput.Focused:Connect(function()
    local focusConnection
    focusConnection = RunService.RenderStepped:Connect(function()
        if not KeyInput or not KeyInput.Parent or not KeyInput:IsFocused() then
            if focusConnection then focusConnection:Disconnect() end
            KeyInputStroke.Color = KeySystemData.Colors.InputFieldBorder
            KeyInputStroke.Transparency = 0.5
            return
        end
        KeyInputStroke.Color = GetRainbowColor(0)
        KeyInputStroke.Transparency = 0
    end)
end)

KeyInput.FocusLost:Connect(function()
    SmoothTween(KeyInputStroke, 0.2, {
        Color = KeySystemData.Colors.InputFieldBorder,
        Transparency = 0.5
    })
end)

local function openGetKey()
    -- PROTECTION: Check if already getting key
    if getgenv().GettingKey then
        ShowStatusMessage("Already generating link...", Color3.fromRGB(255, 165, 0))
        return
    end
    getgenv().GettingKey = true

    local success, result = pcall(function()
        local JunkieKeySystem = loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()

        local API_KEY = Config.api
        local PROVIDER = Config.provider
        local SERVICE = Config.service

        local link = JunkieKeySystem.getLink(API_KEY, PROVIDER, SERVICE)
        return link
    end)

    getgenv().GettingKey = false

    if success and result then
        if setclipboard then
            setclipboard(result)
            ShowStatusMessage("✓ Verification link copied to clipboard!", KeySystemData.Colors.Success)
        else
            ShowStatusMessage("Link: " .. tostring(result), KeySystemData.Colors.Success)
        end
    else
        ShowStatusMessage("✗ Failed to generate link. Try again!", KeySystemData.Colors.Error)
    end
end

local function validateKey()
    -- PROTECTION: Prevent multiple validation attempts
    if getgenv().ValidatingKey then
        ShowStatusMessage("Already validating...", Color3.fromRGB(255, 165, 0))
        return
    end
    getgenv().ValidatingKey = true

    local userKey = (KeyInput.Text or ""):gsub("%s+", "")
    if userKey == "" then
        getgenv().ValidatingKey = false
        ShowStatusMessage("⚠ Please enter a key first!", KeySystemData.Colors.Error)
        return
    end

    ShowStatusMessage("⏳ Validating key...", Color3.fromRGB(255, 200, 0))

    local success, isValid = pcall(function()
        local JunkieKeySystem = loadstring(game:HttpGet("https://junkie-development.de/sdk/JunkieKeySystem.lua"))()

        local API_KEY = Config.api
        local SERVICE = Config.service

        return JunkieKeySystem.verifyKey(API_KEY, userKey, SERVICE)
    end)

    if not success then
        getgenv().ValidatingKey = false
        ShowStatusMessage("✗ Verification error! Check your connection.", KeySystemData.Colors.Error)
        return
    end

    if isValid then
        ShowStatusMessage("✓ Key valid! Loading script...", KeySystemData.Colors.Success)

        -- Disconnect all rainbow effects before destroying
        if rainbowConnection then rainbowConnection:Disconnect() end
        if titleConnection then titleConnection:Disconnect() end
        if submitBorderConnection then submitBorderConnection:Disconnect() end
        if getKeyBorderConnection then getKeyBorderConnection:Disconnect() end

        SmoothTween(MainFrame, 0.5, {
            Position = UDim2.new(0.5, 0, -0.5, 0),
            BackgroundTransparency = 1
        })

        task.wait(0.6)
        ScreenGui:Destroy()

        -- Execute main script
        main()
    else
        getgenv().ValidatingKey = false
        ShowStatusMessage("✗ Invalid key! Please try again.", KeySystemData.Colors.Error)
    end
end

-- Connect button events (separate from border anim connections)
local submitClickConnection = SubmitButton.MouseButton1Click:Connect(validateKey)
local getKeyClickConnection = GetKeyButton.MouseButton1Click:Connect(openGetKey)

-- Dragging functionality
local dragging, dragInput, dragStart, startPos
local function onInputChanged(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(onInputChanged)

DiscordButton.MouseButton1Click:Connect(function()
    local discordUrl = "https://discord.gg/nUjVcV8R9j"

    if setclipboard then
        setclipboard(discordUrl)
        ShowStatusMessage("💬 Discord invite copied to clipboard!", Color3.fromRGB(123, 48, 220))
    else
        ShowStatusMessage("Join: " .. discordUrl, Color3.fromRGB(123, 48, 220))
    end
end)

KeyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateKey()
    end
end)

-- Entrance animation
MainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1

SmoothTween(MainFrame, 0.6, {
    Size = UDim2.new(0, 380, 0, 280),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0
})

print("[KEY SYSTEM] Loaded successfully with enhanced UI (no text borders + subtle glow)!")
