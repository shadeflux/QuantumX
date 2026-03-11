-- [[ QUANTUM X | MAIN HUB ]]
if getgenv().qx_loaded then return end
getgenv().qx_loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===== LOAD FtF MODULE =====
local moduleUrl = "https://raw.githubusercontent.com/shadeflux/QuantumX/main/fleethefacility.lua"
local success, moduleSrc = pcall(function()
    return game:HttpGet(moduleUrl)
end)

if not success or not moduleSrc then
    Rayfield:Notify({
        Title = "❌ Błąd",
        Content = "Nie można pobrać modułu gry.",
        Duration = 10
    })
    error("Failed to download module")
end

local moduleFunc, compileErr = loadstring(moduleSrc)
if not moduleFunc then
    Rayfield:Notify({
        Title = "❌ Błąd",
        Content = "Moduł gry uszkodzony.",
        Duration = 10
    })
    error("Compile error: " .. tostring(compileErr))
end

local moduleOk, moduleResult = pcall(moduleFunc)
if not moduleOk then
    Rayfield:Notify({
        Title = "❌ Błąd",
        Content = "Inicjalizacja modułu nie powiodła się.",
        Duration = 10
    })
    error("Init error: " .. tostring(moduleResult))
end

local FtF = moduleResult

-- ===== GLOBAL CONFIG =====
getgenv().Config = {
    speed     = false,
    speedVal  = 16,
    jump      = false,
    jumpVal   = 50,
    noclip    = false,
    noPcError = false,
}

-- ===== NO PC ERROR LOOP =====
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

-- ===== SPEED, JUMP, NOCLIP =====
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

-- ===== INITIALIZE FtF =====
FtF.Initialize()

-- ===== CREATE WINDOW =====
local win = Rayfield:CreateWindow({
    Name            = "Quantum X | Flee The Facility",
    LoadingTitle    = "Quantum X",
    LoadingSubtitle = "Flee The Facility",
    Theme           = "Amethyst",
    Size            = UDim2.new(0, 500, 0, 440),
})

-- ===== FtF TAB =====
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

-- ===== PLAYER TAB =====
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

-- ===== SERVER TAB =====
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

-- ===== SCRIPTS TAB (z SimplySpy) =====
local tab_scripts = win:CreateTab("Scripts", 4483362458)
tab_scripts:CreateButton({
    Name     = "Infinite Yield",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
})
tab_scripts:CreateButton({
    Name     = "Dex Explorer",
    Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end,
})
tab_scripts:CreateButton({
    Name     = "SimplySpy (Remote Spy)",
    Callback = function() loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))() end,
    })
