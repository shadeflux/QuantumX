-- Loader z mirrorami i diagnostyką dla Quantum X
local urls = {
    "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua",
    "https://ghproxy.net/https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua",
    "https://cdn.jsdelivr.net/gh/shadeflux/QuantumX@main/Hub.lua"
}

local loaded = false
for i, url in ipairs(urls) do
    print("Próbuję URL " .. i .. ": " .. url)
    
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success and result then
        print("✅ Pobrano " .. #result .. " znaków z URL " .. i)
        
        -- Sprawdź pierwsze 100 znaków (czy to na pewno Lua)
        print("Pierwsze 100 znaków:")
        print(string.sub(result, 1, 100))
        
        -- Próba kompilacji z obsługą błędów
        local func, err = loadstring(result)
        if func then
            print("✅ Kompilacja udana, uruchamiam...")
            func()
            loaded = true
            break
        else
            warn("❌ Błąd kompilacji z URL " .. i .. ": " .. tostring(err))
        end
    else
        warn("❌ Nie udało się pobrać z URL " .. i .. ": " .. tostring(result))
    end
    
    task.wait(0.5)
end

if not loaded then
    warn("❌ Quantum X: nie można załadować z żadnego źródła.")
end
