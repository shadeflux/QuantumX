if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")
local Http = game:GetService("HttpService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Globalne zmienne
local speedOn = false
local walkSpeedValue = 16
local jumpOn = false
local jumpPowerValue = 50
local spectating = false
local targetPlayer = nil

-- === GŁÓWNA FUNKCJA ŁADUJĄCA INTERFEJS ===
local function LoadMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X | Unseen. Unpatched. Unstoppable.",
        LoadingTitle = "Quantum X Hub",
        LoadingSubtitle = "by Quantum X Corp",
        Theme = "Amethyst",
        ConfigurationSaving = { Enabled = true, FolderName = "QuantumX", FileName = "Config" },
        Discord = { Enabled = true, Invite = "XHEAeKSx34", RememberJoins = true },
        KeySystem = false
    })

    local MainTab = Window:CreateTab("Features", 4483362458)
    
    MainTab:CreateSection("Movement")
    MainTab:CreateToggle({Name = "Enable WalkSpeed", CurrentValue = speedOn, Flag = "SpeedToggle", Callback = function(Value) 
        speedOn = Value 
        if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end
    end})
    MainTab:CreateSlider({Name = "WalkSpeed Value", Range = {16, 500}, Increment = 1, CurrentValue = walkSpeedValue, Callback = function(Value) 
        walkSpeedValue = Value 
        if speedOn and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = Value end
    end})
    MainTab:CreateToggle({Name = "Enable JumpPower", CurrentValue = jumpOn, Flag = "JumpToggle", Callback = function(Value) 
        jumpOn = Value 
        if not Value and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = 50 end
    end})
    MainTab:CreateSlider({Name = "JumpPower Value", Range = {50, 500}, Increment = 1, CurrentValue = jumpPowerValue, Callback = function(Value) 
        jumpPowerValue = Value 
        if jumpOn and lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = Value end
    end})

    MainTab:CreateSection("Teleportation & Spectate")
    MainTab:CreateInput({Name = "Target Player Name", PlaceholderText = "Wpisz nazwę...", Callback = function(Text)
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():find(Text:lower()) then targetPlayer = v break end
        end
    end})
    MainTab:CreateButton({Name = "Teleport to Player", Callback = function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then 
            lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame 
        end
    end})
    MainTab:CreateToggle({Name = "Spectate Player", CurrentValue = spectating, Callback = function(Value) spectating = Value end})

    MainTab:CreateSection("Server Utils")
    MainTab:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end})
    MainTab:CreateButton({Name = "Server Hop", Callback = function()
        local Raw = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local Decode = Http:JSONDecode(Raw)
        for _, v in pairs(Decode.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, lp) break end
        end
    end})

    local SettingsTab = Window:CreateTab("Settings", 4483362458)
    SettingsTab:CreateSection("System & Credits")
    SettingsTab:CreateLabel("Unseen. Unpatched. Unstoppable. | Developed by Quantum X Team") -- Slogan w jednej linii
    SettingsTab:CreateDivider() -- Separator
    SettingsTab:CreateButton({Name = "Copy Discord Link", Callback = function() setclipboard("https://discord.gg/XHEAeKSx34") end})
    SettingsTab:CreateButton({Name = "Destroy UI", Callback = function() Rayfield:Destroy() getgenv().QuantumXLoaded = false end})

    Rayfield:LoadConfiguration()
end

-- === LOGIKA KEY SYSTEM ===
local function CheckKey(Token)
    local Success, Response = pcall(function() return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token) end)
    return Success and Response:find('"valid":true') ~= nil
end

local KeyFile = "QuantumX_Key.txt"
local SavedKey = (isfile and isfile(KeyFile)) and readfile(KeyFile) or nil
local inputKey = "" -- Zmienna do przechowywania wpisanego klucza

if SavedKey and CheckKey(SavedKey) then
    LoadMainWindow()
else
    local KeyWindow = Rayfield:CreateWindow({Name = "Quantum X | Verification", Theme = "Amethyst", KeySystem = false})
    local KeyTab = KeyWindow:CreateTab("Key System", nil)
    
    KeyTab:CreateButton({Name = "Otwórz checkpointy (Get Key)", Callback = function() setclipboard("https://work.ink/2dRx/key-system") end})
    
    KeyTab:CreateInput({Name = "Wklej klucz", PlaceholderText = "Wpisz tutaj klucz...", Callback = function(Value) 
        inputKey = Value 
    end})
    
    KeyTab:CreateButton({Name = "Zatwierdź klucz", Callback = function()
        if CheckKey(inputKey) then
            writefile(KeyFile, inputKey)
            Rayfield:Destroy()
            LoadMainWindow()
        else
            Rayfield:Notify({Title = "Błąd", Content = "Nieprawidłowy klucz!"})
        end
    end})
end
