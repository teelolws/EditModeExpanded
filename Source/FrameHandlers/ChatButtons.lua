local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initChatButtons()
    local db = addon.db.global
    if not db.EMEOptions.chatButtons then return end
    lib:RegisterFrame(QuickJoinToastButton, "Social", db.QuickJoinToastButton)
    lib:SetDontResize(QuickJoinToastButton)
    lib:RegisterHideable(QuickJoinToastButton)
    
    lib:RegisterFrame(ChatFrameChannelButton, "Channels", db.ChatFrameChannelButton)
    lib:SetDontResize(ChatFrameChannelButton)
    lib:RegisterHideable(ChatFrameChannelButton)
    
    lib:RegisterFrame(ChatFrameMenuButton, "Chat Menu", db.ChatFrameMenuButton)
    lib:SetDontResize(ChatFrameMenuButton)
    lib:RegisterHideable(ChatFrameMenuButton)
    
    lib:GroupOptions({QuickJoinToastButton, ChatFrameChannelButton, ChatFrameMenuButton}, "Chat Buttons")
end
