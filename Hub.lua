-- Quantum X | Flee The Facility - FULL VERSION
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave = false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 500

-- Helper Functions
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

-- Key System
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') ~= nil
end

-- Interaction Loop
task.spawn(function()
    while task.wait(0.1) do
        if not isEvading then
            local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
            if remote then
                if autoComputer then
                    remote:FireServer("Input", "Action", true)
                    remote:FireServer("SetPlayerStatus", 1)
                end
                if autoSave then
                    local pod = getNearest("Tube")
                    if pod then remote:FireServer("Input", "Action", true) end
                end
            end
        end
    end
end)

-- Movement & ESP Loop
RunService.Stepped:Connect(function()
    if lp.Character then
        local h = lp.Character:FindFirstChild("Humanoid")
        if h then
            if speedOn then h.WalkSpeed = walkSpeedValue end
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

task.spawn(function()
    while task.wait(0.3) do
        if game.PlaceId == 893973440 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            
            -- Anti-Beast Evasion
            local beast = getBeast()
            local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
            if bPos and (Vector2.new(bPos.X, bPos.Z) - Vector2.new(hrp.Position.X, hrp.Position.Z)).Magnitude < 60 then
                if not isEvading then
                    savedPos = hrp.CFrame
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                    isEvading = true
                else
                    hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                end
            elseif isEvading and (not bPos or (Vector2.new(bPos.X, bPos.Z) - Vector2.new(hrp.Position.X, hrp.Position.Z)).Magnitude > 80) then
                if savedPos then hrp.CFrame = savedPos end
                isEvading = false
            end

            -- Teleport to Tasks
            if not isEvading then
                local target = nil
                if autoSave then target = getNearest("Tube") end
                if not target and autoComputer then target = getNearest("ComputerTable") end
                if not target and autoDoor then target = getNearest("ExitDoor") end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tPart then 
                        -- FIX: Teleport in front of object
                        hrp.CFrame = CFrame.new(tPart.Position + (tPart.CFrame.LookVector * 4), tPart.Position) 
                    end
                end
            end
        end
    end
end)

-- UI
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({Name = "Quantum X | Flee The Facility", Theme = "Amethyst"})
    local Tab = Window:CreateTab("Main", 4483362458)
    Tab:CreateToggle({Name = "Auto-Computer", Callback = function(v) autoComputer = v end})
    Tab:CreateToggle({Name = "Auto-Save", Callback = function(v) autoSave = v end})
    Tab:CreateToggle({Name = "Auto-Exit Door", Callback = function(v) autoDoor = v end})
    Tab:CreateToggle({Name = "Noclip", Callback = function(v) noclipOn = v end})
    Tab:CreateToggle({Name = "WalkSpeed", Callback = function(v) speedOn = v end})
    Tab:CreateSlider({Name = "Speed Value", Range = {16, 100}, Callback = function(v) walkSpeedValue = v end})
    
    local ScriptsTab = Window:CreateTab("Scripts", nil)
    ScriptsTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
    ScriptsTab:CreateButton({Name = "Dex Explorer", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end})
end

-- Key System Logic
local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
if SavedKey and CheckKey(SavedKey) then LoadMainWindow() else
    local KeyWindow = Rayfield:CreateWindow({Name = "Quantum X | Verification", Theme = "Amethyst"})
    local KeyTab = KeyWindow:CreateTab("Key System", nil)
    KeyTab:CreateButton({Name = "Get Key", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    KeyTab:CreateInput({Name = "Paste Key", Callback = function(v) inputKey = v end})
    KeyTab:CreateButton({Name = "Verify", Callback = function() if CheckKey(inputKey) then writefile(KeyFile, inputKey); KeyWindow:Destroy(); LoadMainWindow() end end})
end
