-- [[ QUANTUM X | SUPREME FTF & UNIVERSAL ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === SETTINGS & VARS ===
local isFtF = (game.PlaceId == 893973440)
local speedOn, walkSpeedValue = false, 16
local noclipOn = false
local noPcError = false
local playerEspOn, computerEspOn, doorEspOn = false, false, false
local autoComputer, autoDoor, autoSave, autoCapture = false, false, false, false
local isEvading, savedPos = false, nil
local safeHeight = 550 
local evadeDistance = 50 

-- === NO PC ERROR LOGIC ===
RunService.RenderStepped:Connect(function()
    if noPcError then
        pcall(function()
            local errorGui = game:GetService("CoreGui"):FindFirstChild("ErrorPrompt", true)
            if errorGui then errorGui:Destroy() end
        end)
    end
end)

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
                if not (p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))) then
                    local d = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d; nearest = p.Character end
                end
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

-- === FTF LOOP ===
if isFtF then
    task.spawn(function()
        while task.wait(0.2) do
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            -- Auto-Capture Updated Logic
            if autoCapture then
                local isBeast = lp.Character:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer"))
                if isBeast then
                    local vic = getNearest(nil, true)
                    if vic and vic:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = vic.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        task.wait(0.1)
                        ReplicatedStorage.RemoteEvent:FireServer("Input", "Swing", true)
                    end
                end
            end

            -- Teleport/Evade Logic
            if autoComputer or autoSave or autoDoor then
                local target = nil
                if autoSave then target = getNearest("Tube", false) end
                if not target and autoComputer then target = getNearest("ComputerTable", false) end
                if not target and autoDoor then target = getNearest("ExitDoor", false) end

                if target then
                    local tPart = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                    if tPart then
                        local beast = getBeast()
                        local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                        
                        if bPos and (bPos - tPart.Position).Magnitude < evadeDistance then
                            hrp.CFrame = CFrame.new(hrp.Position.X, safeHeight, hrp.Position.Z)
                        else
                            hrp.CFrame = tPart.CFrame * CFrame.new(0, 2, 4)
                            if autoComputer then
                                ReplicatedStorage.RemoteEvent:FireServer("Input", "Action", true)
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- === UI ===
local Window = Rayfield:CreateWindow({Name = "Quantum X | Flee The Facility", Theme = "Amethyst"})

if isFtF then
    local FtFTab = Window:CreateTab("FtF Features", 4483362458)
    FtFTab:CreateToggle({Name = "Auto-Computer (Smart)", Callback = function(v) autoComputer = v end})
    FtFTab:CreateToggle({Name = "Auto-Capture (Beast)", Callback = function(v) autoCapture = v end})
    FtFTab:CreateToggle({Name = "No PC Error", Callback = function(v) noPcError = v end})
end

local PlayerTab = Window:CreateTab("Local Player", 4483362458)
PlayerTab:CreateToggle({Name = "Noclip", Callback = function(v) noclipOn = v end})
PlayerTab:CreateSlider({Name = "Speed", Range = {16, 200}, Callback = function(v) walkSpeedValue = v end})

local ServerTab = Window:CreateTab("Server", 4483362458)
ServerTab:CreateButton({Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
ServerTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})

local CreditsTab = Window:CreateTab("Credits", 4483362458)
CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
