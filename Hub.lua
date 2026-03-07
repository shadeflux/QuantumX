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
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Key system – karta na początku
local KeyTab = Window:CreateTab("Key System", nil)

KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
KeyTab:CreateLabel("Po ukończeniu kroków strona auto wygeneruje klucz – skopiuj i wklej poniżej.")

local KeyStatus = KeyTab:CreateLabel("Status: Oczekiwanie na klucz...")

local function CheckKey(Token)
    local Url = "https://work.ink/_api/v2/token/isValid/" .. Token
    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)
    
    if Success and Response:find('"valid":true') then
        return true
    end
    return false
end

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile and isfile(KeyFile) then
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
        pcall(function() delfile(KeyFile) end)
    end

    KeyTab:CreateButton({
        Name = "Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({
                Title = "Skopiowano!",
                Content = "Wklej w przeglądarkę i ukończ WSZYSTKIE kroki.\nPo zakończeniu skopiuj klucz i wklej tutaj.",
                Duration = 15
            })
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz/token tutaj",
        PlaceholderText = "np. abc123-def456-ghi789",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" then
                Rayfield:Notify({Title = "Błąd", Content = "Wklej klucz!", Duration = 5})
                return
            end
            
            if CheckKey(Token) then
                Rayfield:Notify({
                    Title = "Sukces!",
                    Content = "Klucz poprawny! Zapisuję i odblokowuję hub...",
                    Duration = 6
                })
                
                pcall(function()
                    writefile(KeyFile, Token)
                end)
                
                KeyStatus:Set("Status: Klucz ważny – hub odblokowany")
                task.delay(0.8, function()
                    if KeyTab and KeyTab.Container then
                        KeyTab.Container.Visible = false
                    end
                end)
            else
                Rayfield:Notify({
                    Title = "Błąd",
                    Content = "Nieprawidłowy lub expired klucz! Spróbuj ponownie.",
                    Duration = 8
                })
            end
        end
    })
end

-- Główny hub – wszystkie funkcje oprócz aimbota i fly/float

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
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():match("^" .. name:lower()) or player.DisplayName:lower():match("^" .. name:lower()) then
            return player
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
    Flag = "WalkSpeedSlider",
    Callback = function(value)
        customSpeed = value
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Enable Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHackToggle",
    Callback = function(value)
        speedEnabled = value
        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value and customSpeed or defaultSpeed
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(value)
        infiniteJumpEnabled = value
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
    Flag = "NoClipToggle",
    Callback = function(value)
        noclipEnabled = value
        while noclipEnabled and task.wait(0.1) do
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

PlayerTab:CreateInput({
    Name = "Teleport to Player",
    PlaceholderText = "Player name",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character and getRoot(target.Character) then
            getRoot(LocalPlayer.Character).CFrame = getRoot(target.Character).CFrame
        else
            Rayfield:Notify({Title="Error", Content = "Player not found", Duration=3})
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Callback = function(value)
        if value then
            flinging = true
            local char = LocalPlayer.Character
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
        else
            flinging = false
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Callback = function(value)
        if value then
            antifling = RunService.Stepped:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p \~= LocalPlayer and p.Character then
                        for _, v in pairs(p.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
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
    Name = "Set Spawnpoint",
    Callback = function()
        spawnpos = getRoot(LocalPlayer.Character).CFrame
        spawnpoint = true
        Rayfield:Notify({Title="Spawnpoint", Content="Spawnpoint set!", Duration=3})
    end
})

PlayerTab:CreateInput({
    Name = "Spectate Player",
    PlaceholderText = "Player name",
    Callback = function(text)
        local target = getPlayerFromName(text)
        if target and target.Character then
            Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            spectating = true
        end
    end
})

PlayerTab:CreateButton({
    Name = "Stop Spectate",
    Callback = function()
        if spectating then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            spectating = false
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Callback = function(value)
        if value then
            LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
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
    Content = "Quantum X Team\nUnseen. Unpatched. Unstoppable.\nThanks for using Quantum X!"
})

-- Settings

SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Poprawione ładowanie konfiguracji (Rayfield: a nie Window:)
Rayfield:LoadConfiguration()
