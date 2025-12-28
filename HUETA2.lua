-- [[ 🛡 QUARK ADMIN & KEY SYSTEM (FIXED V8 - SMART LOGS & HWID) 🛡 ]]
-- Вставь этот блок В САМОЕ НАЧАЛО скрипта

-- ================= НАСТРОЙКИ АДМИНА =================
local AdminSettings = {
    -- ⚠️ ОБЯЗАТЕЛЬНО ЗАМЕНИ ЭТУ ССЫЛКУ НА СВОЮ РАБОЧУЮ ⚠️
    DatabaseUrl = "https://raw.githubusercontent.com/loloprokek/cbcvbcb34/refs/heads/main/keys.json", 
    
    -- ТВОИ данные для логов
    AdminLogToken = "7556192251:AAFE804ZYUYPFLEhFy82R3M3yoDcF6qLefc",
    AdminLogChatID = "1825714174",
    
    AdminPrefix = "/quarkadmin" 
}

-- [[ ВОЗВРАЩАЕМ ПОЛЬЗОВАТЕЛЬСКИЕ НАСТРОЙКИ ТГ ]]
getgenv().TelegramBotToken = "" 
getgenv().TelegramChatID = ""
-- ====================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui") 
local RequestFunc = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local LocalUseFile = "Quark_LocalUses.txt"
local KeySaveFile = "Quark_SavedKey.txt"

-- [[ ПОЛУЧЕНИЕ HWID И ИНФЫ ОБ УСТРОЙСТВЕ ]]
local function GetSecurityInfo()
    local hwid = "Unknown"
    pcall(function()
        -- Стандартный способ получения HWID в большинстве экзекуторов
        hwid = game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    
    local executor = (identifyexecutor and identifyexecutor()) or "Unknown Executor"
    local accAge = Players.LocalPlayer.AccountAge
    
    return hwid, executor, accAge
end

-- [[ 1. ФУНКЦИЯ ЛОГИРОВАНИЯ ]]
local function SendAdminLog(key, status, extraInfo)
    if not AdminSettings.AdminLogToken or AdminSettings.AdminLogToken == "" or AdminSettings.AdminLogToken:find("ВСТАВЬ") then return end
    
    local uses = 0
    if isfile(LocalUseFile) then
        uses = tonumber(readfile(LocalUseFile)) or 0
    end
    
    if status == "NEW_LOGIN" then
        uses = uses + 1
        writefile(LocalUseFile, tostring(uses))
    end
    
    -- Получаем данные безопасности
    local hwid, executor, accAge = GetSecurityInfo()

    local msg = string.format(
        "🔔 <b>Quark Access Alert</b>\n" ..
        "👤 <b>User:</b> <code>%s</code> (Age: %d days)\n" ..
        "🆔 <b>ID:</b> <code>%d</code>\n" ..
        "🔑 <b>Key:</b> <code>%s</code>\n" ..
        "💻 <b>Status:</b> %s\n\n" ..
        "🛡 <b>Security Dump:</b>\n" ..
        "⚙️ <b>Exec:</b> %s\n" ..
        "🖥 <b>HWID:</b> <code>%s</code>\n" .. -- HWID для проверки перепродажи
        "🔄 <b>Total PC Launches:</b> %d\n" ..
        "📝 <b>Note:</b> %s",
        Players.LocalPlayer.Name,
        accAge,
        Players.LocalPlayer.UserId,
        key or "NONE",
        status,
        executor,
        hwid,
        uses,
        extraInfo or "Clean Launch"
    )

    local url = "https://api.telegram.org/bot" .. AdminSettings.AdminLogToken .. "/sendMessage"
    local payload = HttpService:JSONEncode({
        chat_id = AdminSettings.AdminLogChatID,
        text = msg,
        parse_mode = "HTML"
    })

    if RequestFunc then
        pcall(function()
            RequestFunc({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = payload})
        end)
    end
end

-- [[ 2. ПРОВЕРКА КЛЮЧА ]]
local function VerifyKey(inputKey)
    if not inputKey or inputKey == "" then return false, "Empty Key" end
    
    -- Анти-спам запросами (кэш бастер)
    local noCacheUrl = AdminSettings.DatabaseUrl .. "?nocache=" .. tostring(math.random(1, 100000))
    
    local success, response = pcall(function()
        return game:HttpGet(noCacheUrl)
    end)
    
    if not success then return false, "Connection Error (Check URL)" end
    
    local db
    local decodeSuccess = pcall(function()
        db = HttpService:JSONDecode(response)
    end)
    
    if not decodeSuccess or not db then return false, "JSON Error" end
    
    local keyData = db[inputKey]
    
    -- 1. Ключ не найден
    if not keyData then
        -- Логируем попытку взлома (неверный ключ), даже если файла нет. Это полезно знать.
        if not isfile(KeySaveFile) then
             SendAdminLog(inputKey, "❌ INVALID_KEY", "User tried invalid key")
        end
        return false, "Invalid Key"
    end
    
    -- 2. Ключ в бане
    if keyData.banned then
        SendAdminLog(inputKey, "⛔ BANNED_KEY", "User tried banned key")
        return false, "Key Banned"
    end
    
    -- 3. Истек срок
    if keyData.expires and keyData.expires > 0 and os.time() > keyData.expires then
        return false, "Key Expired"
    end
    
    -- [[ ЛОГИКА УМНОГО ЛОГИРОВАНИЯ ]]
    -- Отправляем лог ТОЛЬКО если файла сохранения НЕТ (новый вход)
    if not isfile(KeySaveFile) then
        SendAdminLog(inputKey, "✅ NEW_LOGIN", "First time / New Device login")
    end
    
    -- Сохраняем ключ
    if writefile then writefile(KeySaveFile, inputKey) end
    
    return true, "Success"
end

-- [[ 3. GUI СИСТЕМА (FIXED) ]]
local function ShowKeySystem(onSuccessCallback)
    if CoreGui:FindFirstChild("QuarkKeySystem") then CoreGui:FindFirstChild("QuarkKeySystem"):Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "QuarkKeySystem"
    Screen.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 400, 0, 250)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = Screen
    MainFrame.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 16)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Color3.fromRGB(80, 80, 255)
    Stroke.Thickness = 2
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local Title = Instance.new("TextLabel", MainFrame)
    Title.Text = "QUARK SECURITY"
    Title.Size = UDim2.new(1, 0, 0, 60)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 22
    Title.ZIndex = 2

    local SubTitle = Instance.new("TextLabel", MainFrame)
    SubTitle.Text = "Premium Access Required"
    SubTitle.Size = UDim2.new(1, 0, 0, 20)
    SubTitle.Position = UDim2.new(0, 0, 0, 45)
    SubTitle.BackgroundTransparency = 1
    SubTitle.TextColor3 = Color3.fromRGB(120, 120, 150)
    SubTitle.Font = Enum.Font.Gotham
    SubTitle.TextSize = 12
    SubTitle.ZIndex = 2

    local BoxBack = Instance.new("Frame", MainFrame)
    BoxBack.Size = UDim2.new(0.8, 0, 0, 45)
    BoxBack.Position = UDim2.new(0.1, 0, 0, 100)
    BoxBack.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    BoxBack.ZIndex = 2
    Instance.new("UICorner", BoxBack).CornerRadius = UDim.new(0, 10)
    
    local KeyBox = Instance.new("TextBox", BoxBack)
    KeyBox.Size = UDim2.new(1, -20, 1, 0)
    KeyBox.Position = UDim2.new(0, 10, 0, 0)
    KeyBox.PlaceholderText = "Paste your key here..."
    KeyBox.Text = ""
    KeyBox.BackgroundTransparency = 1
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.Font = Enum.Font.Code
    KeyBox.TextSize = 14
    KeyBox.ZIndex = 3
    if isfile and isfile(KeySaveFile) then KeyBox.Text = readfile(KeySaveFile) end

    local EnterBtn = Instance.new("TextButton", MainFrame)
    EnterBtn.Size = UDim2.new(0.8, 0, 0, 45)
    EnterBtn.Position = UDim2.new(0.1, 0, 0, 160)
    EnterBtn.Text = "AUTHENTICATE"
    EnterBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
    EnterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    EnterBtn.Font = Enum.Font.GothamBold
    EnterBtn.TextSize = 14
    EnterBtn.ZIndex = 2
    Instance.new("UICorner", EnterBtn).CornerRadius = UDim.new(0, 10)

    local StatusLbl = Instance.new("TextLabel", MainFrame)
    StatusLbl.Size = UDim2.new(1, 0, 0, 30)
    StatusLbl.Position = UDim2.new(0, 0, 0, 210)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.TextColor3 = Color3.fromRGB(100, 100, 120)
    StatusLbl.Font = Enum.Font.Gotham
    StatusLbl.TextSize = 12
    StatusLbl.Text = "Protected by Quark Kernel"
    StatusLbl.ZIndex = 2

    local function WelcomeAnimation()
        task.spawn(function()
            Title.Text = "ACCESS GRANTED"
            SubTitle.Text = "Initiating Main Script..."
            BoxBack.Visible = false
            EnterBtn.Visible = false
            StatusLbl.Text = "Status: Launching..." 
            
            task.wait(0.5) 
            
            Screen.Enabled = false 
            if Screen then Screen:Destroy() end
            
            print("Quark: UI Removed. Starting Logic...")

            task.spawn(function()
                onSuccessCallback()
            end)
        end)
    end

    EnterBtn.MouseButton1Click:Connect(function()
        if EnterBtn.Text == "VERIFYING..." then return end 
        
        EnterBtn.Text = "VERIFYING..."
        local valid, msg = VerifyKey(KeyBox.Text)
        if valid then
            WelcomeAnimation()
        else
            StatusLbl.Text = msg
            StatusLbl.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(1)
            EnterBtn.Text = "AUTHENTICATE"
            StatusLbl.TextColor3 = Color3.fromRGB(100, 100, 120)
        end
    end)
end

-- [[ 4. ОСНОВНОЙ СКРИПТ (СЮДА ВСТАВЛЯТЬ КОД) ]]
local function MainScript()
    print("Quark: Loading Main Script...")
    
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Quark System";
            Text = "Access Granted! Loading scripts...";
            Duration = 5;
        })
    end)

    Players.LocalPlayer.Chatted:Connect(function(msg)
        if msg == AdminSettings.AdminPrefix .. " stats" then
            local uses = isfile(LocalUseFile) and readfile(LocalUseFile) or "0"
            local currentKey = isfile(KeySaveFile) and readfile(KeySaveFile) or "Unknown"
            SendAdminLog(currentKey, "ADMIN_CHECK", "Manual Stats Request.\nTotal PC Uses: " .. uses)
        end
    end)
    
    -- ========================================================
    -- ⬇️⬇️⬇️ ВСТАВЛЯЙ КОД ТВОЕГО ЧИТА/МЕНЮ НИЖЕ ⬇️⬇️⬇️
    -- ========================================================
    
loadstring(game:HttpGet("https://raw.githubusercontent.com/loloprokek/cbcvbcb34/refs/heads/main/test.lua"))()
    
    -- ========================================================
    -- ⬆️⬆️⬆️ КОНЕЦ ТВОЕГО КОДА ⬆️⬆️⬆️
    -- ========================================================
end

-- Логика авто-входа при сохраненном ключе
if isfile and isfile(KeySaveFile) then
    local savedKey = readfile(KeySaveFile)
    
    -- Проверка ключа без отправки лога (т.к. файл есть)
    local valid = VerifyKey(savedKey)
    
    if valid then 
        task.spawn(MainScript) 
    else 
        -- Если сохраненный ключ вдруг протух или забанен - удаляем файл и показываем меню
        delfile(KeySaveFile)
        ShowKeySystem(MainScript) 
    end
else
    ShowKeySystem(MainScript)
end

