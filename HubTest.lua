print("Quantum X – TEST MINIMALNY (bez GUI, tylko konsola)")

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
    print("KLUCZ WAŻNY – TEST PRZESZEDŁ")
    -- Tu możesz wkleić proste testowe funkcje, np.:
    print("Test speed hack: WalkSpeed = 100")
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    end
    print("Test infinite jump włączony")
    -- itd.
else
    print("BRAK WAŻNEGO KLUCZA")
    print("Wklej w konsoli Delta i uruchom skrypt ponownie:")
    print("getgenv().QuantumKey = \"twój_klucz\"")
    print("Link do klucza: https://work.ink/2dRx/key-system")
end

print("Koniec testu – jeśli widzisz ten komunikat, HttpGet działa")
