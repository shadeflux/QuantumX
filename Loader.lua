-- Loader z mirrorami dla Quantum X
local urls = {
    "https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua",
    "https://ghproxy.net/https://raw.githubusercontent.com/shadeflux/QuantumX/refs/heads/main/Hub.lua",
    "https://cdn.jsdelivr.net/gh/shadeflux/QuantumX@main/Hub.lua"
}

local loaded = false
for i, url in ipairs(urls) do
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success and result and #result > 100 then
        loadstring(result)()
        loaded = true
        break
    end
    task.wait(0.5)
end

if not loaded then
    warn("❌ Quantum X: nie można załadować z żadnego źródła.")
end
