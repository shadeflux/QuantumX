-- Quantum X Loader | Linoria Edition

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local LinoriaLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLibV2/main/Library.lua'))()
local Window = LinoriaLib:CreateWindow("Quantum X", "Unseen. Unpatched. Unstoppable.")

-- Key system – prosty input na samym początku (bez osobnego okna)
local KeyTab = Window:AddTab("Key System")

KeyTab:AddLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
KeyTab:AddLabel("Po ukończeniu kroków skopiuj klucz i wklej poniżej.")

local KeyStatus = KeyTab:AddLabel("Status: Oczekiwanie na klucz...")

local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    return Success and Response and Response:find('"valid":true')
end

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = SavedKey and CheckKey(SavedKey)

if KeyValid then
    KeyStatus.Text = "Status: Klucz ważny – hub odblokowany"
    task.delay(0.8, function()
        KeyTab:Hide()  -- chowamy kartę po poprawnym kluczu
    end)
else
    if SavedKey then
        pcall(delfile, KeyFile)
    end

    KeyTab:AddButton({
        Text = "Otwórz stronę z kluczami",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            LinoriaLib:Notify("Skopiowano link! Ukończ kroki i wklej klucz.", 10)
        end
    })

    KeyTab:AddInput("Wklej klucz tutaj", {
        Placeholder = "np. abc123-def456-ghi789",
        ClearTextOnFocus = false,
        Callback = function(Token)
            if Token == "" then return end

            if CheckKey(Token) then
                LinoriaLib:Notify("Sukces! Klucz zaakceptowany.", 5)
                pcall(writefile, KeyFile, Token)

                KeyStatus.Text = "Status: Klucz ważny – hub odblokowany"
                task.delay(0.8, function()
                    KeyTab:Hide()
                end)
            else
                LinoriaLib:Notify("Błąd – nieprawidłowy klucz", 6)
            end
        end
    })
end

-- Główny hub – wszystkie funkcje (po ukryciu karty key)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local PlayerTab = Window:AddTab("Player Mods")
local ScriptsTab = Window:AddTab("Scripts")
local CreditsTab = Window:AddTab("Credits")
local SettingsTab = Window:AddTab("Settings")

-- Zmienne
local speedEnabled = false
local defaultSpeed = 16
local customSpeed = 32
local flinging = false
local antifling = nil
local spawnpoint = false
local spawnpos = nil
local spectating = false
local infiniteJumpEnabled = false
local noclipEnabled = false

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

-- PLAYER MODS

PlayerTab:AddSlider("Walk Speed", 16, 200, 1, function(value)
    customSpeed = value
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

PlayerTab:AddToggle("Enable Speed Hack", false, function(value)
    speedEnabled = value
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = value and customSpeed or defaultSpeed
    end
end)

PlayerTab:AddToggle("Infinite Jump", false, function(value)
    infiniteJumpEnabled = value
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

PlayerTab:AddToggle("NoClip", false, function(value)
    noclipEnabled = value
    if value then
        spawn(function()
            while noclipEnabled do
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

PlayerTab:AddInput("Teleport do gracza", {
    Placeholder = "Wpisz nick",
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character and getRoot(target.Character) then
            getRoot(LocalPlayer.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(0, 3, 0)
        else
            LinoriaLib:Notify("Gracz nie znaleziony", 4)
        end
    end
})

PlayerTab:AddToggle("Fling", false, function(value)
    flinging = value
    if value then
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Massless = true
            end
        end
        local root = getRoot(char)
        local ang = Instance.new("BodyAngularVelocity")
        ang.AngularVelocity = Vector3.new(0, 999999, 0)
        ang.MaxTorque = Vector3.new(0, math.huge, 0)
        ang.Parent = root
    end
end)

PlayerTab:AddToggle("Anti Fling", false, function(value)
    if value then
        antifling = RunService.Stepped:Connect(function()
            for _, p in Players:GetPlayers() do
                if p \~= LocalPlayer and p.Character then
                    for _, part in pairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end
        end)
    else
        if antifling then antifling:Disconnect() end
    end
end)

PlayerTab:AddButton("Ustaw punkt odrodzenia", function()
    spawnpos = getRoot(LocalPlayer.Character).CFrame
    spawnpoint = true
    LinoriaLib:Notify("Spawnpoint ustawiony!", 3)
end)

PlayerTab:AddInput("Obserwuj gracza", {
    Placeholder = "Nick gracza",
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
            spectating = true
        else
            LinoriaLib:Notify("Gracz nie znaleziony", 4)
        end
    end
})

PlayerTab:AddButton("Zakończ obserwację", function()
    if spectating then
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        spectating = false
    end
end)

PlayerTab:AddToggle("Anti AFK", false, function(value)
    if value then
        spawn(function()
            while value do
                game:GetService("VirtualUser"):Button2Down(Vector2.new(), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.new(), Workspace.CurrentCamera.CFrame)
                task.wait(60)
            end
        end)
    end
end)

-- Scripts Tab

ScriptsTab:AddButton("Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

ScriptsTab:AddButton("Hat Hub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))()
end)

ScriptsTab:AddButton("RemoteSpy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
end)

ScriptsTab:AddButton("Dex Explorer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))()
end)

-- Credits

CreditsTab:AddLabel("Created by Quantum X Team")
CreditsTab:AddLabel("Unseen. Unpatched. Unstoppable.")
CreditsTab:AddLabel("Thanks for using!")

-- Settings

SettingsTab:AddButton("Zamknij GUI", function()
    Window:Close()
end)

LinoriaLib:Notify("Quantum X załadowany pomyślnie!", 5)
