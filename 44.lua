-- [НАЧАЛО] Quark Beta: Command Fix V2

-- [[ ДАННЫЕ ТЕЛЕГРАМ ]] 
getgenv().TelegramBotToken = "7556192251:AAFE804ZYUYPFLEhFy82R3M3yoDcF6qLefc" 
getgenv().TelegramChatID = "1825714174"

-- [[ ГЛОБАЛЬНЫЕ НАСТРОЙКИ ]]
getgenv().QuarkSettings = {
    TelegramEnabled = true,     
    UILogging = true,           
    NotifyInject = true,    
    NotifyFinish = true,    
    Filters = { info = true, success = true, warn = true, error = true, action = true, tg = true },
    TGFilters = { info = false, success = false, warn = false, error = false, action = false },
    Transparency = 0.2,         
    ThemeColor = Color3.fromRGB(15, 15, 20) 
}

-- НОВОЕ: Сохранение последнего ID обновления для предотвращения циклов
getgenv().QuarkLastUpdateId = getgenv().QuarkLastUpdateId or 0
local lastUpdateId = getgenv().QuarkLastUpdateId 

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- [[ ЛОГГЕР (ВЫШЕ ДЛЯ ДОСТУПА) ]]
local function Log(text, msgType)
    -- Заглушка, полная функция ниже. Нужна для дебага команд.
    print("Quark: " .. text)
end

-- [[ СИСТЕМА КОМАНД ТЕЛЕГРАМ (FIXED) ]]
local isListening = false

-- 1. Функция сброса Вебхука
local function ClearWebhook()
    if getgenv().TelegramBotToken == "" or string.find(getgenv().TelegramBotToken, "ВСТАВЬ") then return end
    
    local url = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/deleteWebhook"
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if requestFunc then
        pcall(function()
            requestFunc({Url = url, Method = "GET"})
        end)
    end
end

-- 2. Обработчик команд
local function HandleCommands()
    if isListening then return end
    isListening = true
    
    -- Сначала чистим вебхук, чтобы разрешить getUpdates
    ClearWebhook()
    
    task.spawn(function()
        while true do
            task.wait(3) 
            
            if getgenv().QuarkSettings.TelegramEnabled and getgenv().TelegramBotToken ~= "" and not string.find(getgenv().TelegramBotToken, "ВСТАВЬ") then
                
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
                                -- НОВОЕ: Обновляем ID до выполнения команды и сохраняем глобально
                                lastUpdateId = update.update_id
                                getgenv().QuarkLastUpdateId = lastUpdateId
                                
                                -- Проверка ChatID (строгое сравнение строк)
                                if update.message and tostring(update.message.chat.id) == tostring(getgenv().TelegramChatID) then
                                    local text = update.message.text
                                    print("Quark: Получена команда: " .. tostring(text)) -- Дебаг в консоль F9
                                    
                                    if text == "/ping" then
                                        -- Отвечаем реплаем для проверки
                                        local replyUrl = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/sendMessage"
                                        local body = HttpService:JSONEncode({
                                            chat_id = getgenv().TelegramChatID,
                                            text = "🏓 Pong! Связь есть.\nСервер: " .. game.PlaceId,
                                            reply_to_message_id = update.message.message_id
                                        })
                                        requestFunc({Url = replyUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body})
                                        
                                    elseif text == "/stats" then
                                        local stats = Players.LocalPlayer.PlayerStats
                                        local msg = "📊 <b>Статистика Quark:</b>\n" ..
                                                    "👤 <b>Ник:</b> " .. Players.LocalPlayer.Name .. "\n" ..
                                                    "💰 <b>Деньги:</b> " .. stats.Money.Value .. " / " .. getgenv().TargetMoney .. "\n" ..
                                                    "⭐ <b>Уровень:</b> " .. stats.Level.Value .. "\n" ..
                                                    "🏆 <b>Престиж:</b> " .. stats.Prestige.Value .. "\n" ..
                                                    "🕴️ <b>Стенд:</b> " .. stats.Stand.Value
                                        -- Используем прямую отправку для надежности
                                        local sendUrl = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/sendMessage"
                                        local sBody = HttpService:JSONEncode({
                                            chat_id = getgenv().TelegramChatID,
                                            text = msg,
                                            parse_mode = "HTML"
                                        })
                                        requestFunc({Url = sendUrl, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = sBody})
                                        
                                    elseif text == "/rejoin" then
                                        Log("Команда /rejoin получена. Перезапуск...", "warn")
                                        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
                                        return -- НОВОЕ: Сразу выходим из функции
                                        
                                    elseif text == "/stop" then
                                        Log("Команда /stop получена. Кик...", "error")
                                        Players.LocalPlayer:Kick("Stopped via Telegram (/stop)")
                                        return -- НОВОЕ: Сразу выходим из функции
                                    end
                                end
                            end
                        end
                    elseif response and response.StatusCode ~= 200 then
                        -- Если ошибка, пишем в консоль
                        warn("Quark TG Error: " .. tostring(response.StatusCode) .. " | " .. tostring(response.Body))
                    end
                end
            end
        end
    end)
end

-- [[ UI СИСТЕМА (БЕЗ ИЗМЕНЕНИЙ) ]]
local DebugUI = {}
local LogContainer = nil
local MainFrame = nil

function DebugUI:Create()
    if CoreGui:FindFirstChild("QuarkDebugUI") then
        CoreGui:FindFirstChild("QuarkDebugUI"):Destroy()
    end

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
    MainFrame.Size = UDim2.new(0, 450, 0, 420)
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
    Stroke.Thickness = 1

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
    TitleLabel.Text = "⚛️ Quark Beta"
    TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    TitleLabel.TextSize = 18
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame")
    TabContainer.Parent = TitleBar
    TabContainer.BackgroundTransparency = 1
    TabContainer.Size = UDim2.new(0.4, 0, 1, 0)
    TabContainer.Position = UDim2.new(0.6, 0, 0, 0)

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

    local UIListLayout_Logs = Instance.new("UIListLayout")
    UIListLayout_Logs.Parent = LogsPage
    UIListLayout_Logs.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Logs.Padding = UDim.new(0, 4)

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
    SettingsPage.CanvasSize = UDim2.new(0, 0, 0, 750)

    local UIListLayout_Set = Instance.new("UIListLayout")
    UIListLayout_Set.Parent = SettingsPage
    UIListLayout_Set.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Set.Padding = UDim.new(0, 8)

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

    local function CreateSection(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = SettingsPage
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, 0, 0, 25)
        Lbl.Font = Enum.Font.GothamBold
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(150, 150, 200)
        Lbl.TextSize = 14
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function CreateToggle(text, defaultState, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = SettingsPage
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, 0, 0, 35)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(0.7, 0, 1, 0)
        Lbl.Position = UDim2.new(0, 10, 0, 0)
        Lbl.Font = Enum.Font.Gotham
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local Btn = Instance.new("TextButton")
        Btn.Parent = Frame
        Btn.BackgroundColor3 = defaultState and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(60, 60, 60)
        Btn.Position = UDim2.new(1, -50, 0.5, -10)
        Btn.Size = UDim2.new(0, 40, 0, 20)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

        local Circle = Instance.new("Frame")
        Circle.Parent = Btn
        Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Circle.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        Circle.Size = UDim2.new(0, 16, 0, 16)
        Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

        local toggled = defaultState
        Btn.MouseButton1Click:Connect(function()
            toggled = not toggled
            callback(toggled)
            local targetColor = toggled and Color3.fromRGB(100, 255, 120) or Color3.fromRGB(60, 60, 60)
            local targetPos = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(Circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        end)
    end

    local function CreateSlider(text, callback)
        local Frame = Instance.new("Frame")
        Frame.Parent = SettingsPage
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Frame.BackgroundTransparency = 0.95
        Frame.Size = UDim2.new(1, 0, 0, 45)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

        local Lbl = Instance.new("TextLabel")
        Lbl.Parent = Frame
        Lbl.BackgroundTransparency = 1
        Lbl.Position = UDim2.new(0, 10, 0, 5)
        Lbl.Size = UDim2.new(1, 0, 0, 15)
        Lbl.Font = Enum.Font.Gotham
        Lbl.Text = text
        Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
        Lbl.TextSize = 13
        Lbl.TextXAlignment = Enum.TextXAlignment.Left

        local SliderBg = Instance.new("Frame")
        SliderBg.Parent = Frame
        SliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SliderBg.Position = UDim2.new(0, 10, 0, 30)
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
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
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
    
    CreateSection("Основные")
    CreateToggle("Telegram Master Switch", getgenv().QuarkSettings.TelegramEnabled, function(v) getgenv().QuarkSettings.TelegramEnabled = v end)
    CreateToggle("Логи в Меню (UI)", getgenv().QuarkSettings.UILogging, function(v) getgenv().QuarkSettings.UILogging = v end)

    CreateSection("Специальные Уведомления")
    CreateToggle("Уведомлять: Inject (Старт)", getgenv().QuarkSettings.NotifyInject, function(v) getgenv().QuarkSettings.NotifyInject = v end)
    CreateToggle("Уведомлять: Finish (Финиш)", getgenv().QuarkSettings.NotifyFinish, function(v) getgenv().QuarkSettings.NotifyFinish = v end)

    CreateSection("Фильтры Меню (UI)")
    CreateToggle("Show: Success", getgenv().QuarkSettings.Filters.success, function(v) getgenv().QuarkSettings.Filters.success = v end)
    CreateToggle("Show: Info", getgenv().QuarkSettings.Filters.info, function(v) getgenv().QuarkSettings.Filters.info = v end)
    CreateToggle("Show: Error/Kick", getgenv().QuarkSettings.Filters.error, function(v) getgenv().QuarkSettings.Filters.error = v end)
    CreateToggle("Show: Telegram Logs", getgenv().QuarkSettings.Filters.tg, function(v) getgenv().QuarkSettings.Filters.tg = v end)

    CreateSection("Фильтры Telegram (Send)")
    CreateToggle("Send: Success (Квесты)", getgenv().QuarkSettings.TGFilters.success, function(v) getgenv().QuarkSettings.TGFilters.success = v end)
    CreateToggle("Send: Info (Спам)", getgenv().QuarkSettings.TGFilters.info, function(v) getgenv().QuarkSettings.TGFilters.info = v end)
    CreateToggle("Send: Error/Kick (Важно)", getgenv().QuarkSettings.TGFilters.error, function(v) getgenv().QuarkSettings.TGFilters.error = v end)
    CreateToggle("Send: Action (Действия)", getgenv().QuarkSettings.TGFilters.action, function(v) getgenv().QuarkSettings.TGFilters.action = v end)

    CreateSection("Внешний вид")
    CreateSlider("Прозрачность", function(val)
        MainFrame.BackgroundTransparency = val
        getgenv().QuarkSettings.Transparency = val
    end)

    local ColorFrame = Instance.new("Frame")
    ColorFrame.Parent = SettingsPage
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Size = UDim2.new(1, 0, 0, 30)
    
    local function AddColorBtn(color)
        local Btn = Instance.new("TextButton")
        Btn.Parent = ColorFrame
        Btn.BackgroundColor3 = color
        Btn.Size = UDim2.new(0, 25, 0, 25)
        Btn.Text = ""
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(1,0)
        Btn.MouseButton1Click:Connect(function()
            MainFrame.BackgroundColor3 = color
            getgenv().QuarkSettings.ThemeColor = color
        end)
    end
    
    local CL = Instance.new("UIListLayout")
    CL.Parent = ColorFrame
    CL.FillDirection = Enum.FillDirection.Horizontal
    CL.Padding = UDim.new(0, 10)
    
    AddColorBtn(Color3.fromRGB(15, 15, 20))
    AddColorBtn(Color3.fromRGB(20, 10, 30))
    AddColorBtn(Color3.fromRGB(10, 25, 30))
    AddColorBtn(Color3.fromRGB(35, 35, 35))

    local CreditLabel = Instance.new("TextLabel")
    CreditLabel.Parent = SettingsPage
    CreditLabel.BackgroundTransparency = 1
    CreditLabel.Size = UDim2.new(1, 0, 0, 30)
    CreditLabel.Font = Enum.Font.Code
    CreditLabel.Text = "Dev: ModWarmMangos (t.me/zjbvfhgurhhwn)"
    CreditLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    CreditLabel.TextSize = 11
    CreditLabel.TextTransparency = 0.5

    return LogsPage
end

LogContainer = DebugUI:Create()

-- [[ ТЕЛЕГРАМ ОТПРАВКА ]]
local function SendTelegramMessage(text, msgType)
    local typeKey = msgType or "info"

    if not getgenv().QuarkSettings.TelegramEnabled then return end
    if getgenv().QuarkSettings.TGFilters[typeKey] == false then return end
    if getgenv().TelegramBotToken == "ВСТАВЬ_СЮДА_ТОКЕН_БОТА" or getgenv().TelegramBotToken == "" then return end
    
    local url = "https://api.telegram.org/bot" .. getgenv().TelegramBotToken .. "/sendMessage"
    local headers = {["Content-Type"] = "application/json"}
    local body = HttpService:JSONEncode({
        chat_id = getgenv().TelegramChatID,
        text = "⚛️ Quark Beta [" .. typeKey:upper() .. "]:\n" .. text,
        parse_mode = "HTML" 
    })

    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if requestFunc then
        task.spawn(function() 
            requestFunc({Url = url, Method = "POST", Headers = headers, Body = body})
        end)
    end
end

-- [[ ЛОГИРОВАНИЕ (ОБНОВЛЕННАЯ ФУНКЦИЯ) ]]
Log = function(text, msgType) -- Перезаписываем глобальную функцию
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
    end

    print("Quark: " .. text)

    task.spawn(function()
        if LogContainer and LogContainer.Parent then
            local scroller = LogContainer
            local isAtBottom = false
            
            local canvasHeight = scroller.UIListLayout.AbsoluteContentSize.Y
            local windowHeight = scroller.AbsoluteWindowSize.Y
            local currentScroll = scroller.CanvasPosition.Y
            
            if (canvasHeight - currentScroll - windowHeight) < 30 then
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

            if isAtBottom then
                scroller.CanvasPosition = Vector2.new(0, 99999)
            end
            
            if #LogContainer:GetChildren() > 200 then
                local firstChild = LogContainer:GetChildren()[2]
                if firstChild then firstChild:Destroy() end
            end
        end
    end)
end

-- [[ НАСТРОЙКИ ФАРМА ]]
getgenv().TargetMoney = 300000 
getgenv().ItemCollectionDelay = 3 
getgenv().ServerFarmTime = 180 

Log("Инициализация Quark Beta...", "action")

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
                    Log("Inject выполнен. Аккаунт: " .. LocalPlayer.Name, "success")
                end
                
                HandleCommands() -- ЗАПУСКАЕМ ОБРАБОТКУ КОМАНД
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
print("Quark: Экран загрузки пройден.")

print("Quark: Ожидание 5 секунд перед сбросом...")
task.wait(5)

print("Quark: Сброс персонажа для синхронизации...")
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    LocalPlayer.Character.Humanoid.Health = 0
else
    print("Quark: Не удалось найти Humanoid для сброса.")
end

print("Quark: Ожидание 15 секунд (для надежности)...")
task.wait(10) 

Log("Запуск основного скрипта...", "action")

-- [[ ЛОГИКА ФАРМА (БЕЗ ИЗМЕНЕНИЙ) ]]

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
getgenv().lessPing = false 
getgenv().autoRequiem = false 
getgenv().NPCTimeOut = 15 
getgenv().HamonCharge = 90 

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat task.wait() until GrabError.Text ~= "Label"
        local Reason = GrabError.Text
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            local msg = "⚠️ KICK: " .. LocalPlayer.Name .. "\nПричина: " .. Reason
            Log(msg, "error") 
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        end
    end
end)

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local part
local dontTPOnDeath = true

if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value >= getgenv().TargetMoney then 
    if getgenv().QuarkSettings.NotifyFinish then
        local msg = "🎉 УЖЕ ГОТОВО: " .. LocalPlayer.Name .. "\nБаланс: " .. LocalPlayer.PlayerStats.Money.Value
        Log(msg, "success")
    end
    while true do task.wait(9999999) end 
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

local Data = { }
local File = pcall(function()
    Data = HttpService:JSONDecode(readfile("QuarkBeta_"..LocalPlayer.Name..".txt"))
end)

if not File and LocalPlayer.PlayerStats.Level.Value ~= 50 then
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile("QuarkBeta_"..LocalPlayer.Name..".txt", HttpService:JSONEncode(Data))
end

local lastTick = tick()

local itemHook;
itemHook = hookfunction(getrawmetatable(game.Players.LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
        return 0
    end
    return itemHook(p,i)
end)

local Hook;
Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local args = {...}
    local namecallmethod =  getnamecallmethod()

    if namecallmethod == "InvokeServer" then
        if args[1] == "idklolbrah2de" then
            return "  ___XP DE KEY"
        end
    end

    return Hook(self, ...)
end))

local PlaceID = game.PlaceId
local serverHopData = {}
local serverHopFile = pcall(function()
    serverHopData = HttpService:JSONDecode(readfile("QuarkBeta_ServerHop.txt"))
end)

if not serverHopFile or not serverHopData.timestamp or (tick() - serverHopData.timestamp) > 3600 then
    Log("Сброс Hop Data.", "info")
    serverHopData = {
        ["cursor"] = "",
        ["visited"] = {},
        ["timestamp"] = tick()
    }
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
        Log("Ошибка Server List. Жду 5 сек...", "warn")
        serverHopData.cursor = "" 
        serverHopData.visited = {}
        task.wait(5) 
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
            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
            task.wait(5) 
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
    while task.wait(10) do 
        TPReturner()
    end
end


part = Instance.new("Part")
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
        
        if money >= getgenv().TargetMoney then
            if getgenv().QuarkSettings.NotifyFinish then
                local msg = "🎉 ЗАВЕРШЕНО. Баланс: " .. money
                Log(msg, "success")
            end
            
            if Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
            end
            pcall(function()
               delfile("QuarkBeta_"..LocalPlayer.Name..".txt")
            end)
            while true do task.wait(999999) end
            
        else
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
            collectAndSell("Hamon Mask", 1) -- ИЗМЕНЕНО: Исправлено название предмета (было "Pure Rokakaka", что не нужно для хамона)
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
        farmItem("Rokakaka", 25)
        farmItem("Mysterious Arrow", 25)
        if countItems("Mysterious Arrow") >= 25 and countItems("Mysterious Arrow") >= 25 then
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
        -- УДАЛЕНО: Убрал дублирующий SendTelegramMessage.
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
        else
            if dontTPOnDeath then
                Teleport()
            else
                attemptStandFarm()
            end
        end
    end
end)

LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
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
