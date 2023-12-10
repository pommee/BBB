local BBBWindow = _G["BBBWindow"]
local DungeonNames = _G["DungeonNames"]
local messagesFrame = CreateFrame("Frame")
local CELL_WIDTH = 250
local CELL_HEIGHT = 20
local NUM_CELLS = 3
local content

local GroupTable = {}

function OnChatMessage(self, event, message, playerName)
    local mode = UIDropDownMenu_GetText(_G["BBBDropdownMenuMode"])
    local dungeon = GetAbbreviationByFullName(UIDropDownMenu_GetText(_G["BBBDropdownMenuDungeon"]))

    playerName = string.match(playerName, "([^%-]+)")
    if mode == "LFG" or mode == "LFM" then
        if string.find(message:upper(), mode) then
            if ContainsAbbreviation(message:upper(), dungeon) then
                HandleLookingFor(message, playerName, mode)
            end
        end
    end
end

function HandleLookingFor(message, playerName, mode)
    local timestamp = date("%H:%M:%S")
    local tableEntry = {
        timestamp = timestamp,
        player = playerName,
        messageFromPlayer = message,
        mode = mode
    }
    table.insert(GroupTable, tableEntry)
    UpdateList(message, playerName, mode, timestamp)
end

function UpdateList(message, playerName, mode, timestamp)
    local index = #GroupTable
    if not content.rows[index] then
        local button = CreateFrame("Button", nil, content)
        button:SetSize(CELL_WIDTH * NUM_CELLS, CELL_HEIGHT)
        button:SetPoint("TOPLEFT", 0, -(index - 1) * CELL_HEIGHT)
        button.columns = {}
        for j = 1, 3 do
            -- 1 = name, 2 = message, 3 = timestamp
            local currentCellWidth
            if j == 1 then
                currentCellWidth = 50
            end
            if j == 2 then
                currentCellWidth = 100
            end
            if j == 3 then
                currentCellWidth = 250
            end
            button.columns[j] = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            button.columns[j]:SetPoint("LEFT", (j - 1) * currentCellWidth, 0)
        end
        content.rows[index] = button
    end

    -- If a message is long then shorten it
    if #message > 60 then
        message = message:sub(1, 57) .. "..."
    end

    -- now actually update the contents of the row
    content.rows[index].columns[1]:SetText(playerName)
    content.rows[index].columns[2]:SetText(message)
    content.rows[index].columns[3]:SetText(timestamp)

    content.rows[index]:Show()
    -- hide all extra rows (if list shrunk, hiding leftover)
    for i = #GroupTable + 1, #content.rows do
        content.rows[i]:Hide()
    end
end

function ContainsAbbreviation(message, selectedDungeon)
    for abbreviation, fullName in pairs(DungeonNames) do
        if string.find(message:upper(), abbreviation) then
            if abbreviation == selectedDungeon:upper() then
                return true, abbreviation, fullName
            end
        end
    end
    return false, nil, nil
end

function GetAbbreviationByFullName(fullName)
    for abbreviation, name in pairs(DungeonNames) do
        if name == fullName then
            return abbreviation
        end
    end
    return nil
end

------ INITIALIZING ------
if BBBWindow then
    -- adding a scrollframe (includes basic scrollbar thumb/buttons and functionality)
    local ScrollFrame = CreateFrame("ScrollFrame", "BBBScrollFrame", BBBWindow, "UIPanelScrollFrameTemplate")
    ScrollFrame:SetSize(CELL_WIDTH * NUM_CELLS + 40, 300)
    ScrollFrame:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 10, -60)
    ScrollFrame:SetPoint("BOTTOMRIGHT", BBBWindow, "BOTTOMRIGHT", -30, 10)

    -- creating a scrollChild to contain the content
    ScrollFrame.scrollChild = CreateFrame("Frame", nil, ScrollFrame)
    ScrollFrame.scrollChild:SetSize(100, 100)
    ScrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
    ScrollFrame:SetScrollChild(ScrollFrame.scrollChild)

    content = ScrollFrame.scrollChild
    content.rows = {}
end

messagesFrame:RegisterEvent("CHAT_MSG_CHANNEL")
messagesFrame:SetScript("OnEvent", OnChatMessage)
