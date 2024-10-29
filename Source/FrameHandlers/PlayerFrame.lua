local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPlayerFrame()
    local db = addon.db.global
    if db.EMEOptions.playerFrame then
        lib:RegisterHideable(PlayerFrame, PlayerFrame_OnEvent)
        lib:RegisterToggleInCombat(PlayerFrame)
        C_Timer.After(4, function()
            addon:continueAfterCombatEnds(function()
                if lib:IsFrameMarkedHidden(PlayerFrame) then
                    if InCombatLockdown() then return end
                    PlayerFrame:Hide()
                    PlayerFrame:SetScript("OnEvent", nil)
                end
            end)
            
            -- From UIParent.lua
            hooksecurefunc("UpdateUIElementsForClientScene", function(sceneType)
                addon:continueAfterCombatEnds(function()
                    if sceneType == Enum.ClientSceneType.MinigameSceneType then return end
                    if lib:IsFrameMarkedHidden(PlayerFrame) then
                        PlayerFrame:Hide()
                        PlayerFrame:SetScript("OnEvent", nil)
                    end
                end)
            end)
        end)
        
        
        do 
            local frame = PlayerFrame.manabar
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
        
        lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Icons"],
            function()
                PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:Hide()
                PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Hide()
            end,
            function()
                PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual:Show()
                PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:Show()
            end,
            "HideIcons"
        )
        
        C_Timer.After(4, function()
            lib:RegisterCustomCheckbox(PlayerFrame, L["Hide Level"],
                function()
                    PlayerLevelText:Hide()
                end,
                function()
                    PlayerLevelText:Show()
                end,
                "HideLevel"
            )
        end)
    end
end
