local addonName, addon = ...

local handlers = {}
function addon:continueAfterCombatEnds(handler)
    if InCombatLockdown() then
        table.insert(handlers, handler)
    else
        handler()
    end
end

EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_ENABLED", function()
    for _, handler in ipairs(handlers) do
        handler()
    end
    wipe(handlers)
end)
