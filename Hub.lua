local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Quantum X",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "QuantumX",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Karta Key System na samym początku
local KeyTab = Window:CreateTab("Key System")

KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
KeyTab:CreateLabel("Po ukończeniu kroków skopiuj klucz i wklej poniżej.")

local KeyStatus = KeyTab:CreateLabel("Status: Oczekiwanie na klucz...")

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
    KeyStatus:Set("Status: Klucz ważny – hub odblokowany")
    task.delay(0.8, function()
        if KeyTab and KeyTab.Container then
            KeyTab.Container.Visible = false
        end
    end)
else
    if SavedKey then
        pcall(delfile, KeyFile)
    end

    KeyTab:CreateButton({
        Name = "Otwórz stronę z kluczami",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({Title = "Skopiowano!", Content = "Ukończ WSZYSTKIE kroki i wklej klucz.", Duration = 10})
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz tutaj",
        PlaceholderText = "np. abc123-def456-ghi789",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" then return end

            if CheckKey(Token) then
                Rayfield:Notify({Title = "Sukces", Content = "Klucz zaakceptowany!", Duration = 5})
                pcall(writefile, KeyFile, Token)

                KeyStatus:Set("Status: Klucz ważny – hub odblokowany")
                task.delay(0.8, function()
                    if KeyTab and KeyTab.Container then
                        KeyTab.Container.Visible = false
                    end
                end)
            else
                Rayfield:Notify({Title = "Błąd", Content = "Nieprawidłowy klucz", Duration = 5})
            end
        end
    })
end

-- HUB – WSZYSTKIE FUNKCJE (bez aimbota i fly/float)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local PlayerTab = Window:CreateTab("Player Mods", "user")
local ScriptsTab = Window:CreateTab("Scripts", "code")
local CreditsTab = Window:CreateTab("Credits", "info")
local SettingsTab = Window:CreateTab("Settings", "settings")

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
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name:lower()) or p.DisplayName:lower():find(name:lower()) then
            return p
        end
    end
    return nil
end

-- PLAYER MODS

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = 16,
    Callback = function(v)
        customSpeed = v
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Enable Speed Hack",
    CurrentValue = false,
    Callback = function(v)
        speedEnabled = v
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = v and customSpeed or defaultSpeed
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

PlayerTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Callback = function(v)
        noclipEnabled = v
        if v then
            spawn(function()
                while noclipEnabled do
                    if LocalPlayer.Character then
                        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

PlayerTab:CreateInput({
    Name = "Teleport do gracza",
    PlaceholderText = "Nick gracza",
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character and getRoot(target.Character) then
            getRoot(LocalPlayer.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(0, 3, 0)
        else
            Rayfield:Notify({Title = "Błąd", Content = "Gracz nie znaleziony", Duration = 4})
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(v)
        flinging = v
        if v then
            local char = LocalPlayer.Character
            if not char then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p.CanCollide = false
                    p.Massless = true
                end
            end
            local root = getRoot(char)
            local ang = Instance.new("BodyAngularVelocity")
            ang.AngularVelocity = Vector3.new(0, 999999, 0)
            ang.MaxTorque = Vector3.new(0, math.huge, 0)
            ang.Parent = root
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Callback = function(v)
        if v then
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
    end
})

PlayerTab:CreateButton({
    Name = "Ustaw punkt odrodzenia",
    Callback = function()
        spawnpos = getRoot(LocalPlayer.Character).CFrame
        spawnpoint = true
        Rayfield:Notify({Title = "Spawnpoint", Content = "Ustawiono!", Duration = 3})
    end
})

PlayerTab:CreateInput({
    Name = "Obserwuj gracza",
    PlaceholderText = "Nick gracza",
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
            spectating = true
        else
            Rayfield:Notify({Title = "Błąd", Content = "Gracz nie znaleziony", Duration = 4})
        end
    end
})

PlayerTab:CreateButton({
    Name = "Zakończ obserwację",
    Callback = function()
        if spectating then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
            spectating = false
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(v)
        if v then
            spawn(function()
                while v do
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(), Workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(), Workspace.CurrentCamera.CFrame)
                    task.wait(60)
                end
            end)
        end
    end
})

-- Scripts Tab

ScriptsTab:CreateButton({
    Name = "Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end
})

ScriptsTab:CreateButton({
    Name = "Hat Hub",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))() end
})

ScriptsTab:CreateButton({
    Name = "RemoteSpy",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))() end
})

ScriptsTab:CreateButton({
    Name = "Dex Explorer",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))() end
})

-- Credits

CreditsTab:CreateParagraph({
    Title = "Created by",
    Content = "Quantum X Team\nUnseen. Unpatched. Unstoppable.\nThanks for using!"
})

-- Settings

SettingsTab:CreateButton({
    Name = "Zamknij GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

Rayfield:LoadConfiguration()
