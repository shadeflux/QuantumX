-- Quantum X – WSZYSTKO W JEDNYM PLIKU (natywne UI, bez zewnętrznych bibliotek)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Główny Frame – czarny, prostokątny, responsywny
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
MainFrame.BackgroundTransparency = 0.3  -- 70% widoczności
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)  -- prostokątne, lekko zaokrąglone
UICorner.Parent = MainFrame

-- Gradient tła (czarny → ciemny)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 0, 40))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Responsywność – mniejsze na telefonie
local function UpdateSize()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.78, 280, 520)
    local height = math.clamp(screenSize.Y * 0.68, 340, 600)
    MainFrame.Size = UDim2.new(0, width, 0, height)
end

UpdateSize()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateSize)

-- Tytuł – biały
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 32
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

-- Przyciski X i –
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -75, 0, 10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame

-- Mały przycisk po minimalizacji
local MinimizeIcon = Instance.new("TextButton")
MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
MinimizeIcon.Position = UDim2.new(0, 20, 1, -70)
MinimizeIcon.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
MinimizeIcon.Text = "QX"
MinimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeIcon.TextSize = 16
MinimizeIcon.Font = Enum.Font.GothamBold
MinimizeIcon.Visible = false
MinimizeIcon.Parent = ScreenGui

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(1, 0)
UICornerMin.Parent = MinimizeIcon

-- Zmienne funkcji
local speedEnabled = false
local defaultSpeed = 16
local customSpeed = 32
local flinging = false
local antifling = nil
local infiniteJumpEnabled = false
local noclipEnabled = false
local spectating = false

-- Funkcje pomocnicze
local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
end

local function getPlayerFromName(name)
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():match("^" .. name:lower()) or player.DisplayName:lower():match("^" .. name:lower()) then
            return player
        end
    end
    return nil
end

-- ==================== BUTTONY FUNKCJI ====================

local yOffset = 0.15
local buttonHeight = 0.1

-- Speed Hack
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
SpeedButton.Position = UDim2.new(0.1, 0, yOffset, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpeedButton.Text = "Speed Hack (WYŁ)"
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.TextSize = 18
SpeedButton.Font = Enum.Font.GothamSemibold
SpeedButton.Parent = MainFrame

local UICornerSpeed = Instance.new("UICorner")
UICornerSpeed.CornerRadius = UDim.new(0, 10)
UICornerSpeed.Parent = SpeedButton

SpeedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speedEnabled and customSpeed or defaultSpeed
    end
    SpeedButton.Text = "Speed Hack (" .. (speedEnabled and "WŁ" or "WYŁ") .. ")"
end)

yOffset = yOffset + buttonHeight + 0.015

-- Infinite Jump
local InfJumpButton = Instance.new("TextButton")
InfJumpButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
InfJumpButton.Position = UDim2.new(0.1, 0, yOffset, 0)
InfJumpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
InfJumpButton.Text = "Infinite Jump (WYŁ)"
InfJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpButton.TextSize = 18
InfJumpButton.Font = Enum.Font.GothamSemibold
InfJumpButton.Parent = MainFrame

local UICornerInf = Instance.new("UICorner")
UICornerInf.CornerRadius = UDim.new(0, 10)
UICornerInf.Parent = InfJumpButton

InfJumpButton.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    InfJumpButton.Text = "Infinite Jump (" .. (infiniteJumpEnabled and "WŁ" or "WYŁ") .. ")"
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

yOffset = yOffset + buttonHeight + 0.015

-- NoClip
local NoClipButton = Instance.new("TextButton")
NoClipButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
NoClipButton.Position = UDim2.new(0.1, 0, yOffset, 0)
NoClipButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
NoClipButton.Text = "NoClip (WYŁ)"
NoClipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipButton.TextSize = 18
NoClipButton.Font = Enum.Font.GothamSemibold
NoClipButton.Parent = MainFrame

local UICornerNoClip = Instance.new("UICorner")
UICornerNoClip.CornerRadius = UDim.new(0, 10)
UICornerNoClip.Parent = NoClipButton

NoClipButton.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    NoClipButton.Text = "NoClip (" .. (noclipEnabled and "WŁ" or "WYŁ") .. ")"
end)

spawn(function()
    while true do
        if noclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end)

yOffset = yOffset + buttonHeight + 0.015

-- Fling
local FlingButton = Instance.new("TextButton")
FlingButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
FlingButton.Position = UDim2.new(0.1, 0, yOffset, 0)
FlingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
FlingButton.Text = "Fling (WYŁ)"
FlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.TextSize = 18
FlingButton.Font = Enum.Font.GothamSemibold
FlingButton.Parent = MainFrame

local UICornerFling = Instance.new("UICorner")
UICornerFling.CornerRadius = UDim.new(0, 10)
UICornerFling.Parent = FlingButton

FlingButton.MouseButton1Click:Connect(function()
    flinging = not flinging
    FlingButton.Text = "Fling (" .. (flinging and "WŁ" or "WYŁ") .. ")"

    if flinging then
        local char = LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                    v.Massless = true
                end
            end
            local bv = Instance.new("BodyAngularVelocity")
            bv.AngularVelocity = Vector3.new(0,99999,0)
            bv.MaxTorque = Vector3.new(0,math.huge,0)
            bv.Parent = getRoot(char)
            spawn(function()
                while flinging do
                    bv.AngularVelocity = Vector3.new(0,99999,0)
                    task.wait(0.2)
                    bv.AngularVelocity = Vector3.new(0,0,0)
                    task.wait(0.1)
                end
                bv:Destroy()
            end)
        end
    end
end)

yOffset = yOffset + buttonHeight + 0.015

-- Anti Fling
local AntiFlingButton = Instance.new("TextButton")
AntiFlingButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
AntiFlingButton.Position = UDim2.new(0.1, 0, yOffset, 0)
AntiFlingButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AntiFlingButton.Text = "Anti Fling (WYŁ)"
AntiFlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFlingButton.TextSize = 18
AntiFlingButton.Font = Enum.Font.GothamSemibold
AntiFlingButton.Parent = MainFrame

local UICornerAnti = Instance.new("UICorner")
UICornerAnti.CornerRadius = UDim.new(0, 10)
UICornerAnti.Parent = AntiFlingButton

AntiFlingButton.MouseButton1Click:Connect(function()
    if antifling then
        antifling:Disconnect()
        antifling = nil
        AntiFlingButton.Text = "Anti Fling (WYŁ)"
    else
        antifling = RunService.Stepped:Connect(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p \~= LocalPlayer and p.Character then
                    for _, v in pairs(p.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
        end)
        AntiFlingButton.Text = "Anti Fling (WŁ)"
    end
end)

yOffset = yOffset + buttonHeight + 0.015

-- Teleport do gracza
local TpInput = Instance.new("TextBox")
TpInput.Size = UDim2.new(0.8, 0, 0, 50)
TpInput.Position = UDim2.new(0.1, 0, yOffset, 0)
TpInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
TpInput.PlaceholderText = "Nick gracza do TP"
TpInput.Text = ""
TpInput.Parent = MainFrame

local TpButton = Instance.new("TextButton")
TpButton.Size = UDim2.new(0.8, 0, 0, 50)
TpButton.Position = UDim2.new(0.1, 0, yOffset + 0.1, 0)
TpButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TpButton.Text = "Teleportuj"
TpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TpButton.TextSize = 18
TpButton.Font = Enum.Font.GothamSemibold
TpButton.Parent = MainFrame

local UICornerTp = Instance.new("UICorner")
UICornerTp.CornerRadius = UDim.new(0, 10)
UICornerTp.Parent = TpButton

TpButton.MouseButton1Click:Connect(function()
    local target = getPlayerFromName(TpInput.Text)
    if target and target.Character and getRoot(target.Character) then
        getRoot(LocalPlayer.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(0, 3, 0)
    else
        TpButton.Text = "Gracz nie znaleziony"
        task.delay(2, function()
            TpButton.Text = "Teleportuj"
        end)
    end
end)

yOffset = yOffset + buttonHeight + 0.1

-- Obserwuj gracza
local SpectateInput = Instance.new("TextBox")
SpectateInput.Size = UDim2.new(0.8, 0, 0, 50)
SpectateInput.Position = UDim2.new(0.1, 0, yOffset, 0)
SpectateInput.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
SpectateInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpectateInput.PlaceholderText = "Nick gracza do obserwacji"
SpectateInput.Text = ""
SpectateInput.Parent = MainFrame

local SpectateButton = Instance.new("TextButton")
SpectateButton.Size = UDim2.new(0.8, 0, 0, 50)
SpectateButton.Position = UDim2.new(0.1, 0, yOffset + 0.1, 0)
SpectateButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
SpectateButton.Text = "Obserwuj"
SpectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpectateButton.TextSize = 18
SpectateButton.Font = Enum.Font.GothamSemibold
SpectateButton.Parent = MainFrame

local UICornerSpect = Instance.new("UICorner")
UICornerSpect.CornerRadius = UDim.new(0, 10)
UICornerSpect.Parent = SpectateButton

SpectateButton.MouseButton1Click:Connect(function()
    local target = getPlayerFromName(SpectateInput.Text)
    if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
        Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
        spectating = true
    else
        SpectateButton.Text = "Gracz nie znaleziony"
        task.delay(2, function()
            SpectateButton.Text = "Obserwuj"
        end)
    end
end)

-- Zakończ obserwację
local StopSpectateButton = Instance.new("TextButton")
StopSpectateButton.Size = UDim2.new(0.8, 0, 0, 50)
StopSpectateButton.Position = UDim2.new(0.1, 0, yOffset + 0.2, 0)
StopSpectateButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
StopSpectateButton.Text = "Zakończ obserwację"
StopSpectateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopSpectateButton.TextSize = 18
StopSpectateButton.Font = Enum.Font.GothamSemibold
StopSpectateButton.Parent = MainFrame

local UICornerStop = Instance.new("UICorner")
UICornerStop.CornerRadius = UDim.new(0, 10)
UICornerStop.Parent = StopSpectateButton

StopSpectateButton.MouseButton1Click:Connect(function()
    if spectating then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        spectating = false
    end
end)

-- Anti AFK
local AntiAFKButton = Instance.new("TextButton")
AntiAFKButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
AntiAFKButton.Position = UDim2.new(0.1, 0, yOffset + 0.3, 0)
AntiAFKButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AntiAFKButton.Text = "Anti AFK (WYŁ)"
AntiAFKButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiAFKButton.TextSize = 18
AntiAFKButton.Font = Enum.Font.GothamSemibold
AntiAFKButton.Parent = MainFrame

local UICornerAntiAFK = Instance.new("UICorner")
UICornerAntiAFK.CornerRadius = UDim.new(0, 10)
UICornerAntiAFK.Parent = AntiAFKButton

AntiAFKButton.MouseButton1Click:Connect(function()
    if game:GetService("VirtualUser") then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
        AntiAFKButton.Text = "Anti AFK (WŁ)"
    end
end)

-- Minimize i Close
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MinimizeIcon.Visible = true
end)

MinimizeIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    MinimizeIcon.Visible = false
end)

print("Quantum X – czarne, natywne UI załadowane")
