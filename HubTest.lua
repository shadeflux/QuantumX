-- Quantum X – WŁASNE UI (bez bibliotek zewnętrznych)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Tworzymy ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Główny Frame (tło GUI)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Key System – na początku pokazujemy tylko to
local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(0.9, 0, 0, 30)
KeyLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "Wklej klucz poniżej"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyLabel.TextSize = 18
KeyLabel.Parent = MainFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "np. abc123-def456-ghi789"
KeyBox.Text = ""
KeyBox.Parent = MainFrame

local SubmitButton = Instance.new("TextButton")
SubmitButton.Size = UDim2.new(0.8, 0, 0, 40)
SubmitButton.Position = UDim2.new(0.1, 0, 0.55, 0)
SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SubmitButton.Text = "Zatwierdź klucz"
SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitButton.TextSize = 20
SubmitButton.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.75, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Oczekiwanie..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 16
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
        StatusLabel.Text = "Status: Sukces! Ładuję hub..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        
        -- Zapisujemy klucz
        pcall(function()
            writefile("QuantumX_Key.txt", Token)
        end)

        -- Chowamy key system i pokazujemy hub
        task.delay(1, function()
            KeyLabel.Visible = false
            KeyBox.Visible = false
            SubmitButton.Visible = false
            StatusLabel.Visible = false

            -- Tutaj dodajemy resztę GUI i funkcji (na razie puste okno)
            local HubLabel = Instance.new("TextLabel")
            HubLabel.Size = UDim2.new(1, 0, 1, 0)
            HubLabel.BackgroundTransparency = 1
            HubLabel.Text = "Hub załadowany!\nWklej funkcje ręcznie w konsoli Delta."
            HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            HubLabel.TextSize = 20
            HubLabel.Parent = MainFrame

            -- Przykład prostej funkcji (możesz dodać więcej)
            print("Test – możesz dodać speed hack np. tak:")
            print("game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100")
        end)
    else
        StatusLabel.Text = "Status: Nieprawidłowy klucz"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Jeśli klucz był zapisany i ważny – od razu pomijamy key system
if KeyValid then
    SubmitButton.Visible = false
    KeyBox.Visible = false
    KeyLabel.Visible = false
    StatusLabel.Text = "Auto-login udany – hub załadowany"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)

    task.delay(1, function()
        StatusLabel.Visible = false

        local HubLabel = Instance.new("TextLabel")
        HubLabel.Size = UDim2.new(1, 0, 1, 0)
        HubLabel.BackgroundTransparency = 1
        HubLabel.Text = "Hub załadowany!\nDodaj funkcje w konsoli Delta."
        HubLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        HubLabel.TextSize = 20
        HubLabel.Parent = MainFrame
    end)
end

print("Quantum X – własne UI załadowane")
