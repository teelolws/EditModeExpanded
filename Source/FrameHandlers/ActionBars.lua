local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initActionBars()
    local db = addon.db.global
    if not db.EMEOptions.actionBars then return end
        
    addon:continueAfterCombatEnds(function() 
        local bars = {MainActionBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7}

        for _, bar in ipairs(bars) do
            
            --[[
            -- setting.buttonPadding causes taint to spread and cause issues
            -- another method needed, if its even possible
            lib:RegisterCustomCheckbox(bar, "Override Icon Padding to Zero", 
                -- on checked
                function()
                    bar.minButtonPadding = 0
                    bar.buttonPadding = 0
                    bar:UpdateGridLayout()
                end,
                
                -- on unchecked
                function()
                    bar.minButtonPadding = 2
                    bar.buttonPadding = 2
                    bar:UpdateGridLayout()
                end,
                
                "OverrideIconPadding"
            )
            --]]
            
            addon:registerSecureFrameHideable(bar)
            
            local alreadyHidden
            lib:RegisterCustomCheckbox(bar, L["ACTION_BARS_CHECKBOX_HIDE_NAMES_DESCRIPTION"],
                function()
                    for _, button in pairs(bar.actionButtons) do
                        button.Name:Hide()
                        button.HotKey:Hide()
                    end
                    alreadyHidden = true
                end,
                function()
                    if not alreadyHidden then return end
                    for _, button in pairs(bar.actionButtons) do
                        button.Name:Show()
                        button.HotKey:Show()
                    end
                    alreadyHidden = false
                end,
                "HideMacroName"
            )
            
            local namesSize = 1

            local function updateNamesSizes()
                for _, button in pairs(bar.actionButtons) do
                    button.HotKey:SetScale(namesSize)
                    button.Count:SetScale(namesSize)
                    button.Name:SetScale(namesSize)
                end
            end

            lib:RegisterSlider(bar, "Name Scale", "Name Scale",
                function(newValue)
                    namesSize = newValue
                    updateNamesSizes()
                end,
                0.5, 2, 0.05)
            hooksecurefunc("CompactUnitFrame_UpdateName", updateNamesSizes)
            
            lib:RegisterHiddenUntilMouseover(bar, L["HIDE_WHEN_NOT_MOUSEOVER_DESCRIPTION"])
            
            RunNextFrame(function()
                local noInfinite

                local function handler()
                    if noInfinite then return end
                    if InCombatLockdown() then return end
                    if not lib:IsFrameHiddenUntilMouseover(bar) then return end
                    noInfinite = true
                    bar:Hide()
                    noInfinite = false
                end
                hooksecurefunc("ActionBarController_UpdateAll", handler)
                hooksecurefunc(EditModeManagerFrame, "ShowSystemSelections", handler)
                
                local updateVisibilityNoInfinite
                hooksecurefunc(bar, "UpdateVisibility", function()
                    if updateVisibilityNoInfinite then return end
                    if InCombatLockdown() then return end
                    if not lib:IsFrameHiddenUntilMouseover(bar) then return end
                    
                    updateVisibilityNoInfinite = true
                    -- Issue: other action bars will check if MainActionBar is visible, and set their own visibility status accordingly
                    -- Because of this, cannot hide the MainActionBar immediately after UpdateVisibility is called, need to wait for the end of the stack
                    if bar == MainActionBar then
                        RunNextFrame(function()
                            if InCombatLockdown() then return end
                            bar:Hide()
                            updateVisibilityNoInfinite = false
                        end)
                    else
                        bar:Hide()
                        updateVisibilityNoInfinite = false
                    end
                end)
            end)
        end
    end)
end
