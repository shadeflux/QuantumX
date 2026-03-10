-- Loader z mirrorami i diagnostyką dla Quantum X
local urls = {
    "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua?t=" .. tick(),
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
        print("Pierwsze 100 znaków:")
        print(string.sub(result, 1, 100))
        
        -- Próba kompilacji
        local func, compileErr = loadstring(result)
        if not func then
            warn("❌ Błąd kompilacji: " .. tostring(compileErr))
        else
            print("✅ Kompilacja udana, uruchamiam...")
            -- Uruchom w chronionym środowisku
            local ok, runErr = pcall(func)
            if not ok then
                warn("❌ Błąd wykonania: " .. tostring(runErr))
            else
                loaded = true
                break
            end
        end
    else
        warn("❌ Nie udało się pobrać z URL " .. i .. ": " .. tostring(result))
    end
    
    task.wait(0.5)
end

if not loaded then
    warn("❌ Quantum X: nie można załadować z żadnego źródła.")
end
