-- [[ QUANTUM X | FLEE THE FACILITY ]]
if getgenv().qx_loaded then return end
getgenv().qx_loaded = true

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local lp                = Players.LocalPlayer
local Rayfield          = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- ===== KEY SYSTEM (EsidelieHub style) =====
local function CheckKey(token)
    if not token or token == "" then return false end
    local url = "https://work.ink/_api/v2/token/isValid?token=" .. token
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if not success or not response then
        warn("Błąd połączenia z API kluczy")
        return false
    end
    local decodedSuccess, decoded = pcall(function()
        return HttpService:JSONDecode(response)
    end)
    if decodedSuccess and decoded and decoded.valid == true then
        return true
    else
        return false
    end
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

if KeyValid then
    -- Auto-login – od razu ładujemy główne okno
    Rayfield:Notify({
        Title = "Auto-Login",
        Content = "Zapisany klucz ważny – hub załadowany!",
        Duration = 5
    })
else
    -- Usuń stary klucz jeśli był niepoprawny
    if SavedKey then
        pcall(function() delfile(KeyFile) end)
    end

    -- Tworzymy okno key system
    local KeyWin = Rayfield:CreateWindow({
        Name = "🔑 Quantum X | Key System",
        Theme = "Amethyst",
        Size = UDim2.new(0, 400, 0, 280)
    })

    local KeyTab = KeyWin:CreateTab("Verification", 4483362458)

    KeyTab:CreateLabel("🔐 SYSTEM KLUCZY QUANTUM X")
    KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy!")
    KeyTab:CreateLabel("-----------------------------------")

    KeyTab:CreateButton({
        Name = "🌐 Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({
                Title = "Link skopiowany!",
                Content = "Wklej w przeglądarkę i ukończ kroki.",
                Duration = 8
            })
        end
    })

    local inputKey = ""

    KeyTab:CreateInput({
        Name = "🔐 Wklej klucz tutaj",
        PlaceholderText = "np. QX-1234-5678",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            inputKey = Token
        end
    })

    KeyTab:CreateButton({
        Name = "✅ Zatwierdź klucz",
        Callback = function()
            if inputKey == "" then
                Rayfield:Notify({
                    Title = "Błąd",
                    Content = "Wklej klucz!",
                    Duration = 5
                })
                return
            end

            Rayfield:Notify({
                Title = "Sprawdzanie",
                Content = "Weryfikacja klucza...",
                Duration = 3
            })

            if CheckKey(inputKey) then
                Rayfield:Notify({
                    Title = "Sukces!",
                    Content = "Klucz poprawny! Ładowanie...",
                    Duration = 5
                })

                pcall(function()
                    writefile(KeyFile, inputKey)
                end)

                task.wait(1)
                KeyWin:Destroy()
                task.wait(0.3)
                -- Po zamknięciu okna klucza ładujemy główne okno
                LoadMainWindow()
            else
                Rayfield:Notify({
                    Title = "Błąd",
                    Content = "Nieprawidłowy lub wygasły klucz!",
                    Duration = 5
                })
            end
        end
    })

    KeyTab:CreateLabel("-----------------------------------")
    KeyTab:CreateLabel("⚡ Po wpisaniu klucza hub załaduje się automatycznie.")

    -- Zatrzymaj dalsze wykonywanie – główne okno załaduje się dopiero po poprawnym kluczu
    return
end

-- ===== GŁÓWNA FUNKCJA OKNA (wywoływana po key system) =====
function LoadMainWindow()
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
            r:FireServer(...)
        end
    end

    local function set_esp(inst, fill_color, enabled)
        local h = inst:FindFirstChild("_qx_esp")
        if enabled then
            if not h then
                h                     = Instance.new("Highlight", inst)
                h.Name                = "_qx_esp"
                h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                h.FillTransparency    = 0.4
                h.OutlineTransparency = 0
                h.OutlineColor        = Color3.new(1, 1, 1)
            end
            h.FillColor = fill_color
        elseif h then
            h:Destroy()
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

    RunService.Stepped:Connect(function()
        local h = get_hum()
        if h then
            if getgenv().Config.speed then
                h.WalkSpeed = getgenv().Config.speedVal
            end
            if getgenv().Config.jump then
                h.JumpPower = getgenv().Config.jumpVal
            end
        end
        local c = get_char()
        if c and getgenv().Config.noclip then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
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

    task.spawn(function()
        while task.wait(0.25) do
            local h = get_hrp()
            if not h then continue end

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local is_b = p.Character:FindFirstChild("Hammer") or (p.Backpack and p.Backpack:FindFirstChild("Hammer"))
                    set_esp(
                        p.Character,
                        is_b and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(50, 255, 100),
                        getgenv().Config.espPlayer
                    )
                end
            end

            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") then
                    if v.Name == "ComputerTable" then
                        set_esp(v, Color3.fromRGB(0, 200, 255), getgenv().Config.espComputer)
                    elseif v.Name == "ExitDoor" then
                        set_esp(v, Color3.fromRGB(255, 215, 0), getgenv().Config.espDoor)
                    end
                end
            end

            if getgenv().Config.autoComputer or getgenv().Config.autoDoor or getgenv().Config.autoTube then
                local beast_char = get_beast_char()
                local beast_pos  = beast_char
                    and beast_char:FindFirstChild("HumanoidRootPart")
                    and beast_char.HumanoidRootPart.Position

                local target, t_part

                if getgenv().Config.autoTube then
                    local t = get_nearest_tube()
                    if t then
                        target = t.model
                        t_part = t.part
                    end
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
                    local b_near_me  = beast_pos and (beast_pos - h.Position).Magnitude     < getgenv().Config.evadeRange
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

            if getgenv().Config.autoCapture and get_is_beast() then
                local vic = get_nearest_player()
                if vic then
                    local vic_hrp = vic:FindFirstChild("HumanoidRootPart")
                    if vic_hrp then
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
        end
    end)

    local win = Rayfield:CreateWindow({
        Name            = "Quantum X | Flee The Facility",
        LoadingTitle    = "Quantum X",
        LoadingSubtitle = "Flee The Facility",
        Theme           = "Amethyst",
        Size            = UDim2.new(0, 500, 0, 440),
    })

    local tab_ftf = win:CreateTab("FtF", 4483362458)

    tab_ftf:CreateSection("Survivor")
    tab_ftf:CreateToggle({
        Name         = "Auto Computer",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.autoComputer = v end,
    })
    tab_ftf:CreateToggle({
        Name         = "Auto Tube",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.autoTube = v end,
    })
    tab_ftf:CreateToggle({
        Name         = "Auto Exit Door",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.autoDoor = v end,
    })

    tab_ftf:CreateSection("Beast")
    tab_ftf:CreateToggle({
        Name         = "Auto Capture",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.autoCapture = v end,
    })

    tab_ftf:CreateSection("Visuals")
    tab_ftf:CreateToggle({
        Name         = "Player ESP",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.espPlayer = v end,
    })
    tab_ftf:CreateToggle({
        Name         = "Computer ESP",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.espComputer = v end,
    })
    tab_ftf:CreateToggle({
        Name         = "Door ESP",
        CurrentValue = false,
        Callback     = function(v) getgenv().Config.espDoor = v end,
    })

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

    local tab_scripts = win:CreateTab("Scripts", 4483362458)
    tab_scripts:CreateButton({
        Name     = "Infinite Yield",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end,
    })
    tab_scripts:CreateButton({
        Name     = "Dex Explorer",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end,
    })
end

-- Jeśli key system nie został aktywowany (czyli klucz był poprawny) to ładujemy okno
if KeyValid then
    LoadMainWindow()
end
