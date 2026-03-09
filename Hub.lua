-- [[ QUANTUM X | SUPREME FTF & UNIVERSAL ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === SETTINGS & VARS ===
local isFtF = (game.PlaceId == 893973440)
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false
local noPCErrorOn = false

-- FtF Vars
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave, autoCapture = false, false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 550 
local evadeDistance = 50
local autoSaveActive = false
local autoCaptureActive = false
local lastSwingTime = 0
local swingCooldown = 0.5

-- === UTILITIES ===
local function getBeast()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            if p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer")) then
                return p.Character
            end
        end
    end
    return nil
end

local function getNearest(name, isPlayer)
    local nearest, dist = nil, math.huge
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    if isPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; nearest = p.Character end
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == name then
                local p = v:FindFirstChild("ComputerPart") or v:FindFirstChild("TouchInterest") or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (p.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = v end
                end
            end
        end
    end
    return nearest
end

local function getNearestPlayer()
    return getNearest(nil, true)
end

local function getNearestTube()
    local nearest, dist = nil, math.huge
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name == "Tube" or v.Name == "CryoTube") then
            local part = v:FindFirstChild("TouchInterest") and v:FindFirstChildWhichIsA("BasePart") or v:FindFirstChildWhichIsA("BasePart")
            if part then
                local d = (part.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; nearest = {model = v, part = part} end
            end
        end
    end
    return nearest
end

-- Funkcja do klikania w ekran (No PC Error)
local function ClickScreen()
    local vim = game:GetService("VirtualInputManager")
    local pos = Vector2.new(lp:GetMouse().X, lp:GetMouse().Y)
    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.05)
    vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

-- === CORE LOGIC ===
RunService.Stepped:Connect(function()
    if lp.Character then
        local hum = lp.Character:FindFirstChild("Humanoid")
        if hum then
            if speedOn then hum.WalkSpeed = walkSpeedValue end
            if jumpOn then hum.JumpPower = jumpPowerValue end
        end
        if noclipOn then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if isEvading then 
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0,0,0) 
            end
        end
    end
end)

-- Auto-click do No PC Error
task.spawn(function()
    while task.wait(0.1) do
        if noPCErrorOn then
            ClickScreen()
        end
    end
end)

-- FtF Specific Loop
if isFtF then
    task.spawn(function()
        while task.wait(0.3) do
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.5); continue end

            -- 1. ESP Logic
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then 
                            hl = Instance.new("Highlight", p.Character)
                            hl.Name = "QuantumESP"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        end
                        local beast = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = beast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                    elseif hl then hl:Destroy() end
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if v.Name == "ComputerTable" then
                        local hl = v:FindFirstChild("QuantumESP")
                        if computerEspOn then
                            if not hl then 
                                hl = Instance.new("Highlight", v)
                                hl.Name = "QuantumESP"
                                hl.FillColor = Color3.fromRGB(0, 255, 255)
                                hl.FillTransparency = 0.5
                            end
                        elseif hl then hl:Destroy() end
                    elseif v.Name == "ExitDoor" then
                        local hl = v:FindFirstChild("QuantumESP")
                        if doorEspOn then
                            if not hl then 
                                hl = Instance.new("Highlight", v)
                                hl.Name = "QuantumESP"
                                hl.FillColor = Color3.fromRGB(255, 255, 0)
                                hl.FillTransparency = 0.5
                            end
                        elseif hl then hl:Destroy() end
                    end
                end
            end

            -- 2. Smart Teleport & Evasion
            if autoComputer or autoDoor or autoSave then
                local beast = getBeast()
                local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                
                local target = nil
                if autoSave then 
                    local tubeData = getNearestTube()
                    target = tubeData and tubeData.model
                end
                if not target and autoComputer then target = getNearest("ComputerTable", false) end
                if not target and autoDoor then target = getNearest("ExitDoor", false) end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChild("TouchInterest") or target:FindFirstChildWhichIsA("BasePart")
                    if tPart then
                        local beastNearMe = bPos and (bPos - hrp.Position).Magnitude < evadeDistance
                        local beastNearTarget = bPos and (bPos - tPart.Position).Magnitude < evadeDistance
                        
                        if beastNearMe or beastNearTarget then
                            if not isEvading then
                                savedPos = hrp.CFrame
                                isEvading = true
                            end
                            hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        else
                            isEvading = false
                            hrp.CFrame = tPart.CFrame * CFrame.new(0, 2, 4)
                            
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                            if remote then
                                if autoComputer then
                                    remote:FireServer("Input", "Action", true)
                                    remote:FireServer("SetPlayerStatus", 1)
                                end
                                if autoSave then
                                    remote:FireServer("StartTubeMinigame")
                                end
                            end
                        end
                    end
                end
            end
            
            -- 3. Auto-Capture (Beast) - NAPRAWIONE
            if autoCapture then
                local isBeast = lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer"))
                if isBeast then
                    local vic = getNearestPlayer()
                    if vic and vic:FindFirstChild("HumanoidRootPart") then
                        local vicHrp = vic.HumanoidRootPart
                        local distance = (vicHrp.Position - hrp.Position).Magnitude
                        
                        -- Teleport za ofiarę
                        hrp.CFrame = vicHrp.CFrame * CFrame.new(0, 0, 5)
                        
                        -- Automatyczne machanie młotem
                        local currentTime = tick()
                        if currentTime - lastSwingTime > swingCooldown and distance < 20 then
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                            if remote then
                                -- Różne metody ataku
                                remote:FireServer("Input", "Swing", true)
                                remote:FireServer("SwingHammer")
                                remote:FireServer("Attack")
                                task.wait(0.1)
                                remote:FireServer("Input", "Swing", false)
                                lastSwingTime = currentTime
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- === UI LOADING ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | " .. (isFtF and "Flee The Facility" or "Universal"),
        Theme = "Amethyst",
        Size = UDim2.new(0, 500, 0, 400)
    })

    if isFtF then
        local FtFTab = Window:CreateTab("FtF Main", 4483362458)
        FtFTab:CreateSection("Automation")
        FtFTab:CreateToggle({
            Name = "Auto-Computer (Smart)", 
            CurrentValue = false, 
            Callback = function(v) autoComputer = v end
        })
        FtFTab:CreateToggle({
            Name = "Auto-Save (Tubes) - NAPRAWIONE", 
            CurrentValue = false, 
            Callback = function(v) 
                autoSave = v
                if v then
                    Rayfield:Notify({
                        Title = "Auto-Save",
                        Content = "Auto-save aktywne! Skrypt będzie automatycznie zapisywać w tubach.",
                        Duration = 3
                    })
                end
            end
        })
        FtFTab:CreateToggle({
            Name = "Auto-Exit Door", 
            CurrentValue = false, 
            Callback = function(v) autoDoor = v end
        })
        FtFTab:CreateToggle({
            Name = "Auto-Capture (Beast) - NAPRAWIONE", 
            CurrentValue = false, 
            Callback = function(v) 
                autoCapture = v
                if v then
                    Rayfield:Notify({
                        Title = "Auto-Capture",
                        Content = "Auto-capture aktywne! Skrypt będzie automatycznie gonić i bić ofiary.",
                        Duration = 3
                    })
                end
            end
        })

        local EspTab = Window:CreateTab("Visuals", 4483362458)
        EspTab:CreateToggle({
            Name = "Player ESP", 
            CurrentValue = false, 
            Callback = function(v) playerEspOn = v end
        })
        EspTab:CreateToggle({
            Name = "Computer ESP", 
            CurrentValue = false, 
            Callback = function(v) computerEspOn = v end
        })
        EspTab:CreateToggle({
            Name = "Door ESP", 
            CurrentValue = false, 
            Callback = function(v) doorEspOn = v end
        })
    end

    local PlayerTab = Window:CreateTab("Player", 4483362458)
    PlayerTab:CreateToggle({
        Name = "WalkSpeed", 
        CurrentValue = false, 
        Callback = function(v) speedOn = v end
    })
    PlayerTab:CreateSlider({
        Name = "Speed", 
        Range = {16, 200}, 
        Increment = 1, 
        CurrentValue = 16, 
        Callback = function(v) walkSpeedValue = v end
    })
    PlayerTab:CreateToggle({
        Name = "JumpPower", 
        CurrentValue = false, 
        Callback = function(v) jumpOn = v end
    })
    PlayerTab:CreateSlider({
        Name = "Jump Power", 
        Range = {50, 200}, 
        Increment = 1, 
        CurrentValue = 50, 
        Callback = function(v) jumpPowerValue = v end
    })
    PlayerTab:CreateToggle({
        Name = "Noclip", 
        CurrentValue = false, 
        Callback = function(v) noclipOn = v end
    })
    PlayerTab:CreateToggle({
        Name = "⚡ No PC Error (Auto-click)", 
        CurrentValue = false, 
        Callback = function(v) 
            noPCErrorOn = v
            if v then
                Rayfield:Notify({
                    Title = "No PC Error",
                    Content = "Auto-click aktyny! Skrypt klika za ciebie.",
                    Duration = 3
                })
            end
        end
    })

    local ServerTab = Window:CreateTab("Server", 4483362458)
    ServerTab:CreateButton({
        Name = "Rejoin", 
        Callback = function() TeleportService:Teleport(game.PlaceId, lp) end
    })
    ServerTab:CreateButton({
        Name = "Server Hop", 
        Callback = function() TeleportService:Teleport(game.PlaceId) end
    })
    ServerTab:CreateButton({
        Name = "Destroy UI", 
        Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end
    })

    local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
    ScriptsTab:CreateButton({
        Name = "Infinite Yield", 
        Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end
    })
    ScriptsTab:CreateButton({
        Name = "Dex Explorer", 
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end
    })

    local CreditsTab = Window:CreateTab("Credits", 4483362458)
    CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
    CreditsTab:CreateLabel("⚡ No PC Error toggle dodany")
    CreditsTab:CreateLabel("🔧 Auto-Save naprawione")
    CreditsTab:CreateLabel("🔨 Auto-Capture naprawione")
end

-- === KEY SYSTEM - NAPRAWIONY ===
local function ShowNotification(title, text, duration)
    if Rayfield and Rayfield:Notify then
        Rayfield:Notify({Title = title, Content = text, Duration = duration or 5})
    else
        warn(string.format("[%s] %s", title, text))
    end
end

local function CheckKey(Token)
    if not Token or Token == "" then return false end
    
    local apiUrl = "https://work.ink/_api/v2/token/isValid?token=" .. Token
    
    local success, response = pcall(function()
        return game:HttpGet(apiUrl)
    end)
    
    if not success or not response then
        warn("Błąd połączenia z API")
        return false
    end
    
    local decodedSuccess, decodedData = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if decodedSuccess and decodedData and decodedData.valid == true then
        return true
    else
        warn("Nieprawidłowa odpowiedź API")
        return false
    end
end

local KeyFile = "QuantumX_Key.txt"
local SavedKey = nil

if isfile and isfile(KeyFile) then
    local success, data = pcall(readfile, KeyFile)
    if success then SavedKey = data end
end

local inputKey = ""

if SavedKey and CheckKey(SavedKey) then
    LoadMainWindow()
else
    for _, v in pairs(game.CoreGui:GetDescendants()) do
        if v.Name == "QuantumX_KeyWin" then
            v:Destroy()
        end
    end
    
    task.wait(0.5)
    
    local KeyWin = Rayfield:CreateWindow({
        Name = "🔐 Quantum X | Weryfikacja Klucza",
        Theme = "Amethyst",
        Size = UDim2.new(0, 350, 0, 250)
    })
    KeyWin.Name = "QuantumX_KeyWin"
    
    task.wait(0.3)
    
    local KeyTab = KeyWin:CreateTab("🔑 Klucz Dostępu", 4483362458)
    
    KeyTab:CreateLabel("Wpisz swój klucz Quantum X")
    KeyTab:CreateLabel("-----------------------------------")
    
    KeyTab:CreateInput({
        Name = "Klucz", 
        CurrentValue = "",
        PlaceholderText = "np. QX-XXXX-XXXX",
        Callback = function(v) inputKey = v end
    })
    
    KeyTab:CreateButton({
        Name = "✅ Sprawdź klucz", 
        Callback = function()
            if not inputKey or inputKey == "" then
                ShowNotification("❌ Błąd", "Wpisz klucz dostępu!", 3)
                return
            end
            
            ShowNotification("⏳ Sprawdzanie", "Weryfikacja klucza...", 2)
            
            local isValid = CheckKey(inputKey)
            
            if isValid then
                if writefile then
                    pcall(writefile, KeyFile, inputKey)
                end
                
                ShowNotification("✅ Sukces", "Klucz poprawny! Ładowanie Quantum X...", 2)
                task.wait(1)
                KeyWin:Destroy()
                task.wait(0.3)
                LoadMainWindow()
            else
                ShowNotification("❌ Błąd", "Nieprawidłowy klucz! Sprawdź i spróbuj ponownie.", 4)
            end
        end
    })
    
    KeyTab:CreateLabel("-----------------------------------")
    KeyTab:CreateLabel("Potrzebujesz klucza?")
    KeyTab:CreateButton({
        Name = "🌐 Otwórz discord.gg/quantumx", 
        Callback = function()
            setclipboard("https://discord.gg/quantumx")
            ShowNotification("📋 Skopiowano", "Link do discord skopiowany do schowka!", 3)
        end
    })
    
    KeyTab:CreateLabel("-----------------------------------")
    KeyTab:CreateLabel("🔧 Tryb testowy:")
    KeyTab:CreateButton({
        Name = "🧪 Użyj klucza testowego (test123)", 
        Callback = function()
            inputKey = "test123"
            ShowNotification("🧪 Tryb testowy", "Kliknij 'Sprawdź klucz' z kluczem test123", 3)
        end
    })
end
