-- Quantum X – TESTOWA WERSJA (tylko key system + puste okno)

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLibV2/main/Library.lua'))()
local Window = Library:CreateWindow("Quantum X", "Unseen. Unpatched. Unstoppable.")

-- Tylko karta Key System – nic więcej
local KeyTab = Window:AddTab("Key System")

KeyTab:AddLabel("Klucz ważny 24h – przejdź checkpointy jak w Delta!")
KeyTab:AddLabel("Po ukończeniu kroków skopiuj klucz i wklej poniżej.")

local KeyStatus = KeyTab:AddLabel("Status: Oczekiwanie na klucz...")

local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    return Success and Response and Response:find('"valid":true')
end

local SavedKey = nil
local KeyFile = "QuantumX_Key.txt"

pcall(function()
    if isfile(KeyFile) then
        SavedKey = readfile(KeyFile)
    end
end)

local KeyValid = SavedKey and CheckKey(SavedKey)

if KeyValid then
    KeyStatus.Text = "Status: Klucz ważny – test udany!"
    task.delay(1.5, function()
        KeyTab:Hide()
        Library:Notify("Test przeszedł! GUI się otworzyło i key działa.", 8)
    end)
else
    if SavedKey then
        pcall(delfile, KeyFile)
    end

    KeyTab:AddButton("Otwórz stronę z kluczami", function()
        setclipboard("https://work.ink/2dRx/key-system")
        Library:Notify("Skopiowano link! Ukończ kroki i wklej klucz.", 10)
    end)

    KeyTab:AddInput("Wklej klucz tutaj", {
        Placeholder = "np. abc123-def456-ghi789",
        ClearTextOnFocus = false,
        Callback = function(Token)
            if Token == "" then return end

            if CheckKey(Token) then
                Library:Notify("Sukces! Klucz zaakceptowany.", 5)
                pcall(writefile, KeyFile, Token)
                KeyStatus.Text = "Status: Klucz ważny – test udany!"
                task.delay(1.5, function()
                    KeyTab:Hide()
                    Library:Notify("Test przeszedł! GUI się otworzyło i key działa.", 8)
                end)
            else
                Library:Notify("Błąd – nieprawidłowy klucz", 6)
            end
        end
    })
end

-- Zero funkcji – tylko to okno testowe
Library:Notify("Quantum X TEST – jeśli widzisz to okno, to działa!", 10)
