local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local libDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

function addon:initMenuBar()
    local db = addon.db.global
    if db.EMEOptions.menu then
        lib:RegisterHideable(MicroMenuContainer)
        lib:RegisterToggleInCombat(MicroMenuContainer)
        C_Timer.After(1, function()
            if lib:IsFrameMarkedHidden(MicroMenuContainer) then
                MicroMenuContainer:Hide()
            end
        end)
        local dropdown, getSettingDB = lib:RegisterDropdown(MicroMenuContainer, libDD, "PaddingDropdown")
        local dropdownOptions = {-4, -3, -2, -1, 0, 1, 2, 3, 4, 5}
        
        local function updatePadding()
           local db = getSettingDB()
           if not db.checked then return end
           
           for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                if key ~= 1 then
                    local a, b, c, d, e = button:GetPoint(1)
                    button:ClearAllPoints()
                    button:SetPoint(a, b, c, (db.checked + button:GetWidth() - 3) * (key-1), e)
                end
            end
            MicroMenu:SetWidth(MicroMenu:GetWidth() - 30)
            MicroMenuContainer:SetWidth(MicroMenu:GetWidth()*MicroMenu:GetScale())
        end
        
        libDD:UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
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
        libDD:UIDropDownMenu_SetText(dropdown, "Button Padding")
        
        C_Timer.After(1, updatePadding)
        
        hooksecurefunc(MicroMenuContainer, "Layout", function(...)
            if OverrideActionBar.isShown then return end
            if PetBattleFrame and PetBattleFrame:IsShown() then return end
            local db = getSettingDB()
            if not db.checked then return end

            -- don't recall what this was for - doesn't seem to be any issues without it now!
            --[[
            if db.checked and ((math.floor((select(4, MicroMenu:GetLayoutChildren()[2]:GetPoint(1))*100) + 0.5)/100) == (math.floor((db.checked*100) + 0.5)/100)) then
                for key, button in ipairs(MicroMenu:GetLayoutChildren()) do
                    if key ~= 1 then
                        local a, b, c, d, e = button:GetPoint(1)
                        button:ClearAllPoints()
                        button:SetPoint(a, b, c, d-(3*(key-1)), e)
                    end
                end
                MicroMenu:SetWidth(MicroMenu:GetWidth() - 30)
            end
            ]]
        end)
        
        lib:RegisterCustomCheckbox(MicroMenuContainer, "Use 10.0 style buttons (requires reload)", addon.EnableSkinMicroMenuBW, addon.DisableSkinMicroMenuBW, "10.0Style")
        lib:RegisterCustomCheckbox(MicroMenuContainer, "Use Shadowlands style buttons (requires reload)", addon.EnableSkinMicroMenuSL, addon.DisableSkinMicroMenuSL, "SLStyle")
    end
    
    if db.EMEOptions.bags then
        lib:RegisterHideable(BagsBar)
        lib:RegisterToggleInCombat(BagsBar)
        C_Timer.After(1, function()
            if lib:IsFrameMarkedHidden(BagsBar) then
                BagsBar:Hide()
            end
        end)
        
        do
            local alreadyInit, noInfinite
            ContainerFrame1:HookScript("OnShow", function()
                if alreadyInit then return end
                alreadyInit = true
                addon:continueAfterCombatEnds(function()
                    
                    -- workaround for bug introduced in 10.2.5
                    -- not sure why its happening, something to do with layout-local.txt
                    -- but trying SetUserPlaced causes an error
                    ContainerFrame1.Bg:SetFrameLevel(0)
                    
                    lib:RegisterFrame(ContainerFrame1, "Main Bag", db.ContainerFrame1)
                    hooksecurefunc("UpdateContainerFrameAnchors", function()
                        if noInfinite then return end
                        if InCombatLockdown() then return end
                        noInfinite = true
                        lib:RepositionFrame(ContainerFrame1)
                        noInfinite = false
                    end)
                end)
            end)
        end
        
        do
            local alreadyInit, noInfinite
            ContainerFrameCombinedBags:HookScript("OnShow", function()
                if alreadyInit then return end
                alreadyInit = true
                addon:continueAfterCombatEnds(function()
                    lib:RegisterFrame(ContainerFrameCombinedBags, "Combined Bags", db.ContainerFrameCombinedBags)
                    hooksecurefunc("UpdateContainerFrameAnchors", function()
                        if noInfinite then return end
                        if InCombatLockdown() then return end
                        noInfinite = true
                        lib:RepositionFrame(ContainerFrameCombinedBags)
                        noInfinite = false
                    end)
                end)
            end)
        end
    end
end
