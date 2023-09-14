local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initRaidFrames()
    local db = addon.db.global
    if not db.EMEOptions.compactRaidFrameContainer then return end
    lib:RegisterFrame(CompactRaidFrameManager, "Raid Manager", db.CompactRaidFrameManager, nil, nil, false)
        
    local expanded
    hooksecurefunc("CompactRaidFrameManager_Expand", function()
        if InCombatLockdown() then return end
        if expanded then return end
        expanded = true
        CompactRaidFrameManager:ClearPoint("TOPLEFT")
        lib:RepositionFrame(CompactRaidFrameManager)
        for i = 1, CompactRaidFrameManager:GetNumPoints() do
            local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
            x = x + 175
            CompactRaidFrameManager:SetPoint(a,b,c,x,e)
        end
    end)
    hooksecurefunc("CompactRaidFrameManager_Collapse", function()
        if InCombatLockdown() then return end
        if not expanded then return end
        expanded = false
        CompactRaidFrameManager:ClearPoint("TOPLEFT")
        lib:RepositionFrame(CompactRaidFrameManager)
    end)
    lib:RegisterHideable(CompactRaidFrameManager)
    lib:RegisterToggleInCombat(CompactRaidFrameManager)
    
    -- the wasVisible saved in the library when entering Edit Mode cannot be relied upon, as entering Edit Mode shows the raid manager in some situations, before we can detect if it was already visible
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if InCombatLockdown() then return end
        CompactRaidFrameManager:SetShown(IsInGroup() or IsInRaid())
    end)
    
    local noInfinite
    hooksecurefunc(CompactRaidFrameManager, "SetShown", function()
        if noInfinite then return end
        if InCombatLockdown() then return end
        if EditModeManagerFrame.editModeActive then
            CompactRaidFrameManager:Show()
        else
            noInfinite = true
            lib:RepositionFrame(CompactRaidFrameManager)
            if not (IsInGroup() or IsInRaid()) then
                CompactRaidFrameManager:Hide()
            end
            noInfinite = false
        end
    end)
    hooksecurefunc(CompactRaidFrameManager, "Show", function()
        if noInfinite then return end
        if InCombatLockdown() then return end
        if not EditModeManagerFrame.editModeActive then
            noInfinite = true
            lib:RepositionFrame(CompactRaidFrameManager)
            if not (IsInGroup() or IsInRaid()) then
                CompactRaidFrameManager:Hide()
            end
            noInfinite = false
        end
    end)
end
