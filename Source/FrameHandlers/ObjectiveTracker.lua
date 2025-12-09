local addonName, addon = ...

function addon:initObjectiveTracker()
    local db = addon.db.global
    if db.EMEOptions.objectiveTrackerFrame then
        addon:registerSecureFrameHideable(ObjectiveTrackerFrame)
    end
end
