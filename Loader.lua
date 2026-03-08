-- Quantum X Loader – Rayfield przez proxy (ostatnia próba)

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

-- Proxy które czasem omijają blokadę Delty
local url = "https://ghproxy.com/https://sirius.menu/rayfield"

local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet(url))()
end)

if not success or not Rayfield then
    warn("Rayfield nie załadował się nawet przez proxy")
    warn("Delta blokuje wszystko zewnętrzne – trzeba zmienić executora")
    return
end

-- Jeśli dojdzie tutaj = Rayfield się załadował
print("Rayfield załadowany pomyślnie – ładuję hub")
loadstring(game:HttpGet("https://raw.githubusercontent.com/shadeflux/QuantumX/main/Hub.lua"))()
