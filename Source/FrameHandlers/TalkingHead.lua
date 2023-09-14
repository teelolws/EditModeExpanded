local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTalkingHead()
    local db = addon.db.global
    if db.EMEOptions.talkingHead then
        lib:RegisterHideable(TalkingHeadFrame)
        lib:RegisterToggleInCombat(TalkingHeadFrame)
        TalkingHeadFrame:HookScript("OnEvent", function(...)
            if lib:IsFrameMarkedHidden(TalkingHeadFrame) then
                TalkingHeadFrame:Close()
                TalkingHeadFrame:Hide()
            end
        end)
        lib:RegisterResizable(TalkingHeadFrame)
        -- TODO: should be moved to PLAYER_ENTERING_WORLD or something
        C_Timer.After(1, function()
            lib:UpdateFrameResize(TalkingHeadFrame)
        end)
    end
end
