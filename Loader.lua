-- Quantum X Loader - debug + fallback 2026
print("[Quantum X] Loader start...")

if getgenv().QuantumXLoaded then
    print("[Quantum X] Już załadowany – wychodzę")
    return
end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local hubUrl = "https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua"

print("[Quantum X] Próbuję pobrać: " .. hubUrl)

local success, result = pcall(function()
    return game:HttpGet(hubUrl, true)
end)

if success then
    if result and #result > 100 then
        print("[Quantum X] Hub pobrany (" .. #result .. " znaków) – wykonuję...")
        loadstring(result)()
    else
        warn("[Quantum X] Pobrano pusty/za krótki kod – HttpGet zwróciło: " .. tostring(result))
    end
else
    warn("[Quantum X] HttpGet całkowicie padł: " .. tostring(result))
end
