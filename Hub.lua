if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Http = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === GLOBALNE ZMIENNE ===
local speedOn = false
local walkSpeedValue = 16
local jumpOn = false
local jumpPowerValue = 50
local spectating = false
local targetPlayer = nil

-- Zmienne ESP
local playerEspOn = false
local computerEspOn = false
local doorEspOn = false

-- === PĘTLE FUNKCJONALNE ===
-- 1. Szybkość i Skok
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

-- 2. Spectate
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

-- 3. System ESP (Flee the Facility)
task.spawn(function()
    while true do
        -- ESP Graczy / Bestii
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local hl = p.Character:FindFirstChild("QuantumESP")
                if playerEspOn then
                    -- W FtF bestia zazwyczaj ma w ekwipunku lub ręce "Hammer" (młot)
                    local isBeast = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                    
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "QuantumESP"
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0.2
                        hl.Parent = p.Character
                    end
                    -- Bestia = Czerwony, Gracz = Zielony
                    hl.FillColor = isBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    hl.OutlineColor = isBeast and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                else
                    if hl then hl:Destroy() end
                end
            end
        end

        -- Funkcja pomocnicza do ESP obiektów (Komputery i Drzwi)
        local function handleObjEsp(objName, color, isOn)
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name == objName then
                    local hl = obj:FindFirstChild("QuantumESP")
                    if isOn then
                        if not hl then
                            hl = Instance.new("Highlight")
                            hl.Name = "QuantumESP"
                            hl.FillColor = color
                            hl.OutlineColor = color
                            hl.FillTransparency = 0.5
                            hl.OutlineTransparency = 0.2
                            hl.Parent = obj
                        end
                    else
                        if hl then hl:Destroy() end
                    end
                end
            end
        end

        -- Niebieski dla komputerów, Żółty dla drzwi wyjściowych
        handleObjEsp("ComputerTable", Color3.fromRGB(0, 200, 255), computerEspOn)
        handleObjEsp("ExitDoor", Color3.fromRGB(255, 255, 0), doorEspOn)

        task.wait(1) -- Odświeżamy co 1 sekundę, żeby nie lagować gry
    end
end)


-- === GŁÓWNA FUNKCJA ŁADUJĄCA INTERFEJS ===
local function LoadMainWindow()
    local function LoadMainWindow()
    if game.PlaceId == 893973440 then
        -- Jeśli to Flee the Facility, załaduj ten nowy plik
        loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/FleeTheFacility.lua"))()
    else
        -- Jeśli inna gra, odpalasz zwykły Hub, tak jak miałeś w starym kodzie
        loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua"))() -- (tutaj kod Twojego uniwersalnego huba z poprzednich wiadomości)
    end
    end
    
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Unseen. Unpatched. Unstoppable.",
        LoadingTitle = "Quantum X Hub",
        LoadingSubtitle = "by Quantum X Corp",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = true, FolderName = "QuantumX", FileName = "Config" },
        Discord = { Enabled = true, Invite = "XHEAeKSx34", RememberJoins = true },
        KeySystem = false
    })

    -- ZAKŁADKA 1: Flee the Facility
    local FtfTab = Window:CreateTab("Flee the Facility", 4483362458)
    
    FtfTab:CreateSection("Visuals (ESP)")
    FtfTab:CreateToggle({Name = "Enable Player & Beast ESP", CurrentValue = playerEspOn, Flag = "EspPlayer", Callback = function(Value) playerEspOn = Value end})
    FtfTab:CreateToggle({Name = "Enable Computers ESP", CurrentValue = computerEspOn, Flag = "EspComputer", Callback = function(Value) computerEspOn = Value end})
    FtfTab:CreateToggle({Name = "Enable Exit Doors ESP", CurrentValue = doorEspOn, Flag = "EspDoor", Callback = function(Value) doorEspOn = Value end})

    -- ZAKŁADKA 2: Universal Features
    local MainTab = Window:CreateTab("Features", 4483362458)
    
    MainTab:CreateSection("Movement")
    MainTab:CreateToggle({Name = "Enable WalkSpeed", CurrentValue = speedOn, Flag = "SpeedToggle", Callback = function(Value) 
        speedOn = Value 
        if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end
    end})
    MainTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 500}, Increment = 1, CurrentValue = walkSpeedValue, Callback = function(Value) 
        walkSpeedValue = Value 
        if speedOn and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = Value end
    end})
    MainTab:CreateToggle({Name = "Enable JumpPower", CurrentValue = jumpOn, Flag = "JumpToggle", Callback = function(Value) 
        jumpOn = Value 
        if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = 50 end
    end})
    MainTab:CreateSlider({Name = "JumpPower Value", Range = {50, 500}, Increment = 1, CurrentValue = jumpPowerValue, Callback = function(Value) 
        jumpPowerValue = Value 
        if jumpOn and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = Value end
    end})

    MainTab:CreateSection("Teleportation & Spectate")
    MainTab:CreateInput({Name = "Target Player Name", PlaceholderText = "Wpisz nazwę...", Callback = function(Text)
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():find(Text:lower()) then targetPlayer = v break end
        end
    end})
    MainTab:CreateButton({Name = "Teleport to Player", Callback = function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame 
        end
    end})
    MainTab:CreateToggle({Name = "Spectate Player", CurrentValue = spectating, Callback = function(Value) spectating = Value end})

    MainTab:CreateSection("Server Utils")
    MainTab:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
    MainTab:CreateButton({Name = "Server Hop", Callback = function()
        local Raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local Decode = Http:JSONDecode(Raw)
        for _, v in pairs(Decode.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, lp) break end
        end
    end})

    -- ZAKŁADKA 3: Hub Scripts (Skrypty Zewnętrzne)
    local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
    
    ScriptsTab:CreateSection("Exploiting Tools")
    ScriptsTab:CreateButton({Name = "Load Infinite Yield", Callback = function() 
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() 
    end})
    ScriptsTab:CreateButton({Name = "Load Dex Explorer", Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() 
    end})
    ScriptsTab:CreateButton({Name = "Load SimpleSpy", Callback = function() 
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))() 
    end})

    -- ZAKŁADKA 4: Settings
    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    
    SettingsTab:CreateSection("System & Credits")
    SettingsTab:CreateLabel("Unseen. Unpatched. Unstoppable. | Developed by Quantum X Team")
    SettingsTab:CreateDivider()
    SettingsTab:CreateButton({Name = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/XHEAeKSx34") end})
    SettingsTab:CreateButton({Name = "Destroy UI", Callback = function() 
        -- Niszczymy UI i czyścimy wszystkie ESP przed wyjściem
        playerEspOn = false; computerEspOn = false; doorEspOn = false
        task.wait(1.5) -- Czekamy aż pętla ESP oczyści mapę
        Rayfield:Destroy() 
        getgenv().QuantumXLoaded = false 
    end})

    Rayfield:LoadConfiguration()
end

-- === LOGIKA KEY ===
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') ~= nil
end

local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
local inputKey = ""

if SavedKey and CheckKey(SavedKey) then
    LoadMainWindow()
else
    local KeyWindow = Rayfield:CreateWindow({Name = "Quantum X | Verification", Theme = "Amethyst", KeySystem = false})
    local KeyTab = KeyWindow:CreateTab("Key System", nil)
    
    KeyTab:CreateButton({Name = "Otwórz checkpointy (Get Key)", Callback = function() 
        setclipboard("https://work.ink/2dRx/key-system")
    end})
    
    KeyTab:CreateInput({Name = "Wklej klucz", PlaceholderText = "Wpisz tutaj...", Callback = function(Value) inputKey = Value end})
    
    KeyTab:CreateButton({Name = "Zatwierdź klucz", Callback = function()
        if CheckKey(inputKey) then
            writefile(KeyFile, inputKey)
            Rayfield:Destroy()
            task.wait(0.5)
            LoadMainWindow()
        else
            Rayfield:Notify({Title = "Błąd", Content = "Nieprawidłowy klucz!"})
        end
    end})
end
