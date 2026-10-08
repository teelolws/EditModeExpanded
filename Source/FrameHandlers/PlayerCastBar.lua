local addonName, addon = ...
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initPlayerCastBar()
    if not addon.db.global.EMEOptions.playerCastBar then return end
        
    local width, height
    lib:RegisterSlider(PlayerCastingBarFrame, HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH, "Width",
        function(newValue)
            width = newValue
            PlayerCastingBarFrame:SetWidth(newValue)
        end,
        10, 300, 1)
    lib:RegisterSlider(PlayerCastingBarFrame, HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT, "Height",
        function(newValue)
            height = newValue
            PlayerCastingBarFrame:SetHeight(newValue)
        end,
        1, 50, 1)
    
    PlayerCastingBarFrame:HookScript("OnShow", function(self)
        if width then
            PlayerCastingBarFrame:SetWidth(width)
        end
        if height then
            PlayerCastingBarFrame:SetHeight(height)
        end
    end)
end