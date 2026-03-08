-- Quantum X Loader – FLUENT UI (z proxy + fallback)

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = nil

-- Próba 1: normalny GitHub raw
pcall(function()
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()
end)

-- Próba 2: ghproxy
if not Fluent then
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://ghproxy.com/https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()
    end)
end

-- Próba 3: gitmirror (ostatnia deska ratunku)
if not Fluent then
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://raw.gitmirror.com/dawid-scripts/Fluent/master/src/main.lua"))()
    end)
end

if not Fluent then
    print("Fluent NIE załadował się nawet przez proxy – Delta blokuje")
    print("Zmień executora na Solara/Wave lub zostań przy natywnym UI")
    return
end

print("Fluent załadowany – ładuję pełny hub")

-- Pełny kod huba poniżej (wklej cały jako Hub.lua)
loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/main/HubFluent.lua"))()
