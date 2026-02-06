local function ExtendPfQuestConfig()
    for _, entry in pairs(pfQuest_defconfig) do
        if entry.config == "epochAutoAcceptQuests" then
            return true
        end
    end

    local settingPosition = 0
    local cnt = 0
    for _, entry in pairs(pfQuest_defconfig) do
        cnt = cnt + 1
        if entry.type == "header" and entry.text =="Map & Minimap" then
            settingPosition = cnt
        end
    end

    table.insert(pfQuest_defconfig, settingPosition, {
        text = "Accept available quests automatically",
        default = "0",
        type = "checkbox",
        config = "epochAutoAcceptQuests"
    })

    if not pfQuest_config["epochAutoAcceptQuests"] then
        pfQuest_config["epochAutoAcceptQuests"] = "0"
    end

    return true
end

local configExtenderFrame = CreateFrame("Frame")
configExtenderFrame:RegisterEvent("VARIABLES_LOADED")
configExtenderFrame:SetScript("OnEvent", function()
    ExtendPfQuestConfig()
end)

local questLogFrame = CreateFrame("Frame")
questLogFrame:RegisterEvent("QUEST_DETAIL")
questLogFrame:RegisterEvent('GOSSIP_SHOW')
questLogFrame:RegisterEvent('QUEST_COMPLETE')
questLogFrame:RegisterEvent('QUEST_FINISHED')
questLogFrame:RegisterEvent('QUEST_GREETING')
questLogFrame:RegisterEvent('QUEST_LOG_UPDATE')
questLogFrame:RegisterEvent('QUEST_PROGRESS')

local function CompleteQuestWithRewards()
    if GetNumQuestChoices() == 0 then
        GetQuestReward()
    end
end

questLogFrame:SetScript("OnEvent", function(self, event, ...)
    print(event)

    if pfQuest_config["epochAutoAcceptQuests"] == "0" then
        return
    end

    if IsShiftKeyDown() then
        return
    end

    if event == "QUEST_PROGRESS" then
        if IsQuestCompletable() then
            CompleteQuest()
        end
    end

    if event == "QUEST_COMPLETE" then
        GetQuestReward(QuestFrameRewardPanel.itemChoice)
    end
    
    if event == "QUEST_GREETING" then
        local numActiveQuests = GetNumActiveQuests()
        for i=1, numActiveQuests do
            local title, completed = GetActiveTitle(i)
            if completed then
                SelectActiveQuest(i)
                CompleteQuestWithRewards()
            end
        end

        -- The quest dialog closes when the quest gets accepted so no need to do this in a loop
        if GetNumAvailableQuests() >= 1 then
            SelectAvailableQuest(1)
        end
    end

    if event == "QUEST_DETAIL" then
        AcceptQuest()
    end

    if event == "GOSSIP_SHOW" then
        if GetNumGossipActiveQuests() > 0 then
            SelectGossipActiveQuest(1)
            OnQuestCompleteEvent()
        end

        -- The quest dialog closes when the quest gets accepted so no need to do this in a loop
        if GetNumGossipAvailableQuests() > 0 then
            SelectGossipAvailableQuest(1)
        end
    end
end)