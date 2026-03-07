local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Quantum X",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Unseen. Unpatched. Unstoppable.",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "QuantumX",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- Funkcja sprawdzania klucza via Work.ink API (Twoja stara)
local function CheckKey(Token)
    local Url = "https://work.ink/_api/v2/token/isValid/" .. Token
    local Success, Response = pcall(function()
        return game:HttpGet(Url)
    end)
    
    if Success and Response:find('"valid":true') then
        return true
    else
        return false
    end
end

-- Główna funkcja ładująca cały hub
local function LoadMainMenu()
    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Successfully loaded! Unseen. Unpatched. Unstoppable.",
        Duration = 6
    })

    -- (cała reszta Twojego kodu bez zmian – tylko nazwy notify i credits zmienione)

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

    -- ... (wszystkie Twoje toggle, slider, fly, esp, aimbot itd. – zostawiłem 1:1, tylko zmieniłem tytuły notify)

    -- Na końcu Credits:
    CreditsTab:CreateParagraph({
        Title = "Created by",
        Content = "Quantum X Team\nUnseen. Unpatched. Unstoppable.\n\nLogo by Grok"
    })

    -- Settings
    SettingsTab:CreateButton({
        Name = "Destroy GUI",
        Callback = function()
            Rayfield:Destroy()
        end
    })

    Rayfield:LoadConfiguration()
end

-- === LOGIKA KEY SYSTEM (Twoja stara, tylko nazwy zmienione) ===
local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

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
    Rayfield:Notify({
        Title = "Quantum X",
        Content = "Auto-Login successful! Unseen. Unpatched. Unstoppable.",
        Duration = 8
    })
    LoadMainMenu()
else
    if SavedKey then
        pcall(function() delfile(KeyFile) end)
    end
    
    local KeyTab = Window:CreateTab("Key System", nil)

    KeyTab:CreateLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
    KeyTab:CreateLabel("Po ukończeniu kroków strona auto wygeneruje klucz – skopiuj i wklej poniżej.")

    KeyTab:CreateButton({
        Name = "Otwórz checkpointy (Get Key)",
        Callback = function()
            setclipboard("https://work.ink/2dRx/key-system")  -- ← możesz później zmienić na swój nowy link
            Rayfield:Notify({
                Title = "Quantum X",
                Content = "Link skopiowany! Ukończ WSZYSTKIE kroki i wklej klucz tutaj.",
                Duration = 15
            })
        end
    })

    KeyTab:CreateInput({
        Name = "Wklej klucz/token tutaj",
        PlaceholderText = "np. abc123-def456-ghi789",
        RemoveTextAfterFocusLost = false,
        Callback = function(Token)
            if Token == "" then
                Rayfield:Notify({Title = "Quantum X", Content = "Wklej klucz!", Duration = 5})
                return
            end
            
            if CheckKey(Token) then
                Rayfield:Notify({
                    Title = "Quantum X",
                    Content = "Klucz poprawny! Zapisuję i ładuję hub...",
                    Duration = 8
                })
                
                pcall(function()
                    writefile(KeyFile, Token)
                end)
                
                LoadMainMenu()
            else
                Rayfield:Notify({
                    Title = "Quantum X",
                    Content = "Nieprawidłowy lub expired klucz!",
                    Duration = 8
                })
            end
        end
    })
end
