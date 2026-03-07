-- Quantum X – NATYWNE ROBLOX GUI (bez zewnętrznych bibliotek)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Tworzymy ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "QuantumXGui"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

-- Główny Frame (tło)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 500, 0, 400)
Frame.Position = UDim2.new(0.5, -250, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = Frame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 50))
}
UIGradient.Rotation = 90
UIGradient.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundTransparency = 1
Title.Text = "Quantum X"
Title.TextColor3 = Color3.fromRGB(0, 200, 255)
Title.TextSize = 36
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

-- Key System – pole na klucz
local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.8, 0, 0, 50)
KeyBox.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderText = "Wpisz klucz tutaj"
KeyBox.Text = ""
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = Frame

local UICornerBox = Instance.new("UICorner")
UICornerBox.CornerRadius = UDim.new(0, 10)
UICornerBox.Parent = KeyBox

local Submit = Instance.new("TextButton")
Submit.Size = UDim2.new(0.8, 0, 0, 50)
Submit.Position = UDim2.new(0.1, 0, 0.45, 0)
Submit.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
Submit.Text = "ZATWIERDŹ KLUCZ"
Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
Submit.TextSize = 24
Submit.Font = Enum.Font.GothamBold
Submit.Parent = Frame

local UICornerSubmit = Instance.new("UICorner")
UICornerSubmit.CornerRadius = UDim.new(0, 10)
UICornerSubmit.Parent = Submit

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0.8, 0, 0, 40)
Status.Position = UDim2.new(0.1, 0, 0.6, 0)
Status.BackgroundTransparency = 1
Status.Text = "Status: Oczekiwanie..."
Status.TextColor3 = Color3.fromRGB(200, 200, 200)
Status.TextSize = 20
Status.Parent = Frame

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

        task.delay(1, function()
            KeyBox.Visible = false
            Submit.Visible = false
            Status.Text = "Hub załadowany – dodaj funkcje poniżej"

            -- Dodajemy Twoje funkcje jako buttony (możesz dodać więcej)

            local SpeedButton = Instance.new("TextButton")
            SpeedButton.Size = UDim2.new(0.8, 0, 0, 50)
            SpeedButton.Position = UDim2.new(0.1, 0, 0.2, 0)
            SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SpeedButton.Text = "Włącz Speed Hack (100)"
            SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SpeedButton.TextSize = 20
            SpeedButton.Parent = Frame

            SpeedButton.MouseButton1Click:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 100
                    Status.Text = "Speed włączony!"
                end
            end)

            -- Dodaj tu resztę (noclip, fling itd.) w ten sam sposób
            -- np. local NoclipButton = Instance.new("TextButton") ...
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
        Status.Text = "Hub załadowany – dodaj funkcje poniżej"

        -- Dodajemy Twoje funkcje jako buttony
        local SpeedButton = Instance.new("TextButton")
        SpeedButton.Size = UDim2.new(0.8, 0, 0, 50)
        SpeedButton.Position = UDim2.new(0.1, 0, 0.2, 0)
        SpeedButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SpeedButton.Text = "Włącz Speed Hack (100)"
        SpeedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SpeedButton.TextSize = 20
        SpeedButton.Parent = Frame

        SpeedButton.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = 100
                Status.Text = "Speed włączony!"
            end
        end)

        -- Dodaj tu noclip, fling itd. w ten sam sposób
    end)
end

print("Quantum X – natywne GUI załadowane")
