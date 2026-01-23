local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPersonalResourceDisplay()
    local db = addon.db.global
    if not db.EMEOptions.personalResourceDisplay then return end
    
    addon:registerFrame(PersonalResourceDisplayFrame.HealthBarsContainer, "Health Bar", db.PersonalResourceDisplayHealth, PersonalResourceDisplayFrame, "TOPLEFT", false)
    lib:SetDontResize(PersonalResourceDisplayFrame.HealthBarsContainer)
    PersonalResourceDisplayFrame.HealthBarsContainer:SetSize(200, 15)
    addon:registerFrame(PersonalResourceDisplayFrame.PowerBar, "Power Bar", db.PersonalResourceDisplayPower, PersonalResourceDisplayFrame, "TOPLEFT", false)
    lib:SetDontResize(PersonalResourceDisplayFrame.PowerBar)
    addon:registerFrame(PersonalResourceDisplayFrame.ClassFrameContainer, "Class Powers", db.PersonalResourceDisplayClass, PersonalResourceDisplayFrame, "TOPLEFT", false)    
end
