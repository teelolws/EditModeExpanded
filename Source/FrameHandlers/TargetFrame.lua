local addonName, addon = ...

function addon:initTargetFrame()
    local db = addon.db.global
    if db.EMEOptions.targetFrame then
        addon:registerSecureFrameHideable(TargetFrame)
    end
end
