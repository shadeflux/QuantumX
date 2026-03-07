-- ================================================
-- Quantum X Loader v2.0 – FULL HEARTBEAT BYPASS + LOGI
-- ================================================

print("[Quantum X] Loader v2.0 start...")

if getgenv().QuantumXLoaded then
    print("[Quantum X] Już załadowany – wychodzę")
    return
end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then
    print("[Quantum X] Czekam na załadowanie gry...")
    game.Loaded:Wait()
end

print("[Quantum X] Gra załadowana – instaluję bypass heartbeat...")

-- === PEŁNY BYPASS HEARTBEAT (blokuje wszystkie requesty do /pulse) ===
local HttpService = game:GetService("HttpService")
local oldRequestAsync = HttpService.RequestAsync

HttpService.RequestAsync = function(self, request)
    if request.Url and (request.Url:find("user-heartbeats-api") or request.Url:find("pulse") or request.Url:find("heartbeat")) then
        print("[Quantum X] [BYPASS] Zablokowano heartbeat → " .. request.Url)
        return {
            Success = true,
            StatusCode = 200,
            Body = "{}",
            Headers = {}
        }
    end
    return oldRequestAsync(self, request)
end

print("[Quantum X] Bypass heartbeat zainstalowany pomyślnie")

-- === PEŁNE LOGI + pobieranie Hub.lua ===
local hubUrl = "https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua"

print("[Quantum X] Próba pobrania huba z: " .. hubUrl)

local success, result = pcall(function()
    return game:HttpGet(hubUrl, true)
end)

if success then
    if result and #result > 500 then
        print("[Quantum X] Hub pobrany pomyślnie (" .. #result .. " znaków) – wykonuję...")
        local loadSuccess, loadError = pcall(loadstring(result))
        if loadSuccess then
            print("[Quantum X] Hub załadowany pomyślnie!")
        else
            warn("[Quantum X] BŁĄD podczas wykonywania huba: " .. tostring(loadError))
        end
    else
        warn("[Quantum X] Pobrano pusty lub uszkodzony kod (" .. tostring(#result or 0) .. " znaków)")
    end
else
    warn("[Quantum X] HttpGet całkowicie niepowodzenie: " .. tostring(result))
end

print("[Quantum X] Loader zakończył działanie")
