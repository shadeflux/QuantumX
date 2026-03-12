-- [[ QUANTUM X | FLEE THE FACILITY ]]
if getgenv().qx_loaded then return end
getgenv().qx_loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local lp = Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Config
getgenv().Config = {
    speed        = false,
    speedVal     = 16,
    jump         = false,
    jumpVal      = 50,
    noclip       = false,
    noPcError    = false,
    espPlayer    = false,
    espComputer  = false,
    espDoor      = false,
    autoComputer = false,
    autoTube     = false,
    autoDoor     = false,
    autoCapture  = false,
    evadeSafeY   = 550,
    evadeRange   = 50,
    lastSwing    = 0,
}

local SWING_CD = 0.45

local function get_char() return lp.Character end
local function get_hrp()
    local c = get_char()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function get_hum()
    local c = get_char()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end
local function get_is_beast()
    local c = get_char()
    return c and (c:FindFirstChild("Hammer") or (lp.Backpack and lp.Backpack:FindFirstChild("Hammer")))
end

local function fire_remote(...)
    local r = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
    if r then
        pcall(function() r:FireServer(...) end)
    end
end

local function set_esp(inst, fill_color, enabled)
    if not inst then return end
    local h = inst:FindFirstChild("_qx_esp")
    if enabled then
        if not h then
            h = Instance.new("Highlight", inst)
            h.Name = "_qx_esp"
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.FillTransparency = 0.4
            h.OutlineTransparency = 0
            h.OutlineColor = Color3.new(1, 1, 1)
        end
        h.FillColor = fill_color
    elseif h then
        pcall(function() h:Destroy() end)
    end
end

local function get_nearest_model(name)
    local h = get_hrp()
    if not h then return end
    local best, best_dist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name == name then
            local p = v:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (p.Position - h.Position).Magnitude
                if d < best_dist then
                    best_dist = d
                    best = v
                end
            end
        end
    end
    return best
end

local function get_nearest_player()
    local h = get_hrp()
    if not h then return end
    local best, best_dist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local ph = p.Character:FindFirstChild("HumanoidRootPart")
            if ph then
                local d = (ph.Position - h.Position).Magnitude
                if d < best_dist then
                    best_dist = d
                    best = p.Character
                end
            end
        end
    end
    return best
end

local function get_nearest_tube()
    local h = get_hrp()
    if not h then return end
    local best, best_dist = nil, math.huge
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name == "Tube" or v.Name == "CryoTube") then
            local p = v:FindFirstChildWhichIsA("BasePart")
            if p then
                local d = (p.Position - h.Position).Magnitude
                if d < best_dist then
                    best_dist = d
                    best = { model = v, part = p }
                end
            end
        end
    end
    return best
end

local function get_beast_char()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            if p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer")) then
                return p.Character
            end
        end
    end
end

-- Speed, Jump, Noclip loop
RunService.Stepped:Connect(function()
    local h = get_hum()
    if h then
        if getgenv().Config.speed then h.WalkSpeed = getgenv().Config.speedVal end
        if getgenv().Config.jump then h.JumpPower = getgenv().Config.jumpVal end
    end
    local c = get_char()
    if c and getgenv().Config.noclip then
        for _, v in ipairs(c:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- No PC Error loop
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

-- Main automation loop
task.spawn(function()
    while task.wait(0.25) do
        local h = get_hrp()
        if not h then continue end

        -- ESP
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp and p.Character then
                local is_b = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                set_esp(p.Character, is_b and Color3.fromRGB(255,50,50) or Color3.fromRGB(50,255,100), getgenv().Config.espPlayer)
            end
        end

        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") then
                if v.Name == "ComputerTable" then
                    set_esp(v, Color3.fromRGB(0,200,255), getgenv().Config.espComputer)
                elseif v.Name == "ExitDoor" then
                    set_esp(v, Color3.fromRGB(255,215,0), getgenv().Config.espDoor)
                end
            end
        end

        -- Auto Computer/Door/Tube
        if getgenv().Config.autoComputer or getgenv().Config.autoDoor or getgenv().Config.autoTube then
            local beast_char = get_beast_char()
            local beast_pos = beast_char and beast_char:FindFirstChild("HumanoidRootPart") and beast_char.HumanoidRootPart.Position
            local target, t_part

            if getgenv().Config.autoTube then
                local t = get_nearest_tube()
                if t then target, t_part = t.model, t.part end
            end
            if not target and getgenv().Config.autoComputer then
                target = get_nearest_model("ComputerTable")
                t_part = target and target:FindFirstChildWhichIsA("BasePart")
            end
            if not target and getgenv().Config.autoDoor then
                target = get_nearest_model("ExitDoor")
                t_part = target and target:FindFirstChildWhichIsA("BasePart")
            end

            if t_part then
                local b_near_me = beast_pos and (beast_pos - h.Position).Magnitude < getgenv().Config.evadeRange
                local b_near_tgt = beast_pos and (beast_pos - t_part.Position).Magnitude < getgenv().Config.evadeRange

                if b_near_me or b_near_tgt then
                    h.CFrame = CFrame.new(h.Position.X, getgenv().Config.evadeSafeY, h.Position.Z)
                else
                    h.CFrame = t_part.CFrame * CFrame.new(0, 2, 4)
                    if getgenv().Config.autoComputer then
                        fire_remote("Input", "Action", true)
                        fire_remote("SetPlayerStatus", 1)
                    end
                    if getgenv().Config.autoTube then
                        fire_remote("StartTubeMinigame")
                    end
                end
            end
        end

        -- Auto Capture
        if getgenv().Config.autoCapture and get_is_beast() then
            local vic = get_nearest_player()
            if vic and vic:FindFirstChild("HumanoidRootPart") then
                local vic_hrp = vic.HumanoidRootPart
                h.CFrame = vic_hrp.CFrame * CFrame.new(0, 0, 5)
                local now = tick()
                if now - getgenv().Config.lastSwing > SWING_CD and (vic_hrp.Position - h.Position).Magnitude < 20 then
                    fire_remote("Input", "Swing", true)
                    fire_remote("SwingHammer")
                    fire_remote("Attack")
                    task.wait(0.08)
                    fire_remote("Input", "Swing", false)
                    getgenv().Config.lastSwing = now
                end
            end
        end
    end
end)

-- GUI
local win = Rayfield:CreateWindow({
    Name = "Quantum X | Flee The Facility",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Flee The Facility",
    Theme = "Amethyst",
    Size = UDim2.new(0, 500, 0, 440),
})

local tab_ftf = win:CreateTab("FtF", 4483362458)

tab_ftf:CreateSection("Survivor")
tab_ftf:CreateToggle({ Name = "Auto Computer", CurrentValue = false, Callback = function(v) getgenv().Config.autoComputer = v end })
tab_ftf:CreateToggle({ Name = "Auto Tube", CurrentValue = false, Callback = function(v) getgenv().Config.autoTube = v end })
tab_ftf:CreateToggle({ Name = "Auto Exit Door", CurrentValue = false, Callback = function(v) getgenv().Config.autoDoor = v end })

tab_ftf:CreateSection("Beast")
tab_ftf:CreateToggle({ Name = "Auto Capture", CurrentValue = false, Callback = function(v) getgenv().Config.autoCapture = v end })

tab_ftf:CreateSection("Visuals")
tab_ftf:CreateToggle({ Name = "Player ESP", CurrentValue = false, Callback = function(v) getgenv().Config.espPlayer = v end })
tab_ftf:CreateToggle({ Name = "Computer ESP", CurrentValue = false, Callback = function(v) getgenv().Config.espComputer = v end })
tab_ftf:CreateToggle({ Name = "Door ESP", CurrentValue = false, Callback = function(v) getgenv().Config.espDoor = v end })

local tab_player = win:CreateTab("Player", 4483362458)

tab_player:CreateSection("Movement")
tab_player:CreateToggle({ Name = "Speed Hack", CurrentValue = false, Callback = function(v) getgenv().Config.speed = v end })
tab_player:CreateSlider({ Name = "Walk Speed", Range = {16, 250}, Increment = 1, CurrentValue = 16, Callback = function(v) getgenv().Config.speedVal = v end })
tab_player:CreateToggle({ Name = "Jump Hack", CurrentValue = false, Callback = function(v) getgenv().Config.jump = v end })
tab_player:CreateSlider({ Name = "Jump Power", Range = {50, 300}, Increment = 1, CurrentValue = 50, Callback = function(v) getgenv().Config.jumpVal = v end })

tab_player:CreateSection("Misc")
tab_player:CreateToggle({ Name = "Noclip", CurrentValue = false, Callback = function(v) getgenv().Config.noclip = v end })
tab_player:CreateToggle({ Name = "No PC Error", CurrentValue = false, Callback = function(v) getgenv().Config.noPcError = v end })

local tab_server = win:CreateTab("Server", 4483362458)
tab_server:CreateButton({ Name = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, lp) end })
tab_server:CreateButton({ Name = "Server Hop", Callback = function() TeleportService:Teleport(game.PlaceId) end })
tab_server:CreateButton({ Name = "Destroy UI", Callback = function() Rayfield:Destroy(); getgenv().qx_loaded = false end })

local tab_scripts = win:CreateTab("Scripts", 4483362458)
tab_scripts:CreateButton({ Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end })
tab_scripts:CreateButton({ Name = "Dex Explorer", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
tab_scripts:CreateButton({ Name = "SimpleSpy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpyBeta.lua"))() end })
