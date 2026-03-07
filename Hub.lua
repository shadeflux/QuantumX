-- Quantum X – CZARNE, PROSTOKĄTNE, RESPONSIVE UI (styl Aether / Rayfield)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

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
UICorner.CornerRadius = UDim.new(0, 8)  -- prostokątne, lekko zaokrąglone
UICorner.Parent = MainFrame

-- Responsywność – mniejsze na telefonie
local function UpdateSize()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local width = math.clamp(screenSize.X * 0.75, 280, 520)   -- max 75% szerokości, min 280px
    local height = math.clamp(screenSize.Y * 0.65, 340, 600) -- max 65% wysokości
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
Title.TextSize = 28
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

-- Przyciski X i –
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 28, 0, 28)
CloseButton.Position = UDim2.new(1, -36, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = MainFrame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 28, 0, 28)
MinimizeButton.Position = UDim2.new(1, -70, 0, 10)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.TextSize = 20
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = MainFrame

-- Mały przycisk po minimalizacji
local MinimizeIcon = Instance.new("TextButton")
MinimizeIcon.Size = UDim2.new(0, 45, 0, 45)
MinimizeIcon.Position = UDim2.new(0, 20, 1, -60)
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

-- Key System – karta (czarno-biała)
local KeyContainer = Instance.new("Frame")
KeyContainer.Size = UDim2.new(1, 0, 1, -60)
KeyContainer.Position = UDim2.new(0, 0, 0, 60)
KeyContainer.BackgroundTransparency = 1
KeyContainer.Parent = MainFrame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 35)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Wklej klucz poniżej (ważny 24h)"
KeyLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
KeyLabel.TextSize = 20
KeyLabel.Font = Enum.Font.GothamSemibold
KeyLabel.Parent = KeyContainer

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.9, 0, 0, 45)
KeyBox.Position = UDim2.new(0.05, 0, 0.2, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "np. abc123-def456-ghi789"
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = KeyContainer

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 8)
UICornerBox.Parent = KeyBox

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.9, 0, 0, 45)
Submit.Position = UDim2.new(0.05, 0, 0.4, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
Submit.Text = "ZATWIERDŹ KLUCZ"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextSize = 20
Submit.Font = Enum.Font.GothamBold
Submit.Parent = KeyContainer

local UICornerSubmit = Instance.new("UICorner")
UICornerSubmit.CornerRadius = UDim.new(0, 8)
UICornerSubmit.Parent = Submit

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.9, 0, 0, 35)
Status.Position = UDim2.new(0.05, 0, 0.6, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Oczekiwanie..."
Status.TextColor3 = Color3.fromRGB(255, 255, 255)
Status.TextSize = 18
Status.Parent = KeyContainer

-- ==================== LOGIKA KLUCZA ====================
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
        Status.TextColor3 = Color3.fromRGB(255, 120, 120)
        return
    end

    if CheckKey(Token) then
        Status.Text = "SUKCES – HUB ODBLOKOWANY"
        Status.TextColor3 = Color3.fromRGB(120, 255, 120)
        
        pcall(writefile, "QuantumX_Key.txt", Token)

        task.delay(1, function()
            KeyContainer.Visible = false

            local HubLabel = Instance.new("TextLabel")
            HubLabel.Size = UDim2.new(1, 0, 1, 0)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Hub załadowany!\nFunkcje poniżej"
            HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubLabel.TextSize = 26
            HubLabel.Font = Enum.Font.GothamBlack
            HubLabel.Parent = MainFrame

            -- Dodaj tu swoje funkcje jako buttony
            -- Przykład: Speed Hack
            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 50)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.25, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            SpeedButton.Text = "Speed Hack (100)"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.TextSize = 20
            SpeedButton.Font = Enum.Font.GothamSemibold
            SpeedButton.Parent = MainFrame

            local UICornerSpeed = Instance.new("UICorner")
            UICornerSpeed.CornerRadius = UDim.new(0, 10)
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
        Status.TextColor3 = Color3.fromRGB(255, 120, 120)
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
    Status.TextColor3 = Color3.fromRGB(120, 255, 120)
    KeyBox.Visible = false
    Submit.Visible = false

    task.delay(1, function()
        KeyContainer.Visible = false

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, 0, 1, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = "Hub załadowany!\nFunkcje poniżej"
        HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubLabel.TextSize = 26
        HubLabel.Font = Enum.Font.GothamBlack
        HubLabel.Parent = MainFrame

        -- Dodaj funkcje jak wyżej (SpeedButton itd.)
    end)
end

-- ==================== MINIMIZE I CLOSE ====================

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

print("Quantum X – czarne, responsywne UI załadowane")
