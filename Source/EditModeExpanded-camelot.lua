local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
    addon:registerSecureFrameHideable(BossTargetFrameContainer)
    
    if addon.db.global.EMEOptions.showCoordinates then
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "AttachToSystemFrame", function(self, frame)
            local left, bottom = frame:GetLeft(), frame:GetBottom()
            if not (issecretvalue(left) or issecretvalue(bottom)) then
                self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end
        end)
        hooksecurefunc(EditModeExpandedSystemSettingsDialog, "UpdateSettings", function(self, frame)
            local left, bottom = frame:GetLeft(), frame:GetBottom()
            if not (issecretvalue(left) or issecretvalue(bottom)) then
                self.Title:SetText(frame:GetSystemName().." ("..math.floor(frame:GetLeft())..","..math.floor(frame:GetBottom())..")")
            end
        end)
    end

    --addon:initAlertFrame()
    addon:initTargetFrame()    
    addon:initFocusFrame()
    addon:initTargetOfTarget()
    addon:initFocusToT()    
    --addon:initLFG()
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
    addon:initChatFrame()
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
    addon:initPersonalResourceDisplay()
end)

EventUtil.RegisterOnceFrameEventAndCallback("EDIT_MODE_LAYOUTS_UPDATED", function()
    local layoutInfo = EditModeManagerFrame:GetActiveLayoutInfo()
    if layoutInfo.layoutType == 0 then return end
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
        addon.hookScriptOnce(AuctionHouseMultisellProgressFrame, "OnShow", function()
            addon:registerFrame(AuctionHouseMultisellProgressFrame, L["Auction Multisell"], db.AuctionHouseMultisellProgressFrame)
            hooksecurefunc(BottomManagedFrameContainer, "Layout", function()
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

EventUtil.ContinueOnAddOnLoaded("Blizzard_BattlefieldMap", addon.initBattlefieldMap)