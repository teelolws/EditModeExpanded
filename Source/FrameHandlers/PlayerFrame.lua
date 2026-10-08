local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPlayerFrame()
    local db = addon.db.global
    if db.EMEOptions.playerFrame then
        addon:registerSecureFrameHideable(PlayerFrame)
        C_Timer.After(4, function()
            addon:continueAfterCombatEnds(function()
                if lib:IsFrameMarkedHidden(PlayerFrame) then
                    if InCombatLockdown() then return end
                    PlayerFrame:Hide()
                    PlayerFrame:SetScript("OnEvent", nil)
                end
            end)
            
            -- From UIParent.lua
            if UpdateUIElementsForClientScene then
                hooksecurefunc("UpdateUIElementsForClientScene", function(sceneType)
                    addon:continueAfterCombatEnds(function()
                        if sceneType == Enum.ClientSceneType.MinigameSceneType then return end
                        if lib:IsFrameMarkedHidden(PlayerFrame) then
                            PlayerFrame:Hide()
                            PlayerFrame:SetScript("OnEvent", nil)
                        end
                    end)
                end)
            end
        end)
        
        
        do 
            local frame = PlayerFrame.manabar
            if PlayerFrame.PlayerFrameContent then
                frame = PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.ManaBarArea
            end
            local x, y
            
            lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Resource Bar"], 
                -- on checked
                function()
                    if InCombatLockdown() then return end
                    if not x then
                        x, y = frame:GetLeft(), frame:GetBottom()
                    end
                    frame:ClearAllPoints()
                    frame:SetClampedToScreen(false)
                    frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -1000, -1000)
                end,
                
                -- on unchecked
                function()
                    if InCombatLockdown() then return end
                    if not x then return end
                    frame:ClearAllPoints()
                    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
                    x, y = nil, nil
                end
            )
        end
        
        if db.EMEOptions.playerFrameResize then
            lib:RegisterResizable(PlayerFrame)
        end
        
        lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Name"],
            function()
                PlayerFrame.name:Hide()
            end,
            function()
                PlayerFrame.name:Show()
            end,
            "HideName"
        )
        
        C_Timer.After(4, function()
            if not PlayerFrame.PlayerFrameContent then return end
            
            local isShown, isInitialized
            lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Icons"],
                function()
                    isShown = false
                    isInitialized = true
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:Hide()
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Hide()
                    if PlayerFrame_ShowPvPIcon then
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle:Hide()
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon:Hide()
                    end
                end,
                function()
                    isShown = true
                    if not isInitialized then
                        isInitialized = true
                        return
                    end
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:Show()
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Show()
                    if PlayerFrame_ShowPvPIcon then
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle:Show()
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon:Show()
                    end
                end,
                "HideIcons"
            )
            
            -- Only exists in Camelot. Retail uses PVPIcon, PrestigeBadge, etc all under PlayerFrameContentContextual.
            -- Watch this space: PvpBackgroundCircle etc may get moved to under Contextual
            if PlayerFrame_ShowPvPIcon then
                hooksecurefunc("PlayerFrame_ShowPvPIcon", function()
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundCircle:SetShown(isShown)
                    PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.PvpBackgroundIcon:SetShown(isShown)
                end)
            end

            lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Level"],
                function()
                    PlayerLevelText:Hide()
                    -- Only exists in Camelot, Retail puts the level to the top right without a circle
                    if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle then
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle:Hide()
                    end
                end,
                function()
                    PlayerLevelText:Show()
                    if PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle then
                        PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.LevelBackgroundCircle:Show()
                    end
                end,
                "HideLevel"
            )
        end)
    end
end
