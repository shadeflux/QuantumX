-- Quantum X – WERSJA BEZ UI (tylko konsola Delta)

print("Quantum X start – test bez GUI")

local function CheckKey(Token)
    local Success, Response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. Token)
    end)
    if Success and Response and Response:find('"valid":true') then
        return true
    end
    return false
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
    print("Klucz ważny – hub odblokowany")
    -- Tu wklej swoje funkcje ręcznie, np.:
    -- print("Speed hack włączony")
    -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    -- itd.
else
    if SavedKey then
        pcall(delfile, KeyFile)
    end
    print("Brak ważnego klucza")
    print("Wklej w konsoli Delta: getgenv().QuantumKey = \"twój_klucz\" i uruchom skrypt ponownie")
    print("Link do klucza: https://work.ink/2dRx/key-system")
end

print("Koniec testu")
