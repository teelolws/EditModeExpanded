local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initSystemFrames()
    local db = addon.db.global
        
    for _, frame in ipairs(EditModeManagerFrame.registeredSystemFrames) do
        local name = frame:GetName()
        
        -- Backward compatibility: frame name was changed from MicroMenu to MicroMenuContainer in 10.1
        if name == "MicroMenuContainer" then
            if db["MicroMenu"] and (not db[name]) then
                db[name] = db["MicroMenu"]
                db["MicroMenu"] = nil
            end
        end
        
        if not db[name] then db[name] = {} end
        lib:RegisterFrame(frame, "", db[name])
    end
    
    -- The earlier RegisterFrame will :SetShown(true) the TalkingHeadFrame if it was set to Hide then unset.
    -- Since its actually not normally shown on login, we will immediately re-hide it again.
    TalkingHeadFrame:Hide()
end
