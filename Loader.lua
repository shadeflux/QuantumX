-- Quantum X Loader
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua", true))()
