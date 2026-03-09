-- [[ Q U A N T U M   X   |   F L E E   T H E   F A C I L I T Y ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === GLOBAL VARIABLES ===
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false

-- FtF Variables
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave, autoCapture = false, false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 500
local evadeDistance = 55
local noPCErrorOn = false  -- NOWY TOGGLE

-- === HELPER FUNCTIONS ===
local function getBeast()
    for _, p in pairs(Players:GetPlayers()) do
        if p \~= lp and p.Character then
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
            if p \~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
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

-- === FTF AUTO-SKILLCHECK & CAPTURE + NO PC ERROR PROTECTION ===
if true then -- FtF
    task.spawn(function()
        while task.wait(0.05) do
            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
            if remote then
                if autoComputer and not isEvading and noPCErrorOn then
                    pcall(function()
                        remote:FireServer("Input", "Action", true)
                        remote:FireServer("SetPlayerStatus", 1)
                    end)
                elseif autoComputer and not isEvading then
                    pcall(function()
                        remote:FireServer("Input", "Action", true)
                        remote:FireServer("SetPlayerStatus", 1)
                    end)
                end

                if autoCapture then
                    local isMeBeast = lp.Character and (lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer")))
                    if isMeBeast then
                        local targetPlayer = getNearest(nil, true)
                        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                        if targetPlayer and targetPlayer:FindFirstChild("HumanoidRootPart") and hrp then
                            hrp.CFrame = targetPlayer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                            remote:FireServer("Input", "Swing", true)
                            task.wait(0.5)
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

-- === MAIN LOOP ===
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
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- === FTF ESP + SMART EVASION ===
task.spawn(function()
    while task.wait(0.3) do
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- ESP
        for _, p in pairs(Players:GetPlayers()) do
            if p \~= lp and p.Character then
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

        -- SMART EVASION
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
                    beastCampingTarget = true
                end
            end

            if beastNearMe or beastCampingTarget then
                if not isEvading then
                    savedPos = hrp.CFrame
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                    isEvading = true
                else
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                end
            else
                if isEvading then isEvading = false end
                if target then
                    local tRoot = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tRoot then
                        hrp.CFrame = CFrame.new(tRoot.Position + (tRoot.CFrame.LookVector * 4), tRoot.Position)
                    end
                end
            end
        end
    end
end)

-- === UI + NO PC ERROR TOGGLE ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Flee The Facility",
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Initializing...",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    local FtFTab = Window:CreateTab("FtF Main", 4483362458)
    FtFTab:CreateSection("Survivor Automation")
    FtFTab:CreateToggle({Name = "Auto-Computer (Smart Evade)", CurrentValue = false, Callback = function(v) autoComputer = v end})
    FtFTab:CreateToggle({Name = "Auto-Save (Tubes)", CurrentValue = false, Callback = function(v) autoSave = v end})
    FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = false, Callback = function(v) autoDoor = v end})
    
    FtFTab:CreateSection("Beast Automation")
    FtFTab:CreateToggle({Name = "Auto-Capture Players", CurrentValue = false, Callback = function(v) autoCapture = v end})

    FtFTab:CreateSection("Anti Detection")
    FtFTab:CreateToggle({Name = "No PC Error (Anti Kick - Yarhm style)", CurrentValue = false, Callback = function(v)
        noPCErrorOn = v
        if v then
            pcall(function()
                local mt = getrawmetatable(game)
                local old = mt.__namecall
                setreadonly(mt, false)
                mt.__namecall = newcclosure(function(self, ...)
                    if getnamecallmethod() == "Kick" and self == lp then return end
                    return old(self, ...)
                end)
                setreadonly(mt, true)
            end)
            Rayfield:Notify({Title = "No PC Error", Content = "Anti-Kick włączony! Nie wyrzuci za teleport do PC."})
        end
    end})

    local EspTab = Window:CreateTab("Visuals", 4483362458)
    EspTab:CreateToggle({Name = "Player & Beast ESP", CurrentValue = false, Callback = function(v) playerEspOn = v end})
    EspTab:CreateToggle({Name = "Computer ESP", CurrentValue = false, Callback = function(v) computerEspOn = v end})
    EspTab:CreateToggle({Name = "Exit Door ESP", CurrentValue = false, Callback = function(v) doorEspOn = v end})

    local LocalTab = Window:CreateTab("Local Player", 4483362458)
    LocalTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) noclipOn = v end})
    LocalTab:CreateToggle({Name = "WalkSpeed Override", CurrentValue = false, Callback = function(v) speedOn = v; if not v then lp.Character.Humanoid.WalkSpeed = 16 end end})
    LocalTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    LocalTab:CreateToggle({Name = "JumpPower Override", CurrentValue = false, Callback = function(v) jumpOn = v; if not v then lp.Character.Humanoid.JumpPower = 50 end end})
    LocalTab:CreateSlider({Name = "JumpPower Value", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) jumpPowerValue = v end})

    local ServerTab = Window:CreateTab("Server & UI", 4483362458)
    ServerTab:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) end})
    ServerTab:CreateButton({Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
    ServerTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})

    local CreditsTab = Window:CreateTab("Credits", 4483362458)
    CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
end

-- === KEY SYSTEM (bez zmian) ===
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') \~= nil
end

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
