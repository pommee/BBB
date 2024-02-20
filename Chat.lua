local CLASS_COLORS = {
    Druid = {r = 1.00, g = 0.49, b = 0.04},
    Hunter = {r = 0.67, g = 0.83, b = 0.45},
    Mage = {r = 0.41, g = 0.80, b = 0.94},
    Paladin = {r = 0.96, g = 0.55, b = 0.73},
    Priest = {r = 1.00, g = 1.00, b = 1.00},
    Rogue = {r = 1.00, g = 0.96, b = 0.41},
    Shaman = {r = 0.0, g = 0.44, b = 0.87},
    Warlock = {r = 0.58, g = 0.51, b = 0.79},
    Warrior = {r = 0.78, g = 0.61, b = 0.43}
}

local BBBWindow = _G["BBBWindow"]
local DUNGEON_NAMES = _G["DUNGEON_NAMES"]
local editBox = _G["EditBox"]
local clearButton = _G["ClearButton"]
local messagesFrame = CreateFrame("Frame")

GroupTable = {}
Content = {}
ScrollFrame = nil

NUM_CELLS = 3
CELL_WIDTH = 250
CELL_HEIGHT = 20

function OnChatMessage(self, event, message, playerName, _, _, _, _, _, _, _, _, _, guid, _, _, _, _, _)
    playerName = string.match(playerName, "([^%-]+)")
    local playerClass, _, playerRace = GetPlayerInfoByGUID(guid)
    local mode = UIDropDownMenu_GetText(_G["BBBDropdownMenuMode"])
    local dungeon = GetAbbreviationByFullName(UIDropDownMenu_GetText(_G["BBBDropdownMenuDungeon"]))
    local selectedModes = _G["SelectedModes"]

    local isLFG = has_value(selectedModes, "LFG")
    local isLFM = has_value(selectedModes, "LFM")
    local isMISC = has_value(selectedModes, "MISC")

    if isLFG or isLFM then
        local selectedMode = has_any_value(message:upper(), selectedModes)

        if selectedMode then
            if ContainsAbbreviation(message:upper(), dungeon) then
                HandleInsertMessage(message, playerName, selectedMode.value, playerClass, playerRace)
            end
        end
    elseif isMISC then
        local searchTerm = editBox:GetText()

        local searchWords = {}
        for word in searchTerm:gmatch("%S+") do
            table.insert(searchWords, word)
        end

        local matchFound = false
        for _, word in ipairs(searchWords) do
            if message:lower():find(word:lower()) then
                matchFound = true
                break
            end
        end

        if matchFound then
            HandleInsertMessage(message, playerName, mode.value, playerClass, playerRace)
        end
    end
end

function HandleInsertMessage(message, playerName, mode, playerClass, playerRace)
    local timestamp = "00:00"
    local tableEntry = {
        timestamp = timestamp,
        player = playerName,
        messageFromPlayer = message,
        mode = mode
    }
    table.insert(GroupTable, tableEntry)
    UpdateList(message, playerName, mode, timestamp, playerClass, playerRace)
end

function UpdateTimestamps()
    local indexToRemove = nil
    for i = 1, #GroupTable do
        if GroupTable[i].timestamp == "00:00" then
            GroupTable[i].timestamp = 0
        end

        local currentTime = GroupTable[i].timestamp + 1
        GroupTable[i].timestamp = currentTime
        local minutes = math.floor(currentTime / 60)
        local seconds = currentTime % 60
        local formattedTime = string.format("%02d:%02d", minutes, seconds)
        Content.rows[i].columns[3]:SetText(formattedTime)

        if currentTime > 120 then -- If the timestamp exceeds 02:00
            indexToRemove = i
        end
    end

    if indexToRemove then
        -- Remove the entry at indexToRemove and bump up other entries
        table.remove(GroupTable, indexToRemove)
        for i = indexToRemove, #Content.rows do
            if Content.rows[i + 1] then
                Content.rows[i].columns[1]:SetText(Content.rows[i + 1].columns[1]:GetText())
                Content.rows[i].columns[2]:SetText(Content.rows[i + 1].columns[2]:GetText())
                Content.rows[i].columns[3]:SetText(Content.rows[i + 1].columns[3]:GetText())
            else
                Content.rows[i]:Hide()
            end
        end
    end
end

function UpdateList(message, playerName, mode, timestamp, playerClass, playerRace)
    local index = #GroupTable
    if not Content.rows[index] then
        local button = CreateFrame("Button", nil, Content)
        button:SetSize(CELL_WIDTH * NUM_CELLS, CELL_HEIGHT)
        button:SetPoint("TOPLEFT", 0, -(index - 1) * CELL_HEIGHT)
        button.columns = {}

        button.columns[1] = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        button.columns[1]:SetPoint("LEFT", 0, 0)

        button.columns[2] = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        button.columns[2]:SetPoint("LEFT", 100, 0)

        button.columns[3] = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        button.columns[3]:SetPoint("LEFT", BBBWindow:GetWidth() - 80, 0)

        button:RegisterForClicks("RightButtonUp")
        button:SetScript(
            "OnClick",
            function(self, buttonClicked)
                if buttonClicked == "RightButton" then
                    ShowRightClickMenu(index)
                end
                if buttonClicked == "LeftButton" then
                    ShowRightClickMenu(index)
                end
            end
        )
        Content.rows[index] = button
    end

    local shortenedMessage = message
    -- If a message is long then shorten it
    if #message > 58 then
        shortenedMessage = message:sub(1, 55) .. "..."
    end

    -- now actually update the contents of the row
    Content.rows[index].columns[1]:SetText(playerName)
    Content.rows[index].columns[2]:SetText(shortenedMessage)
    Content.rows[index].columns[3]:SetText(timestamp)

    SetClassTextColor(playerClass, Content.rows[index].columns[1])

    Content.rows[index]:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(playerName)
            GameTooltip:AddLine(playerClass .. " " .. playerRace)
            GameTooltip:AddLine(message, nil, nil, nil, true)
            GameTooltip:Show()
        end
    )

    Content.rows[index]:SetScript(
        "OnLeave",
        function(self)
            GameTooltip:Hide()
        end
    )

    Content.rows[index]:Show()
    -- hide all extra rows (if list shrunk, hiding leftover)
    for i = #GroupTable + 1, #Content.rows do
        Content.rows[i]:Hide()
    end
end

function ShowRightClickMenu(index)
    local menu = CreateFrame("Frame", "BBBRightClickMenu", UIParent, "UIDropDownMenuTemplate")
    local playername = Content.rows[index].columns[1]:GetText()

    local menuList = {
        {
            text = "Who",
            func = function()
                DEFAULT_CHAT_FRAME.editBox:SetText("/who " .. playername)
                ChatEdit_SendText(DEFAULT_CHAT_FRAME.editBox, 0)
            end
        },
        {
            text = "Whisper",
            func = function()
                ChatFrame_SendTell(playername)
            end
        },
        {
            text = "Invite",
            func = function()
                InviteUnit(playername)
            end
        },
        {
            text = "Ignore",
            func = function()
                C_FriendList.AddIgnore(playername)
            end
        }
    }

    local function InitializeRightClickMenu(self, level)
        for _, option in ipairs(menuList) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.func = option.func
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(menu, InitializeRightClickMenu, "MENU")
    ToggleDropDownMenu(1, nil, menu, "cursor", 0, 0)
end

function ContainsAbbreviation(message, selectedDungeon)
    for abbreviation, fullName in pairs(DUNGEON_NAMES) do
        if string.find(message:upper(), abbreviation) then
            if abbreviation == selectedDungeon:upper() then
                return true, abbreviation, fullName
            end
        end
    end
    return false, nil, nil
end

function GetAbbreviationByFullName(fullName)
    for abbreviation, name in pairs(DUNGEON_NAMES) do
        if name == fullName then
            return abbreviation
        end
    end
    return nil
end

function SetClassTextColor(className, fontString)
    local color = CLASS_COLORS[className]
    if color then
        fontString:SetTextColor(color.r, color.g, color.b)
    else
        fontString:SetTextColor(1.0, 1.0, 1.0)
    end
end

------ INITIALIZING ------
local function initScrollableTable(args)
    if BBBWindow then
        ScrollFrame = CreateFrame("ScrollFrame", "BBBScrollFrame", BBBWindow, "UIPanelScrollFrameTemplate")
        ScrollFrame:SetSize(CELL_WIDTH * NUM_CELLS + 40, 300)
        ScrollFrame:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 10, -60)
        ScrollFrame:SetPoint("BOTTOMRIGHT", BBBWindow, "BOTTOMRIGHT", -30, 10)

        ScrollFrame.scrollChild = CreateFrame("Frame", nil, ScrollFrame)
        ScrollFrame.scrollChild:SetSize(100, 100)
        ScrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
        ScrollFrame:SetScrollChild(ScrollFrame.scrollChild)

        Content = ScrollFrame.scrollChild
        Content.rows = {}
    end
end

messagesFrame:RegisterEvent("CHAT_MSG_CHANNEL")
messagesFrame:SetScript("OnEvent", OnChatMessage)

local updateInterval = 1
local timerFrame = CreateFrame("Frame")
local accumulatedTime = 0
timerFrame:SetScript(
    "OnUpdate",
    function(self, elapsed)
        accumulatedTime = accumulatedTime + elapsed
        if accumulatedTime >= updateInterval then
            UpdateTimestamps()
            accumulatedTime = 0
        end
    end
)

initScrollableTable()

local function RemoveAllEntries()
    if ScrollFrame then
        local scrollChild = ScrollFrame:GetScrollChild()
        if scrollChild then
            for _, row in ipairs(Content.rows) do
                row:Hide()
                row:SetParent(nil)
            end

            wipe(GroupTable)
            wipe(Content.rows)
        end
    end
end

clearButton:SetScript(
    "OnClick",
    function(self)
        RemoveAllEntries()
    end
)

function has_value(tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return val, true
        end
    end

    return false
end

function has_any_value(message, values)
    for _, value in ipairs(values) do
        if message.find(message, value) then
            return value, true
        end
    end

    return false
end
