local addonName, addon = ...

function addon:initChatButtons()
    local db = addon.db.global
    if not db.EMEOptions.chatButtons then return end
    ChatFrame1:SetClampedToScreen(false)
end
