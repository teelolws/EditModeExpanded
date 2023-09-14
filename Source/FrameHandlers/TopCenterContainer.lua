local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initTopCenterContainer()
    local db = addon.db.global
    if db.EMEOptions.uiWidgetTopCenterContainerFrame then
        lib:RegisterFrame(UIWidgetTopCenterContainerFrame, "Subzone Information", db.UIWidgetTopCenterContainerFrame)
        lib:SetDontResize(UIWidgetTopCenterContainerFrame)
    end
end
