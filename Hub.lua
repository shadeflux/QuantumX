-- Quantum X – Full custom black UI + hacks hub (no Rayfield dependency)
-- Fly, Noclip, Speed, Jump, God, ESP, Inf Jump, Teleport to player

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- States
local Toggles = {
    Speed = false,
    HighJump = false,
    Fly = false,
    Noclip = false,
    God = false,
    ESP = false,
    InfJump = false
}

local Connections = {}
local ESPHighlights = {}
local FlyBG, FlyBV
local Flying = false
local BodyVelocitySpeed = 50  -- adjust fly speed

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "QuantumX"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (centered, responsive)
local mf = Instance.new("Frame")
mf.AnchorPoint = Vector2.new(0.5, 0.5)
mf.Position = UDim2.new(0.5, 0, 0.5, 0)
mf.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
mf.BackgroundTransparency = 0.25
mf.BorderSizePixel = 0
mf.Active = true
mf.Draggable = true
mf.Parent = sg

local mc = Instance.new("UICorner", mf)
mc.CornerRadius = UDim.new(0, 16)

local function updateSize()
    local vs = Camera.ViewportSize
    mf.Size = UDim2.new(0, math.clamp(vs.X * 0.4, 380, 620), 0, math.clamp(vs.Y * 0.75, 480, 780))
end
updateSize()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateSize)

local grad = Instance.new("UIGradient", mf)
grad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30,0,60))
}
grad.Rotation = 135

-- Top bar
local top = Instance.new("Frame", mf)
top.Size = UDim2.new(1,0,0,55)
top.BackgroundColor3 = Color3.fromRGB(20,20,35)
top.BorderSizePixel = 0

local tc = Instance.new("UICorner", top)
tc.CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(0.5,0,1,0)
title.Position = UDim2.new(0,15,0,0)
title.BackgroundTransparency = 1
title.Text = "Quantum X"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 26
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left

-- Minimize & Close
local minBtn = Instance.new("TextButton", top)
minBtn.Size = UDim2.new(0,40,0,40)
minBtn.Position = UDim2.new(1,-90,0.5,-20)
minBtn.BackgroundColor3 = Color3.fromRGB(255,180,0)
minBtn.Text = "–"
minBtn.TextColor3 = Color3.new(1,1,1)
minBtn.TextSize = 28
minBtn.Font = Enum.Font.GothamBold

local minc = Instance.new("UICorner", minBtn)
minc.CornerRadius = UDim.new(0,10)

local closeBtn = Instance.new("TextButton", top)
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(1,-45,0.5,-20)
closeBtn.BackgroundColor3 = Color3.fromRGB(220,50,50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold

local closec = Instance.new("UICorner", closeBtn)
closec.CornerRadius = UDim.new(0,10)

-- Scrolling hub content
local scroll = Instance.new("ScrollingFrame", mf)
scroll.Size = UDim2.new(1, -20, 1, -75)
scroll.Position = UDim2.new(0,10,0,65)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.CanvasSize = UDim2.new(0,0,0,800) -- auto later

local list = Instance.new("UIListLayout", scroll)
list.Padding = UDim.new(0,12)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.FillDirection = Enum.FillDirection.Vertical

-- Toggle creator function
local function CreateToggle(name, desc, callbackOn, callbackOff)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,65)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,40)
    frame.BorderSizePixel = 0

    local fc = Instance.new("UICorner", frame)
    fc.CornerRadius = UDim.new(0,12)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0.7,0,0.5,0)
    lbl.Position = UDim2.new(0.03,0,0.1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextSize = 20
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", frame)
    sub.Size = UDim2.new(0.7,0,0.4,0)
    sub.Position = UDim2.new(0.03,0,0.55,0)
    sub.BackgroundTransparency = 1
    sub.Text = desc or ""
    sub.TextColor3 = Color3.fromRGB(180,180,200)
    sub.TextSize = 14
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left

    local tog = Instance.new("TextButton", frame)
    tog.Size = UDim2.new(0,80,0,40)
    tog.Position = UDim2.new(1,-95,0.5,-20)
    tog.BackgroundColor3 = Color3.fromRGB(60,60,70)
    tog.Text = "OFF"
    tog.TextColor3 = Color3.new(1,1,1)
    tog.TextSize = 18
    tog.Font = Enum.Font.GothamBold

    local tc = Instance.new("UICorner", tog)
    tc.CornerRadius = UDim.new(0,20)

    local state = false
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.Text = state and "ON" or "OFF"
        tog.BackgroundColor3 = state and Color3.fromRGB(0,200,80) or Color3.fromRGB(60,60,70)
        if state then callbackOn() else callbackOff() end
    end)

    frame.Parent = scroll
    return frame
end

-- Hacks logic
local function GetChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function EnforceProps()
    local char = GetChar()
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    hum.WalkSpeed = Toggles.Speed and 100 or 16
    hum.JumpPower = Toggles.HighJump and 100 or 50
    hum.MaxHealth = Toggles.God and math.huge or 100
    hum.Health = Toggles.God and math.huge or hum.MaxHealth
end

Connections.Heartbeat = RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    EnforceProps()
end)

LocalPlayer.CharacterAdded:Connect(EnforceProps)

-- Noclip
local function ToggleNoclip(en)
    if en then
        if Connections.Noclip then Connections.Noclip:Disconnect() end
        Connections.Noclip = RunService.Stepped:Connect(function()
            local char = GetChar()
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end)
    else
        if Connections.Noclip then Connections.Noclip:Disconnect() Connections.Noclip = nil end
    end
end

-- Fly
local function StartFly()
    local char = GetChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    Flying = true

    FlyBG = Instance.new("BodyGyro", hrp)
    FlyBG.P = 9e4
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.CFrame = hrp.CFrame

    FlyBV = Instance.new("BodyVelocity", hrp)
    FlyBV.Velocity = Vector3.new()
    FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    Connections.FlyInput = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.KeyCode == Enum.KeyCode.W then FlyBV.Velocity = (Camera.CFrame.LookVector * BodyVelocitySpeed) end
        if inp.KeyCode == Enum.KeyCode.S then FlyBV.Velocity = (Camera.CFrame.LookVector * -BodyVelocitySpeed) end
        if inp.KeyCode == Enum.KeyCode.A then FlyBV.Velocity = (Camera.CFrame.RightVector * -BodyVelocitySpeed) end
        if inp.KeyCode == Enum.KeyCode.D then FlyBV.Velocity = (Camera.CFrame.RightVector * BodyVelocitySpeed) end
        if inp.KeyCode == Enum.KeyCode.Space then FlyBV.Velocity = Vector3.new(0, BodyVelocitySpeed, 0) end
        if inp.KeyCode == Enum.KeyCode.LeftControl then FlyBV.Velocity = Vector3.new(0, -BodyVelocitySpeed, 0) end
    end)

    Connections.FlyInputEnd = UserInputService.InputEnded:Connect(function(inp)
        if inp.KeyCode == Enum.KeyCode.W or inp.KeyCode == Enum.KeyCode.S or inp.KeyCode == Enum.KeyCode.A or inp.KeyCode == Enum.KeyCode.D or inp.KeyCode == Enum.KeyCode.Space or inp.KeyCode == Enum.KeyCode.LeftControl then
            FlyBV.Velocity = Vector3.new()
        end
    end)
end

local function StopFly()
    Flying = false
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if Connections.FlyInput then Connections.FlyInput:Disconnect() Connections.FlyInput = nil end
    if Connections.FlyInputEnd then Connections.FlyInputEnd:Disconnect() Connections.FlyInputEnd = nil end
end

-- ESP
local function AddESP(plr)
    if plr == LocalPlayer or not plr.Character then return end
    local hl = Instance.new("Highlight")
    hl.Name = "QX_ESP"
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(255,60,60)
    hl.OutlineColor = Color3.fromRGB(255,255,255)
    hl.FillTransparency = 0.35
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = plr.Character
    ESPHighlights[plr] = hl
end

local function ToggleESP(en)
    if en then
        for _, plr in ipairs(Players:GetPlayers()) do AddESP(plr) end
        Connections.PlayerAdded = Players.PlayerAdded:Connect(AddESP)
        Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
            if ESPHighlights[plr] then ESPHighlights[plr]:Destroy() ESPHighlights[plr] = nil end
        end)
        Connections.CharAdded = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then AddESP(plr) end
            Connections.CharAdded[plr] = plr.CharacterAdded:Connect(function() if Toggles.ESP then AddESP(plr) end end)
        end
    else
        for _, hl in pairs(ESPHighlights) do if hl then hl:Destroy() end end
        ESPHighlights = {}
        for _, conn in pairs(Connections) do
            if conn and typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
        end
        Connections.PlayerAdded = nil
        Connections.PlayerRemoving = nil
        for _, c in pairs(Connections.CharAdded or {}) do if c then c:Disconnect() end end
        Connections.CharAdded = {}
    end
end

-- Inf Jump
local function ToggleInfJump(en)
    if en then
        Connections.InfJump = UserInputService.JumpRequest:Connect(function()
            local hum = GetChar():FindFirstChild("Humanoid")
            if hum then hum:ChangeState("Jumping") end
        end)
    else
        if Connections.InfJump then Connections.InfJump:Disconnect() Connections.InfJump = nil end
    end
end

-- Teleport to nearest player
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1, -20, 0, 50)
tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tpBtn.Text = "Teleport do najbliższego gracza"
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.TextSize = 20
tpBtn.Font = Enum.Font.GothamBold

local tpc = Instance.new("UICorner", tpBtn)
tpc.CornerRadius = UDim.new(0,12)

tpBtn.MouseButton1Click:Connect(function()
    local char = GetChar()
    if not char or not char.PrimaryPart then return end
    local root = char.PrimaryPart
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr \~= LocalPlayer and plr.Character and plr.Character.PrimaryPart then
            local d = (root.Position - plr.Character.PrimaryPart.Position).Magnitude
            if d < dist then dist = d closest = plr end
        end
    end
    if closest and closest.Character and closest.Character.PrimaryPart then
        root.CFrame = closest.Character.PrimaryPart.CFrame * CFrame.new(0,5,0)
    end
end)

tpBtn.Parent = scroll

-- Tworzymy toggles
CreateToggle("Szybkość x6", "WalkSpeed = 100", function() Toggles.Speed = true EnforceProps() end, function() Toggles.Speed = false EnforceProps() end)
CreateToggle("Super Skok", "JumpPower = 100", function() Toggles.HighJump = true EnforceProps() end, function() Toggles.HighJump = false EnforceProps() end)
CreateToggle("Latanie (WASD + Space/Ctrl)", "Klasyczne fly", function() Toggles.Fly = true StartFly() end, function() Toggles.Fly = false StopFly() end)
CreateToggle("NoClip", "Przechodzenie przez ściany", function() Toggles.Noclip = true ToggleNoclip(true) end, function() Toggles.Noclip = false ToggleNoclip(false) end)
CreateToggle("God Mode", "Nieśmiertelność", function() Toggles.God = true EnforceProps() end, function() Toggles.God = false EnforceProps() end)
CreateToggle("ESP (czerwone podświetlenie)", "Widzisz wszystkich graczy", function() Toggles.ESP = true ToggleESP(true) end, function() Toggles.ESP = false ToggleESP(false) end)
CreateToggle("Nieskończone Skoki", "Spam spacja = lataj", function() Toggles.InfJump = true ToggleInfJump(true) end, function() Toggles.InfJump = false ToggleInfJump(false) end)

-- Minimize / Close
minBtn.MouseButton1Click:Connect(function()
    mf.Visible = false
    local icon = Instance.new("ImageButton") -- możesz dodać ikonkę później
    icon.Size = UDim2.new(0,60,0,60)
    icon.Position = UDim2.new(0,20,1,-80)
    icon.BackgroundColor3 = Color3.fromRGB(0,170,255)
    icon.Parent = sg
    icon.MouseButton1Click:Connect(function() mf.Visible = true icon:Destroy() end)
end)

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

-- Cleanup on leave/destroy
LocalPlayer.CharacterRemoving:Connect(function()
    StopFly()
    ToggleNoclip(false)
    ToggleESP(false)
    ToggleInfJump(false)
end)

game:BindToClose(function()
    sg:Destroy()
end)

print("Quantum X loaded – custom UI + hacks ready")
