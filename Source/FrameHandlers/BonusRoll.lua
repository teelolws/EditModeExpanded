local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBonusRoll()
    local db = addon.db.global
    if db.EMEOptions.bonusRoll then
        local alreadyInitialized = false
        
        BonusRollFrame:HookScript("OnShow", function()
            if alreadyInitialized then
                if BonusRollFrame.system then
                    lib:RepositionFrame(BonusRollFrame)
                end
                return
            end
            alreadyInitialized = true
            addon:continueAfterCombatEnds(function()
                lib:RegisterFrame(BonusRollFrame, L["Bonus Roll"], db.BonusRoll)
                lib:HideByDefault(BonusRollFrame)
                BonusRollFrame.Selection:SetFrameStrata("TOOLTIP")
            end)
        end)
    end
end
