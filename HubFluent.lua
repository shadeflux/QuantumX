local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Quantum X",
    SubTitle = "Unseen. Unpatched. Unstoppable.",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",  -- czarny styl jak w Aether
    Acrylic = true,  -- blur tła (bardzo ładnie wygląda)
    MinimizeKeybind = Enum.KeyCode.LeftControl,
    ShowCustomCursor = true
})

-- Tab Player Mods
local PlayerTab = Window:AddTab({ Title = "Player Mods" })

-- Zmienne
local speedEnabled = false
local defaultSpeed = 16
local customSpeed = 32
local infiniteJumpEnabled = false
local noclipEnabled = false
local flinging = false
local antiflingConn = nil

-- Speed Hack
PlayerTab:AddSlider("Walk Speed", {
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Rounding = 1,
    Callback = function(value)
        customSpeed = value
        if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

PlayerTab:AddToggle("Enable Speed Hack", {
    Title = "Włącz Speed Hack",
    Default = false,
    Callback = function(value)
        speedEnabled = value
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value and customSpeed or defaultSpeed
        end
    end
})

-- Infinite Jump
PlayerTab:AddToggle("Infinite Jump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(value)
        infiniteJumpEnabled = value
    end
})

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- NoClip
PlayerTab:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(value)
        noclipEnabled = value
        if value then
            spawn(function()
                while noclipEnabled do
                    if LocalPlayer.Character then
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Fling
PlayerTab:AddToggle("Fling", {
    Title = "Fling",
    Default = false,
    Callback = function(value)
        flinging = value
        if value then
            local char = LocalPlayer.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                        v.Massless = true
                    end
                end
                local bv = Instance.new("BodyAngularVelocity")
                bv.AngularVelocity = Vector3.new(0, 99999, 0)
                bv.MaxTorque = Vector3.new(0, math.huge, 0)
                bv.Parent = char:FindFirstChild("HumanoidRootPart")
                spawn(function()
                    while flinging do
                        bv.AngularVelocity = Vector3.new(0, 99999, 0)
                        task.wait(0.2)
                        bv.AngularVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.1)
                    end
                    bv:Destroy()
                end)
            end
        end
    end
})

-- Anti Fling
PlayerTab:AddToggle("Anti Fling", {
    Title = "Anti Fling",
    Default = false,
    Callback = function(value)
        if value then
            antiflingConn = RunService.Stepped:Connect(function()
                for _, p in pairs(Players:GetPlayers()) do
                    if p \~= LocalPlayer and p.Character then
                        for _, v in pairs(p.Character:GetDescendants()) do
                            if v:IsA("BasePart") then v.CanCollide = false end
                        end
                    end
                end
            end)
        else
            if antiflingConn then
                antiflingConn:Disconnect()
                antiflingConn = nil
            end
        end
    end
})

-- Teleport do gracza
PlayerTab:AddInput("Teleport do gracza", {
    Title = "Teleport do gracza",
    Placeholder = "Wpisz nick gracza",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():match(text:lower()) or p.DisplayName:lower():match(text:lower()) then
                target = p
                break
            end
        end
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            Fluent:Notify({
                Title = "Teleport",
                Content = "Teleportowano do " .. target.Name,
                Duration = 4
            })
        else
            Fluent:Notify({
                Title = "Błąd",
                Content = "Gracz nie znaleziony lub bez postaci",
                Duration = 5
            })
        end
    end
})

-- Spectate
PlayerTab:AddInput("Obserwuj gracza", {
    Title = "Obserwuj gracza",
    Placeholder = "Wpisz nick gracza",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local target = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():match(text:lower()) or p.DisplayName:lower():match(text:lower()) then
                target = p
                break
            end
        end
        if target and target.Character and target.Character:FindFirstChildOfClass("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character:FindFirstChildOfClass("Humanoid")
            Fluent:Notify({
                Title = "Spectate",
                Content = "Obserwujesz " .. target.Name,
                Duration = 4
            })
        else
            Fluent:Notify({
                Title = "Błąd",
                Content = "Gracz nie znaleziony",
                Duration = 5
            })
        end
    end
})

-- Stop Spectate
PlayerTab:AddButton({
    Title = "Zakończ obserwację",
    Callback = function()
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        Fluent:Notify({
            Title = "Spectate",
            Content = "Obserwacja zakończona",
            Duration = 4
        })
    end
})

-- Anti AFK
PlayerTab:AddToggle("Anti AFK", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(value)
        if value then
            spawn(function()
                while value do
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                    task.wait(60)
                end
            end)
        end
    end
})

-- Tab Scripts (zewnętrzne skrypty)
local ScriptsTab = Window:AddTab({ Title = "Scripts" })

ScriptsTab:AddButton({
    Title = "Infinite Yield",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

ScriptsTab:AddButton({
    Title = "Hat Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))()
    end
})

ScriptsTab:AddButton({
    Title = "RemoteSpy",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
    end
})

ScriptsTab:AddButton({
    Title = "Dex Explorer",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))()
    end
})

-- Tab Credits
local CreditsTab = Window:AddTab({ Title = "Credits" })

CreditsTab:AddParagraph({
    Title = "Created by",
    Content = "Quantum X Team\nUnseen. Unpatched. Unstoppable.\nThanks for using!"
})

-- Tab Settings (opcjonalnie)
local SettingsTab = Window:AddTab({ Title = "Settings" })

SettingsTab:AddButton({
    Title = "Zamknij GUI",
    Callback = function()
        Window:Destroy()
    end
})

Fluent:Notify({
    Title = "Quantum X",
    Content = "Hub załadowany pomyślnie! Fluent UI działa.",
    Duration = 8
})

print("Quantum X – pełny hub z Fluent UI załadowany")
