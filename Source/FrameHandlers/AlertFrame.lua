local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local function resetScales()
    local scale = AlertFrame:GetScale()
    for _, alertSystem in pairs(AlertFrame.alertFrameSubSystems) do
        if alertSystem.alertFramePool then
            for achievementAlertFrame in alertSystem.alertFramePool:EnumerateActive() do
                achievementAlertFrame:SetParent(UIParent)
                achievementAlertFrame:SetScale(scale)
            end
        end
    end
end

function addon:initAlertFrame()
    local db = addon.db.global
    
    if not db.EMEOptions.achievementAlert then return end
    
    if ( not AchievementFrame ) then
        AchievementFrame_LoadUI()
    end
    lib:RegisterFrame(AlertFrame, L["Alert"], db.Achievements)
    lib:SetDefaultSize(AlertFrame, 20, 20)
    lib:RegisterResizable(AlertFrame)
    AlertFrame.Selection:HookScript("OnMouseDown", function()
        AchievementAlertSystem:AddAlert(6)
    end)
    AlertFrame:HookScript("OnEvent", function()
        addon.ResetFrame(AlertFrame)
    end)
    hooksecurefunc(AlertFrame, "SetScaleOverride", resetScales)
    hooksecurefunc(AlertFrame, "ReparentAlerts", resetScales)
    hooksecurefunc(AlertFrame, "UpdateAnchors", resetScales)
end
