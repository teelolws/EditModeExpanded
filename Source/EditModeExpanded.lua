local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED" and arg1 == "EditModeExpanded") then
        if not EditModeExpandedDB then EditModeExpandedDB = {} end
        if not EditModeExpandedDB.MicroButtonAndBagsBar then EditModeExpandedDB.MicroButtonAndBagsBar = {} end
        if not EditModeExpandedDB.StatusTrackingBarManager then EditModeExpandedDB.StatusTrackingBarManager = {} end
        if not EditModeExpandedDB.QueueStatusButton then EditModeExpandedDB.QueueStatusButton = {} end
        if not EditModeExpandedDB.TotemFrame then EditModeExpandedDB.TotemFrame = {} end

        lib:RegisterFrame(MicroButtonAndBagsBar, "Micro Menu", EditModeExpandedDB.MicroButtonAndBagsBar)
        lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", EditModeExpandedDB.StatusTrackingBarManager)
        lib:RegisterFrame(QueueStatusButton, "LFG", EditModeExpandedDB.QueueStatusButton)
        
        lib:RegisterFrame(TotemFrame, "Totem Frame", EditModeExpandedDB.TotemFrame)
        lib:SetDefaultSize(TotemFrame, 100, 40)
    end
end)

f:RegisterEvent("ADDON_LOADED")