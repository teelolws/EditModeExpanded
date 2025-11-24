local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initActionBars()
    local db = addon.db.global
    if not db.EMEOptions.actionBars then return end
    C_Timer.After(5, function()
        if InCombatLockdown() then return end 
        local bars = {MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7}

        for barIndex, bar in ipairs(bars) do
            
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

            local secureHandlerFrame = CreateFrame("Frame", nil, nil, "SecureHandlerEnterLeaveTemplate")
            secureHandlerFrame:SetPoint("TOPLEFT", bar, "TOPLEFT")
            secureHandlerFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
            secureHandlerFrame:SetFrameRef("bar", bar)
            secureHandlerFrame:SetFrameStrata("TOOLTIP")
            secureHandlerFrame:EnableMouse(false)
            secureHandlerFrame:EnableMouseMotion(true)
            secureHandlerFrame:SetPropagateMouseMotion(true)
            
            local skipInit
            lib:RegisterCustomCheckbox(bar, L["HIDE_WHEN_NOT_MOUSEOVER_DESCRIPTION"],
                function()
                    secureHandlerFrame:SetAttribute("_onenter", "self:GetFrameRef('bar'):Show()")
                    secureHandlerFrame:SetAttribute("_onleave", "self:GetFrameRef('bar'):Hide()")
                    if not skipInit then
                        skipInit = true
                        return
                    end
                    bar:Hide()
                end,
                function()
                    secureHandlerFrame:SetAttribute("_onenter", "")
                    secureHandlerFrame:SetAttribute("_onleave", "")
                    if not skipInit then
                        skipInit = true
                        return
                    end
                    bar:Show()
                end,
                "HideUntilMouseover"
            )
            
            hooksecurefunc("CompactUnitFrame_UpdateName", updateNamesSizes)
        end
    end)
end
