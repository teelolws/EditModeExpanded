local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBonusRoll()
    local db = addon.db.global
    if db.EMEOptions.bonusRoll then
        addon.hookScriptOnce(BonusRollFrame, "OnShow", function()
            addon:continueAfterCombatEnds(function()
                lib:RegisterFrame(BonusRollFrame, L["Bonus Roll"], db.BonusRoll)
                lib:HideByDefault(BonusRollFrame)
                BonusRollFrame.Selection:SetFrameStrata("TOOLTIP")
                BonusRollFrame:HookScript("OnShow", function()
                    if BonusRollFrame.system then
                        addon.ResetFrame(BonusRollFrame)
                    end
                end)
            end)
        end)
    end
end
