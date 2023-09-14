local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initAchievementFrame()
    local db = addon.db.global
    
    if not db.EMEOptions.achievementAlert then return end
    
    if ( not AchievementFrame ) then
	AchievementFrame_LoadUI()
    end
    lib:RegisterFrame(AlertFrame, "Achievements", db.Achievements)
    lib:SetDefaultSize(AlertFrame, 20, 20)
    AlertFrame.Selection:HookScript("OnMouseDown", function()
        AchievementAlertSystem:AddAlert(6)
    end)
    AlertFrame:HookScript("OnEvent", function()
        lib:RepositionFrame(AlertFrame)
    end)
end
