if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- Ładowanie biblioteki Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Tworzenie głównego okna
local Window = Rayfield:CreateWindow({
    Name = "Quantum X",
    LoadingTitle = "Ładowanie Quantum X...",
    LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "QuantumX",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "", 
        RememberJoins = true 
    },
    KeySystem = false
})

-- Tworzenie zakładki
local MainTab = Window:CreateTab("Główne", 4483362458) -- ID ikony
local Section = MainTab:CreateSection("Funkcje Postaci")

-- Zmienne
local speedOn = false
local ij = false
local nc = false
local flingOn = false
local antiFling = nil
local flingVelocity = nil

local function getRoot()
    local c = lp.Character
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"))
end

-- SPEED
MainTab:CreateToggle({
    Name = "Speed (32)",
    CurrentValue = false,
    Flag = "SpeedTog",
    Callback = function(Value)
        speedOn = Value
        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = speedOn and 32 or 16 end
    end,
})

-- INFINITE JUMP
MainTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpTog",
    Callback = function(Value)
        ij = Value
    end,
})

UIS.JumpRequest:Connect(function()
    if ij and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- NOCLIP
MainTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClipTog",
    Callback = function(Value)
        nc = Value
    end,
})

task.spawn(function()
    while true do
        if nc and lp.Character then
            for _, v in lp.Character:GetDescendants() do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
        task.wait(0.1)
    end
end)

local CombatSection = MainTab:CreateSection("Funkcje PVP / Trolling")

-- FLING
MainTab:CreateToggle({
    Name = "Fling",
    CurrentValue = false,
    Flag = "FlingTog",
    Callback = function(Value)
        flingOn = Value
        local c = lp.Character
        local root = getRoot()
        
        if flingOn and c and root then
            for _, v in c:GetDescendants() do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                    v.Massless = true
                end
            end
            
            flingVelocity = Instance.new("BodyAngularVelocity")
            flingVelocity.AngularVelocity = Vector3.new(0, 99999, 0)
            flingVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
            flingVelocity.Parent = root

            task.spawn(function()
                while flingOn do
                    if flingVelocity and flingVelocity.Parent then flingVelocity.AngularVelocity = Vector3.new(0, 99999, 0) end
                    task.wait(0.2)
                    if flingVelocity and flingVelocity.Parent then flingVelocity.AngularVelocity = Vector3.new(0, 0, 0) end
                    task.wait(0.1)
                end
                if flingVelocity then flingVelocity:Destroy() end
            end)
        else
            if flingVelocity then flingVelocity:Destroy() end
        end
    end,
})

-- ANTI FLING
MainTab:CreateToggle({
    Name = "Anti Fling",
    CurrentValue = false,
    Flag = "AntiFlingTog",
    Callback = function(Value)
        if Value then
            antiFling = RS.Stepped:Connect(function()
                for _, player in Players:GetPlayers() do
                    if player ~= lp and player.Character then
                        for _, v in player.Character:GetDescendants() do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end
            end)
        else
            if antiFling then
                antiFling:Disconnect()
                antiFling = nil
            end
        end
    end,
})

Rayfield:Notify({
    Title = "Quantum X",
    Content = "Skrypt załadowany pomyślnie!",
    Duration = 3,
    Image = 4483362458,
})
