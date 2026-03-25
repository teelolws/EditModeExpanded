local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initBattlefieldMap()
    local db = addon.db.global
    if not db.EMEOptions.battlefieldMap then return end
    addon:registerFrame(BattlefieldMapFrame, BATTLEFIELD_MINIMAP, db.BattlefieldMapFrame)
    lib:RegisterResizable(BattlefieldMapFrame)
    lib:HideByDefault(BattlefieldMapFrame)
end
