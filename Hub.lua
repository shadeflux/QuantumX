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
local noPCError = false
local isEvading, savedPos = false, nil
local safeHeight = 550 
local evadeDistance = 50

-- === UTILITIES ===
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

local function getNearest(name, isPlayer)
    local nearest, dist = nil, math.huge
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local myPos = lp.Character.HumanoidRootPart.Position
    
    if isPlayer then
        for _, p in pairs(Players:GetPlayers()) do
            if p \~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
                if d < dist then dist = d; nearest = p.Character end
            end
        end
    else
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name == name then
                local p = v:FindFirstChild("ComputerPart") or v:FindFirstChildWhichIsA("BasePart")
                if p then
                    local d = (p.Position - myPos).Magnitude
                    if d < dist then dist = d; nearest = v end
                end
            end
        end
    end
    return nearest
end

-- === ANTI-KICK HOOK (No PC Error) ===
local function enableNoPCError()
    if noPCError then return end
    noPCError = true
    pcall(function()
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" and self == lp then
                return -- blokujemy kick
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- === CORE MOVEMENT ===
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
        if isEvading and lp.Character:FindFirstChild("HumanoidRootPart") then 
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) 
        end
    end
end)

-- === FtF MAIN LOOP ===
if isFtF then
    task.spawn(function()
        while task.wait(0.08) do  -- szybszy tick dla auto-capture
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- ESP
            for _, p in pairs(Players:GetPlayers()) do
                if p \~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "QuantumESP" end
                        local isBeast = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = isBeast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                        hl.OutlineColor = Color3.fromRGB(220,220,255)
                    elseif hl then hl:Destroy() end
                end
            end

            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if v.Name == "ComputerTable" and computerEspOn then
                        local hl = v:FindFirstChild("QuantumESP") or Instance.new("Highlight", v)
                        hl.Name = "QuantumESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 255)
                    elseif v.Name == "ExitDoor" and doorEspOn then
                        local hl = v:FindFirstChild("QuantumESP") or Instance.new("Highlight", v)
                        hl.Name = "QuantumESP"
                        hl.FillColor = Color3.fromRGB(255, 215, 0)
                    end
                end
            end

            -- Auto Computer / Door / Save + Smart Evasion
            if autoComputer or autoDoor or autoSave then
                local beast = getBeast()
                local bPos = beast and beast.HumanoidRootPart and beast.HumanoidRootPart.Position
                
                local target = nil
                if autoSave then target = getNearest("Tube", false) end
                if not target and autoComputer then target = getNearest("ComputerTable", false) end
                if not target and autoDoor then target = getNearest("ExitDoor", false) end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tPart then
                        local beastNearMe    = bPos and (bPos - hrp.Position).Magnitude < evadeDistance
                        local beastNearTarget = bPos and (bPos - tPart.Position).Magnitude < evadeDistance
                        
                        if beastNearMe or beastNearTarget then
                            if not isEvading then isEvading = true end
                            hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        else
                            isEvading = false
                            hrp.CFrame = tPart.CFrame * CFrame.new(0, 3, -4)  -- lekko z boku/tyłu
                            
                            local remote = ReplicatedStorage:WaitForChild("RemoteEvent", 5)
                            if remote and autoComputer then
                                remote:FireServer("Input", "Action", true)
                                remote:FireServer("SetPlayerStatus", 1)
                            end
                        end
                    end
                end
            end
            
            -- Auto-Capture – teleport + SPAM swing
            if autoCapture then
                local isBeast = lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer"))
                if isBeast then
                    local victim = getNearest(nil, true)
                    if victim and victim:FindFirstChild("HumanoidRootPart") then
                        -- Teleport tuż za plecami (negative Z = za plecami)
                        hrp.CFrame = victim.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.8) * CFrame.Angles(0, math.pi, 0)
                        
                        local remote = ReplicatedStorage:WaitForChild("RemoteEvent", 3)
                        if remote then
                            -- Natychmiastowy swing + spam co tick (działa lepiej niż pojedynczy)
                            remote:FireServer("Input", "Swing", true)
                            -- Można dodać task.spawn z wait(0.1) i kolejnym swing jeśli chcesz jeszcze mocniej
                        end
                    end
                end
            end
        end
    end)
end

-- === UI ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | " .. (isFtF and "Supreme FtF" or "Universal"),
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Supreme Edition",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = false }
    })

    if isFtF then
        local FtFTab = Window:CreateTab("FtF Main", 4483362458)
        FtFTab:CreateSection("Automation")
        FtFTab:CreateToggle({Name = "Auto-Computer (Smart)", CurrentValue = false, Callback = function(v) autoComputer = v end})
        FtFTab:CreateToggle({Name = "Auto-Save (Tubes)", CurrentValue = false, Callback = function(v) autoSave = v end})
        FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = false, Callback = function(v) autoDoor = v end})
        
        FtFTab:CreateSection("Beast")
        FtFTab:CreateToggle({Name = "Auto-Capture + Instant Hammer", CurrentValue = false, Callback = function(v) autoCapture = v end})

        FtFTab:CreateSection("Anti-Detection")
        FtFTab:CreateToggle({Name = "No PC Error (Anti-Kick)", CurrentValue = false, Callback = function(v)
            if v then enableNoPCError() end
        end})

        local EspTab = Window:CreateTab("Visuals")
        EspTab:CreateToggle({Name = "Player ESP", Callback = function(v) playerEspOn = v end})
        EspTab:CreateToggle({Name = "Computer ESP", Callback = function(v) computerEspOn = v end})
        EspTab:CreateToggle({Name = "Door ESP", Callback = function(v) doorEspOn = v end})
    end

    local PlayerTab = Window:CreateTab("Player")
    PlayerTab:CreateToggle({Name = "WalkSpeed", Callback = function(v) speedOn = v end})
    PlayerTab:CreateSlider({Name = "Speed Value", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    PlayerTab:CreateToggle({Name = "Noclip", Callback = function(v) noclipOn = v end})

    local ServerTab = Window:CreateTab("Server")
    ServerTab:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
    ServerTab:CreateButton({Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId) end})
    ServerTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})

    local CreditsTab = Window:CreateTab("Credits")
    CreditsTab:CreateLabel("Quantum X – Unseen. Supreme. Unstoppable.")
end

-- === KEY SYSTEM (bez zmian) ===
local function CheckKey(Token)
    local s, r = pcall(game.HttpGet, game, "https://work.ink/_api/v2/token/isValid/" .. Token)
    return s and r:find('"valid":true') 
end

local KeyFile = "QuantumX_Key.txt"
local saved = isfile and isfile(KeyFile) and readfile(KeyFile)

if saved and CheckKey(saved) then
    LoadMainWindow()
else
    local kw = Rayfield:CreateWindow({Name = "Quantum X | Key", Theme = "Amethyst"})
    local kt = kw:CreateTab("Key")
    kt:CreateButton({Name = "Copy Link", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    kt:CreateInput({Name = "Key", Callback = function(v) inputKey = v end})
    kt:CreateButton({Name = "Submit", Callback = function()
        if CheckKey(inputKey) then
            if writefile then writefile(KeyFile, inputKey) end
            kw:Destroy()
            LoadMainWindow()
        else
            Rayfield:Notify({Title="Błąd", Content="Nieprawidłowy klucz!"})
        end
    end})
end
