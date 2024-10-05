local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initGroupLoot()
    local db = addon.db.global
    if not db.EMEOptions.groupLootContainer then return end
    
    local alreadyInitialized
    GroupLootContainer:HookScript("OnShow", function()
        addon:continueAfterCombatEnds(function()
            if alreadyInitialized then
                if GroupLootContainer.system then
                    lib:RepositionFrame(GroupLootContainer)
                end
                return
            end
            alreadyInitialized = true
            lib:RegisterFrame(GroupLootContainer, L["Group Loot Container"], db.GroupLootContainer)
            local noInfinite
            hooksecurefunc(GroupLootContainer, "SetPoint", function()
                if noInfinite then return end
                noInfinite = true
                lib:RepositionFrame(GroupLootContainer)
                noFinite = nil
            end)
            hooksecurefunc("GroupLootContainer_Update", function()
                lib:RepositionFrame(GroupLootContainer)
            end)
            hooksecurefunc(UIParentBottomManagedFrameContainer, "Layout", function()
                lib:RepositionFrame(GroupLootContainer)
            end)
        end)
    end)
end
