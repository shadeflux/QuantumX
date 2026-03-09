-- [[ QUANTUM X | SUPREME FTF & UNIVERSAL ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === SETTINGS & VARS ===
local isFtF = (game.PlaceId == 893973440)
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false

-- FtF Vars
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave, autoCapture = false, false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 550 
local evadeDistance = 50 -- Distance from beast to trigger evasion

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
                local p = v:FindFirstChild("ComputerPart") or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (p.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = v end
                end
            end
        end
    end
    return nearest
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
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) 
        end
    end
end)

-- FtF Specific Loop
if isFtF then
    task.spawn(function()
        while task.wait(0.3) do
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- 1. ESP Logic
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "QuantumESP" end
                        local beast = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = beast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
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

            -- 2. Smart Teleport & Evasion
            if autoComputer or autoDoor or autoSave then
                local beast = getBeast()
                local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                
                local target = nil
                if autoSave then target = getNearest("Tube", false) end
                if not target and autoComputer then target = getNearest("ComputerTable", false) end
                if not target and autoDoor then target = getNearest("ExitDoor", false) end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
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
                            -- FIX: Y-Offset +2 to prevent teleporting under floor
                            hrp.CFrame = tPart.CFrame * CFrame.new(0, 2, 4)
                            
                            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
                            if remote and autoComputer then
                                remote:FireServer("Input", "Action", true)
                                remote:FireServer("SetPlayerStatus", 1)
                            end
                        end
                    end
                end
            end
            
            -- 3. Auto-Capture (Beast)
            if autoCapture then
                local isBeast = lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer"))
                if isBeast then
                    local vic = getNearest(nil, true)
                    if vic and vic:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = vic.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        ReplicatedStorage.RemoteEvent:FireServer("Input", "Swing", true)
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
        Theme = "Amethyst"
    })

    if isFtF then
        local FtFTab = Window:CreateTab("FtF Main", 4483362458)
        FtFTab:CreateSection("Automation")
        FtFTab:CreateToggle({Name = "Auto-Computer (Smart)", CurrentValue = false, Callback = function(v) autoComputer = v end})
        FtFTab:CreateToggle({Name = "Auto-Save (Tubes)", CurrentValue = false, Callback = function(v) autoSave = v end})
        FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = false, Callback = function(v) autoDoor = v end})
        FtFTab:CreateToggle({Name = "Auto-Capture (Beast)", CurrentValue = false, Callback = function(v) autoCapture = v end})

        local EspTab = Window:CreateTab("Visuals", 4483362458)
        EspTab:CreateToggle({Name = "Player ESP", CurrentValue = false, Callback = function(v) playerEspOn = v end})
        EspTab:CreateToggle({Name = "Computer ESP", CurrentValue = false, Callback = function(v) computerEspOn = v end})
        EspTab:CreateToggle({Name = "Door ESP", CurrentValue = false, Callback = function(v) doorEspOn = v end})
    end

    local PlayerTab = Window:CreateTab("Player", 4483362458)
    PlayerTab:CreateToggle({Name = "WalkSpeed", Callback = function(v) speedOn = v end})
    PlayerTab:CreateSlider({Name = "Speed", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    PlayerTab:CreateToggle({Name = "Noclip", Callback = function(v) noclipOn = v end})

    local ServerTab = Window:CreateTab("Server", 4483362458)
    ServerTab:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
    ServerTab:CreateButton({Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId) end})
    ServerTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})

    local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
    ScriptsTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
    ScriptsTab:CreateButton({Name = "Dex Explorer", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end})

    local CreditsTab = Window:CreateTab("Credits", 4483362458)
    CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
end

-- === KEY SYSTEM ===
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') ~= nil
end

local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
local inputKey = ""

if SavedKey and CheckKey(SavedKey) then LoadMainWindow() else
    local KeyWin = Rayfield:CreateWindow({Name = "Quantum X | Key System", Theme = "Amethyst"})
    local KeyTab = KeyWin:CreateTab("Verification")
    KeyTab:CreateInput({Name = "Enter Key", Callback = function(v) inputKey = v end})
    KeyTab:CreateButton({Name = "Verify", Callback = function()
        if CheckKey(inputKey) then writefile(KeyFile, inputKey); KeyWin:Destroy(); LoadMainWindow() end
    end})
end
