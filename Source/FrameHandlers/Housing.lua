local addonName, addon = ...

function addon:initHousing()
    local db = addon.db.global
    if not db.EMEOptions.housingControlsFrame then return end
    
    addon.hookScriptOnce(HousingControlsFrame, "OnShow", function()
        addon:continueAfterCombatEnds(function()
            addon:registerFrame(HousingControlsFrame, BINDING_HEADER_HOUSING_SYSTEM, db.HousingControlsFrame)
        end)
    end)
end
