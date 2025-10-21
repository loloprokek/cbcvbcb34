getgenv().standList =  {
    ["The World"] = true,
    ["Star Platinum"] = true,
    ["Star Platinum: The World"] = true,
    ["Crazy Diamond"] = true,
    ["King Crimson"] = true,
    ["King Crimson Requiem"] = true
}
getgenv().waitUntilCollect = 0.5 --Change this if ur getting kicked a lot
getgenv().sortOrder = "Asc" --desc for less players, asc for more
getgenv().lessPing = false --turn this on if u want lower ping servers, cant guarantee you will see same people using script, and data error 1
getgenv().autoRequiem = false --turn this on for auto requiem
getgenv().NPCTimeOut = 15 --timeout for npc not spawning
getgenv().HamonCharge = 90 --change if u want to charge hamon after every kill (around 90)
getgenv().webhook = "" --change this if u want to use ur own webhook
getgenv().moneyTarget = 250000 -- [НОВОЕ] Цель по деньгам после P3 L50

-- [DEBUG/LOGGING FUNCTIONS START]
local function LogDebug(msg)
    print("[Xenon V3 DEBUG]: " .. msg)
end

local function SendWebhook(msg, isError, ping)
    local url = getgenv().webhook
    
    -- Red for error (FF0000), Orange/Yellow for Warning (FFB347), Blue for Status (7269ff)
    local color = isError == true and tonumber(0xFF0000) or (isError == "WARN" and tonumber(0xFFB347) or tonumber(0x7269ff))
    local title = isError == true and "Xenon V3 - Auto Prestige 3 [CRITICAL ERROR]" or (isError == "WARN" and "Xenon V3 - Auto Prestige 3 [WARNING]" or "Xenon V3 - Auto Prestige 3 [STATUS]")
    local pingMsg = ping and "@everyone \n" or ""

    local data;
    data = {
        ["embeds"] = {
            {
                ["title"] = title,
                ["description"] = pingMsg .. msg,
                ["type"] = "rich",
                ["color"] = color,
                ["footer"] = {
                    ["text"] = "Current Time: " .. os.date("!%Y-%m-%d %H:%M:%S") .. " UTC"
                }
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
    pcall(function()
        request(abcdef)
    end)
end
-- [DEBUG/LOGGING FUNCTIONS END]

game:GetService("CoreGui").DescendantAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" then
        local GrabError = child:FindFirstChild("ErrorMessage",true)
        repeat task.wait() until GrabError.Text ~= "Label"
        local Reason = GrabError.Text
        LogDebug("Roblox Error Detected: " .. Reason)
        if Reason:match("kick") or Reason:match("You") or Reason:match("conn") or Reason:match("rejoin") then
            SendWebhook("Roblox Kick Detected. Rejoining server. Reason: `" .. Reason .. "`", true, true)
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
        end
    end
end)

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
LogDebug("Game loaded, player character ready.")

local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
repeat task.wait() until Character:FindFirstChild("RemoteEvent") and Character:FindFirstChild("RemoteFunction")
local RemoteFunction, RemoteEvent = Character.RemoteFunction, Character.RemoteEvent
local HRP = Character.PrimaryPart
local part
local dontTPOnDeath = true
local farmMoney -- [НОВОЕ] Предварительное объявление для новой функции

if LocalPlayer.PlayerStats.Level.Value == 50 then 
    SendWebhook("Level 50 reached. Script execution stopped.", false)
    while true do 
        LogDebug("Level 50 reached, Auto pres disabled.")
        task.wait(9999999) 
    end 
end

if not LocalPlayer.PlayerGui:FindFirstChild("HUD") then
    LogDebug("HUD not found, cloning it.")
    local HUD = game:GetService("ReplicatedStorage").Objects.HUD:Clone()
    HUD.Parent = LocalPlayer.PlayerGui
end

LogDebug("Sending PressedPlay event.")
RemoteEvent:FireServer("PressedPlay")

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen1"):Destroy()
end

if LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen") then
    LocalPlayer.PlayerGui:FindFirstChild("LoadingScreen"):Destroy()
end

task.spawn(function()
    if game.Lighting:WaitForChild("DepthOfField", 10) then
        LogDebug("Destroying DepthOfField for performance.")
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
    LogDebug("No save file found. Initializing new data.")
    Data = {
        ["Time"] = tick(),
        ["Prestige"] = LocalPlayer.PlayerStats.Prestige.Value,
        ["Level"] = LocalPlayer.PlayerStats.Level.Value
    }
    writefile("AutoPres3_"..LocalPlayer.Name..".txt", game:GetService('HttpService'):JSONEncode(Data))
end

-- start
local lastTick = tick()

SendWebhook("Loading Xenon V3 - Auto Prestige 3\nCurrent level: `"..LocalPlayer.
PlayerStats.Level.Value.."`\nCurrent prestige: `"..LocalPlayer.PlayerStats.Prestige.Value.."`\nTime since start: `" .. string.format("%.2f", (tick() - Data["Time"])/60) .. " minutes`", false)

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

--// Hop Func //--
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local function TPReturner()
    local Site;
    if foundAnything == "" then
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100'))
    else
       Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=' .. getgenv().sortOrder .. '&limit=100&cursor=' .. foundAnything))
    end

    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
       foundAnything = Site.nextPageCursor
    end

    local num = 0;
    for _,v in pairs(Site.data) do
       local Possible = true
       ID = tostring(v.id)
       if tonumber(v.maxPlayers) > tonumber(v.playing) then
          for _,Existing in pairs(AllIDs) do
             if num ~= 0 then
                if ID == tostring(Existing) then
                   Possible = false
                end
             else
                if tonumber(actualHour) ~= tonumber(Existing) then
                   local delFile = pcall(function()
                   delfile("XenonAutoPres3ServerBlocker.json")
                   AllIDs = {}
                   table.insert(AllIDs, actualHour)
                   end)
                end
             end
             num = num + 1
          end
          if Possible == true then
             table.insert(AllIDs, ID)
             task.wait()
             pcall(function()
                writefile("XenonAutoPres3ServerBlocker.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                task.wait()
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
             end)
             task.wait(4)
          end
       end
    end
 end

 local function Teleport(reason) -- Added reason parameter
    LogDebug("Teleporting server. Reason: " .. (reason or "Rejoining to fix script failure/kick"))
    if not reason then
        SendWebhook("Rejoining server. Reason: `Manual/Unknown Error`.", false)
    end
    
    while task.wait() do
       pcall(function()
        if getgenv().lessPing then
            game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
     
            game:GetService("TeleportService").TeleportInitFailed:Connect(function()
                 game:GetService("TeleportService"):Teleport(2809202155, game:GetService("Players").LocalPlayer)
            end)
            
            repeat task.wait() until game.JobId ~= game.JobId
        end

       TPReturner()
       if foundAnything ~= "" then
          TPReturner()
       end
       end)
    end
 end

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
    
    LogDebug("Searching for item: " .. itemName)
    for _,item in pairs(game:GetService("Workspace")["Item_Spawns"].Items:GetChildren()) do
        if item:FindFirstChild("MeshPart") and item.ProximityPrompt.ObjectText == itemName then
            if item.ProximityPrompt.MaxActivationDistance == 8 then
                table.insert(ItemsDict["Items"], item.ProximityPrompt.ObjectText)
                table.insert(ItemsDict["ProximityPrompt"], item.ProximityPrompt)
                table.insert(ItemsDict["Position"], item.MeshPart.CFrame)
            else
                LogDebug("Found item with wrong distance: " .. item.ProximityPrompt.ObjectText)
            end
        end
    end
    LogDebug("Found " .. #ItemsDict["Position"] .. " spawns for " .. itemName)
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

    return itemAmount
end

--uses item, use amount to specify what worthiness
local function useItem(aItem, amount)
    local item = LocalPlayer.Backpack:WaitForChild(aItem, 5)

    if not item then
        Teleport()
    end

    if amount then
        LocalPlayer.Character.Humanoid:EquipTool(item)
        -- This line is probably only for arrows, but we'll leave it as per the request to not change logic.
        LocalPlayer.Character:WaitForChild("RemoteFunction"):InvokeServer("LearnSkill",{["Skill"] = "Worthiness",["SkillTreeType"] = "Character"})
        
        -- Activate item and wait for the dialogue GUI
        repeat item:Activate() task.wait() until LocalPlayer.PlayerGui:FindFirstChild("DialogueGui")
        
        -- [FIX] Wait for the Dialogue GUI to fully appear and become interactive.
        local dialogueGui = LocalPlayer.PlayerGui:WaitForChild("DialogueGui", 5)
        if not dialogueGui then Teleport("Dialogue GUI timeout") return end
        
        LogDebug("Dialogue appeared for " .. aItem .. ". Attempting to click through.")
        task.wait(0.3) -- A small delay for stability

        -- Click the first continue button if it's visible.
        local clickContinue = dialogueGui.Frame:FindFirstChild("ClickContinue")
        if clickContinue and clickContinue.Visible then
            firesignal(clickContinue.MouseButton1Click)
            LogDebug("Clicked initial 'Continue'.")
        end
        
        task.wait(0.3) -- Wait for the options to appear

        -- Click the first option if it's visible.
        local optionsFrame = dialogueGui.Frame:FindFirstChild("Options")
        if optionsFrame then
            local option1 = optionsFrame:WaitForChild("Option1", 2)
            if option1 and option1:FindFirstChild("TextButton") and option1.TextButton.Visible then
                firesignal(option1.TextButton.MouseButton1Click)
                LogDebug("Clicked 'Option1'.")
            end
        end

        task.wait(0.3) -- Wait for the next screen to load

        -- Click the next continue button if it's there.
        if clickContinue and clickContinue.Visible then
            firesignal(clickContinue.MouseButton1Click)
            LogDebug("Clicked second 'Continue'.")
        end

        -- [FIX] This part waits for specific text ("You") that likely only appears for Arrows.
        -- For a Rokakaka, this will wait forever and freeze the script.
        -- We'll add a timeout to this wait to prevent it from hanging indefinitely.
        local startTime = tick()
        local textFound = false
        
        -- Wrap in pcall to avoid errors if the UI path doesn't exist immediately.
        pcall(function()
            repeat 
                task.wait()
                -- Check if the GUI still exists. If not, break the loop.
                if not LocalPlayer.PlayerGui:FindFirstChild("DialogueGui") then break end
                -- Check for the text
                if LocalPlayer.PlayerGui.DialogueGui.Frame.DialogueFrame.Frame.Line001.Container.Group001.Text == "You" then
                    textFound = true
                end
            until textFound or (tick() - startTime > 3) -- Wait a max of 3 seconds
        end)
        
        -- Only click the final button if the specific text was found.
        if textFound then
            LogDebug("Arrow-specific text found, clicking final 'Continue'.")
            firesignal(dialogueGui.Frame.ClickContinue.MouseButton1Click)
        else
            LogDebug("Arrow-specific text not found or timed out, skipping final click.")
        end
    end
end

--main function (entrypoint) of standfarm
local function attemptStandFarm()
    LogDebug("Starting Stand Farm Attempt.")
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
    
    if LocalPlayer.PlayerStats.Stand.Value == "None" then
        LogDebug("Stand is None. Using Mysterious Arrow.")
        useItem("Mysterious Arrow", "II")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= "None"
        LogDebug("New Stand: " .. (LocalPlayer.PlayerStats.Stand.Value or "None"))

        if not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            LogDebug("Stand '"..LocalPlayer.PlayerStats.Stand.Value.."' is not desired. Using Rokakaka.")
            useItem("Rokakaka", "II")
        elseif getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
            SendWebhook("Got desirable stand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`", false)
            dontTPOnDeath = true
            Teleport("Successfully obtained desired stand: " .. LocalPlayer.PlayerStats.Stand.Value)
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        LogDebug("Stand '"..LocalPlayer.PlayerStats.Stand.Value.."' is not desired. Using Rokakaka to clear.")
        useItem("Rokakaka", "II")
    end
    LogDebug("Stand farm attempt finished.")
end


--teleport not to get caught
local function getitem(item, itemIndex)
    local gotItem = false
    local timeout = getgenv().waitUntilCollect + 5

    LogDebug("Attempting to collect item at index " .. itemIndex)

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
            LogDebug("ScreenGui not found for item acceptance.")
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
                    LogDebug("Item accepted via ScreenGui.")
                end
            end
        end
    end)
    
    task.spawn(function()
        for i=timeout, 1, -1 do
            task.wait(1)
        end

        if not gotItem then
            LogDebug("Item collection timed out.")
            gotItem = true
            return
        end
    end)


    while not gotItem do
        task.wait()
    end
end

--farm item with said name and amount
local function farmItem(itemName, amount)
    LogDebug("Starting item farm: " .. itemName .. ", target: " .. amount)
    local items = findItem(itemName)
    local initialAmount = countItems(itemName)
    local amountFirst = initialAmount >= amount

    if #items["Position"] == 0 then
        LogDebug("No item spawns found for: " .. itemName .. ". Teleporting.")
        SendWebhook("Farming Warning: No spawn locations found for `" .. itemName .. "`.", "WARN")
        Teleport("No item spawns for " .. itemName)
        return true
    end

    for itemIndex, _ in pairs(items["Position"]) do
        if countItems(itemName) >= amount or amountFirst then
            LogDebug("Target amount reached for: " .. itemName .. ". Breaking farm loop.")
            break
        else
            LogDebug("Collecting item " .. itemIndex .. " of " .. #items["Position"] .. ". Current: " .. countItems(itemName))
            getitem(items, itemIndex)
            task.wait(1)
        end
    end
    
    if countItems(itemName) < amount then
        LogDebug("Failed to reach target amount for: " .. itemName .. ". Current: " .. countItems(itemName) .. ", Target: " .. amount)
        SendWebhook("Farming Warning: Failed to collect target amount of `" .. itemName .. "`. Current: `" .. countItems(itemName) .. "`, Target: `" .. amount .. "`.", "WARN")
    end

    LogDebug("FarmItem routine finished for: " .. itemName)
    return true
end

--// End Dialogue Func //--
local function endDialogue(NPC, Dialogue, Option)
    LogDebug("Ending dialogue for NPC: " .. NPC)
    local dialogueToEnd = {
        ["NPC"] = NPC,
        ["Dialogue"] = Dialogue,
        ["Option"] = Option
     }
    RemoteEvent:FireServer("EndDialogue", dialogueToEnd)
end

--// End Storyline Dialogue Func //--
local function storyDialogue()
    LogDebug("Firing Story Dialogue events.")
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
    LogDebug("Starting killNPC routine for: " .. npcName .. ". Timeout: " .. getgenv().NPCTimeOut .. "s")
 local NPC = workspace.Living:WaitForChild(npcName,getgenv().NPCTimeOut)
 local beingTargeted = true
    local doneKilled = false
 local deadCheck

    if not NPC then
        LogDebug("NPC '" .. npcName .. "' timed out after " .. getgenv().NPCTimeOut .. "s. Teleporting.")
        SendWebhook("NPC Timeout: Could not find `" .. npcName .. "` after `" .. getgenv().NPCTimeOut .. "s`. Rejoining.", true, true)
        Teleport("NPC '" .. npcName .. "' timed out.")
    end

    local function setStandMorphPosition()
        pcall(function()
            -- Проверяем, существует ли еще NPC и его основная часть
            if not NPC or not NPC:FindFirstChild("HumanoidRootPart") then return end

            -- Если у игрока нет стенда, просто перемещаемся к NPC
            if LocalPlayer.PlayerStats.Stand.Value == "None" then
                HRP.CFrame = NPC.HumanoidRootPart.CFrame - Vector3.new(0, 5, 0)
                return
            end

            -- Проверяем, призван ли стенд и существует ли его модель
            local summonedStand = Character:FindFirstChild("SummonedStand")
            local standMorph = Character:FindFirstChild("StandMorph")

            if not summonedStand or not summonedStand.Value or not standMorph then
                -- Если стенд не призван, пытаемся его призвать
                RemoteFunction:InvokeServer("ToggleStand", "Toggle")
                -- Ждем немного, чтобы дать стенду появиться. Это должно предотвратить ошибку.
                task.wait(0.5) 
                return -- Выходим из функции на этой итерации
            end

            -- Убедимся, что у модели стенда есть PrimaryPart
            if standMorph and standMorph.PrimaryPart then
                -- Позиционируем стенд и игрока
                standMorph.PrimaryPart.CFrame = NPC.HumanoidRootPart.CFrame + NPC.HumanoidRootPart.CFrame.lookVector * -1.1
                HRP.CFrame = standMorph.PrimaryPart.CFrame + standMorph.PrimaryPart.CFrame.lookVector - Vector3.new(0, playerDistance, 0)
                
                -- Логика для FocusCam
                if not Character:FindFirstChild("FocusCam") then
                    local FocusCam = Instance.new("ObjectValue", Character)
                    FocusCam.Name = "FocusCam"
                    FocusCam.Value = standMorph.PrimaryPart
                end
                
                if Character:FindFirstChild("FocusCam") and Character.FocusCam.Value ~= standMorph.PrimaryPart then
                    Character.FocusCam.Value = standMorph.PrimaryPart
                end
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
            LogDebug("NPC '" .. npcName .. "' successfully killed.")
            deadCheck:Disconnect()

            if not dontDestroyOnKill then
                NPC:Destroy()
            end
        end
    end)
    
    local startTime = tick()
    local killTimeout = 60 * 5 -- 5 minutes max kill time for error detection

    while beingTargeted do
        task.wait()
        
        -- Stuck/Kill Timeout Check
        if tick() - startTime > killTimeout then
            LogDebug("Kill routine for " .. npcName .. " timed out after 5 minutes. Teleporting.")
            SendWebhook("Stuck/Kill Timeout: Failed to kill `" .. npcName .. "` within 5 minutes. Rejoining.", true, true)
            deadCheck:Disconnect()
            beingTargeted = false
            Teleport("Kill routine timed out.")
        end
        
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
    
    
    LogDebug("Finished killNPC routine for: " .. npcName .. ". Success: " .. tostring(doneKilled))
    return doneKilled
end 

local function checkPrestige(level, prestige)
    if (level == 35 and prestige == 0) or (level == 40 and prestige == 1) or (level == 45 and prestige == 2) then
        LogDebug("Prestige condition met. Current Level: " .. level .. ", Prestige: " .. prestige)
        SendWebhook("@everyone Congratulations you have prestiged!\nTook around `" ..
        string.format("%.2f", (tick() - Data["Time"]) / 60) .. " minutes` or `" .. string.format("%.2f", (tick() - Data["Time"]) / 3600) ..
        " hours` to go from `Prestige " .. Data["Prestige"] .. ", Level " .. Data["Level"] ..
        "`, to `Prestige " .. tostring(prestige + 1) .. ", Level 1!`", false, true
        )
        endDialogue("Prestige", "Dialogue2", "Option1")
        return true
    else
        return false
    end
end

local function allocateSkills() --this should allocate the destructive shit stuff
    LogDebug("Allocating Stand/Spec skills.")
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
        LogDebug("Skill allocation complete.")
    end)
end

local function autoStory()
    LogDebug("Starting autoStory routine. Current Stand: " .. LocalPlayer.PlayerStats.Stand.Value .. ", Level: " .. LocalPlayer.PlayerStats.Level.Value)
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests
    local repeatCount = 0
    allocateSkills()

    if LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Prestige.Value >= 1 and LocalPlayer.Backpack:FindFirstChild("Requiem Arrow") and (LocalPlayer.PlayerStats.Stand.Value == "King Crimson" or LocalPlayer.PlayerStats.Stand.Value == "Star Platinum") and getgenv().autoRequiem then
        LogDebug("Auto Requiem condition met. Using Requiem Arrow.")
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(500, 2010, 500)
        local oldStand = LocalPlayer.PlayerStats.Stand.Value
        SendWebhook("Evolving Stand to Requiem: `" .. oldStand .. "`.", false)
        useItem("Requiem Arrow", "V")
        repeat task.wait() until LocalPlayer.PlayerStats.Stand.Value ~= oldStand
        autoStory()
        return
    end
    

    if LocalPlayer.PlayerStats.Spec.Value == "None" and LocalPlayer.PlayerStats.Level.Value >= 25 then
        LogDebug("Spec is None and Level >= 25. Starting Hamon acquisition.")
        local function collectAndSell(toolName, amount)
            LogDebug("Collecting/Selling item: " .. toolName)
            farmItem(toolName, amount)

LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
            endDialogue("Merchant", "Dialogue5", "Option2")
        end
        
        if not LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            SendWebhook("Farming Caesar's Headband to purchase `Hamon`", false)
            task.wait(10)
            farmItem("Zeppeli's Hat", 1)
        end

        if LocalPlayer.PlayerStats.Money.Value <= 10000 then
            SendWebhook("Collecting $10000 for `Hamon`. Current: $" .. LocalPlayer.PlayerStats.Money.Value, false)
            collectAndSell("Mysterious Arrow", 25)
   collectAndSell("Rokakaka", 25)
   collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end

        if LocalPlayer.Backpack:FindFirstChild("Zeppeli's Hat") then
            SendWebhook("Buying `Hamon`", false)
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
            Teleport("Failed to purchase Hamon, missing hat or dialogue failed.")
        end
        return
    end
        
    while #questPanel:GetChildren() < 2 and repeatCount < 1000 do
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. string.format("%.2f", (tick() - lastTick)) .. " seconds to complete a quest")
            lastTick = tick()
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
        end
    
        LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"})
        storyDialogue()
        task.wait(0.01)
        repeatCount = repeatCount + 1
        LogDebug("Checking quest: " .. repeatCount .. "/1000 attempts.")
    end
    

    if repeatCount >= 1000 then
        LogDebug("STUCK IN QUEST LOOP. Max attempts reached. Teleporting.")
        SendWebhook("Stuck Loop Error: Failed to accept a quest after 1000 attempts. Rejoining.", true, true)
        Teleport("Stuck in quest acceptance loop.")
        return
    end

    local questName = ""
    if #questPanel:GetChildren() > 0 then
        questName = questPanel:GetChildren()[1].Name
    end
    LogDebug("Current Quest Detected: " .. questName)

    if questPanel:FindFirstChild("Help Giorno by Defeating Security Guards") then
        SendWebhook("Killing Security Guard `" .. LocalPlayer.PlayerStats.QuestProgress.Value.."/"..LocalPlayer.PlayerStats.QuestMaxProgress.Value .."`", false)
        if killNPC("Security Guard", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif not getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] and LocalPlayer.PlayerStats.Level.Value >= 3 and dontTPOnDeath then
        LogDebug("No desirable stand. Starting stand farm preparation.")
        task.wait(5)
    
        farmItem("Rokakaka", 25)
        farmItem("Mysterious Arrow", 25)
        farmItem("Zeppeli's Hat", 1)

        if countItems("Mysterious Arrow") >= 25 and countItems("Rokakaka") >= 25 then
            LogDebug("Max arrow and roka collected. Attempting to stand farm.")
            dontTPOnDeath = false
            attemptStandFarm()
        else
            Teleport("Failed to collect enough items for stand farm prep.")
        end
    
    elseif questPanel:FindFirstChild("Defeat Leaky Eye Luca") and getgenv().standList[LocalPlayer.PlayerStats.Stand.Value] then
        SendWebhook("Killing `Leaky Eye Luca`", false)
        if killNPC("Leaky Eye Luca", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Bucciarati") then
        SendWebhook("Killing `Bucciarati`", false)

        if killNPC("Bucciarati", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Collect $5,000 To Cover For Popo's Real Fortune") then
        LogDebug("Quest: Collect $5,000. Current money: " .. LocalPlayer.PlayerStats.Money.Value)
        if LocalPlayer.PlayerStats.Money.Value < 5000 then
            SendWebhook("Collecting `$5000`. Current money: $" .. LocalPlayer.PlayerStats.Money.Value, false)
            local function collectAndSell(toolName, amount)
                if countItems(toolName) <= amount then
                    farmItem(toolName, amount)
                    Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild(toolName))
                    endDialogue("Merchant", "Dialogue5", "Option2")
                end

                if LocalPlayer.PlayerStats.Money.Value < 5000 then
                    storyDialogue()
                    autoStory()
                end
            end
            task.wait(10)
            collectAndSell("Mysterious Arrow", 25)
   collectAndSell("Rokakaka", 25)
   collectAndSell("Diamond", 10)
            collectAndSell("Steel Ball", 10)
            collectAndSell("Quinton's Glove", 10)
            collectAndSell("Pure Rokakaka", 10)
            collectAndSell("Ribcage Of The Saint's Corpse", 10)
            collectAndSell("Ancient Scroll", 10)
            collectAndSell("Clackers", 10)
            collectAndSell("Caesar's headband", 10)
        end
        autoStory()

    elseif questPanel:FindFirstChild("Defeat Fugo And His Purple Haze") then
        SendWebhook("Killing `Fugo`", false)
        if killNPC("Fugo", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Pesci") then
        SendWebhook("Killing `Pesci`", false)
        if killNPC("Pesci", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Ghiaccio") then
        SendWebhook("Killing `Ghiaccio`", false)
        if killNPC("Ghiaccio", 15) then
            task.wait(1)
            storyDialogue()
            autoStory()
        else
            autoStory()
        end

    elseif questPanel:FindFirstChild("Defeat Diavolo") then
        SendWebhook("Killing `Diavolo`", false)
        killNPC("Diavolo", 15)
        endDialogue("Storyline #14", "Dialogue7", "Option1")
        if Character:WaitForChild("Requiem Arrow", 5) then
            LocalPlayer.Character.Humanoid.Health = 0
            Teleport("Killed Diavolo and acquired Requiem Arrow. Rejoining.")
        else
            autoStory()
        end
    
    -- [ИЗМЕНЕНИЕ] Вместо остановки, запускаем фарм денег
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        LogDebug("Final Level 50 check reached. Switching to money farm.")
        SendWebhook(
            "**Prestige 3, Level 50 reached!**" ..
            "\nTime: `" .. string.format("%.2f", (tick() - Data["Time"])/60) .. " minutes or " .. string.format("%.2f", (tick() - Data["Time"])/3600) .. " hours`" ..
            "\nFrom: `Prestige: ".. Data["Prestige"]  .. ", Level " .. Data["Level"] .. "`" ..
            "\nStand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`" ..
            "\nSpec: `" .. LocalPlayer.PlayerStats.Spec.Value .. "`" ..
            "\nAccount: `" .. LocalPlayer.Name .. "`", false, true
        )
        farmMoney() -- Вызываем новую функцию фарма денег
        return -- Выходим из autoStory

    elseif questPanel:FindFirstChild("Take down 3 vampires") and LocalPlayer.PlayerStats.Spec.Value ~= "None" and LocalPlayer.PlayerStats.Level.Value >= 25 and LocalPlayer.PlayerStats.Level.Value ~= 50 then
        getgenv().HamonCharge = 10
        local function vampire()
            LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                if (tick() - lastTick) >= 5 then
                    SendWebhook("Account: " .. LocalPlayer.Name .. "`\nTook around: `".. string.format("%.2f", (tick() - lastTick)) .. " seconds to complete `Vampire Quest`")
                    lastTick = tick()
                end
                endDialogue("William Zeppeli", "Dialogue4", "Option1")
            end
        end
        SendWebhook("Killing `Vampire`", false)
        killNPC("Vampire", 15, false, vampire)
        autoStory()

    -- [ИЗМЕНЕНИЕ] То же самое, что и выше. Это дублирующая проверка в оригинальном коде.
    elseif LocalPlayer.PlayerStats.Level.Value == 50 then
        LogDebug("Final Level 50 check (2) reached. Switching to money farm.")
        SendWebhook(
            "**Prestige 3, Level 50 reached!**" ..
            "\nTime: `" .. string.format("%.2f", (tick() - Data["Time"])/60) .. " minutes or " .. string.format("%.2f", (tick() - Data["Time"])/3600) .. " hours`" ..
            "\nFrom: `Prestige: ".. Data["Prestige"]  .. ", Level " .. Data["Level"] .. "`" ..
            "\nStand: `" .. LocalPlayer.PlayerStats.Stand.Value .. "`" ..
            "\nSpec: `" .. LocalPlayer.PlayerStats.Spec.Value .. "`" ..
            "\nAccount: `" .. LocalPlayer.Name .. "`", false, true
        )
        farmMoney() -- Вызываем новую функцию фарма денег
        return -- Выходим из autoStory
    end
    LogDebug("autoStory end reached.")
end

-- [НОВАЯ ФУНКЦИЯ] Задача 2: Фарм денег
farmMoney = function()
    LogDebug("Target P3 L50 reached. Starting money farm. Target: " .. getgenv().moneyTarget)
    SendWebhook("Prestige 3, Level 50 reached. Starting money farm. Target: $" .. getgenv().moneyTarget, false)
    
    pcall(function()
        delfile("AutoPres3_"..LocalPlayer.Name..".txt")
    end)
    
    if Character:FindFirstChild("FocusCam") then
        Character.FocusCam:Destroy()
    end

    getgenv().HamonCharge = 10 
    local questPanel = LocalPlayer.PlayerGui.HUD.Main.Frames.Quest.Quests

    while LocalPlayer.PlayerStats.Money.Value < getgenv().moneyTarget do
        LogDebug("Money farm loop. Current: " .. LocalPlayer.PlayerStats.Money.Value .. ", Target: " .. getgenv().moneyTarget)
        
        -- Эта функция будет выполняться во время убийства NPC
        local function vampireLoop()
            pcall(function()
                -- Проверяем, существует ли вампир, прежде чем телепортироваться
                if not workspace.Living:FindFirstChild("Vampire") or not workspace.Living.Vampire:FindFirstChild("HumanoidRootPart") then return end
                LocalPlayer.Character.PrimaryPart.CFrame = workspace.Living:FindFirstChild("Vampire").HumanoidRootPart.CFrame - Vector3.new(0, 15, 0)
                
                -- Если квест "Take down 3 vampires" не активен, берем его
                if not questPanel:FindFirstChild("Take down 3 vampires") then
                    if (tick() - lastTick) >= 5 then
                        SendWebhook("Account: " .. LocalPlayer.Name .. "`\nFarming money. Took around: `".. string.format("%.2f", (tick() - lastTick)) .. " seconds to complete `Vampire Quest`", false)
                        lastTick = tick()
                    end
                    endDialogue("William Zeppeli", "Dialogue4", "Option1")
                end
            end)
        end

        -- Если у нас нет квеста, берем его
        if not questPanel:FindFirstChild("Take down 3 vampires") then
            LogDebug("Taking vampire quest for money.")
            endDialogue("William Zeppeli", "Dialogue4", "Option1")
            
            local timeout = 0
            -- Ждем, пока квест не появится
            while not questPanel:FindFirstChild("Take down 3 vampires") and timeout < 50 do
                LocalPlayer.QuestsRemoteFunction:InvokeServer({[1] = "ReturnData"}) -- Обновляем список квестов
                storyDialogue() -- Завершаем любые зависшие диалоги
                task.wait(0.1)
                timeout = timeout + 1
            end
            
            if not questPanel:FindFirstChild("Take down 3 vampires") then
                 LogDebug("Failed to take vampire quest for money. Retrying loop.")
                 task.wait(1)
                 -- 'continue' перезапустит цикл 'while'
                 continue 
            end
        end
        
        -- Если мы здесь, значит, квест есть. Убиваем вампира.
        LogDebug("Killing Vampire for money.")
        SendWebhook("Farming Money: Killing `Vampire`. Current: $" .. LocalPlayer.PlayerStats.Money.Value, false)
        
        -- 'vampireLoop' будет вызван функцией killNPC, чтобы сразу взять квест заново
        killNPC("Vampire", 15, false, vampireLoop)
        
        task.wait(1) -- Небольшая задержка перед следующей проверкой цикла
    end

    -- Цикл завершен
    LogDebug("Money farm target reached: " .. LocalPlayer.PlayerStats.Money.Value)
    SendWebhook("Money farm complete! Target: `$" .. getgenv().moneyTarget .. "` Reached: `$" .. LocalPlayer.PlayerStats.Money.Value .. "`", false, true)
    
    while true do
        LogDebug("Money farm finished. Script idling.")
        task.wait(999999)
    end
end


task.spawn(function()
    while task.wait(3) do
        if checkPrestige(LocalPlayer.PlayerStats.Level.Value, LocalPlayer.PlayerStats.Prestige.Value) then
            LogDebug("Prestiged successfully, rejoining server.")
            Teleport("Prestiged successfully.")
        -- [ИЗМЕНЕНИЕ] Вместо 'break', вызываем фарм денег
        elseif LocalPlayer.PlayerStats.Level.Value == 50 then
            if Character:FindFirstChild("FocusCam") then
                Character.FocusCam:Destroy()
            end
            LogDebug("Prestige checker detected L50. Switching to money farm.")
            farmMoney()
            return -- Выходим из этой задачи (task.spawn)
        else
            LogDebug("Not yet ready to prestige.")
        end
    end
end)

game.Workspace.Living.ChildAdded:Connect(function(character)
    if character.Name == LocalPlayer.Name then
        if LocalPlayer.PlayerStats.Level.Value == 50 then
            LogDebug("Player model added, but Level 50 reached. Not re-triggering logic.")
        else
            LogDebug("Player model added (respawn/rejoin). Checking next step.")
            if dontTPOnDeath then
                Teleport("Respawn/Rejoin detected, restarting script.")
            else
                attemptStandFarm()
            end
        end
    end
end)

LocalPlayer.PlayerStats.Level:GetPropertyChangedSignal("Value"):Connect(function()
    SendWebhook("Account: `" .. LocalPlayer.Name .. "`\nNew level: `" .. LocalPlayer.PlayerStats.Level.Value .. "`\nCurrent prestige: `" .. LocalPlayer.PlayerStats.Prestige.Value .. "`", false)
    LogDebug("Level up detected: " .. LocalPlayer.PlayerStats.Level.Value)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    LogDebug("Character added. Disabling collision on parts.")
    for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
        if child:IsA("BasePart") and child.CanCollide == true then
            child.CanCollide = false
        end
    end
end)

hookfunction(workspace.Raycast, function() -- noclip bypass
    return
end)

autoStory()