local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Funkcja sprawdzania klucza via Work.ink
local function CheckKey(Token)
    local Url = "https://work.ink/_api/v2/token/isValid/" .. Token
    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)
    
    if Success and Response:find('"valid":true') then
        return true
    else
        return false
    end
end

-- Najpierw tylko okno z key system
local KeyWindow = Rayfield:CreateWindow({
    Name = "Quantum X - Key System",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
    KeySystem = false
})

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile and isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = SavedKey and CheckKey(SavedKey)

if KeyValid then
    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Auto-login udany – ładuję hub...",
        Duration = 4.5
    })
    KeyWindow:Destroy()
    LoadMainHub()
else
    if SavedKey then
        pcall(function() delfile(KeyFile) end)
    end

    local KeyTab = KeyWindow:CreateTab("Key System", nil)

    KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
    KeyTab:CreateLabel("Po ukończeniu wszystkich kroków skopiuj wygenerowany klucz i wklej poniżej.")

    KeyTab:CreateButton({
        Name = "Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")   -- <--- zmień na swój link jak będziesz miał własny
            Rayfield:Notify({
                Title = "Skopiowano!",
                Content = "Ukończ WSZYSTKIE kroki i wklej klucz tutaj.",
                Duration = 12
            })
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz / token tutaj",
        PlaceholderText = "np. abc123-def456-ghi789",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" or Token:len() < 5 then
                Rayfield:Notify({Title = "Błąd", Content = "Wklej poprawny klucz!", Duration = 4})
                return
            end
            
            if CheckKey(Token) then
                Rayfield:Notify({
                    Title = "Sukces!",
                    Content = "Klucz zaakceptowany – zapisuję i ładuję hub...",
                    Duration = 5
                })
                
                pcall(function()
                    if writefile then writefile(KeyFile, Token) end
                end)
                
                KeyWindow:Destroy()
                LoadMainHub()
            else
                Rayfield:Notify({
                    Title = "Błąd",
                    Content = "Nieprawidłowy lub wygasły klucz. Spróbuj ponownie.",
                    Duration = 6
                })
            end
        end
    })
end
-- ────────────────────────────────────────────────
-- Główny hub – ładuje się dopiero po poprawnym kluczu
-- ────────────────────────────────────────────────

function LoadMainHub()
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

    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Successfully loaded! Enjoy the features.",
        Duration = 6
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local PlayerTab = Window:CreateTab("Player Mods", "user")
    local AimbotTab = Window:CreateTab("Aimbot & ESP", nil)
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
    local FLYING = false
    local QEfly = true
    local iyflyspeed = 5
    local Floating = false
    local floatName = "FloatPart_" .. math.random(1000, 9999)
    local FloatValue = -3.1
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

    -- === PLAYER MODS ===

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

    -- ... (tu jest obcięte w Twojej wiadomości, ale zakładam, że reszta Twoich funkcji toggle/sliderów/anty-fling/fly/spectate/anti-afk itd. idzie w to samo miejsce)

    -- Scripts Tab (Twoje oryginalne przyciski)
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
        Name = "Destroy GUI",
        Callback = function()
            Window:Destroy()
        end
    })

    Window:LoadConfiguration()
end
