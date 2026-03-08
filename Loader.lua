-- Loader dla Quantum X
-- Wklej poniżej swój link RAW z GitHuba do pliku hub.lua
local hubURL = "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua"

local success, result = pcall(function()
    return game:HttpGet(hubURL)
end)

if success then
    loadstring(result)()
else
    warn("Quantum X: Nie udało się załadować skryptu. Sprawdź link do GitHuba.")
end
