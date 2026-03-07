local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initStatusTrackingBar()
    local db = addon.db.global
    if db.EMEOptions.mainStatusTrackingBarContainer then
        lib:RegisterResizable(MainStatusTrackingBarContainer)
        lib:RegisterHideable(MainStatusTrackingBarContainer)
        lib:RegisterToggleInCombat(MainStatusTrackingBarContainer)
    end
    
    if db.EMEOptions.secondaryStatusTrackingBarContainer then
        lib:RegisterResizable(SecondaryStatusTrackingBarContainer)
        lib:RegisterHideable(SecondaryStatusTrackingBarContainer)
        lib:RegisterToggleInCombat(SecondaryStatusTrackingBarContainer)
    end
end
