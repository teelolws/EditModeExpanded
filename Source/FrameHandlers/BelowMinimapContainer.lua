local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local alreadyLoaded

function addon:initBelowMinimapContainer()
    if alreadyLoaded then return end
    local db = addon.db.global
    if db.EMEOptions.UIWidgetBelowMinimapContainerFrame then
        if UIWidgetBelowMinimapContainerFrame then
            alreadyLoaded = true
            UIWidgetBelowMinimapContainerFrame:SetParent(UIParent)
            lib:RegisterFrame(UIWidgetBelowMinimapContainerFrame, "PvP Objectives", db.UIWidgetBelowMinimapContainerFrame)
            ArenaEnemyFramesContainer:SetParent(UIParent)
            lib:RegisterFrame(ArenaEnemyFramesContainer, "BG Targets", db.ArenaEnemyFramesContainer)
        end
    end
end
