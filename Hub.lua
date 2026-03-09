if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Http = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Globalne zmienne
local speedOn = false
local walkSpeedValue = 16
local jumpOn = false
local jumpPowerValue = 50
local spectating = false
local targetPlayer = nil

-- Pętla aktualizująca statystyki gracza
task.spawn(function()
    while true do
        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if h then
            if speedOn then h.WalkSpeed = walkSpeedValue end
            if jumpOn then h.JumpPower = jumpPowerValue end
        end
        task.wait(0.1)
    end
end)

-- Pętla spectate
task.spawn(function()
    while true do
        if spectating and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
        elseif not spectating and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        end
        task.wait(0.1)
    end
end)

-- === GŁÓWNY INTERFEJS ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Unseen. Unpatched. Unstoppable.",
        LoadingTitle = "Quantum X Hub",
        LoadingSubtitle = "by Quantum X Corp",
        Theme = "Amethyst", -- Ustawiony na stałe motyw Amethyst
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "QuantumX",
            FileName = "Config"
        },
        Discord = {
            Enabled = true,
            Invite = "XHEAeKSx34",
            RememberJoins = true 
        },
        KeySystem = false
    })

    -- 1. ZAKŁADKA: WSZYSTKIE FUNKCJE
    local MainTab = Window:CreateTab("Features", 4483362458)
    
    -- Sekcja Movement
    MainTab:CreateSection("Movement")
    
    MainTab:CreateToggle({
        Name = "Enable WalkSpeed",
        CurrentValue = speedOn,
        Flag = "SpeedToggle",
        Callback = function(Value)
            speedOn = Value
            if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = 16
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "WalkSpeed Value",
        Range = {16, 500},
        Increment = 1,
        Suffix = "Speed",
        CurrentValue = walkSpeedValue,
        Flag = "SpeedSlider",
        Callback = function(Value)
            walkSpeedValue = Value
        end,
    })

    MainTab:CreateToggle({
        Name = "Enable JumpPower",
        CurrentValue = jumpOn,
        Flag = "JumpToggle",
        Callback = function(Value)
            jumpOn = Value
            if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.JumpPower = 50
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "JumpPower Value",
        Range = {50, 500},
        Increment = 1,
        Suffix = "Power",
        CurrentValue = jumpPowerValue,
        Flag = "JumpSlider",
        Callback = function(Value)
            jumpPowerValue = Value
        end,
    })

    -- Sekcja Teleportation
    MainTab:CreateSection("Teleportation & Spectate")
    
    MainTab:CreateInput({
        Name = "Target Player Name",
        PlaceholderText = "Type username...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
            for _, v in pairs(Players:GetPlayers()) do
                if v.Name:lower():find(Text:lower()) or v.DisplayName:lower():find(Text:lower()) then
                    targetPlayer = v
                    Rayfield:Notify({Title = "Target Found", Content = "Selected: " .. v.Name, Duration = 3})
                    break
                end
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Teleport to Player",
        Callback = function()
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
            else
                Rayfield:Notify({Title = "Error", Content = "Player not found or dead", Duration = 3})
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Spectate Player",
        CurrentValue = spectating,
        Flag = "SpectateToggle",
        Callback = function(Value)
            spectating = Value
        end,
    })

    -- Sekcja Server Utils
    MainTab:CreateSection("Server Utils")
    
    MainTab:CreateButton({
        Name = "Rejoin Server",
        Callback = function()
            TeleportService:Teleport(game.PlaceId, lp)
        end,
    })

    MainTab:CreateButton({
        Name = "Server Hop",
        Callback = function()
            local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local Raw = game:HttpGet(Api)
            local Decode = Http:JSONDecode(Raw)
            for _, v in pairs(Decode.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, lp)
                    break
                end
            end
        end,
    })


    -- 2. ZAKŁADKA: USTAWIENIA I CREDITS
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    
    SettingsTab:CreateSection("System & Credits")

    SettingsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    SettingsTab:CreateLabel("Developed by Quantum X Team")

    SettingsTab:CreateButton({
        Name = "Copy Discord Link",
        Callback = function()
            setclipboard("https://discord.gg/XHEAeKSx34")
            Rayfield:Notify({Title = "Success", Content = "Link copied to clipboard!", Duration = 3})
        end,
    })

    SettingsTab:CreateButton({
        Name = "Destroy UI",
        Callback = function()
            Rayfield:Destroy()
            getgenv().QuantumXLoaded = false
        end,
    })

    Rayfield:LoadConfiguration()
end


-- === LOGIKA KEY SYSTEM ===
local function CheckKey(Token)
    local Url = "https://work.ink/_api/v2/token/isValid/" .. Token
    local Success, Response = pcall(function() return game:HttpGet(Url) end)
    return Success and Response:find('"valid":true') ~= nil
end

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile and isfile(KeyFile) then SavedKey = readfile(KeyFile) end
end)

if SavedKey and CheckKey(SavedKey) then
    -- Poprawny klucz przy starcie -> Ładujemy hub w motywie Amethyst
    LoadMainWindow()
    Rayfield:Notify({Title = "Auto-Login", Content = "Zapisany klucz ważny!", Duration = 5})
else
    if SavedKey then pcall(function() delfile(KeyFile) end) end
    
    -- Okno logowania
    local KeyWindow = Rayfield:CreateWindow({
        Name = "Quantum X | Verification",
        LoadingTitle = "Checking Access...",
        LoadingSubtitle = "by Quantum X",
        Theme = "Amethyst",
        KeySystem = false
    })
    
    local KeyTab = KeyWindow:CreateTab("Key System", nil)

    KeyTab:CreateLabel("Ukończ kroki, aby wygenerować klucz.")

    KeyTab:CreateButton({
        Name = "Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({Title = "Skopiowano!", Content = "Wklej w przeglądarkę i ukończ kroki.", Duration = 8})
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz/token tutaj",
        PlaceholderText = "Wprowadź klucz...",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" then return end
            
            if CheckKey(Token) then
                pcall(function() writefile(KeyFile, Token) end)
                Rayfield:Notify({Title = "Sukces!", Content = "Klucz poprawny! Ładowanie...", Duration = 3})
                
                -- Klucz poprawny -> Zamykamy okno weryfikacji i ładujemy pełny Hub
                Rayfield:Destroy()
                task.wait(0.2)
                LoadMainWindow()
            else
                Rayfield:Notify({Title = "Błąd", Content = "Nieprawidłowy klucz!", Duration = 5})
            end
        end
    })
end
