-- [[ QUANTUM X | MAIN HUB ]]
if getgenv().qx_loaded then return end
getgenv().qx_loaded = true

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Load FtF module
local FtF = loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/FleeTheFacility.lua"))()

-- Configuration
getgenv().Config = {
    speed = false,
    speedVal = 16,
    jump = false,
    jumpVal = 50,
    noclip = false,
    noPcError = false,
}

-- Key System
local function CheckKey(token)
    if not token or token == "" then return false end
    token = token:gsub("%s+", "")
    
    local endpoints = {
        "https://work.ink/_api/v2/token/isValid?token=" .. token,
    }
    
    for _, url in ipairs(endpoints) do
        local success, response = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success and response then
            local decodedSuccess, decoded = pcall(function()
                return HttpService:JSONDecode(response)
            end)
            
            if decodedSuccess and decoded and decoded.valid == true then
                return true
            end
        end
    end
    return false
end

local KeyFile = "QuantumX_Key.txt"
local SavedKey = nil

pcall(function()
    if isfile and isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = false
if SavedKey then
    KeyValid = CheckKey(SavedKey)
end

-- Main Window Function
local function LoadMainWindow()
    task.wait(0.5)
    
    -- Initialize FtF module
    FtF.Initialize()
    
    -- Core loops
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

    -- No PC Error
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

    -- Create main window
    local win = Rayfield:CreateWindow({
        Name = "Quantum X | Flee The Facility",
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Flee The Facility Edition",
        Theme = "Amethyst",
        Size = UDim2.new(0, 520, 0, 460),
    })

    -- FtF Tab
    local tab_ftf = win:CreateTab("FtF", 4483362458)

    tab_ftf:CreateDivider("🤖 SURVIVOR AUTOMATION")
    
    tab_ftf:CreateToggle({
        Name = "Auto Computer",
        CurrentValue = false,
        Callback = function(v) FtF.Config.autoComputer = v end,
    })
    tab_ftf:CreateToggle({
        Name = "Auto Tube (Save)",
        CurrentValue = false,
        Callback = function(v) FtF.Config.autoTube = v end,
    })
    tab_ftf:CreateToggle({
        Name = "Auto Exit Door",
        CurrentValue = false,
        Callback = function(v) FtF.Config.autoDoor = v end,
    })

    tab_ftf:CreateDivider("👹 BEAST AUTOMATION")
    
    tab_ftf:CreateToggle({
        Name = "Auto Capture",
        CurrentValue = false,
        Callback = function(v) FtF.Config.autoCapture = v end,
    })

    tab_ftf:CreateDivider("👁️ VISUALS")
    
    tab_ftf:CreateToggle({
        Name = "Player ESP",
        CurrentValue = false,
        Callback = function(v) FtF.Config.espPlayer = v end,
    })
    tab_ftf:CreateToggle({
        Name = "Computer ESP",
        CurrentValue = false,
        Callback = function(v) FtF.Config.espComputer = v end,
    })
    tab_ftf:CreateToggle({
        Name = "Door ESP",
        CurrentValue = false,
        Callback = function(v) FtF.Config.espDoor = v end,
    })

    -- Player Tab
    local tab_player = win:CreateTab("Player", 4483362458)

    tab_player:CreateDivider("🏃 MOVEMENT")
    
    tab_player:CreateToggle({
        Name = "Speed Hack",
        CurrentValue = false,
        Callback = function(v) getgenv().Config.speed = v end,
    })
    tab_player:CreateSlider({
        Name = "Walk Speed",
        Range = { 16, 250 },
        Increment = 1,
        CurrentValue = 16,
        Callback = function(v) getgenv().Config.speedVal = v end,
    })
    tab_player:CreateToggle({
        Name = "Jump Hack",
        CurrentValue = false,
        Callback = function(v) getgenv().Config.jump = v end,
    })
    tab_player:CreateSlider({
        Name = "Jump Power",
        Range = { 50, 300 },
        Increment = 1,
        CurrentValue = 50,
        Callback = function(v) getgenv().Config.jumpVal = v end,
    })

    tab_player:CreateDivider("⚙️ MISC")
    
    tab_player:CreateToggle({
        Name = "Noclip",
        CurrentValue = false,
        Callback = function(v) getgenv().Config.noclip = v end,
    })
    tab_player:CreateToggle({
        Name = "No PC Error",
        CurrentValue = false,
        Callback = function(v) getgenv().Config.noPcError = v end,
    })

    -- Server Tab
    local tab_server = win:CreateTab("Server", 4483362458)
    
    tab_server:CreateDivider("🔄 SERVER ACTIONS")
    
    tab_server:CreateButton({
        Name = "Rejoin",
        Callback = function() TeleportService:Teleport(game.PlaceId, lp) end,
    })
    tab_server:CreateButton({
        Name = "Server Hop",
        Callback = function() TeleportService:Teleport(game.PlaceId) end,
    })
    tab_server:CreateButton({
        Name = "Destroy UI",
        Callback = function() 
            pcall(function() Rayfield:Destroy() end)
            getgenv().qx_loaded = false 
        end,
    })

    -- Scripts Tab
    local tab_scripts = win:CreateTab("Scripts", 4483362458)
    
    tab_scripts:CreateDivider("📜 ADDITIONAL SCRIPTS")
    
    tab_scripts:CreateButton({
        Name = "Infinite Yield",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
    })
    tab_scripts:CreateButton({
        Name = "Dex Explorer",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end,
    })

    -- Credits Tab
    local tab_credits = win:CreateTab("Credits", 4483362458)
    
    tab_credits:CreateDivider("⭐ QUANTUM X")
    tab_credits:CreateLabel("Version: 2.0.0")
    tab_credits:CreateLabel("Game: Flee The Facility")
    tab_credits:CreateDivider("👨‍💻 DEVELOPERS")
    tab_credits:CreateLabel("Lead Developer: Quantum Team")
    tab_credits:CreateLabel("UI Library: Rayfield")
    tab_credits:CreateDivider("📞 CONTACT")
    tab_credits:CreateLabel("Discord: discord.gg/quantumx")
end

-- Auto-login or show key window
if KeyValid then
    task.spawn(function()
        Rayfield:Notify({
            Title = "✅ Auto-Login",
            Content = "Saved key is valid - loading Quantum X...",
            Duration = 5
        })
        task.wait(1)
        LoadMainWindow()
    end)
else
    -- Delete invalid saved key
    if SavedKey then
        pcall(function() delfile(KeyFile) end)
    end

    -- Key window
    local KeyWin = Rayfield:CreateWindow({
        Name = "🔑 Quantum X | Key Verification",
        Theme = "Amethyst",
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Key System",
        Size = UDim2.new(0, 400, 0, 300)
    })

    local KeyTab = KeyWin:CreateTab("Verification", 4483362458)

    KeyTab:CreateDivider("🔐 KEY SYSTEM")
    KeyTab:CreateLabel("Please verify your key to continue")

    KeyTab:CreateDivider("📋 GET KEY")
    KeyTab:CreateButton({
        Name = "🌐 Get Key",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({Title = "Link Copied", Content = "Complete steps and copy your key", Duration = 5})
        end
    })

    KeyTab:CreateDivider("🔑 ENTER KEY")
    local inputKey = ""
    KeyTab:CreateInput({
        Name = "Your Key",
        PlaceholderText = "Paste your key here",
        Callback = function(Token) inputKey = Token end
    })

    KeyTab:CreateButton({
        Name = "✅ Verify",
        Callback = function()
            if inputKey == "" then
                Rayfield:Notify({Title = "Error", Content = "Enter your key!", Duration = 5})
                return
            end

            if CheckKey(inputKey) then
                Rayfield:Notify({Title = "Success", Content = "Key valid! Loading...", Duration = 5})
                pcall(function() writefile(KeyFile, inputKey) end)
                KeyWin:Destroy()
                task.wait(0.5)
                LoadMainWindow()
            else
                Rayfield:Notify({Title = "Error", Content = "Invalid key!", Duration = 5})
            end
        end
    })

    KeyTab:CreateDivider("ℹ️ INFO")
    KeyTab:CreateLabel("• Keys valid 24h")
    KeyTab:CreateLabel("• Auto-save feature")
end
