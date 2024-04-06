local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initCompactArena()
    local db = addon.db.global
    if db.EMEOptions.arena then
        local buttons = {}
        for i, memberUnitFrame in ipairs(CompactArenaFrame.memberUnitFrames) do
            lib:RegisterFrame(memberUnitFrame, "Arena "..i, db["ArenaMember"..i])
            lib:SetDontResize(memberUnitFrame)
            lib:RegisterResizable(memberUnitFrame)
            lib:RegisterFrame(memberUnitFrame.CastingBarFrame, "Arena "..i.." Cast", db["ArenaCast"..i])
            lib:SetDontResize(memberUnitFrame.CastingBarFrame)
            lib:RegisterResizable(memberUnitFrame.CastingBarFrame)
            lib:RegisterFrame(memberUnitFrame.CcRemoverFrame, "C"..i, db["ArenaCC"..i])
            lib:SetDontResize(memberUnitFrame.CcRemoverFrame)
            lib:RegisterResizable(memberUnitFrame.CcRemoverFrame)
            lib:RegisterFrame(memberUnitFrame.DebuffFrame, "D"..i, db["ArenaDebuff"..i])
            lib:SetDontResize(memberUnitFrame.DebuffFrame)
            lib:RegisterResizable(memberUnitFrame.DebuffFrame)
            
            hooksecurefunc(CompactArenaFrame, "UpdateLayout", function()
                lib:RepositionFrame(memberUnitFrame.CastingBarFrame)
                lib:RepositionFrame(memberUnitFrame.CcRemoverFrame)
                lib:RepositionFrame(memberUnitFrame.DebuffFrame)
                
                if InCombatLockdown() then return end
                lib:RepositionFrame(memberUnitFrame)
            end)
            
            table.insert(buttons, memberUnitFrame)
            table.insert(buttons, memberUnitFrame.CastingBarFrame)
            table.insert(buttons, memberUnitFrame.CcRemoverFrame)
            table.insert(buttons, memberUnitFrame.DebuffFrame)
        end
        
        lib:GroupOptions(buttons, "Arena Frames")
        
        hooksecurefunc(CompactArenaFrame, "UpdateLayout", function()
            if InCombatLockdown() then return end
            CompactArenaFrame:SetSize(1, 1)
        end)
        CompactArenaFrame:SetSize(1, 1)
    end
end
