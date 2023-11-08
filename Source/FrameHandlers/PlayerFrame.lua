local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPlayerFrame()
    local db = addon.db.global
    if db.EMEOptions.playerFrame then
        lib:RegisterHideable(PlayerFrame)
        lib:RegisterToggleInCombat(PlayerFrame)
        C_Timer.After(4, function()
            if lib:IsFrameMarkedHidden(PlayerFrame) then
                PlayerFrame:Hide()
            end
        end)
        
        local checked = false
        lib:RegisterCustomCheckbox(PlayerFrame, "Hide Resource Bar", 
            -- on checked
            function()
                checked = true
                PlayerFrame.manabar:Hide()
            end,
            
            -- on unchecked
            function()
                checked = false
                PlayerFrame.manabar:Show()
            end
        )
        PlayerFrame.manabar:HookScript("OnShow", function()
            if checked then
                PlayerFrame.manabar:Hide()
            end
        end)
        
        if db.EMEOptions.playerFrameResize then
            lib:RegisterResizable(PlayerFrame)
        end
    end
end
