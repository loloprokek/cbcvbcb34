-- [НАЧАЛО] Quark Beta: Unified Farm (Story + Lucky + Modes)
-- Объединенный и доработанный скрипт по запросу пользователя.
-- FIX V3: Полная замена хуков и физики на версию из 'Lucky Farm'.

-- [[ ГЛОБАЛЬНЫЕ НАСТРОЙКИ ПО УМОЛЧАНИЮ ]] 
getgenv().TelegramBotToken = "" 
getgenv().TelegramChatID = ""

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- [[ СИСТЕМА СОХРАНЕНИЯ КОНФИГА ]]
local ConfigFileName = "QuarkBeta_Unified_Settings.json"

-- Режимы фарма
local FarmModes = {
    "Standard (Money & Stop)", -- 1: Обычный: Сюжет -> Деньги -> Стоп
    "Money -> Lucky Farm",     -- 2: Сюжет -> Деньги -> Покупка/Фарм Лаки
    "P3/Lvl50 -> Lucky Farm",  -- 3: Сюжет (до упора) -> Покупка/Фарм Лаки (игнор денег)
    "Just Prestige/Level"      -- 4: Только кач, без фарма денег и лаки
}

local function SaveConfig()
    local data = {
        TelegramEnabled = getgenv().QuarkSettings.TelegramEnabled,
        TelegramBotToken = getgenv().TelegramBotToken,
        TelegramChatID = getgenv().TelegramChatID,
        UILogging = getgenv().QuarkSettings.UILogging,
        NotifyInject = getgenv().QuarkSettings.NotifyInject,
        NotifyFinish = getgenv().QuarkSettings.NotifyFinish,
        Filters = getgenv().QuarkSettings.Filters,
        TGFilters = getgenv().QuarkSettings.TGFilters,
        Transparency = getgenv().QuarkSettings.Transparency,
        GlassEffect = getgenv().QuarkSettings.GlassEffect,
        TargetMoney = getgenv().QuarkSettings.TargetMoney,
        FarmModeIndex = getgenv().QuarkSettings.FarmModeIndex,
        AutoBuyLucky = getgenv().QuarkSettings.AutoBuyLucky,
        ThemeColor = {
            R = getgenv().QuarkSettings.ThemeColor.R,
            G = getgenv().QuarkSettings.ThemeColor.G,
            B = getgenv().QuarkSettings.ThemeColor.B
        }
    }
    
    if writefile then
        writefile(ConfigFileName, HttpService:JSONEncode(data))
    end
end

local function LoadConfig()
    local Defaults = {
        TelegramEnabled = true,     
        UILogging = true,           
        NotifyInject = true,    
        NotifyFinish = true,    
        Filters = { info = true, success = true, warn = true, error = true, action = true, tg = true },
        TGFilters = { info = false, success = false, warn = false, error = false, action = false },
        Transparency = 0.2,
        GlassEffect = false,
        TargetMoney = 300000, 
        FarmModeIndex = 1,
        AutoBuyLucky = true,
        ThemeColor = Color3.fromRGB(15, 15, 20) 
    }

    if isfile and isfile(ConfigFileName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        
        if success and result then
            Defaults.TelegramEnabled = result.TelegramEnabled
            if result.TelegramBotToken and result.TelegramBotToken ~= "" then
                getgenv().TelegramBotToken = result.TelegramBotToken
            end
            if result.TelegramChatID and result.TelegramChatID ~= "" then
                getgenv().TelegramChatID = result.TelegramChatID
            end
            
            Defaults.UILogging = result.UILogging
            Defaults.NotifyInject = result.NotifyInject
            Defaults.NotifyFinish = result.NotifyFinish
            Defaults.Filters = result.Filters or Defaults.Filters
            Defaults.TGFilters = result.TGFilters or Defaults.TGFilters
            Defaults.Transparency = result.Transparency or 0.2
            Defaults.GlassEffect = result.GlassEffect or false
            Defaults.TargetMoney = result.TargetMoney or 300000
            Defaults.FarmModeIndex = result.FarmModeIndex or 1
            Defaults.AutoBuyLucky = result.AutoBuyLucky ~= nil and result.AutoBuyLucky or true
            
            if result.ThemeColor then
                Defaults.ThemeColor = Color3.new(result.ThemeColor.R, result.ThemeColor.G, result.ThemeColor.B)
            end
        end
    end
    
    getgenv().QuarkSettings = Defaults
    getgenv().TargetMoney = getgenv().QuarkSettings.TargetMoney 
end

LoadConfig()

-- [[ SETUP UI: ПЕРВЫЙ ЗАПУСК ]]
if getgenv().TelegramBotToken == "" or string.find(getgenv().TelegramBotToken, "ВСТАВЬ") or getgenv().TelegramChatID == "" then
    local SetupScreen = Instance.new("ScreenGui")
    SetupScreen.Name = "QuarkSetup"
    SetupScreen.Parent = CoreGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 300)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -150)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.BorderSizePixel = 0
    Frame.Parent = SetupScreen
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 2
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Text = "Quark Unified Setup"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 24
    
    local function CreateInput(placeholder, pos)
        local Box = Instance.new("TextBox", Frame)
        Box.Size = UDim2.new(0.8, 0, 0, 40)
        Box.Position = UDim2.new(0.1, 0, 0, pos)
        Box.PlaceholderText = placeholder
        Box.Text = ""
        Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.Gotham
        Box.TextSize = 14
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)
        return Box
    end
    
    local TokenBox = CreateInput("Telegram Bot Token", 70)
    local ChatIDBox = CreateInput("Telegram Chat ID", 130)
    
    local SaveBtn = Instance.new("TextButton", Frame)
    SaveBtn.Size = UDim2.new(0.6, 0, 0, 45)
    SaveBtn.Position = UDim2.new(0.2, 0, 0, 220)
    SaveBtn.Text = "Save & Start"
    SaveBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.TextSize = 18
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 8)
    
    local waiting = true
    
    SaveBtn.MouseButton1Click:Connect(function()
        if TokenBox.Text ~= "" and ChatIDBox.Text ~= "" then
            getgenv().TelegramBotToken = TokenBox.Text
            getgenv().TelegramChatID = ChatIDBox.Text
            SaveConfig()
            SetupScreen:Destroy()
            waiting = false
        else
            SaveBtn.Text = "Fill all fields!"
            task.wait(1)
            SaveBtn.Text = "Save & Start"
        end
    end)
    
    repeat task.wait() until not waiting
end

getgenv().QuarkLastUpdateId = getgenv().QuarkLastUpdateId or 0
local lastUpdateId = getgenv().QuarkLastUpdateId 

-- [[ ТЕЛЕГРАМ СИСТЕМА ]]
local function SendTelegramMessage(text, msgType, replyMarkup)
    local typeKey = msgType or "info"

    if not getgenv().QuarkSettings.TelegramEnabled then return end
    
    local allowSend = false
    
    if typeKey == "finish" and getgenv().QuarkSettings.NotifyFinish then
        allowSend = true
    elseif typeKey == "inject" and getgenv().QuarkSettings.NotifyInject then
        allowSend = true
    elseif getgenv().QuarkSettings.TGFilters[typeKey] == true then
        allowSend = true
    elseif typeKey == "manual_response" then 
        allowSend = true
    end

    if not allowSend then return end
    if getgenv().TelegramBotToken == "" then return end
    
    local url = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/sendMessage"
    local headers = {["Content-Type"] = "application/json"}
    
    local titleType = typeKey:upper()
    if typeKey == "finish" then titleType = "🏆 FINISH" end
    if typeKey == "inject" then titleType = "💉 INJECT" end
    
    local payload = {
        chat_id = getgenv().TelegramChatID,
        text = "⚛️ Quark Unified [" .. titleType .. "]:\n" .. text,
        parse_mode = "HTML"
    }
    
    if replyMarkup then
        payload.reply_markup = replyMarkup
    end

    local body = HttpService:JSONEncode(payload)

    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if requestFunc then
        task.spawn(function() 
            requestFunc({Url = url, Method = "POST", Headers = headers, Body = body})
        end)
    end
end

-- [[ ЛОГГЕР ]]
local Log 
local LogContainer = nil

-- [[ КОМАНДЫ ТЕЛЕГРАМ ]]
local isListening = false

local function ClearWebhook()
    if getgenv().TelegramBotToken == "" then return end
    local url = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/deleteWebhook"
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if requestFunc then
        pcall(function() requestFunc({Url = url, Method = "GET"}) end)
    end
end

local function SendControlPanel()
    local keyboard = {
        inline_keyboard = {
            {
                {text = "📊 Статистика", callback_data = "/stats"},
                {text = "🔄 Rejoin", callback_data = "/rejoin"}
            },
            {
                {text = "🏓 Ping", callback_data = "/ping"},
                {text = "🛑 STOP", callback_data = "/stop"}
            },
             {
                {text = "❓ Help", callback_data = "/help"}
            }
        }
    }
    SendTelegramMessage("🎛 <b>Панель управления Quark:</b>\nВыберите действие:", "manual_response", keyboard)
end

local function HandleCommands()
    if isListening then return end
    isListening = true
    ClearWebhook()
    
    task.spawn(function()
        while true do
            task.wait(2) 
            
            if getgenv().QuarkSettings.TelegramEnabled and getgenv().TelegramBotToken ~= "" then
                local url = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/getUpdates?offset=" .. (lastUpdateId + 1) .. "&timeout=5"
                local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
                
                if requestFunc then
                    local success, response = pcall(function()
                        return requestFunc({Url = url, Method = "GET"})
                    end)

                    if success and response and response.StatusCode == 200 then
                        local data = HttpService:JSONDecode(response.Body)
                        if data.ok and data.result then
                            for _, update in ipairs(data.result) do
                                lastUpdateId = update.update_id
                                getgenv().QuarkLastUpdateId = lastUpdateId
                                
                                local text = ""
                                local isCallback = false
                                local callbackId = nil
                                
                                if update.message and tostring(update.message.chat.id) == tostring(getgenv().TelegramChatID) then
                                    text = update.message.text
                                elseif update.callback_query and tostring(update.callback_query.message.chat.id) == tostring(getgenv().TelegramChatID) then
                                    text = update.callback_query.data
                                    isCallback = true
                                    callbackId = update.callback_query.id
                                end
                                
                                if text ~= "" then
                                    print("Quark: Команда: " .. text)
                                    
                                    if isCallback then
                                        local ansUrl = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/answerCallbackQuery"
                                        requestFunc({Url = ansUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({callback_query_id = callbackId})})
                                    end

                                    if text == "/ping" then
                                        SendTelegramMessage("🏓 Pong! Связь стабильна.\nСервер: " .. game.PlaceId, "manual_response")
                                    
                                    elseif text == "/help" or text == "/start" then
                                        SendControlPanel()
                                        
                                    elseif text == "/stats" then
                                        local stats = Players.LocalPlayer.PlayerStats
                                        local msg = "📊 <b>Статистика Quark:</b>\n" ..
                                                    "👤 <b>Ник:</b> " .. Players.LocalPlayer.Name .. "\n" ..
                                                    "💰 <b>Деньги:</b> " .. stats.Money.Value .. " / " .. getgenv().TargetMoney .. "\n" ..
                                                    "⭐ <b>Уровень:</b> " .. stats.Level.Value .. "\n" ..
                                                    "🏆 <b>Престиж:</b> " .. stats.Prestige.Value .. "\n" ..
                                                    "🕹️ <b>Режим:</b> " .. FarmModes[getgenv().QuarkSettings.FarmModeIndex]
                                        SendTelegramMessage(msg, "manual_response")
                                        
                                    elseif text == "/rejoin" then
                                        SendTelegramMessage("🔄 Команда Rejoin получена. Перезапуск...", "action")
                                        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                                        return 
                                        
                                    elseif text == "/stop" then
                                        SendTelegramMessage("🛑 Команда Stop получена. Кик...", "error")
                                        Players.LocalPlayer:Kick("Stopped via Telegram (/stop)")
                                        return 
                                    end
                                end
                            end
                        end
                    elseif response and response.StatusCode ~= 200 then
                        warn("Quark TG Error: " .. tostring(response.StatusCode))
                    end
                end
            end
        end
    end)
end

-- [[ UI СИСТЕМА (НОВАЯ: КАТЕГОРИИ И РАСКРЫВАЮЩИЕСЯ СПИСКИ) ]]
local DebugUI = {}
local MainFrame = nil
local BlurEffect = nil

local function UpdateGlassEffect()
    if not MainFrame then return end
    
    if not BlurEffect then
        BlurEffect = Instance.new("BlurEffect")
        BlurEffect.Name = "QuarkBlur"
        BlurEffect.Size = 0
        BlurEffect.Parent = Lighting
    end
    
    if getgenv().QuarkSettings.GlassEffect then
        TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 20}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.3}):Play()
        MainFrame.UIStroke.Transparency = 0.5 
    else
        TweenService:Create(BlurEffect, TweenInfo.new(0.5), {Size = 0}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = getgenv().QuarkSettings.Transparency}):Play()
        MainFrame.UIStroke.Transparency = 0.85
    end
end

function DebugUI:Create()
    if CoreGui:FindFirstChild("QuarkDebugUI") then
        CoreGui:FindFirstChild("QuarkDebugUI"):Destroy()
    end
    if Lighting:FindFirstChild("QuarkBlur") then Lighting:FindFirstChild("QuarkBlur"):Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "QuarkDebugUI"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = getgenv().QuarkSettings.ThemeColor
    MainFrame.BackgroundTransparency = getgenv().QuarkSettings.Transparency
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 500) -- Увеличил высоту
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = MainFrame
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Transparency = 0.85
    Stroke.Thickness = 1.5 

    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundTransparency = 0.95
    TitleBar.Size = UDim2.new(1, 0, 0, 40)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TitleBar
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = "⚛️ Quark Unified"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = TitleBar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Size = UDim2.new(0.4, 0, 1, 0)
    TabContainer.Position = UDim2.new(0.55, 0, 0, 0)

    local LayoutTabs = Instance.new("UIListLayout")
    LayoutTabs.Parent = TabContainer
    LayoutTabs.FillDirection = Enum.FillDirection.Horizontal
    LayoutTabs.HorizontalAlignment = Enum.HorizontalAlignment.Right
    LayoutTabs.VerticalAlignment = Enum.VerticalAlignment.Center
    LayoutTabs.Padding = UDim.new(0, 5)

    local Pages = Instance.new("Frame")
    Pages.Parent = MainFrame
    Pages.BackgroundTransparency = 1
    Pages.Position = UDim2.new(0, 0, 0, 40)
    Pages.Size = UDim2.new(1, 0, 1, -40)

    local LogsPage = Instance.new("ScrollingFrame")
    LogsPage.Name = "LogsPage"
    LogsPage.Parent = Pages
    LogsPage.Active = true
    LogsPage.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LogsPage.BackgroundTransparency = 1
    LogsPage.BorderSizePixel = 0
    LogsPage.Position = UDim2.new(0, 10, 0, 10)
    LogsPage.Size = UDim2.new(1, -20, 1, -20)
    LogsPage.ScrollBarThickness = 3
    LogsPage.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 255)
    LogsPage.Visible = true
    LogsPage.CanvasSize = UDim2.new(0, 0, 0, 0)

    local UIListLayout_Logs = Instance.new("UIListLayout")
    UIListLayout_Logs.Parent = LogsPage
    UIListLayout_Logs.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Logs.Padding = UDim.new(0, 4)

    UIListLayout_Logs:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        LogsPage.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_Logs.AbsoluteContentSize.Y + 20)
    end)

    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = "SettingsPage"
    SettingsPage.Parent = Pages
    SettingsPage.Active = true
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.BorderSizePixel = 0
    SettingsPage.Position = UDim2.new(0, 10, 0, 10)
    SettingsPage.Size = UDim2.new(1, -20, 1, -20)
    SettingsPage.ScrollBarThickness = 3
    SettingsPage.Visible = false
    SettingsPage.CanvasSize = UDim2.new(0, 0, 0, 800)

    local UIListLayout_Set = Instance.new("UIListLayout")
    UIListLayout_Set.Parent = SettingsPage
    UIListLayout_Set.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Set.Padding = UDim.new(0, 8)

    -- [[ UI COMPONENTS HELPERS ]]
    local function CreateTabButton(text, active)
        local Btn = Instance.new("TextButton")
        Btn.Parent = TabContainer
        Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Btn.BackgroundTransparency = active and 0.85 or 1
        Btn.Size = UDim2.new(0, 70, 0, 26)
        Btn.Font = Enum.Font.GothamMedium
        Btn.Text = text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.TextSize = 12
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 6)
        Corner.Parent = Btn
        return Btn
    end

    local LogTabBtn = CreateTabButton("Логи", true)
    local SetTabBtn = CreateTabButton("Настройки", false)

    LogTabBtn.MouseButton1Click:Connect(function()
        LogsPage.Visible = true
        SettingsPage.Visible = false
        TweenService:Create(LogTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
        TweenService:Create(SetTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
    end)

    SetTabBtn.MouseButton1Click:Connect(function()
        LogsPage.Visible = false
        SettingsPage.Visible = true
        TweenService:Create(LogTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        TweenService:Create(SetTabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.85}):Play()
    end)

    -- НОВАЯ ФУНКЦИЯ: Раскрывающаяся категория
    local function CreateCategory(name)
        local CategoryFrame = Instance.new("Frame")
        CategoryFrame.Parent = SettingsPage
        CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        CategoryFrame.Size = UDim2.new(1, -10, 0, 35) -- Начальная высота (закрыто)
        CategoryFrame.ClipsDescendants = true
        Instance.new("UICorner", CategoryFrame).CornerRadius = UDim.new(0, 6)

        local HeaderBtn = Instance.new("TextButton")
        HeaderBtn.Parent = CategoryFrame
        HeaderBtn.Size = UDim2.new(1, 0, 0, 35)
        HeaderBtn.BackgroundTransparency = 1
        HeaderBtn.Text = "  " .. name
        HeaderBtn.Font = Enum.Font.GothamBold
        HeaderBtn.TextColor3 = Color3.fromRGB(200, 200, 255)
        HeaderBtn.TextSize = 14
        HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

        local Icon = Instance.new("TextLabel")
        Icon.Parent = HeaderBtn
        Icon.BackgroundTransparency = 1
        Icon.Size = UDim2.new(0, 30, 1, 0)
        Icon.Position = UDim2.new(1, -30, 0, 0)
        Icon.Text = "▼"
        Icon.TextColor3 = Color3.fromRGB(150, 150, 150)
        Icon.Font = Enum.Font.Gotham
        Icon.TextSize = 12

        local ContentFrame = Instance.new("Frame")
        ContentFrame.Parent = CategoryFrame
        ContentFrame.BackgroundTransparency = 1
        ContentFrame.Position = UDim2.new(0, 0, 0, 35)
        ContentFrame.Size = UDim2.new(1, 0, 0, 0) -- Высота автоматом
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Parent = ContentFrame
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local expanded = false
        HeaderBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            Icon.Text = expanded and "▲" or "▼"
            Icon.TextColor3 = expanded and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
            
            local contentHeight = ContentLayout.AbsoluteContentSize.Y + 10
            local targetHeight = expanded and (35 + contentHeight) or 35
            
            TweenService:Create(CategoryFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -10, 0, targetHeight)}):Play()
            task.delay(0.3, function()
                SettingsPage.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_Set.AbsoluteContentSize.Y + 50)
            end)
        end)
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if expanded then
                local contentHeight = ContentLayout.AbsoluteContentSize.Y + 10
                CategoryFrame.Size = UDim2.new(1, -10, 0, 35 + contentHeight)
                SettingsPage.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_Set.AbsoluteContentSize.Y + 50)
            end
        end)

        return ContentFrame
    end

    -- Хелпер для элементов внутри категории
    local function CreateToggleIn(parent, text, defaultState, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = parent
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, -10, 0, 30)
        Frame.Position = UDim2.new(0, 5, 0, 0)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(0.7, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.Font = Enum.Font.Gotham
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton")
        Btn.Parent = Frame
        Btn.BackgroundColor3 = defaultState and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(60, 60, 60)
        Btn.Position = UDim2.new(1, -45, 0.5, -10)
        Btn.Size = UDim2.new(0, 36, 0, 18)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame")
        Circle.Parent = Btn
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        Circle.Size = UDim2.new(0, 14, 0, 14)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local toggled = defaultState
        Btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            callback(toggled)
            SaveConfig()
            local targetColor = toggled and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(60, 60, 60)
            local targetPos = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        end)
    end

    local function CreateInputIn(parent, text, defaultVal, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = parent
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, -10, 0, 35)
        Frame.Position = UDim2.new(0, 5, 0, 0)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(0.6, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.Font = Enum.Font.Gotham
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        
        local Box = Instance.new("TextBox")
        Box.Parent = Frame
        Box.Size = UDim2.new(0, 90, 0, 24)
        Box.Position = UDim2.new(1, -100, 0.5, -12)
        Box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.Code
        Box.TextSize = 12
        Box.Text = tostring(defaultVal)
        Box.PlaceholderText = "..."
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
        
        Box.FocusLost:Connect(function()
            local num = tonumber(Box.Text)
            if num then
                callback(num)
                Box.TextColor3 = Color3.fromRGB(100, 255, 100)
                SaveConfig()
                task.wait(0.5)
                Box.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Box.Text = tostring(defaultVal)
            end
        end)
    end

    -- НОВАЯ ФУНКЦИЯ: Dropdown/Cycler для режима
    local function CreateModeSelector(parent, text, modes, currentIdx, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = parent
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, -10, 0, 50)
        Frame.Position = UDim2.new(0, 5, 0, 0)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, 0, 0, 20)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton")
        Btn.Parent = Frame
        Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        Btn.Size = UDim2.new(0.9, 0, 0, 20)
        Btn.Position = UDim2.new(0.05, 0, 0, 25)
        Btn.Text = modes[currentIdx]
        Btn.TextColor3 = Color3.fromRGB(255, 220, 100)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        local idx = currentIdx
        Btn.MouseButton1Click:Connect(function()
            idx = idx + 1
            if idx > #modes then idx = 1 end
            Btn.Text = modes[idx]
            callback(idx)
            SaveConfig()
        end)
    end

    local function CreateSliderIn(parent, text, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = parent
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, -10, 0, 40)
        Frame.Position = UDim2.new(0, 5, 0, 0)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Position = UDim2.new(0, 10, 0, 2)
        Lbl.Size = UDim2.new(1, 0, 0, 15)
        Lbl.Font = Enum.Font.Gotham
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 12
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local SliderBg = Instance.new("Frame")
        SliderBg.Parent = Frame
        SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderBg.Position = UDim2.new(0, 10, 0, 25)
        SliderBg.Size = UDim2.new(1, -20, 0, 4)
        Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1,0)

        local Fill = Instance.new("Frame")
        Fill.Parent = SliderBg
        Fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        Fill.Size = UDim2.new(getgenv().QuarkSettings.Transparency, 0, 1, 0)
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

        local Trigger = Instance.new("TextButton")
        Trigger.Parent = SliderBg
        Trigger.BackgroundTransparency = 1
        Trigger.Size = UDim2.new(1, 0, 1, 0)
        Trigger.Text = ""

        local dragging = false
        Trigger.MouseButton1Down:Connect(function() dragging = true end)
        game:GetService("UserInputService").InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then 
                dragging = false 
                SaveConfig() 
            end
        end)

        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation().X
                local relPos = mousePos - SliderBg.AbsolutePosition.X
                local percent = math.clamp(relPos / SliderBg.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(percent, 0, 1, 0)
                callback(percent)
            end
        end)
    end
    
    -- [[ СБОРКА ИНТЕРФЕЙСА ПО КАТЕГОРИЯМ ]]

    local MainCat = CreateCategory("Основные Настройки")
    CreateToggleIn(MainCat, "Telegram Master Switch", getgenv().QuarkSettings.TelegramEnabled, function(v) getgenv().QuarkSettings.TelegramEnabled = v end)
    CreateToggleIn(MainCat, "Логи в Меню (UI)", getgenv().QuarkSettings.UILogging, function(v) getgenv().QuarkSettings.UILogging = v end)

    local FarmCat = CreateCategory("Настройки Фарма")
    -- Выбор режима
    CreateModeSelector(FarmCat, "Режим Фарма", FarmModes, getgenv().QuarkSettings.FarmModeIndex, function(idx)
        getgenv().QuarkSettings.FarmModeIndex = idx
    end)
    CreateInputIn(FarmCat, "Цель Денег (Lvl 50)", getgenv().QuarkSettings.TargetMoney, function(val)
        getgenv().QuarkSettings.TargetMoney = val
        getgenv().TargetMoney = val
    end)
    
    local LuckyCat = CreateCategory("Lucky Farm Опции")
    CreateToggleIn(LuckyCat, "Авто-Покупка Стрел", getgenv().QuarkSettings.AutoBuyLucky, function(v) getgenv().QuarkSettings.AutoBuyLucky = v end)
    
    local VisualCat = CreateCategory("Внешний вид (UI)")
    CreateToggleIn(VisualCat, "Эффект Liquid Glass", getgenv().QuarkSettings.GlassEffect, function(v) 
        getgenv().QuarkSettings.GlassEffect = v 
        UpdateGlassEffect()
    end)
    CreateSliderIn(VisualCat, "Прозрачность", function(val)
        getgenv().QuarkSettings.Transparency = val
        if not getgenv().QuarkSettings.GlassEffect then
            MainFrame.BackgroundTransparency = val
        end
    end)
    
    local FiltersCat = CreateCategory("Фильтры Логов")
    CreateToggleIn(FiltersCat, "UI: Успех", getgenv().QuarkSettings.Filters.success, function(v) getgenv().QuarkSettings.Filters.success = v end)
    CreateToggleIn(FiltersCat, "UI: Ошибки", getgenv().QuarkSettings.Filters.error, function(v) getgenv().QuarkSettings.Filters.error = v end)
    CreateToggleIn(FiltersCat, "TG: Успех (Квесты)", getgenv().QuarkSettings.TGFilters.success, function(v) getgenv().QuarkSettings.TGFilters.success = v end)
    CreateToggleIn(FiltersCat, "TG: Важное (Кик)", getgenv().QuarkSettings.TGFilters.error, function(v) getgenv().QuarkSettings.TGFilters.error = v end)

    local CreditLabel = Instance.new("TextLabel")
    CreditLabel.Parent = SettingsPage
    CreditLabel.BackgroundTransparency = 1
    CreditLabel.Size = UDim2.new(1, 0, 0, 30)
    CreditLabel.Font = Enum.Font.Code
    CreditLabel.Text = "Dev: ModWarmMangos | Unified V3"
    CreditLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    CreditLabel.TextSize = 11
    CreditLabel.TextTransparency = 0.5

    UpdateGlassEffect() 

    return LogsPage
end

LogContainer = DebugUI:Create()

-- [[ ЛОГИРОВАНИЕ (FIXED SCROLL) ]]
Log = function(text, msgType) 
    SendTelegramMessage(text, msgType)

    if not getgenv().QuarkSettings.UILogging then return end
    if not getgenv().QuarkSettings.Filters[msgType or "info"] then return end

    local timestamp = os.date("%H:%M:%S")
    local formattedMsg = string.format("[%s] %s", timestamp, text)
    
    local textColor = Color3.fromRGB(200, 200, 200)
    local prefix = "•"
    
    if msgType == "success" then textColor = Color3.fromRGB(100, 255, 120); prefix = "✅"
    elseif msgType == "warn" then textColor = Color3.fromRGB(255, 200, 80); prefix = "⚠️"
    elseif msgType == "error" then textColor = Color3.fromRGB(255, 80, 80); prefix = "⛔"
    elseif msgType == "tg" then textColor = Color3.fromRGB(80, 160, 255); prefix = "✈️"
    elseif msgType == "action" then textColor = Color3.fromRGB(180, 180, 255); prefix = "⚡"
    elseif msgType == "finish" then textColor = Color3.fromRGB(255, 215, 0); prefix = "🏆" 
    elseif msgType == "inject" then textColor = Color3.fromRGB(255, 105, 180); prefix = "💉"
    elseif msgType == "lucky" then textColor = Color3.fromRGB(255, 0, 255); prefix = "🏹"
    end

    print("Quark: " .. text)

    task.spawn(function()
        if LogContainer and LogContainer.Parent then
            local scroller = LogContainer
            local isAtBottom = false
            
            if scroller.CanvasPosition.Y >= (scroller.CanvasSize.Y.Offset - scroller.AbsoluteWindowSize.Y - 50) then
                isAtBottom = true
            end

            local Label = Instance.new("TextLabel")
            Label.Parent = LogContainer
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, 0, 0, 0)
            Label.Font = Enum.Font.GothamMedium
            Label.Text = prefix .. " " .. formattedMsg
            Label.TextColor3 = textColor
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextWrapped = true
            Label.AutomaticSize = Enum.AutomaticSize.Y
            Label.TextTransparency = 1
            
            TweenService:Create(Label, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
            task.wait() 
            
            if isAtBottom then
                scroller.CanvasPosition = Vector2.new(0, scroller.CanvasSize.Y.Offset)
            end
            
            if #LogContainer:GetChildren() > 300 then
                local firstChild = LogContainer:GetChildren()[2] 
                if firstChild then firstChild:Destroy() end
            end
        end
    end)
end

-- [[ НАСТРОЙКИ ФАРМА ]]
getgenv().TargetMoney = getgenv().QuarkSettings.TargetMoney 
getgenv().ItemCollectionDelay = 3 
getgenv().ServerFarmTime = 180 

Log("Инициализация Quark Unified...", "action")

local LocalPlayer
local Character
local RemoteEvent
local RemoteFunction
local LocalStartTime = tick() 

while true do
    LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer then
        Character = LocalPlayer.Character
        if Character then
            local foundRE = Character:WaitForChild("RemoteEvent", 5)
            local foundRF = Character:WaitForChild("RemoteFunction", 5)
             
            if foundRE and foundRF then
                RemoteEvent = foundRE
                RemoteFunction = foundRF
                Log("Персонаж и Remotes найдены.", "success")
                
                if getgenv().QuarkSettings.NotifyInject then
                    local userFileName = "QuarkBeta_"..LocalPlayer.Name..".txt"
                    if not isfile(userFileName) then
                        SendTelegramMessage("🆕 Новый аккаунт инициализирован: " .. LocalPlayer.Name, "inject")
                        SendControlPanel()
                    else
                        Log("Inject выполнен (Релог). Аккаунт: " .. LocalPlayer.Name, "info")
                    end
                end
                
                HandleCommands() 
                break 
            else
                print("Quark: Ждем RemoteEvent/RemoteFunction...")
            end
        else
            print("Quark: Ждем Character...")
        end
    else
        print("Quark: Ждем LocalPlayer...")
    end
    task.wait(1)
end

print("Quark: Обход экрана загрузки...")

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    print("Quark: Форсируем HUD...")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end

print("Quark: Ожидание 5 секунд перед сбросом...")
task.wait(5)

print("Quark: Сброс персонажа для синхронизации...")
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.Health = 0
else
    print("Quark: Не удалось найти Humanoid для сброса.")
end

print("Quark: Ожидание 10 секунд...")
task.wait(10) 

Log("Запуск основного скрипта...", "action")

-- [[ ФУНКЦИИ УТИЛИТ (СЕРВЕР ХОП и т.д.) ]]

getgenv().standList =  {
    ["The World"] = true,
    ["Star Platinum"] = true,
    ["Star Platinum: The World"] = true,
    ["Crazy Diamond"] = true,
    ["King Crimson"] = true,
    ["King Crimson Requiem"] = true
}

getgenv().waitUntilCollect = 0.2 
getgenv().sortOrder = "Asc" 
getgenv().NPCTimeOut = 15 
getgenv().HamonCharge = 90 
getgenv().autoRequiem = false

-- СИСТЕМА ФАЙЛОВ ПОЛЬЗОВАТЕЛЯ И ВРЕМЕНИ
local UserData = {}
local UserFile = "QuarkBeta_"..LocalPlayer.Name..".txt"
local FileLoaded = pcall(function()
    UserData = HttpService:JSONDecode(readfile(UserFile))
end)

if not FileLoaded then
    UserData = {
        ["Time"] = tick(), -- Сохраняем время первого запуска
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile(UserFile, HttpService:JSONEncode(UserData))
end

local function GetFarmDuration()
    local startTime = UserData["Time"] or tick()
    local totalSeconds = tick() - startTime
    
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = math.floor(totalSeconds % 60)
    
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

-- СИСТЕМА СЕРВЕР ХОПА
local PlaceID = game.PlaceId
local serverHopData = {}
local serverHopFile = pcall(function()
    serverHopData = HttpService:JSONDecode(readfile("QuarkBeta_ServerHop.txt"))
end)

if not serverHopFile or not serverHopData.timestamp or (tick() - serverHopData.timestamp) > 3600 then
    Log("Сброс Hop Data.", "info")
    serverHopData = { ["cursor"] = "", ["visited"] = {}, ["timestamp"] = tick() }
end

local function TPReturner()
    local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'
    if serverHopData.cursor and serverHopData.cursor ~= "" then
        url = url .. "&cursor=" .. serverHopData.cursor
    end

    local success, Site = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not success or not Site or not Site.data then
        Log("Ошибка Server List. Пробуем еще...", "warn") 
        serverHopData.cursor = "" 
        return
    end

    local nextPageCursor = Site.nextPageCursor
    
    for _,v in pairs(Site.data) do
       local ID = tostring(v.id)
       if tonumber(v.maxPlayers) > tonumber(v.playing) and not serverHopData.visited[ID] then
            serverHopData.visited[ID] = true 
            serverHopData.cursor = nextPageCursor 
            writefile("QuarkBeta_ServerHop.txt", HttpService:JSONEncode(serverHopData))
            
            Log("HOP: Новый сервер...", "action")
            TeleportService:TeleportToPlaceInstance(PlaceID, ID, LocalPlayer)
            return
       end
    end
    
    if nextPageCursor and nextPageCursor ~= "null" and nextPageCursor ~= nil then
        serverHopData.cursor = nextPageCursor
    else
        Log("Сервера закончились, сброс.", "info")
        serverHopData.cursor = ""
        serverHopData.visited = {}
    end
    writefile("QuarkBeta_ServerHop.txt", HttpService:JSONEncode(serverHopData))
end

local function Teleport()
    Log("Инициирую Server Hop...", "action")
    while task.wait(0.5) do 
        TPReturner()
    end
end

-- МГНОВЕННЫЙ REJOIN ПРИ КИКЕ
game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        if GrabError then
            task.delay(0.2, function()
                local Reason = GrabError.Text
                if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
                    local msg = "⚠️ KICK (Instant Rejoin): " .. LocalPlayer.Name .. "\nПричина: " .. Reason
                    Log(msg, "error") 
                    Teleport()
                end
            end)
        end
    end
end)

-- [[ NEW HOOK FROM LUCKY FARM (V3 FIX) ]]
if hookmetamethod and newcclosure then
    pcall(function()
        local oldNc
        oldNc = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local Method = getnamecallmethod()
            local Args = {...}
            if not checkcaller() and rawequal(self.Name, "Returner") and rawequal(Args[1], "idklolbrah2de") then
                return "  ___XP DE KEY"
            end
            return oldNc(self, ...)
        end))
    end)
end

-- =========================================================================================
-- [[ МОДУЛЬ: LUCKY FARM (ИНТЕГРИРОВАННЫЙ & ИСПРАВЛЕННЫЙ V3) ]]
-- =========================================================================================
local function StartLuckyFarmLoop()
    Log("🌟 АКТИВАЦИЯ РЕЖИМА LUCKY FARM (V3 FIX) 🌟", "lucky")
    
    -- Оптимизация графики (Safe Mode)
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("RunService"):Set3dRenderingEnabled(false)
        setfpscap(30)
    end)

    local SellItemsList = {
        ["Gold Coin"] = true, ["Rokakaka"] = true, ["Pure Rokakaka"] = true,
        ["Mysterious Arrow"] = true, ["Diamond"] = true, ["Ancient Scroll"] = true,
        ["Caesar's Headband"] = true, ["Stone Mask"] = true, ["Rib Cage of The Saint's Corpse"] = true,
        ["Quinton's Glove"] = true, ["Zeppeli's Hat"] = true, ["Lucky Arrow"] = false, 
        ["Clackers"] = true, ["Steel Ball"] = true, ["Dio's Diary"] = true
    }

    local function HasLuckyArrows()
        local Count = 0
        for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if Tool.Name == "Lucky Arrow" then Count += 1 end
        end
        return Count >= 10
    end

    local function TeleportTo(cf)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = cf
        end
    end

    local function ToggleNoclip(val)
        for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
            if child:IsA("BasePart") then child.CanCollide = not val end
        end
    end

    local ItemSpawnFolder = workspace:WaitForChild("Item_Spawns"):WaitForChild("Items")
    local SpawnedItems = {}

    local function UpdateItems()
        SpawnedItems = {}
        for _, model in pairs(ItemSpawnFolder:GetChildren()) do
            if model:IsA("Model") and model.PrimaryPart then
                for _, prompt in pairs(model:GetChildren()) do
                    if prompt:IsA("ProximityPrompt") and prompt.MaxActivationDistance == 8 then
                        table.insert(SpawnedItems, {
                            Name = prompt.ObjectText,
                            Prompt = prompt,
                            Pos = model.PrimaryPart.Position,
                            Obj = model
                        })
                    end
                end
            end
        end
    end
    
    local cycles = 0
    local maxCycles = 2 
    local TeleportDelay = 0.6 -- Safe Mode Delay + Buffer
    local ActionDelay = 0.5   -- Safe Mode Delay
    
    while true do
        UpdateItems()
        Log("Lucky Farm: Найдено предметов: " .. #SpawnedItems, "lucky")
        
        -- 1. Сбор предметов (С FIX'ОМ BODYVELOCITY ИЗ ОРИГИНАЛА)
        for _, item in pairs(SpawnedItems) do
            if item.Obj and item.Obj.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                
                -- CRITICAL FIX: BodyVelocity для предотвращения киков античита при телепорте
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)

                ToggleNoclip(true)
                TeleportTo(CFrame.new(item.Pos + Vector3.new(0, 5, 0)))
                task.wait(TeleportDelay)
                
                if item.Prompt.Parent then
                    fireproximityprompt(item.Prompt)
                else
                     -- Fallback for prompt (from original)
                    item.Prompt:InputHoldBegin()
                    task.wait(item.Prompt.HoldDuration or 0.5)
                    item.Prompt:InputHoldEnd()
                end
                
                task.wait(TeleportDelay)
                BodyVelocity:Destroy() 
                
                -- Return to safe spot immediately
                TeleportTo(CFrame.new(978, -42, -49))
            else
                -- Remove invalid item from list logic if needed
            end
        end
        
        TeleportTo(CFrame.new(978, -42, -49)) -- Ensure safe spot
        
        -- 2. Продажа мусора (Замедленная, SafeMode)
        Log("Lucky Farm: Продажа мусора...", "lucky")
        for itemName, shouldSell in pairs(SellItemsList) do
            if shouldSell and LocalPlayer.Backpack:FindFirstChild(itemName) then
                pcall(function()
                    LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(itemName))
                    LocalPlayer.Character.RemoteEvent:FireServer("EndDialogue", {
                        ["NPC"] = "Merchant", ["Dialogue"] = "Dialogue5", ["Option"] = "Option2"
                    })
                end)
                task.wait(ActionDelay) -- Используем безопасную задержку
            end
        end
        
        -- 3. Покупка Lucky Arrows (Замедленная)
        if getgenv().QuarkSettings.AutoBuyLucky and not HasLuckyArrows() then
            local money = LocalPlayer.PlayerStats.Money.Value
            if money >= 75000 then
                Log("Lucky Farm: Покупка Lucky Arrow...", "lucky")
                LocalPlayer.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
                task.wait(ActionDelay + 0.5)
            else
                Log("Lucky Farm: Недостаточно денег ("..money..")", "warn")
            end
        elseif HasLuckyArrows() then
            Log("Lucky Farm: ФУЛЛ Lucky Arrows (10/10)!", "success")
            SendTelegramMessage("🏹 АККАУНТ ЗАБИТ LUCKY ARROWS (10/10)", "finish")
            Teleport() -- Хоп, если фулл
        end
        
        cycles = cycles + 1
        if cycles >= maxCycles then
            Log("Lucky Farm: Смена сервера...", "action")
            Teleport()
        end
        
        task.wait(2)
    end
end
-- =========================================================================================

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local dontTPOnDeath = true

-- [[ ПРОВЕРКА НА ЗАВЕРШЕНИЕ / ВЫБОР РЕЖИМА ПРИ ЗАПУСКЕ ]]
local mode = getgenv().QuarkSettings.FarmModeIndex

if LocalPlayer.PlayerStats.Level.Value == 50 then
    local money = LocalPlayer.PlayerStats.Money.Value
    
    if mode == 2 then -- Money -> Lucky
        if money >= getgenv().TargetMoney then
            StartLuckyFarmLoop() -- Сразу прыгаем в лаки фарм
        end
    elseif mode == 3 then -- Prestige/Level -> Lucky
        -- Если 50 лвл, то сразу лаки фарм, деньги не важны
        StartLuckyFarmLoop()
    elseif mode == 4 then -- Just Prestige
        -- Если 50 лвл, ничего не делаем, скрипт ниже решит (престиж или стоп)
    else -- Standart (1)
        if money >= getgenv().TargetMoney then
             if getgenv().QuarkSettings.NotifyFinish then
                local duration = GetFarmDuration()
                local msg = "🎉 STANDARD FINISH: " .. LocalPlayer.Name .. 
                            "\n💰 Баланс: " .. money ..
                            "\n⏱ Время: " .. duration
                SendTelegramMessage(msg, "finish") 
                Log(msg, "success")
            end
            while true do task.wait(9999999) end 
        end
    end
end

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end

task.spawn(function()
    if game.Lighting:WaitForChild("DepthOfField", 10) then
        game.Lighting.DepthOfField:Destroy()
    end
end)

workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_6.Size = Vector3.new(2048, 89, 2048)
workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_4.Size = Vector3.new(2048, 89, 2048)

local lastTick = tick()

local itemHook;
itemHook = hookfunction(getrawmetatable(game.Players.LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
        return 0
    end
    return itemHook(p,i)
end)

local part = Instance.new("Part")
part.Parent = workspace
part.Anchored = true
part.Size = Vector3.new(25,1,25)
part.Position = Vector3.new(500, 2000, 500)

local function findItem(itemName)
    local ItemsDict = {
        ["Position"] = {},
        ["ProximityPrompt"] = {},
        ["Items"] = {}
    }

    for _,item in pairs(game:GetService("Workspace")["Item_Spawns"].Items:GetChildren()) do
        if item:FindFirstChild("MeshPart") and item.ProximityPrompt.ObjectText == itemName then
            if item.ProximityPrompt.MaxActivationDistance == 8 then
                table.insert(ItemsDict["Items"], item.ProximityPrompt.ObjectText)
                table.insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            end
        end
    end
    return ItemsDict
end

local function countItems(itemName)
    local itemAmount = 0
    for _,item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then
            itemAmount += 1;
end
    end
    return itemAmount
end

local function useItem(aItem, amount)
    Log("Юз предмета: " .. aItem, "action")
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)

    if not item then
        Teleport()
    end

    if amount then
        LocalPlayer.Character.Humanoid:EquipTool(item)
        LocalPlayer.Character:WaitForChild("RemoteFunction"):InvokeServer("LearnSkill",{["Skill"] = "Worthiness",["SkillTreeType"] = "Character"})
        repeat item:Activate() task.wait() until LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.Options:WaitForChild("Option1").TextButton.MouseButton1Click)
        firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
 repeat task.wait() until LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.DialogueFrame.Frame.Line001.Container.Group001.Text == "You"
 firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
    end
end

local function attemptStandFarm()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    
    if LocalPlayer.PlayerStats.Stand.Value == "None" then
        Log("Стенда нет. Использую Стрелу...", "action")
        useItem("Mysterious Arrow", "II")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= "None"

        if not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            Log("Стенд плохой. Сброс (Roka)...", "info")
            useItem("Rokakaka", "II")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            local msg = "🎯 ПОЛУЧЕН СТЕНД: ".. LocalPlayer.PlayerStats.Stand.Value
            Log(msg, "success")
            dontTPOnDeath = true
            Teleport()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        Log("Сброс текущего стенда...", "info")
        useItem("Rokakaka", "II")
    end
end

local function getitem(item, itemIndex)
    local gotItem = false
    local timeout = getgenv().waitUntilCollect + 5

    if Character:FindFirstChild("SummonedStand") then
        if Character:FindFirstChild("SummonedStand").Value then
            RemoteFunction:InvokeServer("ToggleStand", "Toggle")
        end
    end

    LocalPlayer.Backpack.ChildAdded:Connect(function()
        gotItem = true
    end)
    
    task.spawn(function()
        while not gotItem do
            task.wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item["Position"][itemIndex] - Vector3.new(0,10,0)
        end
    end)

    task.wait(getgenv().waitUntilCollect)

    task.spawn(function()
        fireproximityprompt(item["ProximityPrompt"][itemIndex])
        local screenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui",5)
        if not screenGui then return end

        local screenGuiPart = screenGui:WaitForChild("Part")
        for _, button in pairs(screenGuiPart:GetDescendants()) do
            if button:FindFirstChild("Part") then
                if button:IsA("ImageButton") and button:WaitForChild("Part").TextColor3 == Color3.new(0, 1, 0) then
                    repeat
                        firesignal(button.MouseEnter)
                        firesignal(button.MouseButton1Up)
firesignal(button.MouseButton1Click)
                        firesignal(button.Activated)
                        task.wait()
                    until not LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
                end
            end
        end
    end)
    
    task.spawn(function()
        for i=timeout, 1, -1 do
            task.wait(1)
        end
        if not gotItem then
            gotItem = true
            return
        end
    end)

    while not gotItem do
        task.wait()
    end
end

local function farmItem(itemName, amount)
    local items = findItem(itemName)
    local amountFirst = countItems(itemName) == amount

    for itemIndex, _ in pairs(items["Position"]) do
        if countItems(itemName) == amount or amountFirst then
            Log("Собрано " .. itemName, "success")
            break
        else
            getitem(items, itemIndex)
        end
    end
    return true
end

local function endDialogue(NPC, Dialogue, Option)
    local dialogueToEnd = {
        ["NPC"] = NPC,
        ["Dialogue"] = Dialogue,
        ["Option"] = Option
     }
    RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
end

local function storyDialogue()
    local Quest =
    {
    ["Storyline"] = {"#1", "#1", "#1", "#2", "#3", "#3", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#10", "#11", "#11", "#12", "#14"},
    ["Dialogue"] = {"Dialogue2", "Dialogue6", "Dialogue6", "Dialogue3", "Dialogue3", "Dialogue3", "Dialogue6", "Dialogue3", "Dialogue5", "Dialogue5", "Dialogue5", "Dialogue4", "Dialogue7", "Dialogue6", "Dialogue8", "Dialogue11", "Dialogue3", "Dialogue2"}
    }
    
    for counter = 1, 18, 1 do
       RemoteEvent:FireServer("EndDialogue", {["NPC"] = "Storyline".. " " .. Quest["Storyline"][counter],["Dialogue"] = Quest["Dialogue"][counter],["Option"] = "Option1"})
    end
end

local function killNPC(npcName, playerDistance, dontDestroyOnKill, extraParameters)
 local NPC = workspace.Living:WaitForChild(npcName,getgenv().NPCTimeOut)
 local beingTargeted = true
    local doneKilled = false
 local deadCheck

    if not NPC then
        Log("NPC " .. npcName .. " не найден, телепорт.", "warn")
        Teleport()
    end

    local function setStandMorphPosition()
        pcall(function()
            if LocalPlayer.PlayerStats.Stand.Value == "None" then
                HRP.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                return
            end

            if not Character:FindFirstChild("SummonedStand").Value or not Character:FindFirstChild("StandMorph") then
                RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                return
            end

            Character.StandMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
            HRP.CFrame = Character.StandMorph.PrimaryPart.CFrame + Character.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance, 0)
            
            if not Character:FindFirstChild("FocusCam") then
                local FocusCam = Instance.new("ObjectValue", Character)
                FocusCam.Name = "FocusCam"
                FocusCam.Value = Character.StandMorph.PrimaryPart
            end
            
            if Character:FindFirstChild("FocusCam") and Character.FocusCam.Value ~= Character.StandMorph.PrimaryPart then
                Character.FocusCam.Value = Character.StandMorph.PrimaryPart
            end
        end)
    end

    local function HamonCharge()
        if not Character:FindFirstChild("Hamon") then
            return
        end

        if Character.Hamon.Value <= getgenv().HamonCharge then
            RemoteFunction:InvokeServer("AssignSkillKey", {["Type"] = "Spec",["Key"] = "Enum.KeyCode.L",["Skill"] = "Hamon Breathing"})
            Character.RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.L})
        end
    end

    local function BlockBreaker()
        if not NPC or NPC.Parent == nil then
            return
        end
     
        if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
            RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
        elseif NPC.Humanoid.Health <= 1 then
            task.spawn(function()
                task.wait(5)
                if NPC then
                    RemoteFunction:InvokeServer("Attack", "m1")
                end
            end)
        elseif NPC.Humanoid.Health >= 1 then
            RemoteFunction:InvokeServer("Attack", "m1")
        end
    end
    

    deadCheck = LocalPlayer.PlayerGui.HUD.Main.DropMoney.Money.ChildAdded:Connect(function(child)
        local number = tonumber(string.match(child.Name,"%d+"))

        if number and NPC then
            doneKilled = true

            deadCheck:Disconnect()

            if not dontDestroyOnKill then
                NPC:Destroy()
            end
        end
    end)

    while beingTargeted do
        task.wait()
        if not NPC:FindFirstChild("HumanoidRootPart") then
            deadCheck:Disconnect()
            beingTargeted = false
        end
    
        if extraParameters then
            extraParameters()
        end
    
        task.spawn(setStandMorphPosition)
        task.spawn(HamonCharge) 
        task.spawn(BlockBreaker)
    end
    
    return doneKilled
end 

local function checkPrestige(level, prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        local msg = "🌟 ПРЕСТИЖ ВЗЯТ!"
        Log(msg, "success")
        endDialogue("Prestige", "Dialogue2", "Option1")
        return true
    else
        return false
    end
end

local function allocateSkills() 
    task.spawn(function()
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power V",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})

        if LocalPlayer.PlayerStats.Spec.Value == "Hamon (William Zeppeli)" then
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Hamon Punch V",["SkillTreeType"] = "Spec"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Lung Capacity V", ["SkillTreeType"] = "Spec"})
            RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Breathing Technique V",["SkillTreeType"] = "Spec"})
        end
    end)
end

local function autoStory()
    Log("Запуск логики AutoStory...", "action")
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    allocateSkills()

    if LocalPlayer.PlayerStats.Level.Value == 50 then
        local money = LocalPlayer.PlayerStats.Money.Value
        local mode = getgenv().QuarkSettings.FarmModeIndex
        
        -- [[ НОВАЯ ЛОГИКА ОКОНЧАНИЯ ФАРМА ]]
        
        -- MODE 2: MONEY -> LUCKY
        if mode == 2 then 
            if money >= getgenv().TargetMoney then
                StartLuckyFarmLoop()
                return -- Прерываем AutoStory
            end
        
        -- MODE 3: PRESTIGE/LVL -> LUCKY (Игнор денег)
        elseif mode == 3 then
            StartLuckyFarmLoop()
            return
            
        -- MODE 4: JUST LEVEL/PRESTIGE (Игнор денег и лаки)
        elseif mode == 4 then
            -- Просто висит на 50, может фармить вампиров для фана
            
        -- MODE 1: STANDARD (Money -> Stop)
        else 
            if money >= getgenv().TargetMoney then
                if getgenv().QuarkSettings.NotifyFinish then
                    local duration = GetFarmDuration()
                    local msg = "🎉 STANDARD FINISH: " .. money .. "\n⏱ Время фарма: " .. duration
                    SendTelegramMessage(msg, "finish") 
                    Log(msg, "success")
                end
                
                if Character:FindFirstChild("FocusCam") then
                    Character.FocusCam:Destroy()
                end
                pcall(function()
                   delfile("QuarkBeta_"..LocalPlayer.Name..".txt")
                end)
                while true do task.wait(999999) end
            end
        end

        -- Если режим требует денег (1 или 2), но их мало -> фармим вампиров
        if (mode == 1 or mode == 2) and money < getgenv().TargetMoney then
            Log("Lvl 50. Фарм Вампиров до: " .. getgenv().TargetMoney, "info")
            local function vampire()
                pcall(function() 
                    if workspace.Living:FindFirstChild("Vampire") and workspace.Living:FindFirstChild("Vampire"):FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
                    end
                    if not questPanel:FindFirstChild("Take down 3 vampires") then
                        if (tick() - lastTick) >= 5 then
                            lastTick = tick()
                        end
                        endDialogue("William Zeppeli", "Dialogue4", "Option1")
                    end
                end)
            end
            killNPC("Vampire", 15, false, vampire)
            autoStory()
            return
        end
    end

    if getgenv().autoRequiem and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        useItem("Requiem Arrow", "V")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        autoStory()
    end

    if LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 then
        local function collectAndSell(toolName, amount)
            farmItem(toolName, amount)
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
            endDialogue("Merchant", "Dialogue5", "Option2")
        end
        
        if not LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            Log("Фарм Caesar's Headband...", "info")
            task.wait(1) 
            farmItem("Zeppeli's Hat", 1)
        end

        if LocalPlayer.PlayerStats.Money.Value <= 10000 then
            Log("Нужно $10000 для Hamon. Фарм денег...", "warn")
            collectAndSell("Mysterious Arrow", 5)
            collectAndSell("Rokakaka", 5)
            collectAndSell("Diamond", 3)
            collectAndSell("Steel Ball", 3)
            collectAndSell("Quinton's Glove", 2)
            collectAndSell("Hamon Mask", 1) 
            collectAndSell("Pure Rokakaka", 1)
            collectAndSell("Ribcage Of The Saint's Corpse", 1)
            collectAndSell("Ancient Scroll", 2)
            collectAndSell("Clackers", 2)
            collectAndSell("Caesar's headband", 2)
        end

        if LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            Log("Покупка Hamon...", "action")
            LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat"))
            game.Players.LocalPlayer.Character.RemoteEvent:FireServer("PromptTriggered", game.ReplicatedStorage.NewDialogue:FindFirstChild("Lisa Lisa"))
            repeat
              game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
                 task.wait(0.05)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") then
             repeat
            game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,8,0, true, nil, 1)
            task.wait(0.05)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            end
            firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            repeat
            firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
            task.wait(0.05)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
             firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            end
            repeat
            firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
            task.wait(0.05)
            until game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1")
            if game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options:FindFirstChild("Option1") then
            firesignal(game.Players.LocalPlayer.PlayerGui:FindFirstChild("DialogueGui").Frame.Options.Option1.TextButton.MouseButton1Click)
            end
            task.wait(10)
            autoStory()
        else
            Teleport()
        end
    end
       
    while #questPanel:GetChildren() < 2 and repeatCount < 1000 do
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            Log("Квест завершен (".. math.floor(tick() - lastTick) .. "с)", "success")
            lastTick = tick()
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
    
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        storyDialogue()
        task.wait(0.01)
        repeatCount = repeatCount + 1
    end
    

    if repeatCount >= 1000 then
        Teleport()
    end
if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        Log("NPC: Security Guard", "info")
        if killNPC("Security Guard", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        Log("Фарм ресурсов для стенда...", "warn")
        task.wait(5)
        farmItem("Rokakaka", 5) 
        farmItem("Mysterious Arrow", 5) 
        if countItems("Mysterious Arrow") >= 5 and countItems("Mysterious Arrow") >= 5 then 
            Log("Ресурсы готовы. Получаю стенд...", "action")
            dontTPOnDeath = false
            attemptStandFarm()
        else
            Teleport()
        end
    
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        Log("NPC: Leaky Eye Luca", "info")
        if killNPC("Leaky Eye Luca", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        Log("NPC: Bucciarati", "info")
        if killNPC("Bucciarati", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        Log("Квест на $5000. Баланс: " .. LocalPlayer.PlayerStats.Money.Value, "info")
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            Log("Фарм денег...", "action")
            local function collectAndSell(toolName, amount)
                if countItems(toolName) <= amount then
                    farmItem(toolName, amount)
                    Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                    endDialogue("Merchant", "Dialogue5", "Option2")
                    storyDialogue()
                    autoStory()
                end
                if LocalPlayer.PlayerStats.Money.Value < 5000 then
                    storyDialogue()
                    autoStory()
                end
            end
            task.wait(10)
            collectAndSell("Mysterious Arrow", 5)
            collectAndSell("Rokakaka", 5)
            collectAndSell("Diamond", 3)
            collectAndSell("Steel Ball", 3)
            collectAndSell("Quinton's Glove", 2)
            collectAndSell("Pure Rokakaka", 1)
            collectAndSell("Ribcage Of The Saint's Corpse", 1)
            collectAndSell("Ancient Scroll", 2)
            collectAndSell("Clackers", 2)
            collectAndSell("Caesar's headband", 2)
        end
        autoStory()

    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        Log("NPC: Fugo", "info")
        if killNPC("Fugo", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Pesci") then
        Log("NPC: Pesci", "info")
        if killNPC("Pesci", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        Log("NPC: Ghiaccio", "info")
        if killNPC("Ghiaccio", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        Log("BOSS: Diavolo!", "warn") 
        killNPC("Diavolo", 15)
        endDialogue("Storyline #14", "Dialogue7", "Option1")
        if Character:WaitForChild("Requiem Arrow", 5) then
            LocalPlayer.Character.Humanoid.Health = 0
            Teleport()
        else
            autoStory()
        end
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        if Character:FindFirstChild("FocusCam") then
            Character.FocusCam:Destroy()
        end

    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then 
        local function vampire()
            LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    Log("Вампир убит.", "success")
                    lastTick = tick()
                end
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
        end
        killNPC("Vampire", 15, false, vampire)
        autoStory()
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        if Character:FindFirstChild("FocusCam") then
            Character.FocusCam:Destroy()
        end
    end
end

task.spawn(function()
    while task.wait(3) do
        if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
            Log("Престиж! HOP...", "success")
            Teleport()
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            if Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
            end
            break 
        end
    end
end)

game.Workspace.Living.ChildAdded:Connect(function(character)
    if character.Name == LocalPlayer.Name then
        if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value < getgenv().TargetMoney then
            Log("Смерть на 50 ур. Продолжаю.", "warn")
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            -- Если 50 лвл, то проверяем режим, если лаки фарм - возрождаемся и продолжаем
            if getgenv().QuarkSettings.FarmModeIndex == 2 or getgenv().QuarkSettings.FarmModeIndex == 3 then
                task.wait(3)
                StartLuckyFarmLoop()
            end
        else
            if dontTPOnDeath then
                Teleport()
            else
                attemptStandFarm()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide == true then
            child.CanCollide = false
        end
    end
end)

hookfunction(workspace.Raycast, function() 
    return
end)

autoStory()
