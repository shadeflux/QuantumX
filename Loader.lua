-- Loader dla Quantum X
local url = "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua"
local success, result = pcall(function()
    return game:HttpGet(url)
end)
if success then
    loadstring(result)()
else
    warn("Nie udało się załadować Quantum X. Sprawdź URL.")
end
