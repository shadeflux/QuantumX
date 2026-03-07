local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Quantum X",
    SubTitle = "Unseen. Unpatched. Unstoppable.",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",  -- lub "Aqua" albo "Amethyst" – najlepsze pod Aether vibe
    MinimizeKeybind = Enum.KeyCode.LeftControl,
    Acrylic = true,  -- blur background – bardzo Aether-like
    ShowCustomCursor = true,
    MinimizeOnEscape = true
})

-- Gradient + neon vibe (bardzo zbliżony do Aether)
Window:SelectTab(1)

-- Key System (pierwsza karta)
local KeyTab = Window:AddTab({ Title = "Key System" })

KeyTab:AddParagraph({
    Title = "Key System",
    Content = "Klucz ważny 24h – przejdź checkpointy jak w Delta!\nPo ukończeniu skopiuj klucz i wklej poniżej."
})

local KeyStatus = KeyTab:AddParagraph({
    Title = "Status",
    Content = "Oczekiwanie na klucz..."
})

local KeyInput = KeyTab:AddInput("KeyInput", {
    Title = "Wklej klucz tutaj",
    Placeholder = "np. abc123-def456-ghi789",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        if value == "" then return end

        local function CheckKey(Token)
            local Success, Response = pcall(function()
                return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
            end)
            return Success and Response and Response:find('"valid":true')
        end

        if CheckKey(value) then
            KeyStatus:SetDesc("Status: Klucz zaakceptowany! Hub odblokowany.")
            pcall(writefile, "QuantumX_Key.txt", value)
            task.delay(1.2, function()
                KeyTab:Destroy()
                LoadMainHub()
            end)
        else
            KeyStatus:SetDesc("Status: Nieprawidłowy lub wygasły klucz")
            Fluent:Notify({
                Title = "Błąd",
                Content = "Nieprawidłowy klucz – spróbuj ponownie",
                Duration = 6
            })
        end
    end
})

KeyTab:AddButton({
    Title = "Otwórz stronę z kluczami",
    Callback = function()
        setclipboard("https://work.ink/2dRx/key-system")
        Fluent:Notify({
            Title = "Skopiowano!",
            Content = "Ukończ kroki w przeglądarce i wklej klucz tutaj.",
            Duration = 10
        })
    end
})

-- Auto-login jeśli klucz zapisany
local SavedKey = nil
pcall(function()
    if isfile("QuantumX_Key.txt") then
        SavedKey = readfile("QuantumX_Key.txt")
    end
end)

if SavedKey and CheckKey(SavedKey) then
    KeyStatus:SetDesc("Status: Auto-login udany – hub odblokowany")
    task.delay(1.2, function()
        KeyTab:Destroy()
        LoadMainHub()
    end)
end

-- Główny hub – ładuje się po kluczu
function LoadMainHub()
    local PlayerTab = Window:AddTab({ Title = "Player Mods" })
    local ScriptsTab = Window:AddTab({ Title = "Scripts" })
    local CreditsTab = Window:AddTab({ Title = "Credits" })
    local SettingsTab = Window:AddTab({ Title = "Settings" })

    -- PLAYER MODS (wszystkie Twoje funkcje oprócz aimbota i fly/float)

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
        Title = "Enable Speed Hack",
        Default = false,
        Callback = function(value)
            speedEnabled = value
            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = value and customSpeed or defaultSpeed
            end
        end
    })

    PlayerTab:AddToggle("Infinite Jump", {
        Title = "Infinite Jump",
        Default = false,
        Callback = function(value)
            infiniteJumpEnabled = value
        end
    })

    UserInputService.JumpRequest:Connect(function()
        if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState("Jumping")
        end
    end)

    PlayerTab:AddToggle("NoClip", {
        Title = "NoClip",
        Default = false,
        Callback = function(value)
            noclipEnabled = value
            while noclipEnabled and task.wait(0.1) do
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    })

    -- ... (dodaj tu resztę toggle/slider/buttonów z Twojego oryginalnego kodu – tp, fling, anti-fling, spawnpoint, spectate, anti-afk itd.)

    -- Scripts Tab
    ScriptsTab:AddButton("Infinite Yield", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)

    ScriptsTab:AddButton("Hat Hub", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/inkdupe/hat-scripts/refs/heads/main/updatedhathub.lua"))()
    end)

    ScriptsTab:AddButton("RemoteSpy", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
    end)

    ScriptsTab:AddButton("Dex Explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/Dex/refs/heads/master/main.lua"))()
    end)

    -- Credits
    CreditsTab:AddParagraph({
        Title = "Created by",
        Content = "Quantum X Team\nUnseen. Unpatched. Unstoppable.\nThanks for using!"
    })

    -- Settings
    SettingsTab:AddButton("Zamknij GUI", function()
        Window:Destroy()
    end)

    Fluent:Notify({
        Title = "Quantum X",
        Content = "Hub załadowany pomyślnie!",
        Duration = 6
    })
end
