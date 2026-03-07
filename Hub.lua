-- Quantum X – ŁADNE NATYWNE UI (styl Rayfield / Aether)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

-- Tworzymy ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Główny Frame (tło z gradientem i blur vibe)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

-- Gradient tła (jak w Aether)
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 0, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 30))
}
UIGradient.Rotation = 90
UIGradient.Parent = MainFrame

-- Neon glow / shadow (bardzo Aether-like)
local UIGlow = Instance.new("ImageLabel")
UIGlow.Size = UDim2.new(1, 40, 1, 40)
UIGlow.Position = UDim2.new(0, -20, 0, -20)
UIGlow.BackgroundTransparency = 1
UIGlow.Image = "rbxassetid://6014261993" -- neon glow asset (publiczny)
UIGlow.ImageColor3 = Color3.fromRGB(0, 170, 255)
UIGlow.ImageTransparency = 0.6
UIGlow.ScaleType = Enum.ScaleType.Slice
UIGlow.SliceCenter = Rect.new(49, 49, 450, 450)
UIGlow.Parent = MainFrame

-- Tytuł z neonem
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 36
Title.Font = Enum.Font.GothamBlack
Title.TextStrokeTransparency = 0.8
Title.TextStrokeColor3 = Color3.fromRGB(0, 100, 255)
Title.Parent = MainFrame

-- Key System – karta na początku
local KeyContainer = Instance.new("Frame")
KeyContainer.Size = UDim2.new(0.9, 0, 0.8, 0)
KeyContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
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

-- Funkcja sprawdzania klucza
local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    return Success and Response and Response:find('"valid":true')
end

-- Przycisk zatwierdzania
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

        -- Animacja znikania key system (jak w Aether)
        TweenService:Create(KeyContainer, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        task.delay(0.5, function()
            KeyContainer.Visible = false

            -- Pokazujemy hub (puste na razie – dodamy funkcje)
            local HubLabel = Instance.new("TextLabel")
            HubLabel.Size = UDim2.new(1, 0, 1, 0)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Hub załadowany!\nDodaj funkcje poniżej"
            HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubLabel.TextSize = 28
            HubLabel.Font = Enum.Font.GothamBlack
            HubLabel.Parent = MainFrame

            -- Przykład pierwszej funkcji (dodaj resztę w ten sam sposób)
            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 60)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.3, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpeedButton.Text = "Włącz Speed Hack (100)"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.TextSize = 22
            SpeedButton.Font = Enum.Font.GothamBold
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

            -- Dodaj tu noclip, fling, anti-fling itd. jako kolejne buttony
        end)
    else
        Status.Text = "Nieprawidłowy klucz"
        Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Auto-login jeśli klucz zapisany
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
        Status.Visible = false

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, 0, 1, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = "Hub załadowany!\nDodaj funkcje poniżej"
        HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubLabel.TextSize = 28
        HubLabel.Font = Enum.Font.GothamBlack
        HubLabel.Parent = MainFrame

        -- Przykład pierwszej funkcji
        local SpeedButton = Instance.new("TextButton")
        SpeedButton.Size = UDim2.new(0.8, 0, 0, 60)
        SpeedButton.Position = UDim2.new(0.1, 0, 0.3, 0)
        SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SpeedButton.Text = "Włącz Speed Hack (100)"
        SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SpeedButton.TextSize = 22
        SpeedButton.Font = Enum.Font.GothamBold
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
end

print("Quantum X – ładne natywne UI załadowane")
