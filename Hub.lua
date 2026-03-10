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

-- Funkcja No PC Error (Yarhm style)
local function startNoPCError()
    task.spawn(function()
        while noPCErrorOn do
            pcall(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton1(Vector2.new(0,0))
            end)
            task.wait(0.1)
        end
    end)
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

-- No PC Error loop
task.spawn(function()
    while task.wait(0.1) do
        if noPCErrorOn then
            startNoPCError()
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
            
            -- 3. Auto-Capture (Beast)
            if autoCapture then
                local isBeast = lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer"))
                if isBeast then
                    local vic = getNearestPlayer()
                    if vic and vic:FindFirstChild("HumanoidRootPart") then
                        local vicHrp = vic.HumanoidRootPart
                        local distance = (vicHrp.Position - hrp.Position).Magnitude
                        
                        hrp.CFrame = vicHrp.CFrame * CFrame.new(0, 0, 5)
                        
                        local currentTime = tick()
                        if currentTime - lastSwingTime > swingCooldown and distance < 20 then
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                            if remote then
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

-- === FUNKCJE POMOCNICZE ===
local function Notify(title, text, duration)
    if Rayfield and Rayfield:Notify then
        Rayfield:Notify({Title = title, Content = text, Duration = duration or 5})
    else
        warn("[" .. title .. "] " .. text)
    end
end

-- === FUNKCJA SPRAWDZANIA KLUCZA ===
local function CheckKey(token)
    if not token or token == "" then return false end
    
    local url = "https://work.ink/_api/v2/token/isValid?token=" .. token
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success or not response then
        warn("Błąd połączenia z API kluczy")
        return false
    end
    
    local decodedSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    
    if decodedSuccess and decoded and decoded.valid == true then
        return true
    else
        return false
    end
end

-- === GŁÓWNE OKNO ===
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
            Name = "Auto-Save (Tubes)", 
            CurrentValue = false, 
            Callback = function(v) autoSave = v end
        })
        FtFTab:CreateToggle({
            Name = "Auto-Exit Door", 
            CurrentValue = false, 
            Callback = function(v) autoDoor = v end
        })
        FtFTab:CreateToggle({
            Name = "Auto-Capture (Beast)", 
            CurrentValue = false, 
            Callback = function(v) autoCapture = v end
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
        Name = "⚡ No PC Error", 
        CurrentValue = false, 
        Callback = function(v) 
            noPCErrorOn = v
            if v then Notify("No PC Error", "Aktywny!", 2) end
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
    CreditsTab:CreateLabel("Quantum X | Supreme FtF & Universal")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
    CreditsTab:CreateLabel("⚡ No PC Error included")
    CreditsTab:CreateLabel("🔑 Key System active")
end

-- === KEY SYSTEM (EsidelieHub style) ===
local KeyFile = "QuantumX_Key.txt"
local SavedKey = nil

pcall(function()
    if isfile and isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = false
if SavedKey then
    KeyValid = CheckKey(SavedKey)
end

if KeyValid then
    Notify("Auto-Login", "Zapisany klucz ważny – hub załadowany!", 8)
    LoadMainWindow()
else
    if SavedKey then
        pcall(function() delfile(KeyFile) end)
    end
    
    local KeyWin = Rayfield:CreateWindow({
        Name = "🔑 Quantum X | Key System",
        Theme = "Amethyst",
        Size = UDim2.new(0, 400, 0, 300)
    })
    
    local KeyTab = KeyWin:CreateTab("Verification", 4483362458)
    
    KeyTab:CreateLabel("🔐 SYSTEM KLUCZY QUANTUM X")
    KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy!")
    KeyTab:CreateLabel("-----------------------------------")
    
    KeyTab:CreateButton({
        Name = "🌐 Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/quantumx-key")
            Notify("Link skopiowany!", "Wklej w przeglądarkę i ukończ kroki.", 8)
        end
    })
    
    local inputKey = ""
    
    KeyTab:CreateInput({
        Name = "🔐 Wklej klucz tutaj",
        PlaceholderText = "np. QX-1234-5678",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            inputKey = Token
        end
    })
    
    KeyTab:CreateButton({
        Name = "✅ Zatwierdź klucz",
        Callback = function()
            if inputKey == "" then
                Notify("Błąd", "Wklej klucz!", 5)
                return
            end
            
            Notify("Sprawdzanie", "Weryfikacja klucza...", 3)
            
            if CheckKey(inputKey) then
                Notify("Sukces!", "Klucz poprawny! Ładowanie...", 5)
                
                pcall(function()
                    writefile(KeyFile, inputKey)
                end)
                
                task.wait(1)
                KeyWin:Destroy()
                task.wait(0.3)
                LoadMainWindow()
            else
                Notify("Błąd", "Nieprawidłowy lub wygasły klucz!", 5)
            end
        end
    })
    
    KeyTab:CreateLabel("-----------------------------------")
    KeyTab:CreateLabel("⚡ No PC Error w zakładce Player")
end
