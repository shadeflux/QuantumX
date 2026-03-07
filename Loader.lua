-- Quantum X Loader | Unseen. Unpatched. Unstoppable.
print("Quantum X Loader v1.0 - initializing...")

if not game:IsLoaded() then game.Loaded:Wait() end

-- Anti-crash + podstawowe zabezpieczenie
if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

-- Ładujemy właściwy hub
loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua"))()
