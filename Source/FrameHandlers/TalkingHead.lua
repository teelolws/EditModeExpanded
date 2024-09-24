local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function addon:initTalkingHead()
    local db = addon.db.global
    if db.EMEOptions.talkingHead then
        local function hideDialogKeepSound()
            TalkingHeadFrame:ClearAllPoints()
            TalkingHeadFrame:SetClampedToScreen(false)
            TalkingHeadFrame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -1000, -1000)    
        end
        
        local function hideDialogMuteSound()
            TalkingHeadFrame:Close()
            TalkingHeadFrame:Hide()
        end

        local shouldHideDialog, shouldMuteSound, hideOnlyInCombat
        
        TalkingHeadFrame:HookScript("OnEvent", function(...)
            if hideOnlyInCombat and (not InCombatLockdown()) then
                return
            end
            
            if shouldHideDialog then
                if shouldMuteSound then
                    hideDialogMuteSound()
                else
                    hideDialogKeepSound()
                end
            end
        end)
        
        lib:RegisterResizable(TalkingHeadFrame)
        -- TODO: should be moved to PLAYER_ENTERING_WORLD or something
        C_Timer.After(1, function()
            lib:UpdateFrameResize(TalkingHeadFrame)
        end)
        
        local dropdown, getSettingDB = lib:RegisterDropdown(TalkingHeadFrame, libDD, "HideDD")
        
        libDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local db = getSettingDB()
            local info = libDD:UIDropDownMenu_CreateInfo()        
            
            info.text = "Never"
            info.checked = (db.checked == nil)
            info.func = function()
                db.checked = nil
                shouldHideDialog = nil
                shouldMuteSound = nil
                hideOnlyInCombat = nil
            end
            libDD:UIDropDownMenu_AddButton(info)
            
            info.text = "Dialog only, keep sound"
            info.checked = db.checked == 2
            info.func = function()
                db.checked = 2
                shouldHideDialog = true
                shouldMuteSound = nil
                hideOnlyInCombat = nil
            end
            libDD:UIDropDownMenu_AddButton(info)
            
            info.text = "Always, and mute sound"
            info.checked = db.checked == 3
            info.func = function()
                db.checked = 3
                shouldHideDialog = true
                shouldMuteSound = true
                hideOnlyInCombat = nil
            end
            libDD:UIDropDownMenu_AddButton(info)
            
            info.text = "In Combat, but keep sound"
            info.checked = db.checked == 4
            info.func = function()
                db.checked = 4
                hideOnlyInCombat = true
                shouldHideDialog = true
                shouldMuteSound = nil
            end
            libDD:UIDropDownMenu_AddButton(info)
            
            info.text = "In combat, and mute sound"
            info.checked = db.checked == 5
            info.func = function()
                db.checked = 5
                hideOnlyInCombat = true
                shouldHideDialog = true
                shouldMuteSound = true
            end
            libDD:UIDropDownMenu_AddButton(info)
        end)
        libDD:UIDropDownMenu_SetWidth(dropdown, 100)
        libDD:UIDropDownMenu_SetText(dropdown, "Hide if:")

        C_Timer.After(1, function()
            local db = getSettingDB()
            if db.checked ~= 1 then
                shouldHideDialog = true
            end
            if (db.checked == 3) or (db.checked == 5) then
                shouldMuteSound = true
            end
            if db.checked and (db.checked > 3) then
                hideOnlyInCombat = true
            end
        end)
    end
end
