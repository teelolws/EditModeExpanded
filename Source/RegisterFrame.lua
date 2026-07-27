local addonName, addon = ...

--local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

-- A simple wrapper for lib:RegisterFrame to also call RegisterCoordinates if that option is enabled

function addon:registerFrame(frame, ...)
    local system = frame.system
    lib:RegisterFrame(frame, ...)
    if addon.db.global.EMEOptions.allowSetCoordinates then
        lib:RegisterCoordinates(frame)
    end
    -- don't apply anchor to, to system frames
    if (not system) and addon.db.global.EMEOptions.anchorToEnabled then
        addon.registerAnchorToDropdown(frame)
    end
    
    -- TODO: Code similar to AnchorToDropdown, consolidate and refactor
    if addon.db.global.EMEOptions.reparentEnabled then
        local dropdown, getSettingDB = lib:RegisterDropdown(frame, libDD, "ReparentDropdown")
        
        local function updateFrameParent()
            if InCombatLockdown() then return end
            local db = getSettingDB()
            if db.checked then
                frame:SetParent(_G[db.checked])
            end
        end
        
        libDD:UIDropDownMenu_Initialize(dropdown, function(self) --, level, menuList)
            local db = getSettingDB()
            local info = libDD:UIDropDownMenu_CreateInfo()        
            
            for _, f in ipairs(EditModeManagerFrame.registeredSystemFrames) do
                if frame ~= f then
                    info.text = f:GetName()
                    info.checked = db.checked == f:GetName()
                    info.func = function()
                        if db.checked == f:GetName() then
                            db.checked = nil
                        else
                            db.checked = f:GetName()
                        end
                        updateFrameParent()
                    end
                    libDD:UIDropDownMenu_AddButton(info)
                end
            end
        end)
        libDD:UIDropDownMenu_SetWidth(dropdown, 100)
        libDD:UIDropDownMenu_SetText(dropdown, "Reparent To:")
        
        EventRegistry:RegisterCallback("EDIT_MODE_LAYOUTS_UPDATED", updateFrameParent)
        -- System frames may be loaded in before their profile is loaded
        C_Timer.After(1, updateFrameParent)
        if frame.EMEResetButton then
            frame.EMEResetButton:HookScript("OnClick", function()
                local db = getSettingDB()
                db.checked = false
            end)
        end
    end
end