local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initRaidFrames()
    local db = addon.db.global
    if not db.EMEOptions.compactRaidFrameContainer then return end
    lib:RegisterFrame(CompactRaidFrameManager, "Raid Manager", db.CompactRaidFrameManager, nil, nil, false)
    
    hooksecurefunc("CompactRaidFrameManager_Expand", function()
        if InCombatLockdown() then return end
        CompactRaidFrameManager:ClearPoint("TOPLEFT")
        lib:RepositionFrame(CompactRaidFrameManager)
        local db = lib.framesDB[CompactRaidFrameManager.system]
        if db.positionWasSavedWhileCollapsed then
            for i = 1, CompactRaidFrameManager:GetNumPoints() do
                local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
                x = x + 193
                CompactRaidFrameManager:SetPoint(a,b,c,x,e)
            end
        end
    end)
    hooksecurefunc("CompactRaidFrameManager_Collapse", function()
        if InCombatLockdown() then return end
        CompactRaidFrameManager:ClearPoint("TOPLEFT")
        lib:RepositionFrame(CompactRaidFrameManager)
        local db = lib.framesDB[CompactRaidFrameManager.system]
        if not db.positionWasSavedWhileCollapsed then
            for i = 1, CompactRaidFrameManager:GetNumPoints() do
                local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
                x = x - 193
                CompactRaidFrameManager:SetPoint(a,b,c,x,e)
            end
        end
    end)
    CompactRaidFrameManager.Selection:HookScript("OnDragStop", function()
        local db = lib.framesDB[CompactRaidFrameManager.system]
        db.positionWasSavedWhileCollapsed = CompactRaidFrameManager.collapsed
    end)
    C_Timer.After(1, function()
        if InCombatLockdown() then return end
        local db = lib.framesDB[CompactRaidFrameManager.system]
        if db.positionWasSavedWhileCollapsed and not CompactRaidFrameManager.collapsed then
            for i = 1, CompactRaidFrameManager:GetNumPoints() do
                local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
                x = x + 193
                CompactRaidFrameManager:SetPoint(a,b,c,x,e)
            end
        elseif (not db.positionWasSavedWhileCollapsed) and CompactRaidFrameManager.collapsed then
            for i = 1, CompactRaidFrameManager:GetNumPoints() do
                local a, b, c, x, e = CompactRaidFrameManager:GetPoint(i)
                x = x - 193
                CompactRaidFrameManager:SetPoint(a,b,c,x,e)
            end
        end
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
    
    local partyFrameNamesWereHidden
    lib:RegisterCustomCheckbox(PartyFrame, "Hide Names",
        function()
            for i = 1, 4 do
                PartyFrame["MemberFrame"..i].name:Hide()
            end
            partyFrameNamesWereHidden = true
        end,
        function()
            if not partyFrameNamesWereHidden then return end
            for i = 1, 4 do
                PartyFrame["MemberFrame"..i].name:Show()
            end
            partyFrameNamesWereHidden = false
        end,
        "HidePartyNames"
    )
    
    local showRaidFrameNames
    
    local function updateHideRaidFrameNames()
        for groupID = 1, 8 do
            local group = _G["CompactRaidGroup"..groupID]
            if group then
                for playerID = 1, 5 do
                    local player = _G["CompactRaidGroup"..groupID.."Member"..playerID]
                    if player then
                        player.name:SetShown(showRaidFrameNames)
                    end
                end
            end
        end
    end
                        
    
    lib:RegisterCustomCheckbox(CompactRaidFrameContainer, "Hide Names",
        function()
            showRaidFrameNames = false
            updateHideRaidFrameNames()
        end,
        function()
            showRaidFrameNames = true
            updateHideRaidFrameNames()
        end,
        "HideRaidNames"
    )

    hooksecurefunc("CompactUnitFrame_UpdateName", updateHideRaidFrameNames)
end
