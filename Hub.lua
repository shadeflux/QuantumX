local Kavo = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

local Window = Kavo:CreateLib("Quantum X", "DarkTheme")  -- czarny styl

-- Tab główny – Player Mods
local Tab = Window:NewTab("Player Mods")

-- Zmienne
local speedEnabled = false
local customSpeed = 32
local infiniteJumpEnabled = false
local noclipEnabled = false

Tab:NewSlider("Walk Speed", "Ustaw prędkość chodzenia", 200, 16, function(value)
    customSpeed = value
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
end)

Tab:NewToggle("Speed Hack", "Włącz / Wyłącz", function(state)
    speedEnabled = state
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = state and customSpeed or 16
    end
end)

Tab:NewToggle("Infinite Jump", "Włącz / Wyłącz", function(state)
    infiniteJumpEnabled = state
end)

Tab:NewToggle("NoClip", "Włącz / Wyłącz", function(state)
    noclipEnabled = state
end)

-- Infinite Jump listener
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- NoClip loop
spawn(function()
    while true do
        if noclipEnabled and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        wait(0.1)
    end
end)

-- Dodatkowe tab'y (dodaj tu fling, anti-fling, tp itd. w ten sam sposób)

print("Quantum X – Kavo UI załadowane")
