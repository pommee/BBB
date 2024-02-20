local MinimapButton = CreateFrame("Button", "BBBMinimapButton", Minimap)
MinimapButton:SetSize(32, 32)
MinimapButton:SetMovable(true)

MinimapButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Map02")
MinimapButton:SetHighlightTexture("Interface\\Minimap\\Artifacts-PerkRing-Final-Mask")

local maskTexture = MinimapButton:CreateMaskTexture()
maskTexture:SetTexture("Interface\\AddOns\\BBB\\CircularMask")
maskTexture:SetAllPoints(MinimapButton)

MinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

MinimapButton:SetScript(
    "OnEnter",
    function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("BBB Open/Close")
        GameTooltip:Show()
    end
)
MinimapButton:SetScript(
    "OnLeave",
    function()
        GameTooltip:Hide()
    end
)

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
