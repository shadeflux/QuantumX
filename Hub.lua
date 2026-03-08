-- Quantum X Loader – TEST RAYFIELD (bez key, bez funkcji)

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

-- Proxy 1 (ghproxy)
local Rayfield = nil
local success = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://ghproxy.com/https://sirius.menu/rayfield"))()
end)

if not success or not Rayfield then
    print("Proxy ghproxy nie zadziałało – próbuję drugie")
    -- Proxy 2 (gitmirror)
    pcall(function()
        Rayfield = loadstring(game:HttpGet("https://raw.gitmirror.com/sirius.menu/rayfield/main/rayfield.lua"))()
    end)
end

if not Rayfield then
    print("Rayfield NIE załadował się nawet przez proxy")
    print("Delta blokuje sirius.menu – trzeba zmienić executora na Solara/Wave")
    return
end

print("Rayfield załadowany! Tworzę testowe UI")

-- Testowe okno – tylko Rayfield, bez key i funkcji
local Window = Rayfield:CreateWindow({
    Name = "Quantum X TEST",
    LoadingTitle = "Quantum X",
    LoadingSubtitle = "Test bez key systemu",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Test Tab")

Tab:CreateLabel("Jeśli widzisz to okno – Rayfield działa!")
Tab:CreateParagraph({Title = "Status", Content = "Delta wpuściła Rayfield przez proxy – sukces!"})

Rayfield:Notify({
    Title = "Test udany",
    Content = "Rayfield załadowany bez key systemu",
    Duration = 10,
    Image = 4483362458
})

print("Testowe UI Rayfield powinno być widoczne")
