if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Http = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === ZMIENNE GLOBALNE ===
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false
local playerEspOn, computerEspOn, doorEspOn = false, false, false

-- Zmienne Auto-Farm FtF
local autoComputer, autoDoor = false, false
local isEvading, savedPos = false, nil
local safeHeight = 500

-- === FUNKCJE POMOCNICZE FTF ===
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

-- === PĘTLE (MOVEMENT & FTF LOGIC) ===
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
    while task.wait(0.5) do
        if game.PlaceId == 893973440 then
            -- Logika ESP
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hl = p.Character:FindFirstChild("QuantumESP")
                    if playerEspOn then
                        if not hl then hl = Instance.new("Highlight", p.Character); hl.Name = "QuantumESP" end
                        local isBeast = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                        hl.FillColor = isBeast and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                    elseif hl then hl:Destroy() end
                end
            end

            -- Logika Auto-Farm & Evasion
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (autoComputer or autoDoor) then
                local beast = getBeast()
                local bPos = beast and beast:FindFirstChild("HumanoidRootPart") and beast.HumanoidRootPart.Position
                if bPos and (bPos - hrp.Position).Magnitude < 40 and not isEvading then
                    savedPos = hrp.CFrame; hrp.CFrame = hrp.CFrame + Vector3.new(0, safeHeight, 0)
                    isEvading = true
                    Rayfield:Notify({Title = "BEAST NEAR!", Content = "Teleporting to sky.", Duration = 2})
                elseif isEvading and bPos and (bPos - hrp.Position).Magnitude > 60 then
                    if savedPos then hrp.CFrame = savedPos end
                    isEvading = false
                end

                if not isEvading then
                    local target = autoComputer and getNearest("ComputerTable") or (autoDoor and getNearest("ExitDoor"))
                    if target then
                        local tRoot = target:FindFirstChild("ComputerPart") or target:FindFirstChildWhichIsA("BasePart")
                        if tRoot then hrp.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3) end
                    end
                end
            end
        end
    end
end)

-- === INTERFEJS ===
local function LoadMainWindow()
    local isFtF = (game.PlaceId == 893973440)
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | " .. (isFtF and "Flee The Facility" or "Universal Hub"),
        LoadingTitle = "Quantum X Hub",
        LoadingSubtitle = "by Quantum X Corp",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = true, FolderName = "QuantumX" },
        KeySystem = false
    })

    if isFtF then
        local FtFTab = Window:CreateTab("Flee The Facility", 4483362458)
        FtFTab:CreateSection("Automation")
        FtFTab:CreateToggle({Name = "Auto-Computer (Escape System)", CurrentValue = autoComputer, Callback = function(v) autoComputer = v end})
        FtFTab:CreateToggle({Name = "Auto-Exit Door", CurrentValue = autoDoor, Callback = function(v) autoDoor = v end})
        
        FtFTab:CreateSection("Visuals")
        FtFTab:CreateToggle({Name = "Player/Beast ESP", CurrentValue = playerEspOn, Callback = function(v) playerEspOn = v end})
        
        FtFTab:CreateSection("Movement")
        FtFTab:CreateToggle({Name = "Noclip", CurrentValue = noclipOn, Callback = function(v) noclipOn = v end})
        FtFTab:CreateToggle({Name = "WalkSpeed", CurrentValue = speedOn, Callback = function(v) speedOn = v; if not v then lp.Character.Humanoid.WalkSpeed = 16 end end})
        FtFTab:CreateSlider({Name = "Speed Value", Range = {16, 100}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    else
        local MainTab = Window:CreateTab("Features", 4483362458)
        MainTab:CreateSection("Universal Movement")
        MainTab:CreateToggle({Name = "WalkSpeed", CurrentValue = speedOn, Callback = function(v) speedOn = v end})
        MainTab:CreateSlider({Name = "Speed Value", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    end

    local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
    ScriptsTab:CreateButton({Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})
    ScriptsTab:CreateButton({Name = "Dex Explorer", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end})

    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    SettingsTab:CreateLabel("Unseen. Unpatched. Unstoppable. | Developed by Quantum X Team")
    SettingsTab:CreateDivider()
    SettingsTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().QuantumXLoaded = false end})
end

-- === KEY SYSTEM ===
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
            Rayfield:Notify({Title = "Error", Content = "Invalid Key!"})
        end
    end})
end
