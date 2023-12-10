DungeonNames = {
    ["RFC"] = "Ragefire Chasm",
    ["DM"] = "The Deadmines",
    ["WC"] = "Wailing Caverns",
    ["SFK"] = "Shadowfang Keep",
    ["STK"] = "The Stockade",
    ["BFD"] = "Blackfathom Deeps",
    ["GNO"] = "Gnomeregan",
    ["RFK"] = "Razorfen Kraul",
    ["SM2"] = "Scarlet Monastery",
    ["SMG"] = "Scarlet Monastery: Graveyard",
    ["SML"] = "Scarlet Monastery: Library",
    ["SMA"] = "Scarlet Monastery: Armory",
    ["SMC"] = "Scarlet Monastery: Cathedral",
    ["RFD"] = "Razorfen Downs",
    ["ULD"] = "Uldaman",
    ["ZF"] = "Zul'Farrak",
    ["MAR"] = "Maraudon",
    ["ST"] = "The Sunken Temple",
    ["BRD"] = "Blackrock Depths",
    ["DM2"] = "Dire Maul",
    ["DME"] = "Dire Maul: East",
    ["DMN"] = "Dire Maul: North",
    ["DMW"] = "Dire Maul: West",
    ["STR"] = "Stratholme",
    ["SCH"] = "Scholomance",
    ["LBRS"] = "Lower Blackrock Spire",
    ["UBRS"] = "Upper Blackrock Spire (10)",
    ["RAMPS"] = "Hellfire Citadel: Ramparts",
    ["BF"] = "Hellfire Citadel: Blood Furnace",
    ["SP"] = "Coilfang Reservoir: Slave Pens",
    ["UB"] = "Coilfang Reservoir: Underbog",
    ["MT"] = "Auchindoun: Mana Tombs",
    ["CRYPTS"] = "Auchindoun: Auchenai Crypts",
    ["SETH"] = "Auchindoun: Sethekk Halls",
    ["OHB"] = "Caverns of Time: Old Hillsbrad",
    ["MECH"] = "Tempest Keep: The Mechanar",
    ["BM"] = "Caverns of Time: Black Morass",
    ["MGT"] = "Magisters' Terrace",
    ["SH"] = "Hellfire Citadel: Shattered Halls",
    ["BOT"] = "Tempest Keep: Botanica",
    ["SL"] = "Auchindoun: Shadow Labyrinth",
    ["SV"] = "Coilfang Reservoir: Steamvault",
    ["ARC"] = "Tempest Keep: The Arcatraz",
    ["KARA"] = "Karazhan",
    ["GL"] = "Gruul's Lair",
    ["MAG"] = "Hellfire Citadel: Magtheridon's Lair",
    ["SSC"] = "Coilfang Reservoir: Serpentshrine Cavern",
    ["UK"] = "Utgarde Keep",
    ["NEX"] = "The Nexus",
    ["AZN"] = "Azjol-Nerub",
    ["ANK"] = "Ahn’kahet: The Old Kingdom",
    ["DTK"] = "Drak’Tharon Keep",
    ["VH"] = "Violet Hold",
    ["GD"] = "Gundrak",
    ["HOS"] = "Halls of Stone",
    ["HOL"] = "Halls of Lightning",
    ["COS"] = "The Culling of Stratholme",
    ["OCC"] = "The Oculus",
    ["UP"] = "Utgarde Pinnacle",
    ["FOS"] = "Forge of Souls",
    ["POS"] = "Pit of Saron",
    ["HOR"] = "Halls of Reflection",
    ["CHAMP"] = "Trial of the Champion",
    ["NAXX"] = "Naxxramas",
    ["OS"] = "Obsidian Sanctum",
    ["VOA"] = "Vault of Archavon",
    ["EOE"] = "Eye of Eternity",
    ["ULDAR"] = "Ulduar",
    ["TOTC"] = "Trial of the Crusader",
    ["RS"] = "Ruby Sanctum",
    ["ICC"] = "Icecrown Citadel",
    ["EYE"] = "Tempest Keep: The Eye",
    ["ZA"] = "Zul-Aman",
    ["HYJAL"] = "The Battle For Mount Hyjal",
    ["BT"] = "Black Temple",
    ["SWP"] = "Sunwell Plateau",
    ["ONY"] = "Onyxia's Lair (40)",
    ["MC"] = "Molten Core (40)",
    ["ZG"] = "Zul'Gurub (20)",
    ["AQ20"] = "Ruins of Ahn'Qiraj (20)",
    ["BWL"] = "Blackwing Lair (40)",
    ["AQ40"] = "Temple of Ahn'Qiraj (40)",
    ["NAX"] = "Naxxramas (40)",
    ["WSG"] = "Warsong Gulch (PvP)",
    ["AB"] = "Arathi Basin (PvP)",
    ["AV"] = "Alterac Valley (PvP)",
    ["EOTS"] = "Eye of the Storm (PvP)",
    ["SOTA"] = "Stand of the Ancients (PvP)",
    ["WG"] = "Wintergrasp (PvP)",
    ["ARENA"] = "Arena (PvP)",
    ["MISC"] = "Miscellaneous",
    ["TRADE"] = "Trade",
    ["DEBUG"] = "DEBUG INFO",
    ["BAD"] = "DEBUG BAD WORDS - REJECTED",
    ["BREW"] = "Brewfest - Coren Direbrew",
    ["HOLLOW"] = "Hallow's End - Headless Horseman"
}

-- Window --
local BBBWindow = CreateFrame("Frame", "BBBWindow", UIParent, "UIPanelDialogTemplate")
BBBWindow:SetPoint("CENTER")
BBBWindow:SetSize(600, 500)
BBBWindow:SetMovable(true)
BBBWindow:EnableMouse(true)
BBBWindow:SetClampedToScreen(true)
BBBWindow:SetFrameStrata("DIALOG")

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

-- Title
BBBWindow.title = BBBWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
BBBWindow.title:SetPoint("TOP", BBBWindow, 0, -10)
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

    for abbreviation, fullName in pairs(DungeonNames) do
        info.text = fullName
        info.value = abbreviation
        info.func = function()
            UIDropDownMenu_SetText(DropdownMenuDungeon, fullName)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

UIDropDownMenu_Initialize(DropdownMenuDungeon, InitializeDungeonDropdownMenu)
UIDropDownMenu_SetText(DropdownMenuDungeon, "Ragefire Chasm")

-- Show window
BBBWindow:Show()
