local BBBWindow = _G["BBBWindow"]

-- Create a frame for the minimap button
local MinimapButton = CreateFrame("Button", "BBBMinimapButton", Minimap)
MinimapButton:SetSize(32, 32)
MinimapButton:SetMovable(true)

-- Set the button's appearance and texture
MinimapButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Map02")
MinimapButton:SetHighlightTexture("Interface\\Minimap\\Artifacts-PerkRing-Final-Mask")

-- Set the button's position on the minimap
MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

-- Set a tooltip for the button
MinimapButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("BBB Window")
        GameTooltip:Show()
    end
)
MinimapButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

-- Set the click action for the button to open your window
MinimapButton:SetScript(
    "OnClick",
    function()
        if BBBWindow:IsShown() then
            BBBWindow:Hide()
        else
            BBBWindow:Show()
        end
    end
)
