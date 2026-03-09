if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Quantum X | Unseen. Unpatched. Unstoppable.",
    LoadingTitle = "Quantum X Hub",
    LoadingSubtitle = "by Quantum X Corp",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "QuantumX",
        FileName = "Config"
    },
    Discord = {
        Enabled = true,
        Invite = "XHEAeKSx34", -- Tylko kod zaproszenia
        RememberJoins = true 
    },
    KeySystem = true, -- System kluczy włączony
    KeySettings = {
        Title = "Quantum X | Key System",
        Subtitle = "Join Discord for Key: https://discord.gg/XHEAeKSx34",
        Note = "The key can be obtained via Work.ink",
        FileName = "QX_Key",
        SaveKey = true,
        GrabKeyFromSite = false, -- Ustaw na true jeśli masz API, lub zostaw false dla statycznego sprawdzenia
        Key = {"QX_12345"} -- Tutaj wpisz swój klucz lub logikę sprawdzania
    }
})

-- Zmienne dla funkcji
local speedOn = false
local walkSpeedValue = 16
local jumpOn = false
local jumpPowerValue = 50
local spectating = false
local targetPlayer = nil

-- GŁÓWNA ZAKŁADKA
local MainTab = Window:CreateTab("Player", 4483362458)

-- SPEED SECTION
MainTab:CreateSection("Movement")

MainTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "SpeedToggle",
    Callback = function(Value)
        speedOn = Value
        if not Value then
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = 16
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        walkSpeedValue = Value
    end,
})

-- JUMPPOWER SECTION
MainTab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = false,
    Flag = "JumpToggle",
    Callback = function(Value)
        jumpOn = Value
        if not Value then
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.JumpPower = 50
            end
        end
    end,
})

MainTab:CreateSlider({
    Name = "JumpPower Value",
    Range = {50, 500},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        jumpPowerValue = Value
    end,
})

-- Pętla aktualizująca statystyki
task.spawn(function()
    while true do
        local h = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if h then
            if speedOn then h.WalkSpeed = walkSpeedValue end
            if jumpOn then h.JumpPower = jumpPowerValue end
        end
        task.wait(0.1)
    end
end)

-- TELEPORT & SPECTATE
local TeleportTab = Window:CreateTab("Teleportation", 4483362458)
TeleportTab:CreateSection("Target Player")

local PlayerInput = TeleportTab:CreateInput({
    Name = "Player Name",
    PlaceholderText = "Type username...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():find(Text:lower()) or v.DisplayName:lower():find(Text:lower()) then
                targetPlayer = v
                Rayfield:Notify({Title = "Target Found", Content = "Selected: " .. v.Name, Duration = 3})
                break
            end
        end
    end,
})

TeleportTab:CreateButton({
    Name = "Teleport to Player",
    Callback = function()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found or dead", Duration = 3})
        end
    end,
})

TeleportTab:CreateToggle({
    Name = "Spectate Player",
    CurrentValue = false,
    Flag = "SpectateToggle",
    Callback = function(Value)
        spectating = Value
        if Value then
            task.spawn(function()
                while spectating do
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
                        workspace.CurrentCamera.CameraSubject = targetPlayer.Character.Humanoid
                    end
                    task.wait(0.1)
                end
                workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
            end)
        else
            workspace.CurrentCamera.CameraSubject = lp.Character.Humanoid
        end
    end,
})

-- SERVER UTILS
local ServerTab = Window:CreateTab("Server", 4483362458)

ServerTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, lp)
    end,
})

ServerTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local function GetServer()
            local Raw = game:HttpGet(Api)
            local Decode = Http:JSONDecode(Raw)
            for _, v in pairs(Decode.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    return v.id
                end
            end
        end
        local serverId = GetServer()
        if serverId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, lp)
        end
    end,
})

-- MISC & CREDITS
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Quantum X")

SettingsTab:CreateLabel("Unseen. Unpatched. Unstoppable.")
SettingsTab:CreateLabel("Developed by Quantum X Team")

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Rayfield:Destroy()
        getgenv().QuantumXLoaded = false
    end,
})

SettingsTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/XHEAeKSx34")
        Rayfield:Notify({Title = "Success", Content = "Link copied to clipboard!", Duration = 3})
    end,
})

Rayfield:LoadConfiguration()
