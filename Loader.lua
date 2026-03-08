-- Quantum X Loader – najprostszy możliwy

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

-- Dodajemy random parametr, żeby Delta nie brała starego cache'u
loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua?v=" .. math.random(100000,999999)))()
