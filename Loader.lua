-- Loader dla Quantum X
local url = "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/hub.lua"

print("🔍 Próbuję pobrać: " .. url)
local success, result = pcall(function()
    return game:HttpGet(url)
end)

if success and result then
    print("✅ Pobrano " .. #result .. " znaków")
    if #result > 100 then
        local func, err = loadstring(result)
        if func then
            print("✅ Kompilacja udana, uruchamiam...")
            func()
        else
            warn("❌ Błąd kompilacji: " .. tostring(err))
        end
    else
        warn("❌ Plik jest pusty lub za krótki")
    end
else
    warn("❌ Błąd pobierania: " .. tostring(result))
end
