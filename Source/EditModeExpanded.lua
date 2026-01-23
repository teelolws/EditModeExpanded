local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

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
    addon:initTooltip()
    addon:initLossOfControl()
    addon:initPet()
    addon:initExtraActionButton()
    addon:initCooldownManager()
    addon:initTotemFrame()
    addon:initDurationBars()
    addon:initVigorBar()
    addon:initPersonalResourceDisplay()
        
    local class = UnitClassBase("player")
        
    if class == "PALADIN" then
        addon:initHolyPower()
    elseif class == "WARLOCK" then
        addon:initSoulShards()
        
    elseif class == "MONK" then
        addon:initChiBar()
            
    elseif class == "DEATHKNIGHT" then
        addon:initRunes()
    
    elseif class == "MAGE" then
        addon:initArcaneCharges()

    elseif class == "EVOKER" then
        addon:initEssences()
            
    elseif class == "ROGUE" then
        addon:initRogueComboPoints()
        
    elseif class == "DRUID" then
        addon:initDruidComboPoints()

    end
end)

EventUtil.RegisterOnceFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", function()
    local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
    if layoutInfo.layoutType == 0 then return end
    addon:initRaidFrames()
    
    if EditModeManagerExpandedFrame then
        EditModeExpandedWarningFrame:SetParent(EditModeManagerExpandedFrame)
        EditModeExpandedWarningFrame:SetPoint("TOPLEFT", EditModeManagerExpandedFrame, "BOTTOMLEFT", 0, -2)
        EditModeExpandedWarningFrame.ScrollingFont:SetText(L["WARNING_FRAME_TEXT"])
        if EditModeManagerFrame.EnableSnapCheckButton:IsControlChecked() then
            EditModeExpandedWarningFrame:Show()
        end
        hooksecurefunc(EditModeManagerFrame, "SetEnableSnap", function(self, enableSnap)
            if enableSnap then
                EditModeExpandedWarningFrame:Show()
            else
                EditModeExpandedWarningFrame:Hide()
            end
        end)
    end
end)

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    addon:initOptions()
    addon:initSystemFrames()
    addon:initTalkingHead()
end)

EventUtil.ContinueOnAddOnLoaded("Blizzard_AuctionHouseUI", function()
    local db = addon.db.global
    
    if db.EMEOptions.auctionMultisell then
        addon.hookScriptOnce(AuctionHouseMultisellProgressFrame, "OnShow", function()
            addon:registerFrame(AuctionHouseMultisellProgressFrame, L["Auction Multisell"], db.AuctionHouseMultisellProgressFrame)
            hooksecurefunc(UIParentBottomManagedFrameContainer, "Layout", function()
                addon.ResetFrame(AuctionHouseMultisellProgressFrame)
            end)
            AuctionHouseMultisellProgressFrame:HookScript("OnShow", function()
                addon.ResetFrame(AuctionHouseMultisellProgressFrame)
            end)
        end)
    end
end)

EventUtil.ContinueOnAddOnLoaded("Blizzard_UIWidgets", function()
    local _, finished = C_AddOns.IsAddOnLoaded(addonName)
    if not finished then return end
    addon:initBelowMinimapContainer()
end)

EventUtil.ContinueOnAddOnLoaded("Blizzard_HousingControls", addon.initHousing)