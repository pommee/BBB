local function OnPluginLoaded(self, event, addOnName)
    if string.find(addOnName, "BBB") then
        print("|cff00FF00BBB has loaded, type /bbb to open settings|r")
    end
end

local pluginFrame = CreateFrame("Frame")
pluginFrame:RegisterEvent("ADDON_LOADED")
pluginFrame:SetScript("OnEvent", OnPluginLoaded)
