local BBBWindow = _G["BBBWindow"]
local DUNGEON_NAMES = _G["DUNGEON_NAMES"]
local SoundCheckbox = _G["soundCheckbox"]
local editBox = _G["EditBox"]
local messagesFrame = CreateFrame("Frame")
local CELL_WIDTH = 250
local CELL_HEIGHT = 20
local NUM_CELLS = 3
local GroupTable = {}
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

Content = {}

function OnChatMessage(self, event, message, playerName, _, _, _, _, _, _, _, _, _, guid, _, _, _, _, _)
    local playerClass, _, playerRace = GetPlayerInfoByGUID(guid)
    local mode = UIDropDownMenu_GetText(_G["BBBDropdownMenuMode"])
    local dungeon = GetAbbreviationByFullName(UIDropDownMenu_GetText(_G["BBBDropdownMenuDungeon"]))

    playerName = string.match(playerName, "([^%-]+)")
    if mode == "LFG" or mode == "LFM" then
        if string.find(message:upper(), mode) then
            if ContainsAbbreviation(message:upper(), dungeon) then
                HandleLookingFor(message, playerName, mode, playerClass, playerRace)
            end
        end
    elseif mode == "MISC" then
        local searchTerm = editBox:GetText()

        -- @TODO: Implement so that MISC works
        if message.find(message:lower(), searchTerm) then
            print(message)
        end
    end
end

function HandleLookingFor(message, playerName, mode, playerClass, playerRace)
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
    if #message > 60 then
        shortenedMessage = message:sub(1, 57) .. "..."
    end

    -- now actually update the contents of the row
    Content.rows[index].columns[1]:SetText(playerName)
    SetClassTextColor(playerClass, Content.rows[index].columns[1])
    Content.rows[index].columns[2]:SetText(shortenedMessage)
    Content.rows[index].columns[3]:SetText(timestamp)

    if SoundCheckbox:GetChecked() then
        PlaySoundFile("Interface\\AddOns\\BBB\\Simon.ogg")
    end

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

    -- Define menu options
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
if BBBWindow then
    -- Add a scrollframe (includes basic scrollbar thumb/buttons and functionality)
    local ScrollFrame = CreateFrame("ScrollFrame", "BBBScrollFrame", BBBWindow, "UIPanelScrollFrameTemplate")
    ScrollFrame:SetSize(CELL_WIDTH * NUM_CELLS + 40, 300)
    ScrollFrame:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 10, -60)
    ScrollFrame:SetPoint("BOTTOMRIGHT", BBBWindow, "BOTTOMRIGHT", -30, 10)

    -- Create a scrollChild to contain the content
    ScrollFrame.scrollChild = CreateFrame("Frame", nil, ScrollFrame)
    ScrollFrame.scrollChild:SetSize(100, 100)
    ScrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
    ScrollFrame:SetScrollChild(ScrollFrame.scrollChild)

    Content = ScrollFrame.scrollChild
    Content.rows = {}
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
