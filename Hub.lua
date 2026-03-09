-- [[ Q U A N T U M   X   |   U N I V E R S A L   H U B ]]
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- === GLOBAL VARIABLES (uniwersalne) ===
local speedOn, walkSpeedValue = false, 16
local jumpOn, jumpPowerValue = false, 50
local noclipOn = false

-- === MAIN LOOP (MOVEMENT + NOCLIP) ===
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

-- === UI ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Universal Hub",
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Initializing...",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false
    })

    local LocalTab = Window:CreateTab("Local Player", 4483362458)
    LocalTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) noclipOn = v end})
    LocalTab:CreateToggle({Name = "WalkSpeed Override", CurrentValue = false, Callback = function(v) speedOn = v; if not v then lp.Character.Humanoid.WalkSpeed = 16 end end})
    LocalTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 200}, Increment = 1, CurrentValue = 16, Callback = function(v) walkSpeedValue = v end})
    LocalTab:CreateToggle({Name = "JumpPower Override", CurrentValue = false, Callback = function(v) jumpOn = v; if not v then lp.Character.Humanoid.JumpPower = 50 end end})
    LocalTab:CreateSlider({Name = "JumpPower Value", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) jumpPowerValue = v end})

    local ServerTab = Window:CreateTab("Server & UI", 4483362458)
    ServerTab:CreateButton({Name = "Rejoin Server", Callback = function() 
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp) 
    end})
    ServerTab:CreateButton({Name = "Server Hop", Callback = function()
        TeleportService:Teleport(game.PlaceId, lp)
    end})
    ServerTab:CreateButton({Name = "Destroy UI", Callback = function() 
        Rayfield:Destroy(); getgenv().QuantumXLoaded = false 
    end})

    local CreditsTab = Window:CreateTab("Credits", 4483362458)
    CreditsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
    CreditsTab:CreateLabel("Developed by Quantum X Team")
end

-- === KEY SYSTEM ===
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
