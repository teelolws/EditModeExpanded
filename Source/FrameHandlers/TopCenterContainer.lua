local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTopCenterContainer()
    local db = addon.db.global
    if db.EMEOptions.uiWidgetTopCenterContainerFrame then
        addon:registerFrame(UIWidgetTopCenterContainerFrame, L["Subzone Information"], db.UIWidgetTopCenterContainerFrame)
        lib:SetDontResize(UIWidgetTopCenterContainerFrame)
    end
end
