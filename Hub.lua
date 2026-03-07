-- Quantum X – NATYWNE ROBLOX GUI (bez zewnętrznych bibliotek)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Tworzymy ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Główny Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 28
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 12)
UICornerTitle.Parent = Title

-- Key System – na początku
local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.9, 0, 0, 40)
KeyLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Wklej klucz poniżej (ważny 24h)"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyLabel.TextSize = 20
KeyLabel.Font = Enum.Font.Gotham
KeyLabel.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 50)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "np. abc123-def456-ghi789"
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = MainFrame

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 8)
UICornerBox.Parent = KeyBox

local SubmitButton = Instance.new("TextButton")
SubmitButton.Size = UDim2.new(0.8, 0, 0, 50)
SubmitButton.Position = UDim2.new(0.1, 0, 0.55, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SubmitButton.Text = "ZATWIERDŹ KLUCZ"
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.TextSize = 22
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.Parent = MainFrame

local UICornerSubmit = Instance.new("UICorner")
UICornerSubmit.CornerRadius = UDim.new(0, 8)
UICornerSubmit.Parent = SubmitButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 40)
StatusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Oczekiwanie..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 18
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- Funkcja sprawdzania klucza
local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    return Success and Response and Response:find('"valid":true')
end

-- Przycisk zatwierdzania
SubmitButton.MouseButton1Click:Connect(function()
    local Token = KeyBox.Text
    if Token == "" then
        StatusLabel.Text = "Status: Wpisz klucz!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    if CheckKey(Token) then
        StatusLabel.Text = "Status: Sukces! Hub odblokowany."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        pcall(function()
            writefile("QuantumX_Key.txt", Token)
        end)

        task.delay(1.5, function()
            -- Chowamy key system
            KeyLabel.Visible = false
            KeyBox.Visible = false
            SubmitButton.Visible = false
            StatusLabel.Visible = false

            -- Pokazujemy hub (puste na razie – dodamy funkcje)
            local HubLabel = Instance.new("TextLabel")
            HubLabel.Size = UDim2.new(1, 0, 1, 0)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Hub załadowany!\nMożesz dodać funkcje."
            HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubLabel.TextSize = 24
            HubLabel.Font = Enum.Font.GothamBold
            HubLabel.Parent = MainFrame

            -- Dodaj tu swoje funkcje (przykład speed hack)
            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 50)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.3, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpeedButton.Text = "Włącz Speed Hack (100)"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.TextSize = 20
            SpeedButton.Parent = MainFrame

            SpeedButton.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 100
                    StatusLabel.Text = "Speed Hack włączony!"
                end
            end)
        end)
    else
        StatusLabel.Text = "Status: Nieprawidłowy klucz"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Auto-login jeśli klucz zapisany
if SavedKey and CheckKey(SavedKey) then
    SubmitButton.Visible = false
    KeyBox.Visible = false
    KeyLabel.Visible = false
    StatusLabel.Text = "Auto-login udany – hub załadowany"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)

    task.delay(1.5, function()
        StatusLabel.Visible = false

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, 0, 1, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = "Hub załadowany!\nMożesz dodać funkcje."
        HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubLabel.TextSize = 24
        HubLabel.Font = Enum.Font.GothamBold
        HubLabel.Parent = MainFrame
    end)
end

print("Quantum X – własne UI załadowane")
