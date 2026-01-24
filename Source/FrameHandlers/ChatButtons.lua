local addonName, addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initChatButtons()
    local db = addon.db.global
    if not db.EMEOptions.chatButtons then return end
    addon:registerFrame(QuickJoinToastButton, SOCIAL_BUTTON, db.QuickJoinToastButton)
    lib:SetDontResize(QuickJoinToastButton)
    lib:RegisterHideable(QuickJoinToastButton)
    
    addon:registerFrame(ChatFrameChannelButton, CHANNELS, db.ChatFrameChannelButton)
    lib:SetDontResize(ChatFrameChannelButton)
    lib:RegisterHideable(ChatFrameChannelButton)
    
    addon:registerFrame(ChatFrameMenuButton, L["Chat Menu"], db.ChatFrameMenuButton)
    lib:SetDontResize(ChatFrameMenuButton)
    lib:RegisterHideable(ChatFrameMenuButton)
    
    lib:GroupOptions({QuickJoinToastButton, ChatFrameChannelButton, ChatFrameMenuButton}, L["Chat Buttons"])
    
    hooksecurefunc(ChatAlertFrame, "UpdateAnchors", function()
        lib:RepositionFrame(QuickJoinToastButton)
        lib:RepositionFrame(ChatFrameChannelButton)
        lib:RepositionFrame(ChatFrameMenuButton)
    end)
end
