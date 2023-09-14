local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initObjectiveTracker()
    local db = addon.db.global
    if db.EMEOptions.objectiveTrackerFrame then
        addon:registerSecureFrameHideable(ObjectiveTrackerFrame)
    end
end
