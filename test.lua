-- [ Quark Main ]

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
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while true do
        task.wait(60)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            local currentCam = workspace.CurrentCamera
            if currentCam then
            end
        end)
    end
end)

local ConfigFileName = "QuarkBeta_Settings.json"

local FarmModes = {
    "Standard (Money & Stop)",
    "Money -> Lucky Farm",
    "P3/Lvl50 -> Lucky Farm",
    "Just Prestige/Level"
}

local BlackScreenGui = nil
local StatsUpdateLoop = nil
local UpdateSafeModeState -- Forward declaration

local function ToggleBlackScreen(state)
    if state then
        if not BlackScreenGui then
            BlackScreenGui = Instance.new("ScreenGui")
            BlackScreenGui.Name = "QuarkBlackScreen"
            BlackScreenGui.Parent = CoreGui
            BlackScreenGui.IgnoreGuiInset = true
            BlackScreenGui.DisplayOrder = 9999
            
            local MainBG = Instance.new("Frame")
            MainBG.Name = "Background"
            MainBG.Size = UDim2.new(1, 0, 1, 0)
            MainBG.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
            MainBG.BorderSizePixel = 0
            MainBG.Parent = BlackScreenGui
            
            local ContentHolder = Instance.new("Frame")
            ContentHolder.Size = UDim2.new(0, 400, 0, 300)
            ContentHolder.Position = UDim2.new(0.5, -200, 0.5, -150)
            ContentHolder.BackgroundTransparency = 1
            ContentHolder.Parent = MainBG

            local Logo = Instance.new("TextLabel")
            Logo.Text = "QUARK BETA"
            Logo.Font = Enum.Font.GothamBold
            Logo.TextSize = 40
            Logo.TextColor3 = Color3.fromRGB(120, 120, 255)
            Logo.Size = UDim2.new(1, 0, 0, 50)
            Logo.Position = UDim2.new(0, 0, 0, 0)
            Logo.BackgroundTransparency = 1
            Logo.Parent = ContentHolder
            
            local Status = Instance.new("TextLabel")
            Status.Text = "3D RENDERING DISABLED"
            Status.Font = Enum.Font.Code
            Status.TextSize = 16
            Status.TextColor3 = Color3.fromRGB(100, 255, 100)
            Status.Size = UDim2.new(1, 0, 0, 30)
            Status.Position = UDim2.new(0, 0, 0, 45)
            Status.BackgroundTransparency = 1
            Status.Parent = ContentHolder

            local StatsFrame = Instance.new("Frame")
            StatsFrame.Size = UDim2.new(0.8, 0, 0, 120)
            StatsFrame.Position = UDim2.new(0.1, 0, 0, 90)
            StatsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            StatsFrame.BackgroundTransparency = 0.5
            Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 8)
            local SStroke = Instance.new("UIStroke", StatsFrame)
            SStroke.Color = Color3.fromRGB(60, 60, 100)
            SStroke.Thickness = 1
            StatsFrame.Parent = ContentHolder

            local function CreateStatLine(name, yPos)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -20, 0, 30)
                Lbl.Position = UDim2.new(0, 10, 0, yPos)
                Lbl.BackgroundTransparency = 1
                Lbl.Font = Enum.Font.GothamMedium
                Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
                Lbl.TextSize = 18
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = StatsFrame
                return Lbl
            end

            local MoneyTxt = CreateStatLine("Money: ...", 10)
            local LevelTxt = CreateStatLine("Level: ...", 45)
            local PrestigeTxt = CreateStatLine("Prestige: ...", 80)

            StatsUpdateLoop = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local stats = Players.LocalPlayer.PlayerStats
                    MoneyTxt.Text = "💰 Money: " .. stats.Money.Value .. " / " .. getgenv().TargetMoney
                    LevelTxt.Text = "⭐ Level: " .. stats.Level.Value
                    PrestigeTxt.Text = "🏆 Prestige: " .. stats.Prestige.Value
                end)
            end)

            local DisableBtn = Instance.new("TextButton")
            DisableBtn.Size = UDim2.new(0.6, 0, 0, 40)
            DisableBtn.Position = UDim2.new(0.2, 0, 1, -50)
            DisableBtn.Text = "TURN ON SCREEN"
            DisableBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            DisableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            DisableBtn.Font = Enum.Font.GothamBold
            DisableBtn.TextSize = 14
            Instance.new("UICorner", DisableBtn).CornerRadius = UDim.new(0, 8)
            DisableBtn.Parent = ContentHolder

            DisableBtn.MouseButton1Click:Connect(function()
                getgenv().QuarkSettings.BlackScreen = false
                if UpdateSafeModeState then UpdateSafeModeState() end
            end)
            
            task.spawn(function()
                while BlackScreenGui and BlackScreenGui.Parent do
                    TweenService:Create(Logo, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(200, 200, 255)}):Play()
                    task.wait(2)
                    TweenService:Create(Logo, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {TextColor3 = Color3.fromRGB(120, 120, 255)}):Play()
                    task.wait(2)
                end
            end)
        end
        BlackScreenGui.Enabled = true
        -- RunService:Set3dRenderingEnabled(false) -- УБРАНО ОТСЮДА, ТЕПЕРЬ УПРАВЛЯЕТСЯ В UpdateSafeModeState
    else
        if BlackScreenGui then
            BlackScreenGui.Enabled = false
        end
        if StatsUpdateLoop then
            StatsUpdateLoop:Disconnect()
            StatsUpdateLoop = nil
        end
        -- RunService:Set3dRenderingEnabled(true) -- УБРАНО ОТСЮДА
    end
end

UpdateSafeModeState = function()
    local safeModeEnabled = getgenv().QuarkSettings.SafeMode
    local blackScreenEnabled = getgenv().QuarkSettings.BlackScreen

    pcall(function()
        if safeModeEnabled then
            -- Базовая оптимизация из файла тес.txt
            settings().Rendering.QualityLevel = 1
            if setfpscap then setfpscap(30) end
            
            if blackScreenEnabled then
                RunService:Set3dRenderingEnabled(false)
                ToggleBlackScreen(true) -- Показываем GUI
            else
                RunService:Set3dRenderingEnabled(true)
                ToggleBlackScreen(false) -- Скрываем GUI
            end
        else
            -- Выключение Safe Mode
            RunService:Set3dRenderingEnabled(true)
            ToggleBlackScreen(false) -- Скрываем GUI
            
            settings().Rendering.QualityLevel = 10
            if setfpscap then setfpscap(60) end
        end
    end)
end

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
        SafeMode = getgenv().QuarkSettings.SafeMode, 
        BlackScreen = getgenv().QuarkSettings.BlackScreen,
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
        SafeMode = false,
        BlackScreen = false,
        TargetMoney = 0, 
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
            Defaults.SafeMode = result.SafeMode or false
            Defaults.BlackScreen = result.BlackScreen or false
            Defaults.TargetMoney = result.TargetMoney or 300000
            Defaults.FarmModeIndex = result.FarmModeIndex or 1
            
            if result.AutoBuyLucky ~= nil then
                Defaults.AutoBuyLucky = result.AutoBuyLucky
            else
                Defaults.AutoBuyLucky = true
            end
            
            if result.ThemeColor then
                Defaults.ThemeColor = Color3.new(result.ThemeColor.R, result.ThemeColor.G, result.ThemeColor.B)
            end
        end
    end
    
    getgenv().QuarkSettings = Defaults
    getgenv().TargetMoney = getgenv().QuarkSettings.TargetMoney 
    
    task.spawn(UpdateSafeModeState)
end

LoadConfig()

if getgenv().TelegramBotToken == "" or string.find(getgenv().TelegramBotToken, "ВСТАВЬ") or getgenv().TelegramChatID == "" then
    if CoreGui:FindFirstChild("QuarkSetup") then CoreGui:FindFirstChild("QuarkSetup"):Destroy() end

    local SetupScreen = Instance.new("ScreenGui")
    SetupScreen.Name = "QuarkSetup"
    SetupScreen.Parent = CoreGui
    SetupScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 420, 0, 280)
    Frame.Position = UDim2.new(0.5, -210, 0.5, -140)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Frame.BorderSizePixel = 0
    Frame.Parent = SetupScreen
    Frame.Active = true
    Frame.Draggable = true
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.5
    
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundTransparency = 0.95
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel", TitleBar)
    Title.Text = "⚛️ Quark Beta Setup"
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(220, 220, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    
    local function CreateNiceInput(placeholder, pos, titleText)
        local Container = Instance.new("Frame", Frame)
        Container.Size = UDim2.new(0.9, 0, 0, 55)
        Container.Position = UDim2.new(0.05, 0, 0, pos)
        Container.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", Container)
        Label.Text = titleText
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(180, 180, 180)
        Label.Font = Enum.Font.GothamMedium
        Label.TextSize = 12
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local BoxBack = Instance.new("Frame", Container)
        BoxBack.Size = UDim2.new(1, 0, 0, 35)
        BoxBack.Position = UDim2.new(0, 0, 0, 20)
        BoxBack.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        Instance.new("UICorner", BoxBack).CornerRadius = UDim.new(0, 6)
        local BoxStroke = Instance.new("UIStroke", BoxBack)
        BoxStroke.Color = Color3.fromRGB(60, 60, 80)
        BoxStroke.Thickness = 1

        local Box = Instance.new("TextBox", BoxBack)
        Box.Size = UDim2.new(1, -20, 1, 0)
        Box.Position = UDim2.new(0, 10, 0, 0)
        Box.PlaceholderText = placeholder
        Box.Text = ""
        Box.BackgroundTransparency = 1
        Box.TextColor3 = Color3.fromRGB(255, 255, 255)
        Box.Font = Enum.Font.Code
        Box.TextSize = 13
        Box.TextXAlignment = Enum.TextXAlignment.Left
        
        return Box
    end
    
    local TokenBox = CreateNiceInput("Введите Bot Token...", 60, "Telegram Bot Token")
    local ChatIDBox = CreateNiceInput("Введите Chat ID...", 125, "Telegram Chat ID")
    
    local SaveBtn = Instance.new("TextButton", Frame)
    SaveBtn.Size = UDim2.new(0.9, 0, 0, 40)
    SaveBtn.Position = UDim2.new(0.05, 0, 0, 210)
    SaveBtn.Text = "Save Config & Start"
    SaveBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveBtn.Font = Enum.Font.GothamBold
    SaveBtn.TextSize = 16
    SaveBtn.AutoButtonColor = true
    
    local BtnCorner = Instance.new("UICorner", SaveBtn)
    BtnCorner.CornerRadius = UDim.new(0, 8)
    
    local waiting = true
    
    SaveBtn.MouseButton1Click:Connect(function()
        if TokenBox.Text ~= "" and ChatIDBox.Text ~= "" then
            getgenv().TelegramBotToken = TokenBox.Text
            getgenv().TelegramChatID = ChatIDBox.Text
            SaveConfig()
            
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 420, 0, 0), BackgroundTransparency = 1}):Play()
            for _, v in pairs(Frame:GetDescendants()) do
                if v:IsA("TextLabel") or v:IsA("TextBox") or v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
                elseif v:IsA("UIStroke") then
                    TweenService:Create(v, TweenInfo.new(0.2), {Transparency = 1}):Play()
                end
            end
            task.wait(0.3)
            SetupScreen:Destroy()
            waiting = false
        else
            SaveBtn.Text = "❌ Заполните оба поля!"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            task.wait(1)
            SaveBtn.Text = "Save Config & Start"
            SaveBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
        end
    end)
    
    repeat task.wait() until not waiting
end

getgenv().QuarkLastUpdateId = getgenv().QuarkLastUpdateId or 0
local lastUpdateId = getgenv().QuarkLastUpdateId 

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
        text = "⚛️ Quark Beta [" .. titleType .. "]:\n" .. text,
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

local Log 
local LogContainer = nil

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

local DebugUI = {}
local MainFrame = nil
local UIGradient = nil

local function UpdateGlassEffect()
    if not MainFrame then return end
    
    if not UIGradient then
        UIGradient = Instance.new("UIGradient")
        UIGradient.Rotation = 45
        UIGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        }
        UIGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.5, 0.2), 
            NumberSequenceKeypoint.new(1, 0)
        }
        UIGradient.Parent = MainFrame
        UIGradient.Enabled = false
    end
    
    if getgenv().QuarkSettings.GlassEffect then
        UIGradient.Enabled = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.4}):Play()
        MainFrame.UIStroke.Transparency = 0.4 
        MainFrame.UIStroke.Color = Color3.fromRGB(150, 200, 255)
    else
        UIGradient.Enabled = false
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {BackgroundTransparency = getgenv().QuarkSettings.Transparency}):Play()
        MainFrame.UIStroke.Transparency = 0.85
        MainFrame.UIStroke.Color = Color3.fromRGB(255, 255, 255)
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
    MainFrame.Size = UDim2.new(0, 450, 0, 500)
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
    TitleLabel.Text = "⚛️ Quark Beta"
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

    local function CreateCategory(name)
        local CategoryFrame = Instance.new("Frame")
        CategoryFrame.Parent = SettingsPage
        CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        CategoryFrame.Size = UDim2.new(1, -10, 0, 35)
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
        ContentFrame.Size = UDim2.new(1, 0, 0, 0)
        
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
    
    local MainCat = CreateCategory("Основные Настройки")
    CreateToggleIn(MainCat, "Переключатель логов-управления Telegram", getgenv().QuarkSettings.TelegramEnabled, function(v) getgenv().QuarkSettings.TelegramEnabled = v end)
    CreateToggleIn(MainCat, "Логи в Меню (UI)", getgenv().QuarkSettings.UILogging, function(v) getgenv().QuarkSettings.UILogging = v end)

    local FarmCat = CreateCategory("Настройки Фарма")
    CreateModeSelector(FarmCat, "Режим Фарма", FarmModes, getgenv().QuarkSettings.FarmModeIndex, function(idx)
        getgenv().QuarkSettings.FarmModeIndex = idx
    end)
    CreateInputIn(FarmCat, "Деньги(после 3p 50l)", getgenv().QuarkSettings.TargetMoney, function(val)
        getgenv().QuarkSettings.TargetMoney = val
        getgenv().TargetMoney = val
    end)
    
    local LuckyCat = CreateCategory("Lucky Farm Опции")
    CreateToggleIn(LuckyCat, "Авто-Покупка Стрел", getgenv().QuarkSettings.AutoBuyLucky, function(v) 
        getgenv().QuarkSettings.AutoBuyLucky = v 
        SaveConfig()
    end)
    
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

    local SafeModeCat = CreateCategory("Оптимизация")
    CreateToggleIn(SafeModeCat, "Оптимизация (FPS/GPU)", getgenv().QuarkSettings.SafeMode, function(v)
        getgenv().QuarkSettings.SafeMode = v
        UpdateSafeModeState()
    end)
    CreateToggleIn(SafeModeCat, "  Черный экран (3D Off)", getgenv().QuarkSettings.BlackScreen, function(v)
        getgenv().QuarkSettings.BlackScreen = v
        UpdateSafeModeState()
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
    CreditLabel.Text = "Dev: MDW prod. | Beta"
    CreditLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
    CreditLabel.TextSize = 11
    CreditLabel.TextTransparency = 0.5

    UpdateGlassEffect() 

    return LogsPage
end

LogContainer = DebugUI:Create()

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

getgenv().TargetMoney = getgenv().QuarkSettings.TargetMoney 
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
                    local userFileName = "QuarkBeta_"..LocalPlayer.Name..".txt"
                    if not isfile(userFileName) then
                        SendTelegramMessage("🆕 Новый аккаунт инициализирован: " .. LocalPlayer.Name, "inject")
                        SendControlPanel()
                    else
                        Log("Успешная инициализация. Аккаунт: " .. LocalPlayer.Name, "info")
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

local UserData = {}
local UserFile = "QuarkBeta_"..LocalPlayer.Name..".txt"
local FileLoaded = pcall(function()
    UserData = HttpService:JSONDecode(readfile(UserFile))
end)

if not FileLoaded then
    UserData = {
        ["Time"] = tick(), 
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
    pcall(function() game:GetService("GuiService"):ClearError() end)
    
    while task.wait(1) do 
        TPReturner()
        task.wait(3)
        TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
    end
end

local function ForceRejoin(reason)
    if getgenv().IsRejoining then return end
    getgenv().IsRejoining = true

    local msg = "⚠️ KICK/CRASH DETECTED: " .. (game.Players.LocalPlayer.Name or "Unknown") .. "\nПричина: " .. (reason or "Неизвестна")
    if Log then Log(msg, "error") end
    
    task.spawn(function()
        while true do
            TPReturner()
            task.wait(2)
            
            TeleportService:Teleport(game.PlaceId, Players.LocalPlayer)
            task.wait(5)
            
            pcall(function() game:GetService("GuiService"):ClearError() end)
        end
    end)
    
    if queue_on_teleport then
        queue_on_teleport([[
            repeat task.wait() until game:IsLoaded()
            print("Quark Rejoined from Kick/Crash")
        ]])
    end
end

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage", true)
        if GrabError then
            task.spawn(function()
                local Reason = GrabError.Text
                ForceRejoin(Reason)
            end)
        end
    end
end)

game:GetService("NetworkClient").ChildRemoved:Connect(function()
    ForceRejoin("Потеря соединения (NetworkClient Disconnected)")
end)

TeleportService.TeleportInitFailed:Connect(function(player, result, errorMessage)
    if player == Players.LocalPlayer then
        ForceRejoin("Teleport Failed: " .. tostring(result) .. " " .. tostring(errorMessage))
    end
end)


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

local function StartLuckyFarmLoop()
    Log("🌟 АКТИВАЦИЯ РЕЖИМА LUCKY FARM (V3 FIX) 🌟", "lucky")
    
    if not getgenv().QuarkSettings.SafeMode then
        Log("Совет: Включите Safe Mode в настройках для лучшего FPS!", "warn")
    end

    local SellItemsList = {
        ["Gold Coin"] = true, ["Rokakaka"] = true, ["Pure Rokakaka"] = true,
        ["Mysterious Arrow"] = true, ["Diamond"] = true, ["Ancient Scroll"] = true,
        ["Caesar's Headband"] = true, ["Stone Mask"] = true, ["Rib Cage of The Saint's Corpse"] = true,
        ["Quinton's Glove"] = true, ["Zeppeli's Hat"] = true, ["Lucky Arrow"] = false,
        ["Clackers"] = true, ["Steel Ball"] = true, ["Dio's Diary"] = true
    }

    local function CountLuckyArrows()
        local count = 0
        for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
            if tool.Name == "Lucky Arrow" then count += 1 end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Lucky Arrow") then
            count += 1
        end
        return count
    end

    local function HasLuckyArrows()
        return CountLuckyArrows() >= 10
    end

    local function DetectLimitMessage()
        local foundText = nil
        pcall(function()
            for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        if obj.Visible and obj.Text ~= "" then
                            local lowerText = string.lower(obj.Text)
                            if string.find(lowerText, "10 lucky arrow") then
                                local isRed = obj.TextColor3.R > 0.8 and obj.TextColor3.G < 0.3 and obj.TextColor3.B < 0.3
                                if isRed or true then
                                    foundText = obj.Text
                                    return true
                                end
                            end
                            if string.find(lowerText, "lucky") or string.find(lowerText, "arrow") then
                                Log("Проверка GUI: найден текст '" .. obj.Text .. "' (цвет: " .. tostring(obj.TextColor3) .. ")", "info")
                            end
                        end
                    end
                end
            end
        end)
        if foundText then
            Log("ДЕТЕКТ СРАБОТАЛ! Найден текст лимита: " .. foundText, "success")
        end
        return foundText ~= nil, foundText
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
    local TeleportDelay = 0.6
    local ActionDelay = 0.5

    local limitNotified = false

    while true do
        UpdateItems()
        Log("Lucky Farm: Предметов: " .. #SpawnedItems .. " | Проверка на лимит-сообщение...", "lucky")

        local detected, fullText = DetectLimitMessage()
        if not limitNotified and detected then
            local luckyCount = CountLuckyArrows()
            local duration = "Неизвестно"
            if typeof(GetFarmDuration) == "function" then
                duration = GetFarmDuration()
            end

            local finishMsg = "🏹 LUCKY FARM ЗАВЕРШЁН! (Лимит 10 Lucky Arrow достигнут)\n" ..
                              "Аккаунт: " .. LocalPlayer.Name .. "\n" ..
                              "Сообщение: " .. (fullText or "Лимит инвентаря") .. "\n" ..
                              "🔢 Lucky Arrows: " .. luckyCount .. "/10\n" ..
                              "⏱ Время фарма: " .. duration

            SendTelegramMessage(finishMsg, "finish")
            Log("ФАРМ ОКОНЧЕН! 10 Lucky Arrow в инвентаре.", "success")
            limitNotified = true

            while true do task.wait(999999) end
        end

        for _, item in pairs(SpawnedItems) do
            if item.Obj and item.Obj.Parent and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
                    item.Prompt:InputHoldBegin()
                    task.wait(item.Prompt.HoldDuration or 0.5)
                    item.Prompt:InputHoldEnd()
                end
                
                task.wait(TeleportDelay)
                BodyVelocity:Destroy()
                
                TeleportTo(CFrame.new(978, -42, -49))
            end
        end
        
        TeleportTo(CFrame.new(978, -42, -49))

        Log("Lucky Farm: Продажа мусора...", "lucky")
        for itemName, shouldSell in pairs(SellItemsList) do
            if shouldSell and LocalPlayer.Backpack:FindFirstChild(itemName) then
                pcall(function()
                    LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(itemName))
                    LocalPlayer.Character.RemoteEvent:FireServer("EndDialogue", {
                        ["NPC"] = "Merchant", ["Dialogue"] = "Dialogue5", ["Option"] = "Option2"
                    })
                end)
                task.wait(ActionDelay)
            end
        end

        if getgenv().QuarkSettings.AutoBuyLucky and not HasLuckyArrows() and not limitNotified then
            local money = LocalPlayer.PlayerStats.Money.Value
            if money >= 75000 then
                Log("Lucky Farm: Покупка Lucky Arrow...", "lucky")
                LocalPlayer.Character.RemoteEvent:FireServer("PurchaseShopItem", {["ItemName"] = "1x Lucky Arrow"})
                task.wait(ActionDelay + 0.5)
            else
                Log("Lucky Farm: Недостаточно денег ("..money.."$)", "warn")
            end
        end

        cycles = cycles + 1
        if cycles >= maxCycles then
            Log("Lucky Farm: Смена сервера...", "action")
            Teleport()
        end
        
        task.wait(2)
    end
end

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local dontTPOnDeath = true

local mode = getgenv().QuarkSettings.FarmModeIndex

if LocalPlayer.PlayerStats.Level.Value == 50 then
    local money = LocalPlayer.PlayerStats.Money.Value
    
    if mode == 2 then 
        if money >= getgenv().TargetMoney then
            StartLuckyFarmLoop() 
        end
    elseif mode == 3 then 
        StartLuckyFarmLoop()
    elseif mode == 4 then 
    else 
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
    Log("Использую предмет: " .. aItem, "action")
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)

    if not item then
        Log("Предмет не найден: " .. aItem, "warn")
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
            Log("Стенд " .. LocalPlayer.PlayerStats.Stand.Value .. " не нужнен. Roka...", "info")
            useItem("Rokakaka", "II")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            local msg = "ПОЛУЧЕН СТЕНД: ".. LocalPlayer.PlayerStats.Stand.Value
            Log(msg, "success")
            dontTPOnDeath = true
            Teleport()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        Log("Сброс текущего стенда " .. LocalPlayer.PlayerStats.Stand.Value .. "...", "info")
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
 Log("Атака цели: " .. npcName, "action")
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
        
        if mode == 2 then 
            if money >= getgenv().TargetMoney then
                StartLuckyFarmLoop()
                return 
            end
        
        elseif mode == 3 then
            StartLuckyFarmLoop()
            return
            
        elseif mode == 4 then
            
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
