local addonName, addon = ...
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function addon:initTargetFrame()
    local db = addon.db.global
    if db.EMEOptions.targetFrame then
        addon:registerSecureFrameHideable(TargetFrame)
        local targetFrameWasHidden
        lib:RegisterCustomCheckbox(TargetFrame, "Hide Name",
            function()
                TargetFrame.name:Hide()
                targetFrameWasHidden = true
            end,
            function()
                if targetFrameWasHidden then
                    TargetFrame.name:Show()
                end
                targetFrameWasHidden = false
            end,
            "HideName"
        )
        
        if db.EMEOptions.targetFrameResize then
            lib:RegisterResizable(TargetFrame)
        end
    end
    
    if db.EMEOptions.targetCast then
        -- As of 12.1, target cast bar and buffs have forbidden aspects, preventing us from getting their coordinates, even after a dragstop
        -- Now have to use a fake frame with the cast bar / buffs anchored to it, instead
        
        local fakeFrame = CreateFrame("Frame", "EMETargetFrameCastbar", TargetFrame)
        fakeFrame:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -40)
        fakeFrame:SetSize(150, 30)
        lib:SetDontResize(fakeFrame)
        addon:registerFrame(fakeFrame, L["TARGET_CAST_BAR"], db.TargetSpellBar, TargetFrame, "TOPLEFT")
        
        local realFrame = TargetFrameSpellBar
        hooksecurefunc(realFrame, "AdjustPosition", function(self)
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
            if EditModeManagerFrame.editModeActive then
                realFrame:Show()
            end
        end)
        realFrame:HookScript("OnShow", function(self)
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        end)
        
        -- TODO: pass fake frame settings down to the real target cast bar
        
        --lib:RegisterResizable(fakeFrame, 10, 500)
        --lib:RegisterHideable(fakeFrame)
        
        --[[
        lib:RegisterSlider(fakeFrame, HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH, "Width",
            function(newValue)
                realFrame:SetWidth(newValue)
            end,
            10, 300, 1)
        lib:RegisterSlider(fakeFrame, HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT, "Height",
            function(newValue)
                realFrame:SetHeight(newValue)
            end,
            1, 50, 1)
        --]]
    end
    
    if db.EMEOptions.targetFrameBuffs then
            
        --addon:registerFrame(TargetFrame:GetAuraContainer(), "Target Buffs", db.TargetBuffs)
        local fakeFrame = CreateFrame("Frame", "EMETargetFrameBuffs", TargetFrame)
        fakeFrame:SetPoint("TOPLEFT", TargetFrame, "BOTTOMLEFT", 5, -10)
        fakeFrame:SetSize(100, 70)
        addon:registerFrame(fakeFrame, "Target Buffs", db.TargetBuffs, TargetFrame, "TOPLEFT")
        
        local realFrame = TargetFrame:GetAuraContainer()
        realFrame:ClearAllPoints()
        realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        
        hooksecurefunc(TargetFrame, "AnchorAuraContainer", function()
            realFrame:ClearAllPoints()
            realFrame:SetPoint("TOPLEFT", fakeFrame, "TOPLEFT")
        end)
    end
end
