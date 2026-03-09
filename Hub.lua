if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === ZMIENNE ===
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false
local playerEspOn, computerEspOn, doorEspOn = false, false, false

local autoComputer, autoDoor, autoSave = false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 500 

-- === FUNKCJE FTF ===
local function getBeast()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and (p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))) then
            return p.Character
        end
    end
    return nil
end

local function getNearest(name)
    local nearest, dist = nil, math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            local p = v:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (p.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; nearest = v end
            end
        end
    end
    return nearest
end

-- === PĘTLA INTERAKCJI (FIRESERVER) ===
task.spawn(function()
    while task.wait(0.1) do
        if not isEvading then
            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
            if remote then
                if autoComputer then
                    remote:FireServer("Input", "Action", true) -- Trzymanie 'E'
                    remote:FireServer("SetPlayerStatus", 1)
                end
                if autoSave then
                    local pod = getNearest("Tube") -- Kapsuła/Tuba
                    if pod then remote:FireServer("Input", "Action", true) end
                end
            end
        end
    end
end)

-- === LOGIKA RUCHU I NOCLIP ===
RunService.Stepped:Connect(function()
    if lp.Character then
        if noclipOn then
            for _, v in pairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        -- Zamrażanie w powietrzu podczas ucieczki
        if isEvading and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end)

-- === GŁÓWNA PĘTLA (ESP & AUTO-FARM) ===
task.spawn(function()
    while task.wait(0.3) do
        if game.PlaceId == 893973440 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            
            -- 1. System Ucieczki (Zwiększony dystans do 60)
            local beast = getBeast()
            local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
            
            if bPos and (Vector2.new(bPos.X, bPos.Z) - Vector2.new(hrp.Position.X, hrp.Position.Z)).Magnitude < 60 then
                if not isEvading then
                    savedPos = hrp.CFrame
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                    isEvading = true
                else
                    -- Utrzymywanie wysokości (Anti-Gravity)
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                end
            elseif isEvading and (not bPos or (Vector2.new(bPos.X, bPos.Z) - Vector2.new(hrp.Position.X, hrp.Position.Z)).Magnitude > 80) then
                if savedPos then hrp.CFrame = savedPos end
                isEvading = false
            end

            -- 2. Teleportacja do zadań
            if not isEvading then
                local target = nil
                if autoSave then target = getNearest("Tube") end
                if not target and autoComputer then target = getNearest("ComputerTable") end
                if not target and autoDoor then target = getNearest("ExitDoor") end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tPart then hrp.CFrame = tPart.CFrame * CFrame.new(0, 0, 3) end
                end
            end

            -- 3. ESP
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "QuantumESP" end
                        local beastCheck = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = beastCheck and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                    elseif hl then hl:Destroy() end
                end
            end
        end
    end
end)

-- === UI ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Flee The Facility",
        LoadingTitle = "Quantum X Hub",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    local FtFTab = Window:CreateTab("FtF Features", 4483362458)
    
    FtFTab:CreateSection("Automatyzacja")
    FtFTab:CreateToggle({Name = "Auto-Computer", CurrentValue = autoComputer, Callback = function(v) autoComputer = v end})
    FtFTab:CreateToggle({Name = "Auto-Save (Ratowanie z kapsuł)", CurrentValue = autoSave, Callback = function(v) autoSave = v end})
    FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = autoDoor, Callback = function(v) autoDoor = v end})
    
    FtFTab:CreateSection("Visuals")
    FtFTab:CreateToggle({Name = "ESP Graczy", CurrentValue = playerEspOn, Callback = function(v) playerEspOn = v end})
    FtFTab:CreateToggle({Name = "ESP Komputerów", CurrentValue = computerEspOn, Callback = function(v) computerEspOn = v end})
    
    FtFTab:CreateSection("Movement")
    FtFTab:CreateToggle({Name = "Noclip", CurrentValue = noclipOn, Callback = function(v) noclipOn = v end})
    FtFTab:CreateToggle({Name = "WalkSpeed", CurrentValue = speedOn, Callback = function(v) speedOn = v end})
    FtFTab:CreateSlider({Name = "Speed Value", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})

    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    SettingsTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})
end

-- === KEY SYSTEM (SKRÓCONY) ===
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
    KeyTab:CreateButton({Name = "Get Key", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    KeyTab:CreateInput({Name = "Paste Key", PlaceholderText = "Key here...", Callback = function(v) inputKey = v end})
    KeyTab:CreateButton({Name = "Verify", Callback = function()
        if CheckKey(inputKey) then
            writefile(KeyFile, inputKey); Rayfield:Destroy(); task.wait(0.5); LoadMainWindow()
        else
            Rayfield:Notify({Title = "Błąd", Content = "Nieprawidłowy klucz!"})
        end
    end})
end
