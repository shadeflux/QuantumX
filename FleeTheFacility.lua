-- [[ QUANTUM X | FLEE THE FACILITY MODULE ]]
local FtF = {}

-- Configuration
FtF.Config = {
    autoComputer = false,
    autoTube     = false,
    autoDoor     = false,
    autoCapture  = false,
    espPlayer    = false,
    espComputer  = false,
    espDoor      = false,
    evadeSafeY   = 550,
    evadeRange   = 50,
    lastSwing    = 0,
}

local SWING_CD = 0.45
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- Utility functions
local function get_char()
    return lp.Character
end

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
        pcall(function()
            r:FireServer(...)
        end)
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
    if not h then return nil end
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
    if not h then return nil end
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
    if not h then return nil end
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
    return nil
end

-- Funkcja do interakcji z komputerem/tubą/drzwiami
local function interact_with_object(target_part)
    if not target_part then return end
    
    -- Symuluj kliknięcie lub użyj remote
    local remote = ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
    if remote then
        pcall(function()
            remote:FireServer("Interact", target_part)
        end)
    end
    
    -- Dodatkowo spróbuj fire touch interest
    local touch = target_part:FindFirstChildWhichIsA("TouchTransmitter")
    if touch then
        firetouchinterest(lp.Character.HumanoidRootPart, target_part, 0)
        task.wait(0.1)
        firetouchinterest(lp.Character.HumanoidRootPart, target_part, 1)
    end
end

-- ESP update loop
function FtF.UpdateESP()
    task.spawn(function()
        while task.wait(0.25) do
            -- Player ESP
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local is_b = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                    set_esp(
                        p.Character,
                        is_b and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 100),
                        FtF.Config.espPlayer
                    )
                end
            end

            -- Computer ESP
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if v.Name == "ComputerTable" then
                        set_esp(v, Color3.fromRGB(0, 200, 255), FtF.Config.espComputer)
                    elseif v.Name == "ExitDoor" then
                        set_esp(v, Color3.fromRGB(255, 215, 0), FtF.Config.espDoor)
                    end
                end
            end
        end
    end)
end

-- Automation loop (POPRAWIONA)
function FtF.StartAutomation()
    task.spawn(function()
        while task.wait(0.25) do
            local h = get_hrp()
            if not h then continue end

            -- Auto Computer/Door/Tube
            if FtF.Config.autoComputer or FtF.Config.autoDoor or FtF.Config.autoTube then
                local beast_char = get_beast_char()
                local beast_pos = beast_char and beast_char:FindFirstChild("HumanoidRootPart") and beast_char.HumanoidRootPart.Position

                local target, t_part

                if FtF.Config.autoTube then
                    local t = get_nearest_tube()
                    if t then
                        target = t.model
                        t_part = t.part
                    end
                end

                if not target and FtF.Config.autoComputer then
                    target = get_nearest_model("ComputerTable")
                    t_part = target and target:FindFirstChildWhichIsA("BasePart")
                end

                if not target and FtF.Config.autoDoor then
                    target = get_nearest_model("ExitDoor")
                    t_part = target and target:FindFirstChildWhichIsA("BasePart")
                end

                if t_part then
                    local b_near_me = beast_pos and (beast_pos - h.Position).Magnitude < FtF.Config.evadeRange
                    local b_near_tgt = beast_pos and (beast_pos - t_part.Position).Magnitude < FtF.Config.evadeRange

                    if b_near_me or b_near_tgt then
                        -- Evade mode - go to safe height
                        h.CFrame = CFrame.new(h.Position.X, FtF.Config.evadeSafeY, h.Position.Z)
                    else
                        -- Teleport do obiektu i interakcja
                        h.CFrame = t_part.CFrame * CFrame.new(0, 2, 4)
                        interact_with_object(t_part)
                        
                        -- Specyficzne remotes dla poszczególnych akcji
                        if FtF.Config.autoComputer then
                            fire_remote("Input", "Action", true)
                            fire_remote("SetPlayerStatus", 1)
                        end
                        if FtF.Config.autoTube then
                            fire_remote("StartTubeMinigame")
                        end
                    end
                end
            end

            -- Auto Capture for Beast (POPRAWIONE)
            if FtF.Config.autoCapture and get_is_beast() then
                local vic = get_nearest_player()
                if vic then
                    local vic_hrp = vic:FindFirstChild("HumanoidRootPart")
                    if vic_hrp then
                        -- Teleport za ofiarę
                        h.CFrame = vic_hrp.CFrame * CFrame.new(0, 0, 5)
                        
                        -- Atak
                        local now = tick()
                        if now - FtF.Config.lastSwing > SWING_CD and (vic_hrp.Position - h.Position).Magnitude < 25 then
                            -- Różne metody ataku
                            fire_remote("Input", "Swing", true)
                            fire_remote("SwingHammer")
                            fire_remote("Attack")
                            task.wait(0.1)
                            fire_remote("Input", "Swing", false)
                            
                            -- Dodatkowo spróbuj uderzyć przez TouchInterest
                            local hammer = lp.Character:FindFirstChild("Hammer") or lp.Backpack:FindFirstChild("Hammer")
                            if hammer and vic.Character then
                                for _, part in ipairs(vic.Character:GetDescendants()) do
                                    if part:IsA("BasePart") then
                                        firetouchinterest(hammer.Handle, part, 0)
                                        task.wait(0.05)
                                        firetouchinterest(hammer.Handle, part, 1)
                                    end
                                end
                            end
                            
                            FtF.Config.lastSwing = now
                        end
                    end
                end
            end
        end
    end)
end

-- Initialize FtF module
function FtF.Initialize()
    FtF.UpdateESP()
    FtF.StartAutomation()
end

return FtF
