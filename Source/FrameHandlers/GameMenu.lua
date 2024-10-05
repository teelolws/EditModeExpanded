local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initGameMenu()
    local db = addon.db.global
    if not db.EMEOptions.gameMenu then return end
    local loaded
    hooksecurefunc(GameMenuFrame, "Layout", function()
        if loaded then return end
        if InCombatLockdown() then return end
        loaded = true
        lib:RegisterFrame(GameMenuFrame, MAINMENU_BUTTON, db.GameMenuFrame)
        lib:RegisterResizable(GameMenuFrame)
        lib:HideByDefault(GameMenuFrame)
        GameMenuFrame.Selection:SetFrameStrata("DIALOG")
    end)
    
    -- issue: edit mode is closed while in combat, the .Select never gets hidden and gets in the way when player opens menu again
    hooksecurefunc(GameMenuFrame, "Show", function()
        --if InCombatLockdown() then return end -- uncomment if issues are reported!
        if not GameMenuFrame.Selection then return end
        if not EditModeManagerFrame:IsEditModeActive() then
            GameMenuFrame.Selection:Hide()
        end
    end)
end
