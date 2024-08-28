local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    addon:registerSecureFrameHideable(BossTargetFrameContainer)
    
    if addon.db.global.EMEOptions.showCoordinates then 
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "AttachToSystemFrame", function(self, frame)
            self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
        end)
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "UpdateSettings", function(self, frame)
            self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
        end)
    end

    addon:initAlertFrame()
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
    addon:initGameMenu()
        
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

do
    local once
    EventRegistry:RegisterFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", function()
        if once then return end
        local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
        if layoutInfo.layoutType == 0 then return end
        once = true
        addon:initRaidFrames()
    end)
end

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
    local loading, finished = C_AddOns.IsAddOnLoaded(addonName)
    if not finished then return end
    addon:initBelowMinimapContainer()
end)
