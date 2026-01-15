local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBelowMinimapContainer()
    local db = addon.db.global
    if db.EMEOptions.UIWidgetBelowMinimapContainerFrame then
        if UIWidgetBelowMinimapContainerFrame then
            UIWidgetBelowMinimapContainerFrame:SetParent(UIParent)
            addon:registerFrame(UIWidgetBelowMinimapContainerFrame, L["PvP Objectives"], db.UIWidgetBelowMinimapContainerFrame)
            lib:RegisterResizable(UIWidgetBelowMinimapContainerFrame)
            ArenaEnemyFramesContainer:SetParent(UIParent)
            addon:registerFrame(ArenaEnemyFramesContainer, L["BG Targets"], db.ArenaEnemyFramesContainer)
        end
    end
end