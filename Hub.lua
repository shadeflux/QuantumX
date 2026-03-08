-- Quantum X – NATYWNE UI W STYLU FLUENT (czarne, gradient, neon, responsywne)

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

-- Główny Frame (Fluent-like – czarny z gradientem)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
MainFrame.BackgroundTransparency = 0.25  -- Fluent acrylic vibe
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Gradient tła (Fluent style – ciemny do jaśniejszego)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 20, 60))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Neon glow (jak w Fluent/Aether)
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 60, 1, 60)
Glow.Position = UDim2.new(0, -30, 0, -30)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://6014261993" -- neon glow asset
Glow.ImageColor3 = Color3.fromRGB(0, 180, 255)
Glow.ImageTransparency = 0.65
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(49,49,450,450)
Glow.Parent = MainFrame

-- Responsywność (mniejsze na telefonie)
local function UpdateSize()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.75, 280, 520)
    local height = math.clamp(screenSize.Y * 0.65, 340, 600)
    MainFrame.Size = UDim2.new(0, width, 0, height)
end

UpdateSize()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateSize)

-- Tytuł (biały, neonowy)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 34
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.7
Title.TextStrokeColor3 = Color3.fromRGB(0, 180, 255)
Title.Parent = MainFrame

-- Przyciski X i –
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -75, 0, 15)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame

-- Mały przycisk po minimize
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

-- ==================== FUNKCJE ====================

-- Zmienne
local speedEnabled = false
local defaultSpeed = 16
local customSpeed = 32
local infiniteJumpEnabled = false
local noclipEnabled = false
local flinging = false
local antiflingConn = nil
local spawnpoint = false
local spawnpos = nil
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

-- ==================== BUTTONY / TOGGLE ====================

local yOffset = 0.18
local buttonHeight = 0.1

-- Speed Hack
local SpeedButton = Instance.new("TextButton")
SpeedButton.Size = UDim2.new(0.8, 0, buttonHeight, 0)
SpeedButton.Position = UDim2.new(0.1, 0, yOffset, 0)
SpeedButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
SpeedButton.Text = "Speed Hack (WYŁ)"
SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedButton.TextSize = 18
SpeedButton.Font = Enum.Font.GothamSemibold
SpeedButton.Parent = MainFrame

local UICornerSpeed = Instance.new("UICorner")
UICornerSpeed.CornerRadius = UDim.new(0, 8)
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
InfJumpButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
InfJumpButton.Text = "Infinite Jump (WYŁ)"
InfJumpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
InfJumpButton.TextSize = 18
InfJumpButton.Font = Enum.Font.GothamSemibold
InfJumpButton.Parent = MainFrame

local UICornerInf = Instance.new("UICorner")
UICornerInf.CornerRadius = UDim.new(0, 8)
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
NoClipButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
NoClipButton.Text = "NoClip (WYŁ)"
NoClipButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NoClipButton.TextSize = 18
NoClipButton.Font = Enum.Font.GothamSemibold
NoClipButton.Parent = MainFrame

local UICornerNoClip = Instance.new("UICorner")
UICornerNoClip.CornerRadius = UDim.new(0, 8)
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
FlingButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
FlingButton.Text = "Fling (WYŁ)"
FlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlingButton.TextSize = 18
FlingButton.Font = Enum.Font.GothamSemibold
FlingButton.Parent = MainFrame

local UICornerFling = Instance.new("UICorner")
UICornerFling.CornerRadius = UDim.new(0, 8)
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
AntiFlingButton.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
AntiFlingButton.Text = "Anti Fling (WYŁ)"
AntiFlingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFlingButton.TextSize = 18
AntiFlingButton.Font = Enum.Font.GothamSemibold
AntiFlingButton.Parent = MainFrame

local UICornerAnti = Instance.new("UICorner")
UICornerAnti.CornerRadius = UDim.new(0, 8)
UICornerAnti.Parent = AntiFlingButton

AntiFlingButton.MouseButton1Click:Connect(function()
    if antiflingConn then
        antiflingConn:Disconnect()
        antiflingConn = nil
        AntiFlingButton.Text = "Anti Fling (WYŁ)"
    else
        antiflingConn = RunService.Stepped:Connect(function()
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

print("Quantum X – czarne UI w stylu Fluent załadowane")
