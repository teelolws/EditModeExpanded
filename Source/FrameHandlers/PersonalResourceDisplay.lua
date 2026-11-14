local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:initPersonalResourceDisplay()
    local db = addon.db.global
    if not db.EMEOptions.personalResourceDisplay then return end
    
    addon:registerFrame(PersonalResourceDisplayFrame.HealthBarsContainer, L["Health Bar"], db.PersonalResourceDisplayHealth, PersonalResourceDisplayFrame, "TOPLEFT", false)
    lib:SetDontResize(PersonalResourceDisplayFrame.HealthBarsContainer)
    addon:registerFrame(PersonalResourceDisplayFrame.PowerBar, L["Power Bar"], db.PersonalResourceDisplayPower, PersonalResourceDisplayFrame, "TOPLEFT", false)
    lib:SetDontResize(PersonalResourceDisplayFrame.PowerBar)
    if PersonalResourceDisplayFrame.ClassFrameContainer then
        if PersonalResourceDisplayFrame.ClassFrameContainer:IsShown() then
            addon:registerFrame(PersonalResourceDisplayFrame.ClassFrameContainer, L["Class Powers"], db.PersonalResourceDisplayClass, PersonalResourceDisplayFrame, "TOPLEFT", false)
            lib:SetDontResize(PersonalResourceDisplayFrame.ClassFrameContainer)
        else
            addon.hookScriptOnce(PersonalResourceDisplayFrame.ClassFrameContainer, "OnShow", function()
                addon:registerFrame(PersonalResourceDisplayFrame.ClassFrameContainer, L["Class Powers"], db.PersonalResourceDisplayClass, PersonalResourceDisplayFrame, "TOPLEFT", false)
                lib:SetDontResize(PersonalResourceDisplayFrame.ClassFrameContainer)
            end)
        end
    end
end
