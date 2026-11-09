local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function addon:initMenuBar()
    local globaldb = addon.db.global
    if globaldb.EMEOptions.menu then
        addon:registerSecureFrameHideable(MicroMenuContainer)

        local dropdown, getSettingDB = lib:RegisterDropdown(MicroMenuContainer, libDD, "PaddingDropdown")
        local dropdownOptions = {-4, -3, -2, -1, 0, 1, 2, 3, 4, 5}
        
        local function updatePadding()
            local db = getSettingDB()
            if not db.checked then return end
            if MicroMenu.overrideScale then return end
            
            -- local padding = db.checked - 3
            
            if MicroMenu.isHorizontal then
                for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                    if key ~= 1 then
                        local a, b, c, _, e = button:GetPoint(1)
                        button:ClearAllPoints()
                        button:SetPoint(a, b, c, (db.checked + button:GetWidth() - 3) * (key-1), e)
                    end
                end
                
                -- This is a simpler, alternative method I tried. 
                -- Turns out, it spreads taint into Override Actions Bars. Do not use.
                --MicroMenu.childXPadding = padding
                --MicroMenu:Layout()
                --MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
            else
                for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                    if key ~= 1 then
                        local a, b, c, d = button:GetPoint(1)
                        button:ClearAllPoints()
                        button:SetPoint(a, b, c, d, -1 * (db.checked + button:GetHeight() - 3) * (key-1))
                    end
                end
            end
        end
        
        hooksecurefunc(MicroMenuContainer, "Layout", updatePadding)
        
        libDD:UIDropDownMenu_Initialize(dropdown, function(self)
            local db = getSettingDB()
            local info = libDD:UIDropDownMenu_CreateInfo()        
            
            for _, f in ipairs(dropdownOptions) do
                info.text = f
                info.checked = db.checked == f
                info.func = function()
                    if db.checked == f then
                        db.checked = nil
                    else
                        db.checked = f
                    end
                    updatePadding()
                end
                libDD:UIDropDownMenu_AddButton(info)
            end
        end)
        libDD:UIDropDownMenu_SetWidth(dropdown, 100)
        libDD:UIDropDownMenu_SetText(dropdown, HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_PADDING)
        
        C_Timer.After(1, updatePadding)
        
        if addon.EnableSkinMicroMenuBW then
            lib:RegisterCustomCheckbox(MicroMenuContainer, L["MENU_CHECKBOX_DF_BUTTONS_DESCRIPTION"], addon.EnableSkinMicroMenuBW, addon.DisableSkinMicroMenuBW, "10.0Style")
        end
        if addon.EnableSkinMicroMenuSL then
            lib:RegisterCustomCheckbox(MicroMenuContainer, L["MENU_CHECKBOX_SL_BUTTONS_DESCRIPTION"], addon.EnableSkinMicroMenuSL, addon.DisableSkinMicroMenuSL, "SLStyle")
        end
    end
    
    if globaldb.EMEOptions.bags then
        addon:registerSecureFrameHideable(BagsBar)
        
        addon.hookScriptOnce(ContainerFrame1, "OnShow", function()
            addon:continueAfterCombatEnds(function()
                addon:registerFrame(ContainerFrame1, BACKPACK_TOOLTIP, globaldb.ContainerFrame1)
                hooksecurefunc("UpdateContainerFrameAnchors", function()
                    if InCombatLockdown() then return end
                    addon.ResetFrame(ContainerFrame1)
                end)
            end)
        end)
        
        if ContainerFrameCombinedBags then
            addon.hookScriptOnce(ContainerFrameCombinedBags, "OnShow", function()
                addon:continueAfterCombatEnds(function()
                    addon:registerFrame(ContainerFrameCombinedBags, COMBINED_BAG_TITLE, globaldb.ContainerFrameCombinedBags)
                    hooksecurefunc("UpdateContainerFrameAnchors", function()
                        if InCombatLockdown() then return end
                        addon.ResetFrame(ContainerFrameCombinedBags)
                    end)
                end)
            end)
        end
    end
end
