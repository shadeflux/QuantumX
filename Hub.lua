-- Quantum X – RESPONSIVE NATYWNE UI (dobre na telefon i PC)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Tworzymy ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Główny Frame – responsywny rozmiar
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Automatyczne skalowanie do ekranu (80% szerokości max, min 300px)
local function UpdateSize()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.8, 320, 600)
    local height = math.clamp(screenSize.Y * 0.7, 400, 700)
    MainFrame.Size = UDim2.new(0, width, 0, height)
end

UpdateSize()
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateSize)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

-- Gradient tła
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 0, 80))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Neon glow
local Glow = Instance.new("ImageLabel")
Glow.Size = UDim2.new(1, 50, 1, 50)
Glow.Position = UDim2.new(0, -25, 0, -25)
Glow.BackgroundTransparency = 1
Glow.Image = "rbxassetid://6014261993"
Glow.ImageColor3 = Color3.fromRGB(0, 180, 255)
Glow.ImageTransparency = 0.7
Glow.ScaleType = Enum.ScaleType.Slice
Glow.SliceCenter = Rect.new(49,49,450,450)
Glow.Parent = MainFrame

-- Tytuł
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 34
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.7
Title.Parent = MainFrame

-- Przyciski X i -
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 24
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TopBar

-- Mały przycisk po minimize
local MinimizeIcon = Instance.new("TextButton")
MinimizeIcon.Size = UDim2.new(0, 50, 0, 50)
MinimizeIcon.Position = UDim2.new(0, 20, 1, -70)
MinimizeIcon.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
MinimizeIcon.Text = "QX"
MinimizeIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeIcon.TextSize = 18
MinimizeIcon.Font = Enum.Font.GothamBold
MinimizeIcon.Visible = false
MinimizeIcon.Parent = ScreenGui

local UICornerMin = Instance.new("UICorner")
UICornerMin.CornerRadius = UDim.new(1, 0)
UICornerMin.Parent = MinimizeIcon

-- ==================== KEY SYSTEM ====================
local KeyContainer = Instance.new("Frame")
KeyContainer.Size = UDim2.new(1, 0, 1, -60)
KeyContainer.Position = UDim2.new(0, 0, 0, 60)
KeyContainer.BackgroundTransparency = 1
KeyContainer.Parent = MainFrame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 40)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Wklej klucz poniżej (ważny 24h)"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
KeyLabel.TextSize = 22
KeyLabel.Font = Enum.Font.GothamSemibold
KeyLabel.Parent = KeyContainer

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, 0, 0, 50)
KeyBox.Position = UDim2.new(0, 0, 0.2, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "np. abc123-def456-ghi789"
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyContainer

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 10)
UICornerBox.Parent = KeyBox

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(1, 0, 0, 50)
Submit.Position = UDim2.new(0, 0, 0.4, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Submit.Text = "ZATWIERDŹ KLUCZ"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextSize = 24
Submit.Font = Enum.Font.GothamBold
Submit.Parent = KeyContainer

local UICornerSubmit = Instance.new("UICorner")
UICornerSubmit.CornerRadius = UDim.new(0, 10)
UICornerSubmit.Parent = Submit

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 40)
Status.Position = UDim2.new(0, 0, 0.6, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Oczekiwanie..."
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.TextSize = 18
Status.Parent = KeyContainer

-- Key check + logika (bez zmian)
local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    return Success and Response and Response:find('"valid":true')
end

Submit.MouseButton1Click:Connect(function()
    local Token = KeyBox.Text
    if Token == "" then
        Status.Text = "Wpisz klucz!"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    if CheckKey(Token) then
        Status.Text = "SUKCES – HUB ODBLOKOWANY"
        Status.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        pcall(writefile, "QuantumX_Key.txt", Token)

        task.delay(1, function()
            KeyContainer.Visible = false

            -- Pokazujemy hub (dodaj tu funkcje)
            local HubLabel = Instance.new("TextLabel")
            HubLabel.Size = UDim2.new(1, 0, 1, 0)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Hub załadowany!\nDodaj funkcje poniżej"
            HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubLabel.TextSize = 28
            HubLabel.Font = Enum.Font.GothamBlack
            HubLabel.Parent = MainFrame

            -- Przykład funkcji (dodaj resztę)
            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 60)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.3, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpeedButton.Text = "Włącz Speed Hack (100)"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.TextSize = 22
            SpeedButton.Parent = MainFrame

            local UICornerSpeed = Instance.new("UICorner")
            UICornerSpeed.CornerRadius = UDim.new(0, 12)
            UICornerSpeed.Parent = SpeedButton

            SpeedButton.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 100
                    Status.Text = "Speed włączony!"
                end
            end)
        end)
    else
        Status.Text = "Nieprawidłowy klucz"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Auto-login
local SavedKey = nil
pcall(function()
    if isfile("QuantumX_Key.txt") then
        SavedKey = readfile("QuantumX_Key.txt")
    end
end)

if SavedKey and CheckKey(SavedKey) then
    Status.Text = "Auto-login udany – hub załadowany"
    Status.TextColor3 = Color3.fromRGB(0, 255, 100)
    KeyBox.Visible = false
    Submit.Visible = false

    task.delay(1, function()
        KeyContainer.Visible = false

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, 0, 1, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = "Hub załadowany!\nDodaj funkcje poniżej"
        HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubLabel.TextSize = 28
        HubLabel.Font = Enum.Font.GothamBlack
        HubLabel.Parent = MainFrame

        -- Dodaj tu funkcje jak wyżej
    end)
end

print("Quantum X – responsywne UI załadowane")
