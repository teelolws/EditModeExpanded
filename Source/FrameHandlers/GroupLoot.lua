local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initGroupLoot()
    local db = addon.db.global
    if not db.EMEOptions.groupLootContainer then return end
    
    addon.hookScriptOnce(GroupLootContainer, "OnShow", function()
        addon:continueAfterCombatEnds(function()
            lib:RegisterFrame(GroupLootContainer, L["Group Loot Container"], db.GroupLootContainer)
            hooksecurefunc(GroupLootContainer, "SetPoint", function()
                addon.ResetFrame(GroupLootContainer)
            end)
            hooksecurefunc("GroupLootContainer_Update", function()
                addon.ResetFrame(GroupLootContainer)
            end)
            hooksecurefunc(UIParentBottomManagedFrameContainer, "Layout", function()
                addon.ResetFrame(GroupLootContainer)
            end)
            GroupLootContainer:HookScript("OnShow", function()
                if GroupLootContainer.system then
                    addon.ResetFrame(GroupLootContainer)
                end
            end)
        end)
    end)
end
