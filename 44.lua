getgenv().standList = {
    ["The World"] = true,
    ["Star Platinum"] = true,
    ["Star Platinum: The World"] = true,
    ["Crazy Diamond"] = true,
    ["King Crimson"] = true,
    ["King Crimson Requiem"] = true
}
-- ИЗМЕНЕНИЕ: Уменьшена задержка при подборе предметов
getgenv().waitUntilCollect = 0.2 --Change this if ur getting kicked a lot
getgenv().autoRequiem = false --turn this on for auto requiem
getgenv().NPCTimeOut = 30 --timeout for npc not spawning (increased for single server stability)
getgenv().HamonCharge = 90 --change if u want to charge hamon after every kill (around 90)
-- getgenv().webhook = "https://discord.com/api/webhooks/1414918175413375006/J20Y41wt-303RDUCFlpQJnmuz2ihip4wx9uFC12Q4qFhmUwYlzcr8oNaWePsWyRrMYt1" -- ИЗМЕНЕНИЕ: Вебхук отключен

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat task.wait() until GrabError.Text ~= "Label"
        local Reason = GrabError.Text
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
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

-- ИЗМЕНЕНИЕ: Скрипт не будет останавливаться при Lvl 50, если денег меньше 250к
if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value >= 250000 then 
    while true do print("Level 50 и 250к+ монет, скрипт остановлен.") task.wait(9999999) end 
end

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    print("I FOUND IT")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

print("I DID FOUND IT, MAYBE IT WILL WORK?")
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

-- data
local Data = { }
local File = pcall(function()
    Data = game:GetService('HttpService'):JSONDecode(readfile("AutoPres3_"..LocalPlayer.Name..".txt"))
end)

if not File and LocalPlayer.PlayerStats.Level.Value ~= 50 then
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile("AutoPres3_"..LocalPlayer.Name..".txt", game:GetService('HttpService'):JSONEncode(Data))
end

-- start
local lastTick = tick()
-- ИЗМЕНЕНИЕ: Функция вебхука отключена
local function SendWebhook(msg)
    -- Вебхуки отключены по запросу
    -- print("Webhook call suppressed: ", msg) -- можно раскомментировать для отладки
    --[[
    local url = getgenv().webhook

    local data;
    data = {
        ["embeds"] = {
            {
                ["title"] = "Xenon V3 - Auto Prestige 3",
                ["description"] = msg,
                ["type"] = "rich",
                ["color"] = tonumber(0x7269ff),
            }
        }
    }

    repeat task.wait() until data
    local newdata = game:GetService("HttpService"):JSONEncode(data)


    local headers = {
        ["Content-Type"] = "application/json"
    }
    local request = http_request or request or HttpPost or syn.request or http.request
    local abcdef = {Url = url, Body = newdata, Method = "POST", Headers = headers}
    request(abcdef)
    ]]
end

SendWebhook("Loading Xenon V3 - Auto Prestige 3\nCurrent level: `"..LocalPlayer.

PlayerStats.Level.Value.."`\nCurrent prestige: `"..LocalPlayer.PlayerStats.Prestige.Value.."`\nTime since start: `" .. (tick() - Data["Time"])/60 .. " minutes`")

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

part = Instance.new("Part")
part.Parent = workspace
part.Anchored = true
part.Size = Vector3.new(25,1,25)
part.Position = Vector3.new(500, 2000, 500)

--// Obtaining Stand/Farming items //--
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
                table.

insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            else
                print("FAKE?")
            end
        end
    end
    return ItemsDict
end

--count amount of items for checking if full of item
local function countItems(itemName)
    local itemAmount = 0

    for _,item in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if item.Name == itemName then
            itemAmount += 1;
        end
    end

    print(itemAmount)
    return itemAmount
end

--uses item, use amount to specify what worthiness
local function useItem(aItem, amount)
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)

    if not item then
        -- ИЗМЕНЕНИЕ: Вместо хопа, фарм предмета и повтор
        print("Item not in backpack, attempting to farm it first...")
        farmItem(aItem, 1)
        item = LocalPlayer.Backpack:WaitForChild(aItem, 5)
        if not item then
            print("Failed to obtain item after farming attempt, retrying useItem...")
            task.wait(5)
            useItem(aItem, amount) -- Рекурсивный вызов для повторной попытки
            return
        end
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

--main function (entrypoint) of standfarm
local function attemptStandFarm()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    
    if LocalPlayer.PlayerStats.Stand.Value == "None" then
        print("DEBUG CHECK, USING MYSTERIOUS ARROW")
        useItem("Mysterious Arrow", "II")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= "None"

        if not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            print("DEBUG CHECK, USING ROKAKAKA")
            useItem("Rokakaka", "II")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            SendWebhook("Got ".. LocalPlayer.PlayerStats.Stand.Value .. " stand")
            dontTPOnDeath = true
            -- ИЗМЕНЕНИЕ: Нет хопа, просто продолжаем
            autoStory()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        print("DEBUG CHECK, USING ROKAKAKA TO CLEAR STAND")
        useItem("Rokakaka", "II")
    end
end


--teleport not to get caught
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
        
        if not screenGui then
            return
        end

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

--farm item with said name and amount (adapted for single server: wait for spawn if not found)
local function farmItem(itemName, amount)
    local targetAmount = amount or 1
    local currentAmount = countItems(itemName)
    local maxAttempts = 50 -- Max wait loops to prevent infinite hang
    local attempt = 0

    while currentAmount < targetAmount and attempt < maxAttempts do
        local items = findItem(itemName)
        local amountFirst = currentAmount == targetAmount

        if #items["Position"] > 0 then
            for itemIndex, _ in pairs(items["Position"]) do
                if currentAmount == targetAmount or amountFirst then
                    print("SUCCESSFULLY BROKE")
                    break
                else
                    getitem(items, itemIndex)
                    currentAmount = countItems(itemName) -- Update count after pickup
                end
            end
        else
            print("No " .. itemName .. " found, waiting for spawn...")
            task.wait(5) -- Wait for item respawn
            attempt = attempt + 1
        end
        currentAmount = countItems(itemName)
    end
    
    if attempt >= maxAttempts then
        print("Max attempts reached for farming " .. itemName .. ", continuing anyway...")
    end
    
    return currentAmount >= targetAmount
end

--// End Dialogue Func //--
local function endDialogue(NPC, Dialogue, Option)
    local dialogueToEnd = {
        ["NPC"] = NPC,
        ["Dialogue"] = Dialogue,
        ["Option"] = Option
     }
    RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
end

--// End Storyline Dialogue Func //--
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
    print("DEBUG CHECK 1", npcName, playerDistance, dontDestroyOnKill, extraParameters)

    local maxSpawnAttempts = 20 -- Increased for single server waiting
    local spawnAttempt = 0
    local NPC = nil
    local beingTargeted = true
    local doneKilled = false
    local deadCheck

    -- Wait for NPC to spawn with retries
    repeat
        NPC = workspace.Living:WaitForChild(npcName, getgenv().NPCTimeOut)
        if not NPC then
            spawnAttempt = spawnAttempt + 1
            print("NPC " .. npcName .. " not spawned, attempt " .. spawnAttempt .. ", waiting...")
            task.wait(10) -- Wait longer for respawn
        end
    until NPC or spawnAttempt >= maxSpawnAttempts

    if not NPC then
        print("Failed to find NPC " .. npcName .. " after max attempts, skipping...")
        return false
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
        if not NPC or NPC.
Parent == nil then
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
    
    print(doneKilled)
    return doneKilled
end 

local function checkPrestige(level, prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        SendWebhook("@everyone Congratulations you have prestiged!\nTook around `"..
        (tick() - Data["Time"]) / 60 .. " minutes` or `" .. (tick() - Data["Time"]) / 3600 ..
        " hours` to go from `Prestige " .. Data["Prestige"] .. ", Level " .. Data["Level"] ..
        "`, to `Prestige " .. tostring(prestige + 1) .. ", Level 1!`"
        )
        endDialogue("Prestige", "Dialogue2", "Option1")
        return true
    else
        return false
    end
end

local function allocateSkills() --this should allocate the destructive shit stuff
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
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    allocateSkills()

    -- НАЧАЛО ИЗМЕНЕНИЙ: Фарм денег после 50 уровня
    if LocalPlayer.PlayerStats.Level.Value == 50 then
        if LocalPlayer.PlayerStats.Money.Value >= 250000 then
            -- Остановка, если 250к+ денег
            print("ЗАДАЧА ВЫПОЛНЕНА: Достигнуто 250,000 монет. Скрипт остановлен.")
            if Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
            end
            pcall(function()
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
            -- Полная остановка
            while true do task.wait(999999) end
        else
            -- Продолжаем фармить вампиров, т.к. Lvl 50, но < 250k
            print("Lvl 50 достигнут, продолжаю фарм Вампиров для 250,000 монет. Текущий баланс: " .. LocalPlayer.PlayerStats.Money.Value)
            getgenv().HamonCharge = 10
            local function vampire()
                pcall(function() -- Добавим pcall на случай, если NPC не найден
                    if workspace.Living:FindFirstChild("Vampire") and workspace.Living:FindFirstChild("Vampire"):FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
                    end
                    if not questPanel:FindFirstChild("Take down 3 vampires") then
                        if (tick() - lastTick) >= 5 then
                            -- SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete `Vampire Quest`")
                            lastTick = tick()
                        end
                        endDialogue("William Zeppeli", "Dialogue4", "Option1")
                    end
                end)
            end
    
            killNPC("Vampire", 15, false, vampire)
            autoStory()
            return -- ВАЖНО: Прерываем выполнение старой логики autoStory
        end
    end
    -- КОНЕЦ ИЗМЕНЕНИЙ

    if LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        useItem("Requiem Arrow", "V")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        autoStory()
    end
    

    -- ИЗМЕНЕНИЕ: Блок покупки Hamon и фарма Zeppeli's Hat полностью удалён. Если Spec == "None", продолжаем без spec (адаптация: пропускаем, фарм без Hamon)
    if LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 then
        print("Spec отсутствует, пропускаем покупку Hamon и продолжаем прогресс")
        -- Если нужно, можно добавить альтернативный фарм здесь, но по запросу вырезано
    end
        
    while #questPanel:GetChildren() < 2 and repeatCount < 1000 do
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete a quest")
            lastTick = tick()
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
    
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        storyDialogue()
        task.wait(0.01)
        repeatCount = repeatCount + 1
    end
    

    if repeatCount >= 1000 then
        -- ИЗМЕНЕНИЕ: Рестарт вместо хопа
        print("Quest loop timed out, restarting autoStory...")
        task.wait(10)
        autoStory()
    end
if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        print('SECURITY GUARD')
        SendWebhook("Killing Security Guard `" .. LocalPlayer.PlayerStats.QuestProgress.Value.."/"..LocalPlayer.PlayerStats.QuestMaxProgress.Value .."`")
        if killNPC("Security Guard", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        print('NO STAND?')
        task.wait(5)
    
        farmItem("Rokakaka", 25)
        farmItem("Mysterious Arrow", 25)
        -- ИЗМЕНЕНИЕ: Удалён farmItem("Zeppeli's Hat", 1)

        if countItems("Mysterious Arrow") >= 25 and countItems("Rokakaka") >= 25 then
            print("MAX ARROW AND ROKA, GOT")
            print("ATTEMPTING TO STAND FARM")
            dontTPOnDeath = false
            attemptStandFarm()
        else
            -- ИЗМЕНЕНИЕ: Повтор вместо хопа
            print("Not enough items, retrying farm...")
            task.wait(10)
            autoStory()
        end
    
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        print("LEAKY EYE LUCA")
        SendWebhook("Killing `Leaky Eye Luca`")
        if killNPC("Leaky Eye Luca", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        print("BUCCIARATI")
        SendWebhook("Killing `Bucciarati`")

        if killNPC("Bucciarati", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        print("WAH WAH I DONT HAVE ENOUGH MONEY")
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            SendWebhook("Collecting `$5000`")
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
            -- ИЗМЕНЕНИЕ: Удалён collectAndSell("Caesar's headband", 2)
        end
        autoStory()

    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        print("FUGO")
        SendWebhook("Killing `Fugo`")
        if killNPC("Fugo", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Pesci") then
        print("PESCI")
        SendWebhook("Killing `Pesci`")
        if killNPC("Pesci", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        print("GHIACCIO")
        SendWebhook("Killing `Ghiaccio`")
        if killNPC("Ghiaccio", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        SendWebhook("Killing `Diavolo`")
        killNPC("Diavolo", 15)
        endDialogue("Storyline #14", "Dialogue7", "Option1")
        if Character:WaitForChild("Requiem Arrow", 5) then
            LocalPlayer.Character.Humanoid.Health = 0
            -- ИЗМЕНЕНИЕ: Нет хопа, ждём респавн
            task.wait(10)
            autoStory()
        else
            autoStory()
        end
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        -- Эта часть теперь обрабатывается новым кодом в начале autoStory()
        if Character:FindFirstChild("FocusCam") then
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
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
  end



    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Spec.Value ~= "None" and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
        getgenv().HamonCharge = 10
        local function vampire()
            LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete `Vampire Quest`")
                    lastTick = tick()
                end
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
        end

        killNPC("Vampire", 15, false, vampire)
        autoStory()

    -- ИЗМЕНЕНИЕ: Добавлена обработка для вампиров без spec (адаптация: фарм без Hamon, если spec none)
    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
        print("Spec отсутствует, фармим вампиров без Hamon")
        local function vampire()
            LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. (tick() - lastTick).. " seconds to complete `Vampire Quest`")
                    lastTick = tick()
                end
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
        end

        killNPC("Vampire", 15, false, vampire)
        autoStory()

    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        -- Эта часть теперь обрабатывается новым кодом в начале autoStory()
        if Character:FindFirstChild("FocusCam") then
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
               delfile("AutoPres3_"..LocalPlayer.Name..".txt")
            end)
  end
    end
end

task.spawn(function()
    while task.wait(3) do
        if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
            print("Prestiged")
            -- ИЗМЕНЕНИЕ: Нет хопа, просто продолжаем
            task.wait(10)
            autoStory()
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            -- ИЗМЕНЕНИЕ: Не останавливаем этот поток, если Lvl 50,
            -- так как главный поток autoStory() теперь управляет остановкой по деньгам.
            -- Просто выходим из цикла проверки престижа.
            if Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
            end
            print("Level 50 reached, prestige check loop stopped.")
            break 
        else
            print("not able to prestige yet")
        end
    end
end)

game.Workspace.Living.ChildAdded:Connect(function(character)
    if character.Name == LocalPlayer.Name then
        -- ИЗМЕНЕНИЕ: Не телепортируемся при Lvl 50, если не достигли 250к
        if LocalPlayer.PlayerStats.Level.Value == 50 and LocalPlayer.PlayerStats.Money.Value < 250000 then
            print("Died at Lvl 50, continuing farm...")
            task.wait(5)
            autoStory() -- Рестарт логики после смерти
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            print("didnt reconnect")
        else
            if dontTPOnDeath then
                -- ИЗМЕНЕНИЕ: Рестарт вместо хопа
                task.wait(5)
                autoStory()
            else
                attemptStandFarm()
            end
        end
    end
end)

LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
    -- ИЗМЕНЕНИЕ: Вебхук о новом уровне отключен
    -- SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nNew level: `" .. LocalPlayer.PlayerStats.Level.Value .. "`\nCurrent prestige: `" .. LocalPlayer.PlayerStats.Prestige.Value .. "`")
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide == true then
            child.
CanCollide = false
        end
    end
end)

hookfunction(workspace.Raycast, function() -- noclip bypass
    return
end)

autoStory()
