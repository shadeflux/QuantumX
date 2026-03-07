-- Quantum X Loader – wersja bez błędów nil
print("Quantum X Loader start...")

if getgenv().QuantumXLoaded then 
    print("Już załadowany – wychodzę")
    return 
end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local url = "https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua"  -- ZMIEŃ NA SWÓJ

local success, code = pcall(function()
    return game:HttpGet(url, true)
end)

if success and code and code \~= "" then
    print("Pobrano Hub.lua – ładuję...")
    loadstring(code)()
else
    warn("Błąd pobierania Hub.lua!")
    warn("URL: " .. url)
    if not success then
        warn("HttpGet failed: " .. tostring(code))  -- tu będzie dokładny błąd
    else
        warn("Kod pusty lub nil")
    end
end
