-- Loader dla Quantum X
local url = "https://raw.githubusercontent.com/shadeflux/QuantumX/main/hub.lua"

local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success and result then
    local func, err = loadstring(result)
    if func then
        func()
    else
        warn("Błąd kompilacji: " .. tostring(err))
    end
else
    warn("Nie udało się pobrać skryptu. Sprawdź URL.")
end
