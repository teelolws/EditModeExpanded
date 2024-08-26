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
        lib:RegisterFrame(GameMenuFrame, "Game Menu", db.GameMenuFrame)
        lib:RegisterResizable(GameMenuFrame)
        lib:HideByDefault(GameMenuFrame)
        GameMenuFrame.Selection:SetFrameStrata("DIALOG")
    end)
end
