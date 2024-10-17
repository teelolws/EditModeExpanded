local addonName, addon = ...

-- A wrapper for :HookScript and hooksecurefunc to only trigger once

local savedHookScripts = {}
local savedHookFuncs = {}

function addon.hookScriptOnce(frame, script, callback)
    if not savedHookScripts[frame] then
        savedHookScripts[frame] = {}
    end
    
    local db = savedHookScripts[frame]
    if db[script] then
        table.insert(db[script], callback)
    else
        db[script] = {callback}
        local function handler()
            for _, callback in ipairs(db[script]) do
                callback()
            end
            wipe(db[script])
        end
        frame:HookScript(script, handler)
    end
end

function addon.hookFuncOnce(tbl, script, callback)
    if type(tbl) == "string" then
        callback = script
        script = tbl
        tbl = nil
    end

    if not savedHookFuncs[tbl or script] then
        savedHookFuncs[tbl or script] = {}
    end
    
    local db = savedHookFuncs[tbl or script]
    if db[script] then
        table.insert(db[script], callback)
    else
        db[script] = {callback}
        local function handler()
            for _, callback in ipairs(db[script]) do
                callback()
            end
            wipe(db[script])
        end
        if tbl == nil then
            hooksecurefunc(script, handler)
        else
            hooksecurefunc(tbl, script, handler)
        end
    end
end