DUNGEON_NAMES = {
    ["RFC"] = "Ragefire Chasm",
    ["WC"] = "Wailing Caverns",
    ["DM"] = "Deadmines",
    ["SFK"] = "Shadowfang Keep",
    ["BFD"] = "Blackfathom Deeps",
    ["Stocks"] = "Stockade",
    ["Gnomer"] = "Gnomeregan",
    ["RFK"] = "Razorfen Kraul",
    ["RFD"] = "Razorfen Downs"
}

-- Window --
BBBWindow = CreateFrame("Frame", "BBBWindow", UIParent, "BasicFrameTemplateWithInset")
BBBWindow:SetPoint("CENTER")
BBBWindow:SetResizeBounds(540, 300, 600, 500)
BBBWindow:SetMovable(true)
BBBWindow:EnableMouse(true)
BBBWindow:SetResizable(true)
BBBWindow:SetClampedToScreen(true)
BBBWindow:SetFrameStrata("FULLSCREEN_DIALOG")

BBBWindow:SetScript(
    "OnMouseDown",
    function(self, button)
        if button == "LeftButton" then
            self:StartSizing("BOTTOMRIGHT")
            self:SetUserPlaced(true)
        end
    end
)

BBBWindow:SetScript(
    "OnMouseUp",
    function(self, button)
        self:StopMovingOrSizing()
    end
)

-- Titlebar --
BBBWindow.titleBar = CreateFrame("Frame", nil, BBBWindow)
BBBWindow.titleBar:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 0, 0)
BBBWindow.titleBar:SetPoint("TOPRIGHT", BBBWindow, "TOPRIGHT", 0, 0)
BBBWindow.titleBar:SetHeight(25)
BBBWindow.titleBar:EnableMouse(true)
BBBWindow.titleBar:SetScript(
    "OnMouseDown",
    function(self, button)
        if button == "LeftButton" then
            BBBWindow:StartMoving()
        end
    end
)
BBBWindow.titleBar:SetScript(
    "OnMouseUp",
    function(self, button)
        if button == "LeftButton" then
            BBBWindow:StopMovingOrSizing()
        end
    end
)

BBBWindow:SetScript(
    "OnSizeChanged",
    function()
        local Content = _G["Content"]
        -- Update the widths of the columns for each existing row
        for index = 1, #Content.rows do
            Content.rows[index].columns[1]:SetPoint("LEFT", 0, 0)
            Content.rows[index].columns[2]:SetPoint("LEFT", 100, 0)
            Content.rows[index].columns[3]:SetPoint("LEFT", BBBWindow:GetWidth() - 80, 0)
        end
    end
)

-- Title
BBBWindow.title = BBBWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
BBBWindow.title:SetPoint("TOP", BBBWindow, 0, -5)
BBBWindow.title:SetText("BBB (Better Bulletin Board)")

-- (Mode) Create a frame for the dropdown menu
local DropdownMenuMode = CreateFrame("Frame", "BBBDropdownMenuMode", BBBWindow, "UIDropDownMenuTemplate")
DropdownMenuMode:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", -5, -30)
DropdownMenuMode:SetSize(100, 30)

-- (Mode) Dropdown menu initialization function
local function InitializeModeDropdownMenu(self, level)
    local info = UIDropDownMenu_CreateInfo()

    info.text = "LFG"
    info.value = "Looking For Group"
    info.func = function()
        UIDropDownMenu_SetText(DropdownMenuMode, "LFG")
    end
    UIDropDownMenu_AddButton(info, level)

    info.text = "LFM"
    info.value = "Looking For More"
    info.func = function()
        UIDropDownMenu_SetText(DropdownMenuMode, "LFM")
    end
    UIDropDownMenu_AddButton(info, level)

    info.text = "MISC"
    info.value = "MISC"
    info.func = function()
        UIDropDownMenu_SetText(DropdownMenuMode, "MISC")
    end
    UIDropDownMenu_AddButton(info, level)
end

UIDropDownMenu_Initialize(DropdownMenuMode, InitializeModeDropdownMenu)
UIDropDownMenu_SetText(DropdownMenuMode, "LFG")

-- (Dungeon) Create a frame for the dropdown menu
local DropdownMenuDungeon = CreateFrame("Frame", "BBBDropdownMenuDungeon", BBBWindow, "UIDropDownMenuTemplate")
DropdownMenuDungeon:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 140, -30)
DropdownMenuDungeon:SetSize(150, 30)

-- (Dungeon) Dropdown menu initialization function
local function InitializeDungeonDropdownMenu(self, level)
    local info = UIDropDownMenu_CreateInfo()

    for abbreviation, fullName in pairs(DUNGEON_NAMES) do
        info.text = fullName
        info.value = abbreviation
        info.func = function()
            UIDropDownMenu_SetText(DropdownMenuDungeon, fullName)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(DropdownMenuDungeon, InitializeDungeonDropdownMenu)
UIDropDownMenu_SetText(DropdownMenuDungeon, "Blackfathom Deeps")

soundCheckbox = CreateFrame("CheckButton", "BBBSoundCheckbox", BBBWindow, "UICheckButtonTemplate")
soundCheckbox:SetPoint("TOPLEFT", BBBWindow, "TOPLEFT", 300, -30)

local soundCheckboxTooltip = CreateFrame("GameTooltip", "BBBSoundCheckboxTooltip", nil, "GameTooltipTemplate")

-- Set tooltip script for OnEnter and OnLeave events
soundCheckbox:SetScript(
    "OnEnter",
    function()
        soundCheckboxTooltip:ClearAllPoints()
        soundCheckboxTooltip:SetOwner(soundCheckbox, "ANCHOR_RIGHT")
        soundCheckboxTooltip:SetText("On message play sound")
        soundCheckboxTooltip:Show()
    end
)
soundCheckbox:SetScript(
    "OnLeave",
    function()
        soundCheckboxTooltip:Hide()
    end
)

EditBox = CreateFrame("EditBox", "MyEditBox", BBBWindow, "InputBoxTemplate")
EditBox:SetSize(150, -30)
EditBox:SetPoint("TOP", 150, -60)
EditBox:SetAutoFocus(false)
EditBox:SetFontObject(GameFontNormal)
EditBox:SetText("Type here...")

EditBox:SetScript(
    "OnEnterPressed",
    function(self)
        self:ClearFocus()
    end
)

EditBox:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Custom search term in mischelaneous mode")
        GameTooltip:Show()
    end
)

EditBox:SetScript(
    "OnLeave",
    function(self)
        GameTooltip:Hide()
    end
)

-- Show window
BBBWindow:Show()

-- Hide sound tooltip / visible on startup for some reason
soundCheckboxTooltip:Hide()
