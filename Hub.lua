-- [[ Q U A N T U M   X   |   U N I V E R S A L   &   F T F ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === GLOBAL VARIABLES ===
local isFtF = (game.PlaceId == 893973440)
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false

-- FtF Variables
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave, autoCapture = false, false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 500
local evadeDistance = 55 -- Dystans, z jakiego uciekamy przed bestią

-- === HELPER FUNCTIONS ===
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

local function getNearest(objectName, isPlayer)
    local nearest, shortestDist = nil, math.huge
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = lp.Character.HumanoidRootPart.Position

    if isPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                -- Ignore if they are the beast
                if not (p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))) then
                    local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < shortestDist then shortestDist = dist; nearest = p.Character end
                end
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == objectName then
                local root = v:FindFirstChild("ComputerPart") or v:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - myPos).Magnitude
                    if dist < shortestDist then shortestDist = dist; nearest = v end
                end
            end
        end
    end
    return nearest
end

-- === FTF AUTO-SKILLCHECK & CAPTURE LOGIC ===
if isFtF then
    task.spawn(function()
        while task.wait(0.05) do
            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
            if remote then
                -- Perfect Skillcheck / Auto Hack
                if autoComputer and not isEvading then
                    pcall(function()
                        remote:FireServer("Input", "Action", true)
                        remote:FireServer("SetPlayerStatus", 1)
                    end)
                end
                -- Auto Capture (Beast Mode)
                if autoCapture then
                    local isMeBeast = lp.Character and (lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer")))
                    if isMeBeast then
                        local targetPlayer = getNearest(nil, true)
                        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                        if targetPlayer and targetPlayer:FindFirstChild("HumanoidRootPart") and hrp then
                            -- Teleport to player and swing
                            hrp.CFrame = targetPlayer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                            remote:FireServer("Input", "Swing", true)
                            task.wait(0.5)
                            -- Teleport to Tube to freeze them
                            local tube = getNearest("Tube", false)
                            if tube then
                                local tPart = tube:FindFirstChildWhichIsA("BasePart")
                                if tPart then
                                    hrp.CFrame = tPart.CFrame * CFrame.new(0,0,3)
                                    remote:FireServer("Input", "Action", true)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- === MAIN LOOP (MOVEMENT, ESP, EVASION) ===
RunService.Stepped:Connect(function()
    if lp.Character then
        local h = lp.Character:FindFirstChild("Humanoid")
        if h then
            if speedOn then h.WalkSpeed = walkSpeedValue end
            if jumpOn then h.JumpPower = jumpPowerValue end
        end
        if noclipOn then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        if isEvading and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) -- Zamrożenie w powietrzu
        end
    end
end)

if isFtF then
    task.spawn(function()
        while task.wait(0.3) do
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- 1. ESP LOGIC
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "QuantumESP" end
                        local isBeastCheck = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = isBeastCheck and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                        hl.OutlineColor = Color3.fromRGB(255,255,255)
                    elseif hl then hl:Destroy() end
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if v.Name == "ComputerTable" then
                        local hl = v:FindFirstChild("QuantumESP")
                        if computerEspOn then
                            if not hl then hl = Instance.new("Highlight", v); hl.Name = "QuantumESP"; hl.FillColor = Color3.fromRGB(0, 255, 255) end
                        elseif hl then hl:Destroy() end
                    elseif v.Name == "ExitDoor" then
                        local hl = v:FindFirstChild("QuantumESP")
                        if doorEspOn then
                            if not hl then hl = Instance.new("Highlight", v); hl.Name = "QuantumESP"; hl.FillColor = Color3.fromRGB(255, 255, 0) end
                        elseif hl then hl:Destroy() end
                    end
                end
            end

            -- 2. SMART EVASION & TELEPORT LOGIC
            if autoComputer or autoDoor or autoSave then
                local beast = getBeast()
                local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                
                local target = nil
                if autoSave then target = getNearest("Tube", false) end
                if not target and autoComputer then target = getNearest("ComputerTable", false) end
                if not target and autoDoor then target = getNearest("ExitDoor", false) end

                local beastNearMe = bPos and (bPos - hrp.Position).Magnitude < evadeDistance
                local beastCampingTarget = false

                if target and bPos then
                    local tRoot = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tRoot and (bPos - tRoot.Position).Magnitude < evadeDistance then
                        beastCampingTarget = true -- Bestia stoi przy komputerze!
                    end
                end

                -- Jeśli bestia blisko nas ALBO kampi przy komputerze -> Uciekamy / Zostajemy w górze
                if beastNearMe or beastCampingTarget then
                    if not isEvading then
                        savedPos = hrp.CFrame
                        hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        isEvading = true
                    else
                        hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z) -- Anti-Gravity
                    end
                else
                    -- Bezpiecznie! Teleport do celu
                    if isEvading then isEvading = false end
                    if target then
                        local tRoot = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                        if tRoot then
                            -- Teleport przodem do obiektu
                            hrp.CFrame = CFrame.new(tRoot.Position + (tRoot.CFrame.LookVector * 4), tRoot.Position)
                        end
                    end
                end
            end
        end
    end)
end

-- === KEY SYSTEM & UI ===
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') ~= nil
end

local function LoadMainWindow()
    local WindowName = isFtF and "Quantum X | Flee The Facility" or "Quantum X | Universal Hub"
    local Window = Rayfield:CreateWindow({
        Name = WindowName,
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Initializing...",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    if isFtF then
        local FtFTab = Window:CreateTab("FtF Main", 4483362458)
        FtFTab:CreateSection("Survivor Automation")
        FtFTab:CreateToggle({Name = "Auto-Computer (Smart Evade)", CurrentValue = false, Callback = function(v) autoComputer = v end})
        FtFTab:CreateToggle({Name = "Auto-Save (Tubes)", CurrentValue = false, Callback = function(v) autoSave = v end})
        FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = false, Callback = function(v) autoDoor = v end})
        
        FtFTab:CreateSection("Beast Automation")
        FtFTab:CreateToggle({Name = "Auto-Capture Players", CurrentValue = false, Callback = function(v) autoCapture = v end})

        local EspTab = Window:CreateTab("Visuals", 4483362458)
        EspTab:CreateToggle({Name = "Player & Beast ESP", CurrentValue = false, Callback = function(v) playerEspOn = v end})
        EspTab:CreateToggle({Name = "Computer ESP", CurrentValue = false, Callback = function(v) computerEspOn = v end})
        EspTab:CreateToggle({Name = "Exit Door ESP", CurrentValue = false, Callback = function(v) doorEspOn = v end})
    end

    local LocalTab = Window:CreateTab("Local Player", 4483362458)
    LocalTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) noclipOn = v end})
    LocalTab:CreateToggle({Name = "WalkSpeed Override", CurrentValue = false, Callback = function(v) speedOn = v; if not v then lp.Character.Humanoid.WalkSpeed = 16 end end})
    LocalTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    LocalTab:CreateToggle({Name = "JumpPower Override", CurrentValue = false, Callback = function(v) jumpOn = v; if not v then lp.Character.Humanoid.JumpPower = 50 end end})
    LocalTab:CreateSlider({Name = "JumpPower Value", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) jumpPowerValue = v end})

    local ServerTab = Window:CreateTab("Server & UI", 4483362458)
    ServerTab:CreateButton({Name = "Rejoin Server", Callback = function() 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) 
    end})
    ServerTab:CreateButton({Name = "Server Hop", Callback = function()
        -- Basic server hop wrapper
        TeleportService:Teleport(game.PlaceId, lp)
    end})
    ServerTab:CreateButton({Name = "Destroy UI", Callback = function() 
        Rayfield:Destroy(); getgenv().QuantumXLoaded = false 
    end})

    local CreditsTab = Window:CreateTab("Credits", 4483362458)
    CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
end

-- Key Verification Execution
local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
local inputKey = ""

if SavedKey and CheckKey(SavedKey) then
    LoadMainWindow()
else
    local KeyWindow = Rayfield:CreateWindow({Name = "Quantum X | Verification", Theme = "Amethyst", KeySystem = false})
    local KeyTab = KeyWindow:CreateTab("Key System", nil)
    KeyTab:CreateButton({Name = "Get Key", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    KeyTab:CreateInput({Name = "Paste Key", PlaceholderText = "Enter key here...", Callback = function(v) inputKey = v end})
    KeyTab:CreateButton({Name = "Verify", Callback = function()
        if CheckKey(inputKey) then
            writefile(KeyFile, inputKey); KeyWindow:Destroy(); task.wait(0.5); LoadMainWindow()
        else
            Rayfield:Notify({Title = "Error", Content = "Invalid Key provided!"})
        end
    end})
end
