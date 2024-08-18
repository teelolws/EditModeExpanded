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
    lib:RegisterResizable(AlertFrame)
    AlertFrame.Selection:HookScript("OnMouseDown", function()
        AchievementAlertSystem:AddAlert(6)
    end)
    AlertFrame:HookScript("OnEvent", function()
        lib:RepositionFrame(AlertFrame)
    end)
    hooksecurefunc(AlertFrame, "SetScaleOverride", function(self, scale)
        for achievementAlertFrame in AchievementAlertSystem.alertFramePool:EnumerateActive() do
            achievementAlertFrame:SetScale(scale)
        end
    end)
    hooksecurefunc(AchievementAlertSystem, "AddAlert", function()
        local scale = AlertFrame:GetScale()
        for achievementAlertFrame in AchievementAlertSystem.alertFramePool:EnumerateActive() do
            achievementAlertFrame:SetScale(scale)
        end
    end)
end
