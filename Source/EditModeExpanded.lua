local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:registerSecureFrameHideable(frame)
    local hidden, toggleInCombat, x, y
    
    local function hide()
        if not x then
            x, y = frame:GetLeft(), frame:GetBottom()
        end
        frame:ClearAllPoints()
        frame:SetClampedToScreen(false)
        frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -1000, -1000)
    end
    
    local function show()
        if not x then return end
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
        x, y = nil, nil
    end
    
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_ENABLED", function()
        if not toggleInCombat then return end
        if hidden then
            hide()
        else
            show()
        end
    end)
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_DISABLED", function()
        if not toggleInCombat then return end
        if hidden then
            show()
        else
            hide()
        end
    end)
    
    lib:RegisterCustomCheckbox(frame, "Hide",
        function()
            hidden = true
            if not EditModeManagerFrame.editModeActive then
                hide()
            end
        end,
        function()
            hidden = false
            show()
        end,
        "HidePermanently")
    
    lib:RegisterCustomCheckbox(frame, "Toggle In Combat",
        function()
            toggleInCombat = true
        end,
        function()
            toggleInCombat = false
        end,
        "ToggleInCombat")
    
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
        show()
    end)
    
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if hidden then
            hide()
        end
    end)
    
    hooksecurefunc(frame, "Show", function()
        if InCombatLockdown() then return end
        if hidden then hide() end
    end)
    
    hooksecurefunc(frame, "SetShown", function()
        if InCombatLockdown() then return end
        if hidden then hide() end
    end)
end

EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    if addon.db.global.EMEOptions.showCoordinates then 
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "AttachToSystemFrame", function(self, frame)
            self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
        end)
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "UpdateSettings", function(self, frame)
            self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
        end)
    end

    addon:initAchievementFrame()
    addon:initTargetFrame()    
    addon:initFocusFrame()
    addon:initTargetOfTarget()
    addon:initTargetCastBar()
    addon:initFocusToT()
    addon:initFocusCastBar()    
    addon:initLFG()
    addon:initMinimap()
    addon:initTopCenterContainer()
    addon:initBelowMinimapContainer()    
    addon:initStanceBar()
    addon:initPlayerFrame()    
    addon:initStatusTrackingBar()
    addon:initMenuBar()    
    addon:initBonusRoll()
    addon:initGroupLoot()
    addon:initActionBars()    
    addon:initChatButtons()
    addon:initBuffs()
    addon:initObjectiveTracker()    

        
    local class = UnitClassBase("player")
        
    if class == "PALADIN" then
        addon:initHolyPower()
        -- Consecration
        addon:initTotemFrame()
        
    elseif class == "WARLOCK" then
        addon:initSoulShards()
        -- Summon Darkglare
        addon:initTotemFrame()
        
    elseif class == "SHAMAN" then
        addon:initTotemFrame()
        
    elseif class == "MONK" then
        -- Summon black ox
        addon:initTotemFrame()
        addon:initChiBar()
            
    elseif class == "DEATHKNIGHT" then
        addon:initRunes()
        -- Ghoul
        addon:initTotemFrame()
    
    elseif class == "MAGE" then
        addon:initArcaneCharges()

    elseif class == "EVOKER" then
        addon:initEssences()
            
    elseif class == "ROGUE" then
        addon:initRogueComboPoints()
        
    elseif class == "PRIEST" then
        -- shadowfiend
        addon:initTotemFrame()
        
    elseif class == "DRUID" then
        addon:initDruidComboPoints()
        -- Effloresence
        addon:initTotemFrame()
    end
end)

local editModeLayoutsUpdatedHandle
editModeLayoutsUpdatedHandle = EventRegistry:RegisterFrameEventAndCallbackWithHandle("EDIT_MODE_LAYOUTS_UPDATED", function()
    local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
    if layoutInfo.layoutType == 0 then return end
    editModeLayoutsUpdatedHandle:Unregister()
    addon:initRaidFrames()
end)

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    addon:initOptions()
    addon:initSystemFrames()
    addon:initTalkingHead()
end)

EventUtil.ContinueOnAddOnLoaded("Blizzard_AuctionHouseUI", function()
    local db = addon.db.global
    
    if db.EMEOptions.auctionMultisell then
        local alreadyInitialized
        AuctionHouseMultisellProgressFrame:HookScript("OnShow", function()
            if alreadyInitialized then
                lib:RepositionFrame(AuctionHouseMultisellProgressFrame)
                return
            end
            alreadyInitialized = true
            lib:RegisterFrame(AuctionHouseMultisellProgressFrame, "Auction Multisell", db.AuctionHouseMultisellProgressFrame)
            hooksecurefunc(UIParentBottomManagedFrameContainer, "Layout", function()
                lib:RepositionFrame(AuctionHouseMultisellProgressFrame)
            end)
        end)
    end
end)

EventUtil.ContinueOnAddOnLoaded("Blizzard_UIWidgets", function()
    local loading, finished = IsAddOnLoaded(addonName)
    if not finished then return end
    addon:initBelowMinimapContainer()
end)
