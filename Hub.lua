-- Quantum X – NATYWNE ROBLOX GUI (bez Linoria, Rayfield itp.)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tworzymy GUI ręcznie
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 300)
Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.9, 0, 0, 30)
Status.Position = UDim2.new(0.05, 0, 0.2, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Oczekiwanie na klucz..."
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 18
Status.Parent = Frame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 40)
KeyBox.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Wpisz klucz tutaj"
KeyBox.Parent = Frame

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.8, 0, 0, 40)
Submit.Position = UDim2.new(0.1, 0, 0.55, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Submit.Text = "ZATWIERDŹ"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextSize = 20
Submit.Parent = Frame

-- Key check
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

        -- Chowamy key i pokazujemy hub (na razie pusty)
        task.delay(1, function()
            KeyBox.Visible = false
            Submit.Visible = false
            Status.Text = "Hub załadowany – dodaj funkcje"

            -- Przykład prostej funkcji (dodaj swoje)
            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 50)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.3, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpeedButton.Text = "Włącz Speed 100"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.Parent = Frame

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
        Status.Text = "Hub załadowany – dodaj funkcje"
        -- Dodaj tu swoje buttony/toggle jak wyżej
    end)
end

print("Quantum X natywne GUI załadowane – sprawdź okno")
