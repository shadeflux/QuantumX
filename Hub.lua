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
    Rayfield:Destroy()               
    task.wait(0.3)                    
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
                    Content = "Klucz zaakceptowany
