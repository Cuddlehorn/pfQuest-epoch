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

questLogFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_DETAIL" then
        if pfQuest_config["epochAutoAcceptQuests"] then
            AcceptQuest()
        end
    end
end)