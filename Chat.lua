local BBBWindow = _G["BBBWindow"]
local messagesFrame = CreateFrame("Frame")
local ContentFrame
local yOffset = -5
local scrollHeight = 5

GroupTable = {}

function OnChatMessage(self, event, message, playerName)
    local mode = UIDropDownMenu_GetText(_G["BBBDropdownMenu"])
    playerName = string.match(playerName, "([^%-]+)")
    if mode == "LFG" or mode == "LFM" then
        if string.find(message:upper(), mode) then
            local timestamp = date("%H:%M:%S")
            HandleLookingFor(message, playerName, mode, timestamp)
            local tableEntry = {
                timestamp = timestamp,
                player = playerName,
                messageFromPlayer = message,
                mode = mode
            }
            table.insert(GroupTable, tableEntry)
        end
    end
end

function HandleLookingFor(message, playerName, mode, timestamp)
    local line = ContentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    line:SetPoint("TOPLEFT", ContentFrame, "TOPLEFT", 5, yOffset)
    line:SetText(playerName .. " " .. message .. " " .. timestamp)
    line:SetHeight(20)
    yOffset = yOffset - 20
    scrollHeight = scrollHeight + 5

    SetTooltipForLine(line, message)

    for index, entry in ipairs(GroupTable) do
        print("Entry", index)
        print("Player:", entry.player)
        print("Message:", entry.messageFromPlayer)
        print("Mode:", entry.mode)
        print("Timestamp", entry.timestamp)
        print("----------------")
    end
end

-- Function to add a new row to the table display
function AddTableRow(playerName, message, timestamp)
    local rowOffset = (#GroupTable - 1) * 20

    local playerText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    playerText:SetText(playerName)
    playerText:SetPoint("TOPLEFT", ContentFrame, "TOPLEFT", 5, yOffset - rowOffset)
    playerText:SetWidth(150)

    local messageText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    messageText:SetText(message)
    messageText:SetPoint("TOPLEFT", ContentFrame, "TOPLEFT", 155, yOffset - rowOffset)
    messageText:SetWidth(300)

    local timestampText = ContentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    timestampText:SetText(timestamp)
    timestampText:SetPoint("TOPLEFT", ContentFrame, "TOPLEFT", 460, yOffset - rowOffset)
    timestampText:SetWidth(100)

    -- Update the yOffset and scrollHeight variables
    yOffset = yOffset - 20
    scrollHeight = scrollHeight + 20
end

-- Update the displayed rows in the table
function UpdateTableDisplay()
    for index, entry in ipairs(GroupTable) do
        AddTableRow(entry.player, entry.messageFromPlayer, entry.timestamp)
    end
    ContentFrame:SetHeight(scrollHeight)
end

-- Create and set tooltips for the lines
function SetTooltipForLine(line, tooltipText)
    line:SetScript(
        "OnEnter",
        function(self)
            local x, y, _, _, _ = GetCursorPosition()
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + 20, y + 20)
            GameTooltip:SetText(tooltipText)
            GameTooltip:Show()
        end
    )
    line:SetScript(
        "OnLeave",
        function(self)
            GameTooltip:Hide()
        end
    )
end

-- Function to update tooltip location as the mouse moves
function UpdateTooltipPosition()
    local x, y = GetCursorPosition()
    GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x + 20, y + 20)
end

messagesFrame:RegisterEvent("CHAT_MSG_CHANNEL")
messagesFrame:SetScript("OnEvent", OnChatMessage)

if BBBWindow then
    -- Create ScrollFrame inside BBBWindow
    local ScrollFrame = CreateFrame("ScrollFrame", "BBBScrollFrame", BBBWindow, "UIPanelScrollFrameTemplate")
    ScrollFrame:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 10, -60)
    ScrollFrame:SetPoint("BOTTOMRIGHT", BBBWindow, "BOTTOMRIGHT", -30, 10)

    -- Create child frame for the ScrollFrame to hold lines of text (as rows in the table)
    ContentFrame = CreateFrame("Frame", "BBBContentFrame", ScrollFrame)
    ContentFrame:SetSize(ScrollFrame:GetWidth(), scrollHeight)
    ScrollFrame:SetScrollChild(ContentFrame)

    -- Enable scrolling for the ScrollFrame
    ScrollFrame:EnableMouseWheel(true)
    ScrollFrame.ScrollBar:EnableMouseWheel(true)
    ScrollFrame.ScrollBar:SetMinMaxValues(1, ContentFrame:GetHeight() - ScrollFrame:GetHeight())
    ScrollFrame.ScrollBar:SetValueStep(20)
    ScrollFrame:SetScript(
        "OnMouseWheel",
        function(self, delta)
            local scrollMax = ContentFrame:GetHeight() - ScrollFrame:GetHeight()
            local newValue = self.ScrollBar:GetValue() - (delta * 20)

            if newValue < 1 then
                newValue = 1
            elseif newValue > scrollMax then
                newValue = scrollMax
            end

            self.ScrollBar:SetValue(newValue)
        end
    )
else
    print("BBBWindow not found or is nil.")
end
