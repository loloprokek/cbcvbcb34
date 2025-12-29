-- [НАЧАЛО] Глобальная функция отладки
local DEBUG_PREFIX = "[XENON_DEBUG] "
local function debug_print(...)
    local args = {...}
    local log = {}
    for i, v in ipairs(args) do
        if type(v) == "table" then
            -- Простой вывод, что это таблица, без рекурсии
            table.insert(log, "{TABLE:" .. tostring(v) .. "}")
        elseif type(v) == "Instance" then
            table.insert(log, "[" .. v.ClassName .. ":" .. v.Name .. "]")
        elseif v == nil then
            table.insert(log, "nil")
        else
            table.insert(log, tostring(v))
        end
    end
    print(DEBUG_PREFIX .. table.concat(log, " "))
end
debug_print("Система отладки инициализирована.")
-- [КОNEC] Глобальная функция отладки


-- [НАЧАЛО] Новый код для сброса и синхронизации
debug_print("Xenon V3: Ожидание загрузки игры...")

local LocalPlayer
local Character
local RemoteEvent
local RemoteFunction

-- Цикл для надежного получения Player, Character и Remotes
debug_print("Вход в главный цикл ожидания игрока...")
while true do
    debug_print("Новая итерация цикла ожидания.")
    LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer then
        debug_print("LocalPlayer найден:", LocalPlayer.Name)
        Character = LocalPlayer.Character
        if Character then
            debug_print("Character найден:", Character.Name)
            -- Ждем, пока Character полностью прогрузится (WaitForChild безопаснее)
            debug_print("Ожидание RemoteEvent и RemoteFunction...")
            local foundRE = Character:WaitForChild("RemoteEvent", 5)
            local foundRF = Character:WaitForChild("RemoteFunction", 5)
            
            if foundRE and foundRF then
                -- Успех! Сохраняем и выходим из цикла
                RemoteEvent = foundRE
                RemoteFunction = foundRF
                debug_print("Xenon V3: Персонаж и Remotes найдены. Выход из цикла.")
                break -- Выход из цикла while true
            else
                debug_print("Xenon V3: Персонаж есть, но RemoteEvent/RemoteFunction не найдены. Повтор...", "Найдено RE:", foundRE, "Найдено RF:", foundRF)
            end
        else
            debug_print("Xenon V3: Игрок есть, но персонаж (Character) еще не загружен. Ожидание...")
        end
    else
        debug_print("Xenon V3: Игрок (LocalPlayer) еще не загружен. Ожидание...")
    end
    task.wait(1) -- Ждем 1 секунду перед следующей попыткой
end

-- Теперь у нас должны быть LocalPlayer, Character, RemoteEvent, RemoteFunction
debug_print("Xenon V3: Обход экрана загрузки...")

-- 1. Логика скипа экрана (скопировано из оригинального скрипта)
if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    debug_print("Xenon V3: HUD не найден. Форсируем создание...")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
    debug_print("HUD создан и привязан.")
else
    debug_print("Xenon V3: HUD уже существует.")
end

debug_print("Вызов RemoteEvent: FireServer('PressedPlay')")
RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    debug_print("Найден LoadingScreen1. Уничтожение...")
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end
if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    debug_print("Найден LoadingScreen. Уничтожение...")
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end
debug_print("Xenon V3: Экран загрузки пройден.")

-- 2. Ожидание 5 секунд
debug_print("Xenon V3: Ожидание 5 секунд перед сбросом...")
task.wait(5)

-- 3. Сброс персонажа (килл)
debug_print("Xenon V3: Выполняется сброс персонажа для синхронизации (по запросу)...")
-- Дополнительная проверка на случай, если персонаж снова пропал
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
    debug_print("Установка здоровья Humanoid на 0.")
    LocalPlayer.Character.Humanoid.Health = 0
else
    debug_print("Xenon V3: Не удалось найти Humanoid для сброса. Пропускаем...")
end

-- 4. Ожидание 20 секунд (для респауна и прогрузки сервера)
debug_print("Xenon V3: Ожидание 20 секунд для полной загрузки...")
task.wait(10)

debug_print("Xenon V3: Запуск основного скрипта AutoPrestige...")
-- [КОНЕЦ] Новый код для сброса и синхронизации

-- 5. Сама логика автопрестижа (весь твой оригинальный скрипт ниже)

debug_print("Установка getgenv().standList")
getgenv().standList =  {
    ["The World"] = true,
    ["Star Platinum"] = true,
    ["Star Platinum: The World"] = true,
    ["Crazy Diamond"] = true,
    ["King Crimson"] = true,
    ["King Crimson Requiem"] = true
}
-- ИЗМЕНЕНИЕ: Уменьшена задержка при подборе предметов
debug_print("Установка getgenv() переменных...")
getgenv().waitUntilCollect = 0.2 --Change this if ur getting kicked a lot
getgenv().sortOrder = "Asc" --desc for less players, asc for more
getgenv().lessPing = false --turn this on if u want lower ping servers, cant guarantee you will see same people using script, and data error 1
getgenv().autoRequiem = false --turn this on for auto requiem
getgenv().NPCTimeOut = 15 --timeout for npc not spawning
debug_print("getgenv() переменные установлены.")
-- [XOXOL] getgenv().HamonCharge = 90 --change if u want to charge hamon after every kill (around 90)
-- getgenv().webhook = "https://discord.com/api/webhooks/1414918175413375006/J20Y41wt-303RDUCFlpQJnmuz2ihip4wx9uFC12Q4qFhmUwYlzcr8oNaWePsWyRrMYt1" -- ИЗМЕНЕНИЕ: Вебхук отключен

debug_print("Установка 'ErrorPrompt' listener (CoreGui.DescendantAdded)...")
game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    debug_print("'ErrorPrompt' listener: Обнаружен новый child:", child.Name)
    if child.Name == "ErrorPrompt" then
        debug_print("'ErrorPrompt' listener: Это ErrorPrompt. Поиск ErrorMessage...")
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat 
            debug_print("'ErrorPrompt' listener: Ожидание текста ошибки...")
            task.wait() 
        until GrabError.Text ~= "Label"
        
        local Reason = GrabError.Text
        debug_print("'ErrorPrompt' listener: Получена ошибка:", Reason)
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            debug_print("'ErrorPrompt' listener: Обнаружена ошибка кика. Телепортация...")
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        else
            debug_print("'ErrorPrompt' listener: Ошибка не связана с киком.")
        end
    end
end)

debug_print("Ожидание game:IsLoaded() и LocalPlayer.Character...")
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
debug_print("Игра загружена, игрок и персонаж существуют.")

-- Эти переменные будут ПЕРЕОПРЕДЕЛЕНЫ, но это нормально, так как они нужны для основного скрипта
debug_print("Переопределение локальных переменных...")
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
debug_print("Ожидание RemoteEvent и RemoteFunction у персонажа...")
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
debug_print("Remotes найдены.")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local part
local dontTPOnDeath = true
debug_print("Локальные переменные установлены.")

-- ИЗМЕНЕНИЕ: Скрипт не будет останавливаться при Lvl 50, если денег меньше 250к
debug_print("Проверка на Level 50 и 300k+ денег...")
if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value >= 300000 then 
    debug_print("Level 50 и 300k+ монет, скрипт остановлен.")
    while true do 
        -- print("Level 50 и 250к+ монет, скрипт остановлен.") -- Закомментировано, чтобы избежать спама
        task.wait(9999999) 
    end 
else
    debug_print("Условие Lvl 50 & 300k+ не выполнено, Lvl:", LocalPlayer.PlayerStats.Level.Value, "Money:", LocalPlayer.PlayerStats.Money.Value)
end

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    debug_print("I FOUND IT (Повторная проверка HUD, вероятно из старого кода)")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

debug_print("I DID FOUND IT, MAYBE IT WILL WORK? (Вызов PressedPlay из старого кода)")
RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    debug_print("(Старый код) Уничтожение LoadingScreen1")
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    debug_print("(Старый код) Уничтожение LoadingScreen")
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end

debug_print("Запуск task.spawn для уничтожения DepthOfField")
task.spawn(function()
    debug_print("task.spawn(DepthOfField): Запущено.")
    if game.Lighting:WaitForChild("DepthOfField", 10) then
        debug_print("task.spawn(DepthOfField): DepthOfField найден. Уничтожение...")
        game.Lighting.DepthOfField:Destroy()
    else
        debug_print("task.spawn(DepthOfField): DepthOfField не найден за 10 сек.")
    end
end)

debug_print("Изменение размера OceanFloor...")
workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_6.Size = Vector3.new(2048, 89, 2048)
workspace.Map.IMPORTANT.OceanFloor.OceanFloor_Sand_4.Size = Vector3.new(2048, 89, 2048)
debug_print("Размер OceanFloor изменен.")

-- data
debug_print("Загрузка данных из файла...")
local Data = { }
local File = pcall(function()
    debug_print("pcall: Попытка readfile AutoPres3_"..LocalPlayer.Name..".txt")
    Data = game:GetService('HttpService'):JSONDecode(readfile("AutoPres3_"..LocalPlayer.Name..".txt"))
end)
debug_print("pcall(readfile) завершен. Успех:", File)

if not File and LocalPlayer.PlayerStats.Level.Value ~= 50 then
    debug_print("Файл не найден (или ошибка) и Lvl != 50. Создание новых данных.")
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    debug_print("Запись нового файла AutoPres3_"..LocalPlayer.Name..".txt")
    writefile("AutoPres3_"..LocalPlayer.Name..".txt", game:GetService('HttpService'):JSONEncode(Data))
    debug_print("Новый файл записан.")
elseif File then
     debug_print("Файл данных успешно загружен.")
else
    debug_print("Файл не загружен, но Lvl == 50. Пропуск создания файла.")
end

-- start
local lastTick = tick()
debug_print("lastTick установлен:", lastTick)

-- ИЗМЕНЕНИЕ: Функция вебхука отключена
local function SendWebhook(msg)
    debug_print("Вызов SendWebhook (отключено). Сообщение:", msg)
    -- Вебхуки отключены по запросу
    -- debug_print("Webhook call suppressed: ", msg) -- можно раскомментировать для отладки
    --[[ ... код вебхука ... ]]
end

debug_print("Отправка 'Loading' вебхука (отключено).")
SendWebhook("Loading Xenon V3 - Auto Prestige 3\nCurrent level: `"..LocalPlayer.

PlayerStats.Level.Value.."`\nCurrent prestige: `"..LocalPlayer.PlayerStats.Prestige.Value.."`\nTime since start: `" .. (tick() - Data["Time"])/60 .. " minutes`")

local itemHook;
debug_print("Установка itemHook (hookfunction)...")
itemHook = hookfunction(getrawmetatable(game.Players.LocalPlayer.Character.HumanoidRootPart.Position).__index, function(p,i)
    -- debug_print("itemHook сработал. p:", p, "i:", i) -- Слишком спамно
    if getcallingscript().Name == "ItemSpawn" and i:lower() == "magnitude" then
        -- debug_print("itemHook: Перехват ItemSpawn.magnitude. Возврат 0.")
        return 0
    end
    return itemHook(p,i)
end)
debug_print("itemHook установлен.")

local Hook;
debug_print("Установка __namecall Hook (hookmetamethod)...")
Hook = hookmetamethod(game, '__namecall', newcclosure(function(self, ...)
    local args = {...}
    local namecallmethod =  getnamecallmethod()
    -- debug_print("__namecall Hook сработал. Method:", namecallmethod) -- Слишком спамно

    if namecallmethod == "InvokeServer" then
        -- debug_print("__namecall Hook: Перехват InvokeServer. Arg1:", args[1]) -- Слишком спамно
        if args[1] == "idklolbrah2de" then
            debug_print("__namecall Hook: Обнаружен 'idklolbrah2de'. Возврат ключа XP.")
            return "  ___XP DE KEY"
        end
    end

    return Hook(self, ...)
end))
debug_print("__namecall Hook установлен.")

--// Hop Func //--
debug_print("Инициализация функции Hop...")
local PlaceID = game.PlaceId
local serverHopData = {}
debug_print("Загрузка данных serverHopFile...")
local serverHopFile = pcall(function()
    debug_print("pcall: Попытка readfile AutoPres3_ServerHop.txt")
    serverHopData = game:GetService('HttpService'):JSONDecode(readfile("AutoPres3_ServerHop.txt"))
end)
debug_print("pcall(readfile ServerHop) завершен. Успех:", serverHopFile)

if not serverHopFile or not serverHopData.timestamp or (tick() - serverHopData.timestamp) > 3600 then
    debug_print("Данные ServerHop устарели или отсутствуют. Сброс...")
    serverHopData = {
        ["cursor"] = "",
        ["visited"] = {},
        ["timestamp"] = tick()
    }
else
    debug_print("Данные ServerHop загружены и актуальны.")
end

local function TPReturner()
    debug_print("Вход в функцию: TPReturner")
    local url = 'https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'
    if serverHopData.cursor and serverHopData.cursor ~= "" then
        url = url .. "&cursor=" .. serverHopData.cursor
    end
    debug_print("TPReturner: URL запроса:", url)

    local success, Site
    pcall(function()
        debug_print("TPReturner: pcall: Выполнение HttpGet...")
        Site = game:GetService('HttpService'):JSONDecode(game:HttpGet(url))
        debug_print("TPReturner: pcall: HttpGet завершен.")
    end)
    success = Site ~= nil -- Простая проверка
    debug_print("TPReturner: pcall(HttpGet) Успех:", success)

    if not success or not Site or not Site.data then
        debug_print("TPReturner: Не удалось получить список серверов или список пуст. Ожидание 5 сек...")
        serverHopData.cursor = "" 
        serverHopData.visited = {}
        task.wait(5) 
        debug_print("Выход из функции: TPReturner (ошибка)")
        return
    end

    local nextPageCursor = Site.nextPageCursor
    debug_print("TPReturner: Получен список серверов. nextCursor:", nextPageCursor)
    
    for _,v in pairs(Site.data) do
       local ID = tostring(v.id)
       debug_print("TPReturner: Проверка сервера ID:", ID, "Players:", v.playing, "/", v.maxPlayers)
       if tonumber(v.maxPlayers) > tonumber(v.playing) and not serverHopData.visited[ID] then
            debug_print("TPReturner: Найден подходящий сервер. ID:", ID)
            serverHopData.visited[ID] = true 
            serverHopData.cursor = nextPageCursor 
            
            debug_print("TPReturner: Запись обновленных данных ServerHop...")
            writefile("AutoPres3_ServerHop.txt", game:GetService('HttpService'):JSONEncode(serverHopData))
            
            debug_print("TPReturner: Телепортация на PlaceInstance:", PlaceID, ID)
            game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
            task.wait(5) 
            -- Скрипт здесь остановится, если телепорт удался
       else
            debug_print("TPReturner: Сервер пропущен (полный или уже посещен).")
       end
    end
    
    if nextPageCursor and nextPageCursor ~= "null" and nextPageCursor ~= nil then
        debug_print("TPReturner: Переход на следующую страницу курсора:", nextPageCursor)
        serverHopData.cursor = nextPageCursor
    else
        debug_print("TPReturner: Достигнут конец списка серверов. Сброс.")
        serverHopData.cursor = ""
        serverHopData.visited = {}
    end
    debug_print("TPReturner: Запись данных ServerHop (конец функции).")
    writefile("AutoPres3_ServerHop.txt", game:GetService('HttpService'):JSONEncode(serverHopData))
    debug_print("Выход из функции: TPReturner")
end

local function Teleport()
    debug_print("Вход в функцию: Teleport (Hop)")
    SendWebhook("Can't find item, hopping servers...")
    
    debug_print("Teleport: Запуск цикла TPReturner...")
    while task.wait(10) do 
        debug_print("Teleport: Вызов TPReturner в цикле.")
        TPReturner()
        debug_print("Teleport: TPReturner завершил сканирование страницы. Повтор через 10 сек.")
    end
    debug_print("Выход из функции: Teleport (НИКОГДА НЕ ДОЛЖЕН ПРОИЗОЙТИ)")
end

debug_print("Создание 'part' (телепорт-якорь)...")
part = Instance.new("Part")
part.Parent = workspace
part.Anchored = true
part.Size = Vector3.new(25,1,25)
part.Position = Vector3.new(500, 2000, 500)
debug_print("'part' создан в", part.Position)

--// Obtaining Stand/Farming items //--
local function findItem(itemName)
    debug_print("Вход в функцию: findItem. Поиск:", itemName)
    local ItemsDict = {
        ["Position"] = {},
        ["ProximityPrompt"] = {},
        ["Items"] = {}
    }

    for _,item in pairs(game:GetService("Workspace")["Item_Spawns"].Items:GetChildren()) do
        if item:FindFirstChild("MeshPart") and item.ProximityPrompt.ObjectText == itemName then
            if item.ProximityPrompt.MaxActivationDistance == 8 then
                -- debug_print("findItem: Найден действительный предмет:", item.Name) -- Слишком спамно
                table.insert(ItemsDict["Items"], item.ProximityPrompt.ObjectText)
                table.insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            else
                debug_print("findItem: Найден FAKE? предмет:", item.Name, "Distance:", item.ProximityPrompt.MaxActivationDistance)
            end
        end
    end
    debug_print("Выход из функции: findItem. Найдено:", #ItemsDict["Items"], "предметов")
    return ItemsDict
end

--count amount of items for checking if full of item
local function countItems(itemName)
    debug_print("Вход в функцию: countItems. Поиск:", itemName)
    local itemAmount = 0

    for _,item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then
            itemAmount += 1;
        end
    end

    debug_print("Выход из функции: countItems. Найдено:", itemAmount)
    return itemAmount
end

--uses item, use amount to specify what worthiness
local function useItem(aItem, amount)
    debug_print("Вход в функцию: useItem. Предмет:", aItem, "Amount (Purpose):", amount)
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)

    if not item then
        debug_print("useItem: Предмет", aItem, "не найден в рюкзаке за 5 сек. Телепортация...")
        Teleport()
        return -- Важно, чтобы остановить выполнение, т.к. Teleport() не вернет управление
    end

    debug_print("useItem: Предмет найден:", item.Name)
    
    if amount then
        debug_print("useItem: 'amount' присутствует. Экипировка инструмента...")
        LocalPlayer.Character.Humanoid:EquipTool(item)
        
        if amount == "II" then -- Обработка Рока/Стрелы
             debug_print("useItem: 'amount' == 'II'. Предмет экипирован. (Логика 'activate' удалена, т.к. ее не было)")
             -- Оригинальный код не делал activate для "II", просто экипировал и выходил.
             -- Если Рока или Стрела требуют активации, ее нужно добавить сюда.
             -- Допустим, они используются автоматически при экипировке или здесь не нужны.
             
             -- НО! Для Рока/Стрелы (II) ОРИГИНАЛЬНЫЙ КОД НЕ ИМЕЕТ ЛОГИКИ АКТИВАЦИИ
             -- ОН ПРОСТО ВЫЗЫВАЕТ useItem("Rokakaka", "II") И ВСЕ.
             -- Это значит, что attemptStandFarm должен сам делать активацию?
             
             -- А, нет, в attemptStandFarm активации тоже нет.
             -- Логика 'amount' ниже (Worthiness) - это для СТРЕЛЫ РЕКВИЕМА!
             
             debug_print("useItem: Логика 'II' (Рока/Стрела). Активация...")
             item:Activate() -- Добавим это, т.к. это логично
             task.wait(1) -- Дадим время на анимацию
             
        elseif amount == "V" then -- Логика для Реквием Стрелы (из 'V' в оригинале)
            debug_print("useItem: 'amount' == 'V' (Реквием). Изучение Worthiness V...")
            LocalPlayer.Character:WaitForChild("RemoteFunction"):InvokeServer("LearnSkill",{["Skill"] = "Worthiness",["SkillTreeType"] = "Character"})
            debug_print("useItem: Активация предмета (петля)...")
            repeat item:Activate() task.wait() until LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
            debug_print("useItem: DialogueGui появился.")
            firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
            firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.Options:WaitForChild("Option1").TextButton.MouseButton1Click)
            firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
            debug_print("useItem: Ожидание диалога 'You'...")
            repeat task.wait() until LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.DialogueFrame.Frame.Line001.Container.Group001.Text == "You"
            debug_print("useItem: Диалог 'You' найден. Закрытие.")
            firesignal(LocalPlayer.PlayerGui:WaitForChild("DialogueGui").Frame.ClickContinue.MouseButton1Click)
        else
             debug_print("useItem: 'amount' == ? (Не 'II' и не 'V'). Просто активация.")
             item:Activate()
             task.wait(1)
        end
    end
    debug_print("Выход из функции: useItem")
end

--main function (entrypoint) of standfarm
local function attemptStandFarm()
    debug_print("Вход в функцию: attemptStandFarm")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    debug_print("attemptStandFarm: Телепорт на якорь.")
    
    if LocalPlayer.PlayerStats.Stand.Value == "None" then
        debug_print("attemptStandFarm: Стэнда нет. Используем Mysterious Arrow...")
        useItem("Mysterious Arrow", "II")
        debug_print("attemptStandFarm: Ожидание появления стэнда...")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= "None"
        debug_print("attemptStandFarm: Стэнд получен:", LocalPlayer.PlayerStats.Stand.Value)

        if not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            debug_print("attemptStandFarm: Стэнд не в списке. Используем Rokakaka...")
            useItem("Rokakaka", "II")
            debug_print("attemptStandFarm: Стэнд сброшен. (Функция завершится и будет вызвана снова)")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            debug_print("attemptStandFarm: Стэнд в списке! Телепортация для продолжения фарма...")
            SendWebhook("Got ".. LocalPlayer.PlayerStats.Stand.Value .. " stand")
            dontTPOnDeath = true
            Teleport()
            return -- Важно
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        debug_print("attemptStandFarm: Стэнд есть, но не в списке. Используем Rokakaka...")
        useItem("Rokakaka", "II")
        debug_print("attemptStandFarm: Стэнд сброшен. (Функция завершится и будет вызвана снова)")
    end
    debug_print("Выход из функции: attemptStandFarm")
end


--teleport not to get caught
local function getitem(item, itemIndex)
    debug_print("Вход в функцию: getitem. itemIndex:", itemIndex)
    local gotItem = false
    local timeout = getgenv().waitUntilCollect + 5
    debug_print("getitem: Тайм-аут установлен:", timeout)

    if Character:FindFirstChild("SummonedStand") then
        if Character:FindFirstChild("SummonedStand").Value then
            debug_print("getitem: Стэнд призван. Отзыв...")
            RemoteFunction:InvokeServer("ToggleStand", "Toggle")
        end
    end

    LocalPlayer.Backpack.ChildAdded:Connect(function()
        debug_print("getitem: Сработал ChildAdded. gotItem = true")
        gotItem = true
    end)
    
    debug_print("getitem: Запуск task.spawn (телепорт к предмету)")
    task.spawn(function()
        debug_print("task.spawn(teleport): Запущен.")
        while not gotItem do
            task.wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = item["Position"][itemIndex] - Vector3.new(0,10,0)
        end
        debug_print("task.spawn(teleport): gotItem = true. Остановка телепорта.")
    end)

    debug_print("getitem: Ожидание waitUntilCollect:", getgenv().waitUntilCollect)
    task.wait(getgenv().waitUntilCollect)

    debug_print("getitem: Запуск task.spawn (fireproximityprompt и ScreenGui)")
    task.spawn(function()
        debug_print("task.spawn(prox): Запущен. Вызов fireproximityprompt...")
        fireproximityprompt(item["ProximityPrompt"][itemIndex])
        
        debug_print("task.spawn(prox): Ожидание ScreenGui...")
        local screenGui = LocalPlayer.PlayerGui:WaitForChild("ScreenGui",5)
        
        if not screenGui then
            debug_print("task.spawn(prox): ScreenGui не найден за 5 сек. Выход.")
            return
        end
        debug_print("task.spawn(prox): ScreenGui найден. Поиск Part...")
        local screenGuiPart = screenGui:WaitForChild("Part")
        debug_print("task.spawn(prox): Поиск кнопок...")
        for _, button in pairs(screenGuiPart:GetDescendants()) do
            if button:FindFirstChild("Part") then
                if button:IsA("ImageButton") and button:WaitForChild("Part").TextColor3 == Color3.new(0, 1, 0) then
                    debug_print("task.spawn(prox): Найдена зеленая кнопка. Клик...")
                    repeat
                        firesignal(button.MouseEnter)
                        firesignal(button.MouseButton1Up)
                        firesignal(button.MouseButton1Click)
                        firesignal(button.Activated)
                        task.wait()
                    until not LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
                    debug_print("task.spawn(prox): ScreenGui закрылся.")
                end
            end
        end
        debug_print("task.spawn(prox): Завершение.")
    end)
    
    debug_print("getitem: Запуск task.spawn (тайм-аут)")
    task.spawn(function()
        debug_print("task.spawn(timeout): Запущен. Ожидание", timeout, "сек.")
        for i=timeout, 1, -1 do
            task.wait(1)
        end

        if not gotItem then
            debug_print("task.spawn(timeout): ВРЕМЯ ВЫШЛО. gotItem = true (для выхода)")
            gotItem = true
            return
        else
            debug_print("task.spawn(timeout): Предмет уже поднят. Тайм-аут отменен.")
        end
    end)

    debug_print("getitem: Ожидание gotItem = true...")
    while not gotItem do
        task.wait()
    end
    debug_print("Выход из функции: getitem. gotItem = true.")
end

--farm item with said name and amount
local function farmItem(itemName, amount)
    debug_print("Вход в функцию: farmItem. Поиск:", itemName, "Нужно:", amount)
    local items = findItem(itemName)
    local amountFirst = countItems(itemName) == amount
    debug_print("farmItem: amountFirst (уже есть нужное кол-во?):", amountFirst)

    for itemIndex, _ in pairs(items["Position"]) do
        debug_print("farmItem: Итерация цикла. itemIndex:", itemIndex)
        if countItems(itemName) == amount or amountFirst then
            debug_print("farmItem: Кол-во достигнуто. SUCCESSFILLY BROKE.")
            break
        else
            debug_print("farmItem: Кол-во не достигнуто. Вызов getitem...")
            getitem(items, itemIndex)
            debug_print("farmItem: getitem завершен.")
        end
    end
    
    debug_print("Выход из функции: farmItem. Завершение фарма", itemName)
    return true
end

--// End Dialogue Func //--
local function endDialogue(NPC, Dialogue, Option)
    debug_print("Вход в функцию: endDialogue. NPC:", NPC, "Dialogue:", Dialogue, "Option:", Option)
    local dialogueToEnd = {
        ["NPC"] = NPC,
        ["Dialogue"] = Dialogue,
        ["Option"] = Option
     }
    debug_print("endDialogue: FireServer('EndDialogue')")
    RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
    debug_print("Выход из функции: endDialogue")
end

--// End Storyline Dialogue Func //--
local function storyDialogue()
    debug_print("Вход в функцию: storyDialogue")
    local Quest =
    {
    ["Storyline"] = {"#1", "#1", "#1", "#2", "#3", "#3", "#3", "#4", "#5", "#6", "#7", "#8", "#9", "#10", "#11", "#11", "#12", "#14"},
    ["Dialogue"] = {"Dialogue2", "Dialogue6", "Dialogue6", "Dialogue3", "Dialogue3", "Dialogue3", "Dialogue6", "Dialogue3", "Dialogue5", "Dialogue5", "Dialogue5", "Dialogue4", "Dialogue7", "Dialogue6", "Dialogue8", "Dialogue11", "Dialogue3", "Dialogue2"}
    }
    
    debug_print("storyDialogue: Запуск цикла прокликивания диалогов...")
    for counter = 1, 18, 1 do
       -- debug_print("storyDialogue: FireServer('EndDialogue') для", "Storyline".. " " .. Quest["Storyline"][counter]) -- Слишком спамно
       RemoteEvent:FireServer("EndDialogue", {["NPC"] = "Storyline".. " " .. Quest["Storyline"][counter],["Dialogue"] = Quest["Dialogue"][counter],["Option"] = "Option1"})
    end
    debug_print("Выход из функции: storyDialogue")
end

local function killNPC(npcName, playerDistance, dontDestroyOnKill, extraParameters)
    debug_print("Вход в функцию: killNPC. NPC:", npcName, "Dist:", playerDistance, "dontDestroy:", dontDestroyOnKill)

    debug_print("killNPC: Ожидание NPC в workspace.Living...")
    local NPC = workspace.Living:WaitForChild(npcName,getgenv().NPCTimeOut)
    local beingTargeted = true
    local doneKilled = false
    local deadCheck
    debug_print("killNPC: NPC найден?", NPC)

    if not NPC then
        debug_print("killNPC: NPC не найден за", getgenv().NPCTimeOut, "сек. Телепортация...")
        Teleport()
        return -- Важно
    end

    local function setStandMorphPosition()
        -- debug_print("Вход в функцию: setStandMorphPosition") -- Слишком спамно
        pcall(function()
            if not NPC or not NPC.Parent or not NPC:FindFirstChild("HumanoidRootPart") then return end -- Добавлена проверка
            
            if LocalPlayer.PlayerStats.Stand.Value == "None" then
                HRP.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                return
            end

            if not Character:FindFirstChild("SummonedStand") or not Character:FindFirstChild("SummonedStand").Value or not Character:FindFirstChild("StandMorph") then
                -- debug_print("setStandMorphPosition: Стэнд не призван или нет морфа. Призыв...") -- Слишком спамно
                RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                return
            end

            Character.StandMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
            HRP.CFrame = Character.StandMorph.PrimaryPart.CFrame + Character.StandMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance, 0)
            
            if not Character:FindFirstChild("FocusCam") then
                -- debug_print("setStandMorphPosition: Создание FocusCam") -- Слишком спамно
                local FocusCam = Instance.new("ObjectValue", Character)
                FocusCam.Name = "FocusCam"
                FocusCam.Value = Character.StandMorph.PrimaryPart
            end
            
            if Character:FindFirstChild("FocusCam") and Character.FocusCam.Value ~= Character.StandMorph.PrimaryPart then
                -- debug_print("setStandMorphPosition: Обновление FocusCam") -- Слишком спамно
                Character.FocusCam.Value = Character.StandMorph.PrimaryPart
            end
        end)
        -- debug_print("Выход из функции: setStandMorphPosition") -- Слишком спамно
    end

    --[[ [XOXOL] Удалена функция зарядки Хамона ... ]]

    local function BlockBreaker()
        -- debug_print("Вход в функцию: BlockBreaker") -- Слишком спамно
        if not NPC or NPC.Parent == nil then
            -- debug_print("BlockBreaker: NPC исчез. Выход.") -- Слишком спамно
            return
        end
    
        if game:GetService("CollectionService"):HasTag(NPC, "Blocking") then
            -- debug_print("BlockBreaker: NPC блокирует. FireServer('InputBegan', R)") -- Слишком спамно
            RemoteEvent:FireServer("InputBegan", {["Input"] = Enum.KeyCode.R})
        elseif NPC.Humanoid.Health <= 1 then
            -- debug_print("BlockBreaker: NPC при смерти. Запуск task.spawn(добивание)") -- Слишком спамно
            task.spawn(function()
                task.wait(5)
                if NPC then
                    -- debug_print("BlockBreaker: task.spawn(добивание): Атака m1") -- Слишком спамно
                    RemoteFunction:InvokeServer("Attack", "m1")
                end
            end)
        elseif NPC.Humanoid.Health >= 1 then
            -- debug_print("BlockBreaker: NPC жив. Атака m1") -- Слишком спамно
            RemoteFunction:InvokeServer("Attack", "m1")
        end
        -- debug_print("Выход из функции: BlockBreaker") -- Слишком спамно
    end
    
    debug_print("killNPC: Установка listener'a (DropMoney.Money.ChildAdded)...")
    deadCheck = LocalPlayer.PlayerGui.HUD.Main.DropMoney.Money.ChildAdded:Connect(function(child)
        local number = tonumber(string.match(child.Name,"%d+"))
        debug_print("killNPC(deadCheck): Обнаружен ChildAdded:", child.Name, "Number:", number)

        if number and NPC then
            debug_print("killNPC(deadCheck): Убийство подтверждено. doneKilled = true.")
            doneKilled = true

            debug_print("killNPC(deadCheck): Отключение listener'a.")
            deadCheck:Disconnect()

            if not dontDestroyOnKill then
                debug_print("killNPC(deadCheck): dontDestroyOnKill = false. Уничтожение NPC...")
                NPC:Destroy()
            else
                debug_print("killNPC(deadCheck): dontDestroyOnKill = true. NPC НЕ уничтожен.")
            end
        end
    end)

    debug_print("killNPC: Вход в главный цикл (while beingTargeted)...")
    while beingTargeted do
        task.wait()
        if not NPC or not NPC.Parent or not NPC:FindFirstChild("HumanoidRootPart") then
            debug_print("killNPC(loop): NPC исчез (убит или удален).")
            debug_print("killNPC(loop): Отключение deadCheck listener'a.")
            deadCheck:Disconnect()
            beingTargeted = false
            debug_print("killNPC(loop): beingTargeted = false. Выход из цикла.")
        else
            -- Цикл жив
            if extraParameters then
                -- debug_print("killNPC(loop): Вызов extraParameters...") -- Слишком спамно
                extraParameters()
            end
        
            -- debug_print("killNPC(loop): Вызов task.spawn(setStandMorphPosition)") -- Слишком спамно
            task.spawn(setStandMorphPosition)
            -- [XOXOL] task.spawn(HamonCharge)
            -- debug_print("killNPC(loop): Вызов task.spawn(BlockBreaker)") -- Слишком спамно
            task.spawn(BlockBreaker)
        end
    end
    
    
    debug_print("Выход из функции: killNPC. Статус doneKilled:", doneKilled)
    return doneKilled
end 

local function checkPrestige(level, prestige)
    debug_print("Вход в функцию: checkPrestige. Lvl:", level, "Prestige:", prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        debug_print("checkPrestige: Условие престижа ВЫПОЛНЕНО.")
        SendWebhook("@everyone Congratulations you have prestiged!\nTook around `" ..
        (tick() - Data["Time"]) / 60 .. " minutes` or `" .. (tick() - Data["Time"]) / 3600 ..
        " hours` to go from `Prestige " .. Data["Prestige"] .. ", Level " .. Data["Level"] ..
        "`, to `Prestige " .. tostring(prestige + 1) .. ", Level 1!`"
        )
        debug_print("checkPrestige: Вызов endDialogue(Prestige)...")
        endDialogue("Prestige", "Dialogue2", "Option1")
        debug_print("Выход из функции: checkPrestige (true)")
        return true
    else
        debug_print("Выход из функции: checkPrestige (false)")
        return false
    end
end

local function allocateSkills() --this should allocate the destructive shit stuff
    debug_print("Вход в функцию: allocateSkills")
    task.spawn(function()
        debug_print("task.spawn(allocateSkills): Запущено.")
        debug_print("task.spawn(allocateSkills): Изучение Destructive Power V-I...")
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power V",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power IV",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power III",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power II",["SkillTreeType"] = "Stand"})
        RemoteFunction:InvokeServer("LearnSkill", {["Skill"] = "Destructive Power I",["SkillTreeType"] = "Stand"})
        debug_print("task.spawn(allocateSkills): Навыки стэнда изучены.")
        
        --[[ [XOXOL] Удалена прокачка навыков Хамона ... ]]
        debug_print("task.spawn(allocateSkills): Завершено.")
    end)
    debug_print("Выход из функции: allocateSkills")
end

local function autoStory()
    debug_print("Вход в функцию: autoStory")
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    debug_print("autoStory: Вызов allocateSkills...")
    allocateSkills()

    -- НАЧАЛО ИЗМЕНЕНИЙ: Фарм денег после 50 уровня
    debug_print("autoStory: Проверка Lvl 50...")
    if LocalPlayer.PlayerStats.Level.Value == 50 then
        debug_print("autoStory: Lvl 50. Проверка денег (>= 300000)...")
        if LocalPlayer.PlayerStats.Money.Value >= 300000 then
            -- Остановка, если 250к+ денег
            debug_print("ЗАДАЧА ВЫПОЛНЕНА: Достигнуто 300,000 монет. Скрипт остановлен.")
            if Character:FindFirstChild("FocusCam") then
                debug_print("Уничтожение FocusCam.")
                Character.FocusCam:Destroy()
            end
            pcall(function()
               debug_print("Удаление файла AutoPres3...")
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
            -- Полная остановка
            debug_print("Вход в бесконечный цикл ожидания.")
            while true do task.wait(999999) end
        else
            -- Продолжаем фармить вампиров, т.к. Lvl 50, но < 250k
            debug_print("autoStory: Lvl 50 достигнут, продолжаю фарм Вампиров для 300,000 монет. Текущий баланс: " .. LocalPlayer.PlayerStats.Money.Value)
            -- [XOXOL] getgenv().HamonCharge = 10
            local function vampire()
                -- debug_print("Вход в функцию: vampire (extraParam)") -- Слишком спамно
                pcall(function() -- Добавим pcall на случай, если NPC не найден
                    if workspace.Living:FindFirstChild("Vampire") and workspace.Living:FindFirstChild("Vampire"):FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
                    end
                    if not questPanel:FindFirstChild("Take down 3 vampires") then
                        if (tick() - lastTick) >= 5 then
                            -- SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete `Vampire Quest`")
                            lastTick = tick()
                            debug_print("vampire(extraParam): Сброс lastTick.")
                        end
                        debug_print("vampire(extraParam): Квест не найден. Вызов endDialogue(William Zeppeli)...")
                        endDialogue("William Zeppeli", "Dialogue4", "Option1")
                    end
                end)
                -- debug_print("Выход из функции: vampire (extraParam)") -- Слишком спамно
            end
    
            debug_print("autoStory(Lvl 50): Вызов killNPC(Vampire)...")
            killNPC("Vampire", 15, false, vampire)
            debug_print("autoStory(Lvl 50): killNPC(Vampire) завершен. Рекурсивный вызов autoStory()...")
            autoStory()
            debug_print("autoStory(Lvl 50): ВЫХОД ИЗ ФУНКЦИИ (return)")
            return -- ВАЖНО: Прерываем выполнение старой логики autoStory
        end
    end
    -- КОНЕЦ ИЗМЕНЕНИЙ
    debug_print("autoStory: Проверка Lvl 50 (else).")

    -- [[ ИСПРАВЛЕНИЕ ЗДЕСЬ ]]
    -- Добавлена проверка getgenv().autoRequiem
    debug_print("autoStory: Проверка autoRequiem...")
    if getgenv().autoRequiem and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum") then
        debug_print("autoStory: Условия autoRequiem выполнены.")
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        debug_print("autoStory(Requiem): Телепорт на якорь.")
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        debug_print("autoStory(Requiem): Вызов useItem(Requiem Arrow, V)...")
        useItem("Requiem Arrow", "V")
        debug_print("autoStory(Requiem): Ожидание смены стэнда...")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        debug_print("autoStory(Requiem): Стэнд сменился на", LocalPlayer.PlayerStats.Stand.Value, ". Рекурсивный вызов autoStory()...")
        autoStory()
        return -- Важно
    else
        debug_print("autoStory: Условия autoRequiem не выполнены.")
    end
    
    --[[ [XOXOL] Полностью удален блок получения Хамона (фарм шляпы, денег для Хамона и покупка) ... ]]
        
    debug_print("autoStory: Вход в цикл while (#questPanel < 2)...")
    while #questPanel:GetChildren() < 2 and repeatCount < 1000 do
        -- debug_print("autoStory(loop): Итерация", repeatCount) -- Слишком спамно
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            debug_print("autoStory(loop): Квест 'Take down 3 vampires' не найден.")
            SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete a quest")
            lastTick = tick()
            debug_print("autoStory(loop): lastTick сброшен. Вызов endDialogue(William Zeppeli)...")
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
    
        -- debug_print("autoStory(loop): InvokeServer('ReturnData')") -- Слишком спамно
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        -- debug_print("autoStory(loop): Вызов storyDialogue()") -- Слишком спамно
        storyDialogue()
        task.wait(0.01)
        repeatCount = repeatCount + 1
    end
    debug_print("autoStory: Выход из цикла while (#questPanel). Итераций:", repeatCount)
    

    if repeatCount >= 1000 then
        debug_print("autoStory: repeatCount >= 1000. Телепортация (зависание квеста)...")
        Teleport()
        return -- Важно
    end
    
    debug_print("autoStory: Анализ квестовой панели...")
    if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        debug_print('autoStory: КВЕСТ: SECURITY GUARD')
        SendWebhook("Killing Security Guard `" .. LocalPlayer.PlayerStats.QuestProgress.Value.."/"..LocalPlayer.PlayerStats.QuestMaxProgress.Value .."`")
        if killNPC("Security Guard", 15) then
            debug_print("autoStory(Security Guard): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Security Guard): НЕ убит (doneKilled=false). Вызов autoStory()...")
            autoStory()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        debug_print('autoStory: КВЕСТ: NO STAND? (Получение стэнда)')
        task.wait(5)
    
        debug_print("autoStory(No Stand): Фарм Rokakaka (25)...")
        farmItem("Rokakaka", 25)
        debug_print("autoStory(No Stand): Фарм Mysterious Arrow (25)...")
        farmItem("Mysterious Arrow", 25)
        -- [XOXOL] farmItem("Zeppeli's Hat", 1)

        if countItems("Mysterious Arrow") >= 25 and countItems("Rokakaka") >= 25 then -- Исправлена ошибка (было 2х Arrow)
            debug_print("autoStory(No Stand): MAX ARROW AND ROKA, GOT")
            debug_print("autoStory(No Stand): ATTEMPTING TO STAND FARM")
            dontTPOnDeath = false
            debug_print("autoStory(No Stand): Вызов attemptStandFarm()...")
            attemptStandFarm()
        else
            debug_print("autoStory(No Stand): Недостаточно предметов. Телепортация...")
            Teleport()
        end
    
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        debug_print("autoStory: КВЕСТ: LEAKY EYE LUCA")
        SendWebhook("Killing `Leaky Eye Luca`")
        if killNPC("Leaky Eye Luca", 15) then
            debug_print("autoStory(Luca): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Luca): НЕ убит. Вызов autoStory()...")
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        debug_print("autoStory: КВЕСТ: BUCCIARATI")
        SendWebhook("Killing `Bucciarati`")

        if killNPC("Bucciarati", 15) then
            debug_print("autoStory(Bucciarati): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Bucciarati): НЕ убит. Вызов autoStory()...")
            autoStory()
        end

    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        debug_print("autoStory: КВЕСТ: WAH WAH I DONT HAVE ENOUGH MONEY ($5,000)")
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            debug_print("autoStory(Money): Денег < 5000. Начинаем сбор...")
            SendWebhook("Collecting `$5000`")
            local function collectAndSell(toolName, amount)
                debug_print("Вход в функцию: collectAndSell. Tool:", toolName, "Amount:", amount)
                if countItems(toolName) <= amount then -- <= ? Логичнее <
                    debug_print("collectAndSell: Фарм", toolName)
                    farmItem(toolName, amount)
                    debug_print("collectAndSell: Экипировка", toolName)
                    Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                    debug_print("collectAndSell: Вызов endDialogue(Merchant)...")
                    endDialogue("Merchant", "Dialogue5", "Option2")
                    debug_print("collectAndSell: Вызов storyDialogue() и autoStory()...")
                    storyDialogue()
                    autoStory()
                    debug_print("collectAndSell: ВЫХОД (return)")
                    return -- Выход после продажи
                end

                if LocalPlayer.PlayerStats.Money.Value < 5000 then
                    debug_print("collectAndSell: Все еще < 5000. Вызов storyDialogue() и autoStory()...")
                    storyDialogue()
                    autoStory()
                    debug_print("collectAndSell: ВЫХОД (return)")
                    return -- Выход
                end
                debug_print("Выход из функции: collectAndSell")
            end
            
            debug_print("autoStory(Money): Ожидание 10 сек...")
            task.wait(10)
            debug_print("autoStory(Money): Вызов collectAndSell (по порядку)...")
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
        debug_print("autoStory(Money): Денег >= 5000. Вызов autoStory()...")
        autoStory()

    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        debug_print("autoStory: КВЕСТ: FUGO")
        SendWebhook("Killing `Fugo`")
        if killNPC("Fugo", 15) then
            debug_print("autoStory(Fugo): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Fugo): НЕ убит. Вызов autoStory()...")
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Pesci") then
        debug_print("autoStory: КВЕСТ: PESCI")
        SendWebhook("Killing `Pesci`")
        if killNPC("Pesci", 15) then
            debug_print("autoStory(Pesci): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Pesci): НЕ убит. Вызов autoStory()...")
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        debug_print("autoStory: КВЕСТ: GHIACCIO")
        SendWebhook("Killing `Ghiaccio`")
        if killNPC("Ghiaccio", 15) then
            debug_print("autoStory(Ghiaccio): Убит. Вызов storyDialogue() и autoStory()...")
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            debug_print("autoStory(Ghiaccio): НЕ убит. Вызов autoStory()...")
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        debug_print("autoStory: КВЕСТ: DIAVOLO")
        SendWebhook("Killing `Diavolo`")
        killNPC("Diavolo", 15)
        debug_print("autoStory(Diavolo): Вызов endDialogue(Storyline #14)...")
        endDialogue("Storyline #14", "Dialogue7", "Option1")
        if Character:WaitForChild("Requiem Arrow", 5) then
            debug_print("autoStory(Diavolo): Найдена Requiem Arrow! Сброс персонажа и Телепорт...")
            LocalPlayer.Character.Humanoid.Health = 0
            Teleport()
        else
            debug_print("autoStory(Diavolo): Requiem Arrow не найдена. Вызов autoStory()...")
            autoStory()
        end
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        debug_print("autoStory: КВЕСТ: Level 50 (Повторная проверка, логика в начале)")
        -- Эта часть теперь обрабатывается новым кодом в начале autoStory()
        if Character:FindFirstChild("FocusCam") then
            debug_print("autoStory(Lvl 50, дубль): Уничтожение FocusCam.")
            Character.FocusCam:Destroy()
            SendWebhook(
                "**Prestige 3, Level 50 reached!**" ..
                "\nTime: `" .. (tick() - Data["Time"])/60 .. " minutes or " .. (tick() - Data["Time"])/3600 .. " hours`" ..
                "\nFrom: `Prestige: ".. Data["Prestige"]  .. ", Level " .. Data["Level"] .. "`" ..
                "\nStand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`" ..
                "\nSpec: `" .. LocalPlayer.PlayerStats.Spec.Value .. "`" ..
                "\nAccount: `" .. LocalPlayer.Name .. "`"
            )
           pcall(function()
               debug_print("autoStory(Lvl 50, дубль): Удаление файла...")
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
        end



    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then -- [XOXOL] Убрана проверка на Spec.Value
        debug_print("autoStory: КВЕСТ: VAMPIRE (Основной фарм Lvl 25-49)")
        -- [XOXOL] getgenv().HamonCharge = 10
        local function vampire()
            -- debug_print("Вход в функцию: vampire (extraParam, Lvl 25-49)") -- Слишком спамно
            LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete `Vampire Quest`")
                    lastTick = tick()
                    debug_print("vampire(extraParam, Lvl 25-49): Сброс lastTick.")
                end
                debug_print("vampire(extraParam, Lvl 25-49): Вызов endDialogue(William Zeppeli)...")
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
            -- debug_print("Выход из функции: vampire (extraParam, Lvl 25-49)") -- Слишком спамно
        end

        debug_print("autoStory(Vampire): Вызов killNPC(Vampire)...")
        killNPC("Vampire", 15, false, vampire)
        debug_print("autoStory(Vampire): Вызов autoStory()...")
        autoStory()

    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        debug_print("autoStory: КВЕСТ: Level 50 (Третья проверка, логика в начале)")
        -- Эта часть теперь обрабатывается новым кодом в начале autoStory()
        if Character:FindFirstChild("FocusCam") then
             debug_print("autoStory(Lvl 50, трибль): Уничтожение FocusCam.")
            Character.FocusCam:Destroy()
            SendWebhook(
                "**Prestige 3, Level 50 reached!**" ..
                "\nTime: `" .. (tick() - Data["Time"])/60 .. " minutes or " .. (tick() - Data["Time"])/3600 .. " hours`" ..
                "\nFrom: `Prestige: ".. Data["Prestige"]  .. ", Level " .. Data["Level"] .. "`" ..
                "\nStand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`" ..
                "\nSpec: `" .. LocalPlayer.PlayerStats.Spec.Value .. "`" ..
                "\nAccount: `" .. LocalPlayer.Name .. "`"
            )
           pcall(function()
               debug_print("autoStory(Lvl 50, трибль): Удаление файла...")
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
        end
    else
        debug_print("autoStory: НЕТ ИЗВЕСТНЫХ КВЕСТОВ. Lvl:", LocalPlayer.PlayerStats.Level.Value, "Stand:", LocalPlayer.PlayerStats.Stand.Value)
        debug_print("autoStory: Квесты на панели:", #questPanel:GetChildren())
        for _, q in pairs(questPanel:GetChildren()) do
            debug_print("autoStory: --", q.Name)
        end
        
        -- [НОВЫЙ ФИКС]
        -- Если у нас неизвестные квесты (сайды), а мы Lvl >= 25,
        -- принудительно берем квест на вампиров, чтобы сбросить старые и встать на рельсы фарма.
        if LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
            debug_print("autoStory(FIX): Неизвестные квесты. Lvl >= 25. Принудительно берем квест у William Zeppeli...")
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
            
            -- Также прокликаем основной сюжет, на всякий случай
            debug_print("autoStory(FIX): Прокликиваем storyDialogue() для сброса...")
            storyDialogue()
            
            debug_print("autoStory(FIX): Ожидание 1 сек и повтор autoStory()...")
            task.wait(1)
            autoStory()
        else
            -- Если мы < Lvl 25, мы, вероятно, застряли.
            -- Попробуем прокликать сюжет и перезапустить.
            debug_print("autoStory(FIX): Неизвестные квесты. Lvl < 25. Прокликиваем storyDialogue() и повторяем...")
            storyDialogue()
            task.wait(1)
            autoStory()
        end
        -- [КОНЕЦ ФИКСА]
    end
    debug_print("Выход из функции: autoStory (КОНЕЦ)")
end

debug_print("Запуск task.spawn (цикл проверки престижа)...")
task.spawn(function()
    debug_print("task.spawn(prestige check): Запущен.")
    while task.wait(3) do
        debug_print("task.spawn(prestige check): Итерация. Вызов checkPrestige...")
        if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
            debug_print("task.spawn(prestige check): Prestiged. Телепортация...")
            Teleport()
            -- Телепорт прервет выполнение этого потока
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            debug_print("task.spawn(prestige check): Level 50. Остановка цикла проверки престижа.")
            -- ИЗМЕНЕНИЕ: Не останавливаем этот поток, если Lvl 50,
            -- так как главный поток autoStory() теперь управляет остановкой по деньгам.
            -- Просто выходим из цикла проверки престижа.
            if Character:FindFirstChild("FocusCam") then
                debug_print("task.spawn(prestige check): Уничтожение FocusCam.")
                Character.FocusCam:Destroy()
            end
            debug_print("Level 50 reached, prestige check loop stopped.")
            break 
        else
            debug_print("task.spawn(prestige check): not able to prestige yet")
        end
    end
    debug_print("task.spawn(prestige check): Цикл завершен.")
end)

debug_print("Установка listener'a (Workspace.Living.ChildAdded)...")
game.Workspace.Living.ChildAdded:Connect(function(character)
    debug_print("Living.ChildAdded: Обнаружен:", character.Name)
    if character.Name == LocalPlayer.Name then
        debug_print("Living.ChildAdded: Это наш персонаж (смерть/респаун).")
        -- ИЗМЕНЕНИЕ: Не телепортируемся при Lvl 50, если не достигли 250к
        if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value < 300000 then
            debug_print("Living.ChildAdded: Died at Lvl 50, continuing farm...")
            -- autoStory() будет вызван снова при респауне персонажа (через CharacterAdded)
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            debug_print("Living.ChildAdded: Lvl 50 и >= 300k. didnt reconnect (ничего не делаем)")
        else
            debug_print("Living.ChildAdded: Lvl < 50. Проверка dontTPOnDeath:", dontTPOnDeath)
            if dontTPOnDeath then
                debug_print("Living.ChildAdded: dontTPOnDeath = true. Телепортация...")
                Teleport()
            else
                debug_print("Living.ChildAdded: dontTPOnDeath = false. Вызов attemptStandFarm()...")
                attemptStandFarm()
            end
        end
    end
end)

debug_print("Установка listener'a (PlayerStats.Level.Value Changed)...")
LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
    debug_print("Level Changed! Новый Lvl:", LocalPlayer.PlayerStats.Level.Value)
    -- ИЗМЕНЕНИЕ: Вебхук о новом уровне отключен
    -- SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nNew level: `" .. LocalPlayer.PlayerStats.Level.Value .. "`\nCurrent prestige: `" .. LocalPlayer.PlayerStats.Prestige.Value .. "`")
end)

debug_print("Установка listener'a (LocalPlayer.CharacterAdded)...")
LocalPlayer.CharacterAdded:Connect(function()
    debug_print("CharacterAdded: Сработало. Ожидание 1 сек...")
    task.wait(1)
    debug_print("CharacterAdded: Отключение CanCollide у всех частей...")
    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide == true then
            child.CanCollide = false
        end
    end
    debug_print("CharacterAdded: CanCollide отключен. Перезапуск autoStory()...")
    autoStory() -- ПЕРЕЗАПУСК ЛОГИКИ ПОСЛЕ РЕСПАУНА
end)

debug_print("Установка hookfunction (workspace.Raycast) для noclip...")
hookfunction(workspace.Raycast, function() -- noclip bypass
    -- debug_print("hookfunction(Raycast) сработал.") -- Слишком спамно
    return
end)
debug_print("hookfunction(Raycast) установлен.")

debug_print("Первый (главный) вызов autoStory()...")
autoStory()
debug_print("------ [XENON SCRIPT] ГЛАВНЫЙ ПОТОК ЗАВЕРШЕН (Все остальное - в эвентах и потоках) ------")
