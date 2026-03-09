local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Zmienne
local speedOn = false
local walkSpeedValue = 16
local jumpOn = false
local jumpPowerValue = 50
local noclipOn = false

local autoComputer = false
local autoDoor = false
local safeHeight = 500 -- Jak wysoko ma nas teleportować przy ucieczce
local isEvading = false
local savedPos = nil
local targetObject = nil

-- === FUNKCJE POMOCNICZE ===
local function getBeast()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            -- Wykrywanie bestii (Bestia ma młot w ręku lub plecaku)
            if p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer")) then
                return p.Character
            end
        end
    end
    return nil
end

local function getNearest(objectName)
    local nearest = nil
    local shortestDist = math.huge
    
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = lp.Character.HumanoidRootPart.Position

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == objectName then
            -- Sprawdzamy, czy komputer nie jest zrobiony / drzwi nie są otwarte (często mają inną nazwę części bazowej)
            local root = v:FindFirstChild("ComputerPart") or v:FindFirstChild("Base") or v:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (root.Position - myPos).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

-- === PĘTLE W TLE ===

-- Pętla Ruchu i Noclipa
RunService.Stepped:Connect(function()
    local char = lp.Character
    if char then
        local h = char:FindFirstChild("Humanoid")
        if h then
            if speedOn then h.WalkSpeed = walkSpeedValue end
            if jumpOn then h.JumpPower = jumpPowerValue end
        end
        
        -- Noclip
        if noclipOn then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end
end)

-- Pętla Auto-Farmy (Komputery/Drzwi) i Ucieczki
task.spawn(function()
    while task.wait(0.2) do
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local beastChar = getBeast()
        local beastPos = beastChar and beastChar:FindFirstChild("HumanoidRootPart") and beastChar.HumanoidRootPart.Position
        
        -- Sprawdzanie zagrożenia
        if beastPos then
            local distToBeast = (beastPos - hrp.Position).Magnitude
            
            -- Jeśli bestia jest blisko (< 40) i cokolwiek robimy (komputery lub drzwi), UCIEKAJ
            if distToBeast < 40 and (autoComputer or autoDoor) and not isEvading then
                savedPos = hrp.CFrame
                hrp.CFrame = hrp.CFrame + Vector3.new(0, safeHeight, 0)
                isEvading = true
                Rayfield:Notify({Title = "Uwaga!", Content = "Bestia w pobliżu! Teleportacja w bezpieczne miejsce.", Duration = 2})
            
            -- Jeśli uciekliśmy, ale bestia odeszła daleko (> 50), WRACAJ
            elseif isEvading and distToBeast > 50 then
                if savedPos then hrp.CFrame = savedPos end
                isEvading = false
                Rayfield:Notify({Title = "Bezpiecznie", Content = "Wracam do pracy.", Duration = 2})
            end
        end

        -- Jeśli bezpiecznie, wykonuj zadanie
        if not isEvading then
            if autoComputer then
                local pc = getNearest("ComputerTable")
                if pc then
                    local pcRoot = pc:FindFirstChild("ComputerPart") or pc:FindFirstChildWhichIsA("BasePart")
                    if pcRoot then
                        -- Ustaw się przy komputerze
                        hrp.CFrame = pcRoot.CFrame * CFrame.new(0, 0, 3) 
                    end
                end
            elseif autoDoor and not autoComputer then -- Drzwi robi, gdy komputery odznaczone
                local door = getNearest("ExitDoor")
                if door then
                    local doorRoot = door:FindFirstChildWhichIsA("BasePart")
                    if doorRoot then
                        hrp.CFrame = doorRoot.CFrame * CFrame.new(0, 0, 3)
                    end
                end
            end
        end
    end
end)


-- === TWORZENIE OKNA UI ===
local Window = Rayfield:CreateWindow({
    Name = "Quantum X | FtF Edition",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Flee The Facility",
    Theme = "Amethyst",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local FtFTab = Window:CreateTab("Flee the Facility", 4483362458)

FtFTab:CreateSection("Movement")
FtFTab:CreateToggle({Name = "Noclip (Przechodzenie przez ściany)", CurrentValue = noclipOn, Flag = "NoclipT", Callback = function(Value) noclipOn = Value end})

FtFTab:CreateToggle({Name = "Enable WalkSpeed", CurrentValue = speedOn, Flag = "SpeedT", Callback = function(Value) 
    speedOn = Value 
    if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end
end})
FtFTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 100}, Increment = 1, CurrentValue = walkSpeedValue, Callback = function(Value) walkSpeedValue = Value end})

FtFTab:CreateToggle({Name = "Enable JumpPower", CurrentValue = jumpOn, Flag = "JumpT", Callback = function(Value) 
    jumpOn = Value 
    if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = 50 end
end})
FtFTab:CreateSlider({Name = "JumpPower Value", Range = {50, 200}, Increment = 1, CurrentValue = jumpPowerValue, Callback = function(Value) jumpPowerValue = Value end})

FtFTab:CreateSection("Automation (Auto-Farm)")
FtFTab:CreateToggle({
    Name = "Auto-Computer (z systemem ucieczki)", 
    CurrentValue = autoComputer, 
    Flag = "AutoComp", 
    Callback = function(Value) 
        autoComputer = Value
        if not Value and isEvading then
            -- Wyłączono funkcję podczas ucieczki, wracamy na ziemię
            if savedPos and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = savedPos
                isEvading = false
            end
        end
    end
})

FtFTab:CreateToggle({
    Name = "Auto-Door (otwieraj tylko jak zrobisz komputery)", 
    CurrentValue = autoDoor, 
    Flag = "AutoDoor", 
    Callback = function(Value) autoDoor = Value end
})

-- Tu dodaj resztę zakładek ze starszego skryptu (np. Scripts, Settings) - skrócone dla czytelności
local ScriptsTab = Window:CreateTab("Scripts", 4483362458)
ScriptsTab:CreateButton({Name = "Load Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end})

Rayfield:LoadConfiguration()
