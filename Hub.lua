local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Kluczowe: tworzymy dwa osobne okna, stare niszczymy przez Rayfield:Destroy()
local KeyWindow = Rayfield:CreateWindow({
    Name = "Quantum X - Key System",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
    KeySystem = false
})

-- Funkcja sprawdzania klucza (bez zmian)
local function CheckKey(Token)
    local Url = "https://work.ink/_api/v2/token/isValid/" .. Token
    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)
    return Success and Response:find('"valid":true')
end

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile and isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = SavedKey and CheckKey(SavedKey)

if KeyValid then
    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Auto-login – klucz ważny, ładuję hub...",
        Duration = 4
    })
    Rayfield:Destroy()               -- niszczymy całe Rayfield (w tym okno key)
    task.wait(0.3)                    -- małe opóźnienie, żeby uniknąć race condition
    LoadMainHub()
else
    if SavedKey then pcall(delfile, KeyFile) end

    local KeyTab = KeyWindow:CreateTab("Key System")

    KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
    KeyTab:CreateLabel("Po ukończeniu wszystkich kroków skopiuj klucz i wklej poniżej.")

    KeyTab:CreateButton({
        Name = "Otwórz stronę z kluczami",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")
            Rayfield:Notify({
                Title = "Skopiowano link",
                Content = "Ukończ WSZYSTKIE kroki i wklej klucz tutaj.",
                Duration = 12
            })
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz / token",
        PlaceholderText = "np. abc123-def456-ghi789",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" or #Token < 8 then
                Rayfield:Notify({Title = "Błąd", Content = "Wklej poprawny klucz", Duration = 4})
                return
            end

            if CheckKey(Token) then
                Rayfield:Notify({
                    Title = "Sukces",
                    Content = "Klucz zaakceptowany – zapisuję i ładuję hub...",
                    Duration = 5
                })
                pcall(writefile, KeyFile, Token)

                Rayfield:Destroy()          -- niszczymy całe Rayfield
                task.wait(0.3)
                LoadMainHub()
            else
                Rayfield:Notify({
                    Title = "Błąd",
                    Content = "Nieprawidłowy lub wygasły klucz",
                    Duration = 6
                })
            end
        end
    })
end

-----------------------------------------------------------------
-- Główny hub – ładowany dopiero po kluczu
-----------------------------------------------------------------
function LoadMainHub()
    local Window = Rayfield:CreateWindow({
        Name = "Quantum X",
        LoadingTitle = "Quantum X",
        LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "QuantumX",
            FileName = "Config"
        },
        Discord = { Enabled = false },
        KeySystem = false
    })

    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Hub załadowany pomyślnie!",
        Duration = 5
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local PlayerTab = Window:CreateTab("Player Mods", "user")
    local AimbotTab = Window:CreateTab("Aimbot & ESP", nil)
    local ScriptsTab = Window:CreateTab("Scripts", "code")
    local CreditsTab = Window:CreateTab("Credits", "info")
    local SettingsTab = Window:CreateTab("Settings", "settings")

    -- Zmienne (bez zmian)
    local speedEnabled = false
    local defaultSpeed = 16
    local customSpeed = 32
    local flinging = false
    local antifling = nil
    local spawnpoint = false
    local spawnpos = nil
    local spectating = false
    local FLYING = false
    local QEfly = true
    local iyflyspeed = 5
    local Floating = false
    local floatName = "FloatPart_" .. math.random(1000, 9999)
    local FloatValue = -3.1
    local infiniteJumpEnabled = false
    local noclipEnabled = false

    -- Funkcje pomocnicze (bez zmian)
    local function getRoot(char)
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end

    local function getPlayerFromName(name)
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower():match("^" .. name:lower()) or player.DisplayName:lower():match("^" .. name:lower()) then
                return player
            end
        end
        return nil
    end

    -- PLAYER MODS (cały Twój kod – bez skrótów)

    PlayerTab:CreateSlider({
        Name = "Walk Speed",
        Range = {16, 200},
        Increment = 1,
        Suffix = " Speed",
        CurrentValue = 16,
        Flag = "WalkSpeedSlider",
        Callback = function(value)
            customSpeed = value
            if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = value
            end
        end
    })

    PlayerTab:CreateToggle({
        Name = "Enable Speed Hack",
        CurrentValue = false,
        Flag = "SpeedHackToggle",
        Callback = function(value)
            speedEnabled = value
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value and customSpeed or defaultSpeed
            end
        end
    })

    PlayerTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Flag = "InfiniteJumpToggle",
        Callback = function(value)
            infiniteJumpEnabled = value
        end
    })

    UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end)

    PlayerTab:CreateToggle({
        Name = "NoClip",
        CurrentValue = false,
        Flag = "NoClipToggle",
        Callback = function(value)
            noclipEnabled = value
            if value then
                while noclipEnabled and task.wait() do
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end
        end
    })

    -- Fly
    local flyConnectionDown, flyConnectionUp
    local function StartFly()
        repeat task.wait() until LocalPlayer.Character and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hrp = getRoot(LocalPlayer.Character)
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local controls = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local speed = 0

        FLYING = true

        local bg = Instance.new("BodyGyro", hrp)
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = hrp.CFrame

        local bv = Instance.new("BodyVelocity", hrp)
        bv.Velocity = Vector3.new()
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        flyConnectionDown = UserInputService.InputBegan:Connect(function(input)
            if not FLYING then return end
            local key = input.KeyCode.Name:lower()
            if key == "w" then controls.F = iyflyspeed
            elseif key == "s" then controls.B = -iyflyspeed
            elseif key == "a" then controls.L = -iyflyspeed
            elseif key == "d" then controls.R = iyflyspeed
            elseif QEfly and key == "q" then controls.Q = iyflyspeed
            elseif QEfly and key == "e" then controls.E = iyflyspeed end
        end)

        flyConnectionUp = UserInputService.InputEnded:Connect(function(input)
            if not FLYING then return end
            local key = input.KeyCode.Name:lower()
            if key == "w" then controls.F = 0
            elseif key == "s" then controls.B = 0
            elseif key == "a" then controls.L = 0
            elseif key == "d" then controls.R = 0
            elseif key == "q" then controls.Q = 0
            elseif key == "e" then controls.E = 0 end
        end)

        RunService.RenderStepped:Connect(function()
            if not FLYING then return end
            humanoid.PlatformStand = true
            speed = (controls.L + controls.R \~= 0 or controls.F + controls.B \~= 0 or controls.Q + controls.E \~= 0) and 50 or 0
            bv.Velocity = speed > 0 and (
                Workspace.CurrentCamera.CFrame.lookVector * (controls.F + controls.B) +
                (Workspace.CurrentCamera.CFrame * CFrame.new(controls.L + controls.R, (controls.F + controls.B + controls.Q + controls.E)*0.2, 0).Position - Workspace.CurrentCamera.CFrame.Position)
            ) * speed or Vector3.new()
            bg.CFrame = Workspace.CurrentCamera.CFrame
        end)
    end

    local function StopFly()
        FLYING = false
        if flyConnectionDown then flyConnectionDown:Disconnect() end
        if flyConnectionUp then flyConnectionUp:Disconnect() end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").PlatformStand = false
        end
        if getRoot(LocalPlayer.Character) then
            for _, v in pairs(getRoot(LocalPlayer.Character):GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
            end
        end
    end

    PlayerTab:CreateToggle({
        Name = "Fly (WASD + QE)",
        CurrentValue = false,
        Callback = function(v) if v then StartFly() else StopFly() end end
    })

    PlayerTab:CreateInput({
        Name = "Fly Speed",
        PlaceholderText = "1-50",
        RemoveTextAfterFocusLost = false,
        Callback = function(text)
            local n = tonumber(text)
            if n and n >= 1 and n <= 50 then
                iyflyspeed = n
            else
                Rayfield:Notify({Title = "Błąd", Content = "Podaj liczbę 1-50", Duration = 4})
            end
        end
    })

    -- Float (Q/E)
    local floatPart, floatHeartbeat, qBegan, qEnded, eBegan, eEnded

    local function StartFloat()
        Floating = true
        local char = LocalPlayer.Character
        if not char or char:FindFirstChild(floatName) then return end

        floatPart = Instance.new("Part")
        floatPart.Name = floatName
        floatPart.Transparency = 1
        floatPart.Size = Vector3.new(2, 0.2, 1.5)
        floatPart.Anchored = true
        floatPart.CFrame = getRoot(char).CFrame * CFrame.new(0, FloatValue, 0)
        floatPart.Parent = char

        qBegan = UserInputService.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.Q then FloatValue = FloatValue - 0.5 end
            if i.KeyCode == Enum.KeyCode.E then FloatValue = FloatValue + 0.5 end
        end)

        eBegan = UserInputService.InputBegan:Connect(function(i)
            if i.KeyCode == Enum.KeyCode.E then FloatValue = FloatValue + 0.5 end
            if i.KeyCode == Enum.KeyCode.Q then FloatValue = FloatValue - 0.5 end
        end)

        floatHeartbeat = RunService.Heartbeat:Connect(function()
            if char and floatPart and getRoot(char) then
                floatPart.CFrame = getRoot(char).CFrame * CFrame.new(0, FloatValue, 0)
            else
                Floating = false
                if floatPart then floatPart:Destroy() end
                if floatHeartbeat then floatHeartbeat:Disconnect() end
                if qBegan then qBegan:Disconnect() end
                if eBegan then eBegan:Disconnect() end
            end
        end)
    end

    local function StopFloat()
        Floating = false
        if floatPart then floatPart:Destroy() end
        if floatHeartbeat then floatHeartbeat:Disconnect() end
        if qBegan then qBegan:Disconnect() end
        if eBegan then eBegan:Disconnect() end
    end

    PlayerTab:CreateToggle({
        Name = "Float (Q/E do kontroli)",
        CurrentValue = false,
        Callback = function(v) if v then StartFloat() else StopFloat() end end
    })

    -- ESP (Chams)
    local ESPEnabled = false
    local ESPConnection
    local ChamsFolder = Instance.new("Folder")
    ChamsFolder.Name = "QuantumX_Chams"
    ChamsFolder.Parent = game:GetService("CoreGui")

    Players.PlayerRemoving:Connect(function(p)
        if ChamsFolder:FindFirstChild(p.Name) then
            ChamsFolder[p.Name]:Destroy()
        end
    end)

    local function RefreshESP()
        for _, plr in pairs(Players:GetPlayers()) do
            local hl = ChamsFolder:FindFirstChild(plr.Name)
            if hl then hl.Enabled = false end

            if plr \~= LocalPlayer and plr.Character then
                if not ChamsFolder:FindFirstChild(plr.Name) then
                    hl = Instance.new("Highlight")
                    hl.Name = plr.Name
                    hl.Parent = ChamsFolder
                end
                hl.Enabled = true
                hl.Adornee = plr.Character
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.6
                hl.FillColor = Color3.fromRGB(200, 200, 255)
                hl.OutlineTransparency = 0
                hl.OutlineColor = Color3.fromRGB(255, 80, 80)
            end
        end
    end

    AimbotTab:CreateToggle({
        Name = "ESP (Chams)",
        CurrentValue = false,
        Callback = function(v)
            ESPEnabled = v
            if v then
                if not ESPConnection then
                    ESPConnection = RunService.RenderStepped:Connect(RefreshESP)
                end
            else
                if ESPConnection then ESPConnection:Disconnect() ESPConnection = nil end
                ChamsFolder:ClearAllChildren()
            end
        end
    })

    -- Teleport do gracza
    PlayerTab:CreateInput({
        Name = "Teleport do gracza",
        PlaceholderText = "Wpisz nick",
        RemoveTextAfterFocusLost = false,
        Callback = function(name)
            local target = getPlayerFromName(name)
            if target and target.Character and getRoot(target.Character) then
                getRoot(LocalPlayer.Character).CFrame = getRoot(target.Character).CFrame + Vector3.new(0, 3, 0)
            else
                Rayfield:Notify({Title = "Błąd", Content = "Gracz nie znaleziony", Duration = 4})
            end
        end
    })

    -- Fling
    PlayerTab:CreateToggle({
        Name = "Fling",
        CurrentValue = false,
        Callback = function(v)
            flinging = v
            if v then
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.Massless = true
                    end
                end
                local root = getRoot(char)
                local ang = Instance.new("BodyAngularVelocity")
                ang.AngularVelocity = Vector3.new(0, 999999, 0)
                ang.MaxTorque = Vector3.new(0, math.huge, 0)
                ang.Parent = root

                spawn(function()
                    while flinging and root do
                        ang.AngularVelocity = Vector3.new(0, 999999, 0)
                        task.wait(0.15)
                        ang.AngularVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.1)
                    end
                    if ang then ang:Destroy() end
                end)
            end
        end
    })

    -- Anti Fling
    PlayerTab:CreateToggle({
        Name = "Anti Fling",
        CurrentValue = false,
        Callback = function(v)
            if v then
                antifling = RunService.Stepped:Connect(function()
                    for _, p in Players:GetPlayers() do
                        if p \~= LocalPlayer and p.Character then
                            for _, part in pairs(p.Character:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end
                end)
            else
                if antifling then antifling:Disconnect() antifling = nil end
            end
        end
    })

    -- Set Spawnpoint
    PlayerTab:CreateButton({
        Name = "Ustaw punkt odrodzenia",
        Callback = function()
            spawnpos = getRoot(LocalPlayer.Character).CFrame
            spawnpoint = true
            Rayfield:Notify({Title = "Spawnpoint", Content = "Ustawiono punkt odrodzenia", Duration = 4})
        end
    })

    -- Spectate
    PlayerTab:CreateInput({
        Name = "Obserwuj gracza",
        PlaceholderText = "Nick gracza",
        Callback = function(name)
            local target = getPlayerFromName(name)
            if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
                Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
                spectating = true
            else
                Rayfield:Notify({Title = "Błąd", Content = "Gracz nie znaleziony", Duration = 4})
            end
        end
    })

    PlayerTab:CreateButton({
        Name = "Zakończ obserwację",
        Callback = function()
            if spectating then
                Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                spectating = false
            end
        end
    })

    -- Anti AFK
    PlayerTab:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = false,
        Callback = function(v)
            if v then
                LocalPlayer.Idled:Connect(function()
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(), Workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(), Workspace.CurrentCamera.CFrame)
                end)
            end
        end
    })

    -- Scripts Tab
    ScriptsTab:CreateButton({
        Name = "Infinite Yield",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end
    })

    ScriptsTab:CreateButton({
        Name = "Hat Hub",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))() end
    })

    ScriptsTab:CreateButton({
        Name = "RemoteSpy",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))() end
    })

    ScriptsTab:CreateButton({
        Name = "Dex Explorer",
        Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))() end
    })

   -- Credits
    CreditsTab:CreateParagraph({
        Title = "Quantum X",
        Content = "Unseen. Unpatched. Unstoppable.\n2026"
    })

    -- Settings
    SettingsTab:CreateButton({
        Name = "Zamknij GUI",
        Callback = function()
            Rayfield:Destroy()
        end
    })

    Window:LoadConfiguration()
end
