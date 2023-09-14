local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initActionBars()
    local db = addon.db.global
    if not db.EMEOptions.actionBars then return end
    C_Timer.After(10, function()
        if InCombatLockdown() then return end 
        local bars = {MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7}

        for _, bar in ipairs(bars) do
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
            
            addon:registerSecureFrameHideable(bar)
        end
    end)
end
