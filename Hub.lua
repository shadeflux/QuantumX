-- Quantum X | Flee The Facility - Full Version
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
local autoComputer, autoDoor = false, false
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

local function getNearest(objectName)
    local nearest, shortestDist = nil, math.huge
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == objectName then
            local root = v:FindFirstChild("ComputerPart") or v:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (root.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then shortestDist = dist; nearest = v end
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

-- Main Logic
task.spawn(function()
    while task.wait(0.1) do
        if autoComputer then
            pcall(function()
                ReplicatedStorage.RemoteEvent:FireServer("SetPlayerStatus", 1)
                ReplicatedStorage.RemoteEvent:FireServer("ComputerFinished", true)
            end)
        end
    end
end)

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
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        if game.PlaceId == 893973440 then
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (autoComputer or autoDoor) then
                local beast = getBeast()
                local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                
                if bPos and (bPos - hrp.Position).Magnitude < 40 and not isEvading then
                    savedPos = hrp.CFrame; hrp.CFrame = hrp.CFrame + Vector3.new(0, safeHeight, 0)
                    isEvading = true
                elseif isEvading and (not bPos or (bPos - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude > 60) then
                    if savedPos then hrp.CFrame = savedPos end
                    isEvading = false
                end

                if not isEvading then
                    local target = autoComputer and getNearest("ComputerTable") or (autoDoor and getNearest("ExitDoor"))
                    if target then
                        local tRoot = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                        if tRoot then
                            -- Corrected Teleport: 4 studs in front
                            hrp.CFrame = CFrame.new(tRoot.Position + (tRoot.CFrame.LookVector * 4), tRoot.Position)
                        end
                    end
                end
            end
        end
    end
end)

-- UI Setup
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({Name = "Quantum X | Flee The Facility", Theme = "Amethyst"})
    local Tab = Window:CreateTab("Main", 4483362458)
    Tab:CreateToggle({Name = "Auto-Computer", Callback = function(v) autoComputer = v end})
    Tab:CreateToggle({Name = "Auto-Exit Door", Callback = function(v) autoDoor = v end})
    Tab:CreateToggle({Name = "Noclip", Callback = function(v) noclipOn = v end})
    Tab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})
end

-- Key Window Logic
local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
local inputKey = ""

if SavedKey and CheckKey(SavedKey) then
    LoadMainWindow()
else
    local KeyWindow = Rayfield:CreateWindow({Name = "Quantum X | Verification", Theme = "Amethyst"})
    local KeyTab = KeyWindow:CreateTab("Key System", nil)
    KeyTab:CreateButton({Name = "Get Key", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    KeyTab:CreateInput({Name = "Paste Key", PlaceholderText = "Key here...", Callback = function(v) inputKey = v end})
    KeyTab:CreateButton({Name = "Verify", Callback = function()
        if CheckKey(inputKey) then
            writefile(KeyFile, inputKey); KeyWindow:Destroy(); LoadMainWindow()
        else
            Rayfield:Notify({Title = "Error", Content = "Invalid Key!"})
        end
    end})
end
