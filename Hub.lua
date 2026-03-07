-- Quantum X – custom UI bez zewnętrznych lib (Rayfield/sirius etc.)

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera

local toggles = {Speed=false, Jump=false, Fly=false, Noclip=false, God=false, ESP=false, InfJump=false}
local conns, esps, flybg, flybv = {}, {}, nil, nil
local flySpeed = 50

local sg = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
sg.Name = "QXHub"
sg.ResetOnSpawn = false

local mf = Instance.new("Frame", sg)
mf.AnchorPoint = Vector2.new(0.5,0.5)
mf.Position = UDim2.new(0.5,0,0.5,0)
mf.BackgroundColor3 = Color3.fromRGB(12,12,18)
mf.BackgroundTransparency = 0.2
mf.Active = true
mf.Draggable = true

local uic = Instance.new("UICorner", mf) uic.CornerRadius = UDim.new(0,14)

local function resize()
    local vs = cam.ViewportSize
    mf.Size = UDim2.new(0, math.clamp(vs.X*0.42, 400, 680), 0, math.clamp(vs.Y*0.78, 500, 820))
end
resize() cam:GetPropertyChangedSignal("ViewportSize"):Connect(resize)

local grad = Instance.new("UIGradient", mf)
grad.Color = ColorSequence.new(Color3.fromRGB(0,0,0), Color3.fromRGB(40,0,70))
grad.Rotation = 120

-- Top bar, toggles itd. – reszta jak w poprzedniej wersji (CreateToggle, EnforceProps itd.)
-- Wklej CAŁĄ resztę z mojej poprzedniej wiadomości (od local function GetChar() aż do końca print("Quantum X loaded"))

-- Na samym końcu dodaj to, jeśli chcesz minimize icon po schowaniu:
local minIcon
mf.Visible = true  -- start visible
