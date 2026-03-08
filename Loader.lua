-- Quantum X Loader – FLUENT UI (test)

if getgenv().QuantumXLoaded then return end
getgenv().QuantumXLoaded = true

if not game:IsLoaded() then game.Loaded:Wait() end

local Fluent = nil

-- Próba 1: normalny loadstring
pcall(function()
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()
end)

-- Próba 2: jeśli nie – przez proxy
if not Fluent then
    print("Normalny Fluent nie przeszedł – próbuję proxy")
    pcall(function()
        Fluent = loadstring(game:HttpGet("https://ghproxy.com/https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/main.lua"))()
    end)
end

if not Fluent then
    print("Fluent NIE załadował się nawet przez proxy")
    print("Delta blokuje – zostaje natywne UI albo zmiana executora")
    return
end

print("Fluent załadowany – tworzę testowe UI")

-- Testowe okno Fluent (bez key systemu, bez funkcji – czysto test)
local Window = Fluent:CreateWindow({
    Title = "Quantum X TEST",
    SubTitle = "Test Fluent UI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Theme = "Dark",  -- czarny styl
    Acrylic = true,  -- blur background
    MinimizeKeybind = Enum.KeyCode.LeftControl
})

local Tab = Window:AddTab({ Title = "Test" })

Tab:AddParagraph({
    Title = "Status",
    Content = "Jeśli widzisz to okno – Fluent działa! Możemy dodać key i funkcje."
})

Fluent:Notify({
    Title = "Test udany",
    Content = "Fluent UI załadowane bez key systemu",
    Duration = 8
})

print("Testowe UI Fluent powinno być widoczne")
