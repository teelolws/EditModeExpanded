local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initCooldownManager()
    if not addon.db.global.EMEOptions.cooldownManager then return end
    
    --[[
    for i = 1, 5 do
        local frame = EssentialCooldownViewer:GetItemFrames()[i]
        local statusBar = CreateFrame("StatusBar", "zzzz", frame)
        statusBar:SetPoint("LEFT", frame, "RIGHT")
        statusBar:SetSize(100, 20)
        statusBar:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
        statusBar:SetStatusBarColor(0, 1, 0)
        statusBar:SetFillStyle(1)
        frame:HookScript("OnUpdate", function()
            statusBar:SetTimerDuration(C_Spell.GetSpellCooldownDuration(frame:GetSpellID()))
        end)
    end]]
end