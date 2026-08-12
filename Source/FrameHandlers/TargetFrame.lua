local addonName, addon = ...
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTargetFrame()
    local db = addon.db.global
    if db.EMEOptions.targetFrame then
        addon:registerSecureFrameHideable(TargetFrame)
        local targetFrameWasHidden
        lib:RegisterCustomCheckbox(TargetFrame, "Hide Name",
            function()
                TargetFrame.name:Hide()
                targetFrameWasHidden = true
            end,
            function()
                if targetFrameWasHidden then
                    TargetFrame.name:Show()
                end
                targetFrameWasHidden = false
            end,
            "HideName"
        )
        
        if db.EMEOptions.targetFrameResize then
            lib:RegisterResizable(TargetFrame)
        end
    end
end
