-- [[ QUANTUM X | MAIN HUB ]]
if getgenv().qx_loaded then return end
getgenv().qx_loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load the FtF module (dostosuj URL do swojego repozytorium!)
local FtF = loadstring(game:HttpGet("https://raw.githubusercontent.com/TWÓJ_LOGIN/QuantumX/main/fleethefacility.lua"))()

-- Global config
getgenv().Config = {
    speed     = false,
    speedVal  = 16,
    jump      = false,
    jumpVal   = 50,
    noclip    = false,
    noPcError = false,
}

-- Core loops (speed, jump, noclip, no pc error)
RunService.Stepped:Connect(function()
    local c = lp.Character
    if c then
        local h = c:FindFirstChildWhichIsA("Humanoid")
        if h then
            if getgenv().Config.speed then
                h.WalkSpeed = getgenv().Config.speedVal
            end
            if getgenv().Config.jump then
                h.JumpPower = getgenv().Config.jumpVal
            end
        end
        if getgenv().Config.noclip then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().Config.noPcError then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton1(Vector2.new())
            end)
        end
    end
end)

-- Initialize FtF module (uruchamia ESP i automaty)
FtF.Initialize()

-- Create main window
local win = Rayfield:CreateWindow({
    Name            = "Quantum X | Flee The Facility",
    LoadingTitle    = "Quantum X",
    LoadingSubtitle = "Flee The Facility",
    Theme           = "Amethyst",
    Size            = UDim2.new(0, 500, 0, 440),
})

-- FtF Tab (korzysta z configu modułu)
local tab_ftf = win:CreateTab("FtF", 4483362458)

tab_ftf:CreateSection("Survivor")
tab_ftf:CreateToggle({
    Name         = "Auto Computer",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.autoComputer = v end,
})
tab_ftf:CreateToggle({
    Name         = "Auto Tube",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.autoTube = v end,
})
tab_ftf:CreateToggle({
    Name         = "Auto Exit Door",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.autoDoor = v end,
})

tab_ftf:CreateSection("Beast")
tab_ftf:CreateToggle({
    Name         = "Auto Capture",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.autoCapture = v end,
})

tab_ftf:CreateSection("Visuals")
tab_ftf:CreateToggle({
    Name         = "Player ESP",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.espPlayer = v end,
})
tab_ftf:CreateToggle({
    Name         = "Computer ESP",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.espComputer = v end,
})
tab_ftf:CreateToggle({
    Name         = "Door ESP",
    CurrentValue = false,
    Callback     = function(v) FtF.Config.espDoor = v end,
})

-- Player Tab
local tab_player = win:CreateTab("Player", 4483362458)

tab_player:CreateSection("Movement")
tab_player:CreateToggle({
    Name         = "Speed Hack",
    CurrentValue = false,
    Callback     = function(v) getgenv().Config.speed = v end,
})
tab_player:CreateSlider({
    Name         = "Walk Speed",
    Range        = { 16, 250 },
    Increment    = 1,
    CurrentValue = 16,
    Callback     = function(v) getgenv().Config.speedVal = v end,
})
tab_player:CreateToggle({
    Name         = "Jump Hack",
    CurrentValue = false,
    Callback     = function(v) getgenv().Config.jump = v end,
})
tab_player:CreateSlider({
    Name         = "Jump Power",
    Range        = { 50, 300 },
    Increment    = 1,
    CurrentValue = 50,
    Callback     = function(v) getgenv().Config.jumpVal = v end,
})

tab_player:CreateSection("Misc")
tab_player:CreateToggle({
    Name         = "Noclip",
    CurrentValue = false,
    Callback     = function(v) getgenv().Config.noclip = v end,
})
tab_player:CreateToggle({
    Name         = "No PC Error",
    CurrentValue = false,
    Callback     = function(v) getgenv().Config.noPcError = v end,
})

-- Server Tab
local tab_server = win:CreateTab("Server", 4483362458)
tab_server:CreateButton({
    Name     = "Rejoin",
    Callback = function() TeleportService:Teleport(game.PlaceId, lp) end,
})
tab_server:CreateButton({
    Name     = "Server Hop",
    Callback = function() TeleportService:Teleport(game.PlaceId) end,
})
tab_server:CreateButton({
    Name     = "Destroy UI",
    Callback = function() Rayfield:Destroy(); getgenv().qx_loaded = false end,
})

-- Scripts Tab
local tab_scripts = win:CreateTab("Scripts", 4483362458)
tab_scripts:CreateButton({
    Name     = "Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
})
tab_scripts:CreateButton({
    Name     = "Dex Explorer",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end,
})
