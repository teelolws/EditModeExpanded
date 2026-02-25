local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

-- Code adapted from Hide Chat In Combat, which was accessed 24/2/2026 from https://www.curseforge.com/wow/addons/hcic/comments
-- and was listed as Public Domain

function addon:initChatFrame()
    local db = addon.db.global
    if not db.EMEOptions.chatFrame then return end

    ------------------
    --Config
    local t = .5 -- fade time in seconds
    local isEnabled
    ------------------

    local hcic = CreateFrame("Frame")
    local MouseoverFrames = {}
    --Events
    local event = CreateFrame("Frame")
    event:SetScript(
    	"OnEvent",
    	function(self, e, ...)
    		self[e](self, ...)
    	end
    )
    --Register events
    lib:RegisterCustomCheckbox(ChatFrame1, "Fade out while in combat", 
        -- on checked
        function()
            event:RegisterEvent("PLAYER_REGEN_ENABLED")
            event:RegisterEvent("PLAYER_REGEN_DISABLED")
            event:RegisterEvent("PET_BATTLE_CLOSE")
            event:RegisterEvent("PET_BATTLE_OPENING_START")
            isEnabled = true
        end,
        
        -- on unchecked
        function()
            if not isEnabled then return end
            isEnabled = false
            event:UnregisterEvent("PLAYER_REGEN_ENABLED")
            event:UnregisterEvent("PLAYER_REGEN_DISABLED")
            event:UnregisterEvent("PET_BATTLE_CLOSE")
            event:UnregisterEvent("PET_BATTLE_OPENING_START")
        end,
        
        "FadeOutInCombat"
    )

    --Handle events
    function event:PLAYER_REGEN_ENABLED()
    	hcic:CombatEnd()
    end
    function event:PLAYER_REGEN_DISABLED()
    	hcic:CombatStart()
    end
    function event:PET_BATTLE_CLOSE()
    	hcic:CombatEnd()
    end
    function event:PET_BATTLE_OPENING_START()
    	hcic:CombatStart()
    end

    --
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame" .. i]
		if (f:IsShown()) then
			local chatMouseover = CreateFrame("Frame", "HCIC" .. i, UIParent)
			chatMouseover:SetPoint("BOTTOMLEFT", "ChatFrame" .. i, "BOTTOMLEFT", -20, -10)
			chatMouseover:SetPoint("TOPRIGHT", "ChatFrame" .. i, "TOPRIGHT", 10, 10)

			chatMouseover.FadeOut = function(self)
				hcic:FadeOut(self)
			end
			chatMouseover.FadeIn = function(self)
				hcic:FadeIn(self)
			end

			chatMouseover:SetScript(
				"OnEnter",
				function(self)
					if isEnabled and (UnitAffectingCombat("player") or C_PetBattles.IsInBattle()) then
						self:FadeIn(self)
					end
				end
			)
			chatMouseover:SetScript(
				"OnLeave",
				function(self)
					if not isEnabled then return end
                    hcic:ChatOnLeave(self)
				end
			)

			chatMouseover.Frames = {_G["ChatFrame" .. i], _G["ChatFrame" .. i .. "Tab"], _G["ChatFrame" .. i .. "ButtonFrame"]}
			if (i == 1) then
				table.insert(chatMouseover.Frames, GeneralDockManager)
				table.insert(chatMouseover.Frames, GeneralDockManagerScrollFrame)
				if ChatFrameMenuButton:IsShown() then
					table.insert(chatMouseover.Frames, ChatFrameMenuButton)
				end
				table.insert(chatMouseover.Frames, QuickJoinToastButton)
				table.insert(chatMouseover.Frames, ChatFrameChannelButton)
			end

			chatMouseover:SetFrameStrata("BACKGROUND")
			table.insert(MouseoverFrames, _G["HCIC" .. i])
		end
	end

    --
    function hcic:CombatStart()
    	for _, f in pairs(MouseoverFrames) do
    		f:FadeOut()
    	end
    end

    --
    function hcic:CombatEnd()
    	for _, f in pairs(MouseoverFrames) do
    		f:FadeIn()
    	end
    end

    --Fade
    --0: fade in, 1: fade out
    function hcic:FadeOut(self)
    	hcic:fade(self, 1)
    end
    function hcic:FadeIn(self)
    	hcic:fade(self, 0)
    end
    function hcic:fade(self, mode)
    	for _, frame in pairs(self.Frames) do
    		local alpha = frame:GetAlpha()
    		--fade in
    		if mode == 0 then
    			--fade out
    			frame.Show = Show
    			frame:Show()
    			UIFrameFadeIn(frame, t * (1 - alpha), alpha, 1)
    		else
    			UIFrameFadeOut(frame, t * alpha, alpha, 0)
    			frame.Show = function()
    			end
    			frame.fadeInfo.finishedArg1 = frame
    			frame.fadeInfo.finishedFunc = frame.Hide
    		end
    	end
    end

    function hcic:ChatOnLeave(self)
    	--local f = GetMouseFocus()
    	for _, f in pairs(GetMouseFoci()) do
    		if f.messageInfo then
    			return
    		end
    		if hcic:IsInArray(self.Frames, f) then
    			return
    		end
    		if f:GetParent() then
    			f = f:GetParent()
    			if hcic:IsInArray(self.Frames, f) then
    				return
    			end
    			if f:GetParent() then
    				f = f:GetParent()
    				if hcic:IsInArray(self.Frames, f) then
    					return
    				end
    			end
    		end
    	end

    	if UnitAffectingCombat("player") or C_PetBattles.IsInBattle() then
    		self:FadeOut(self)
    	end
    end

    WorldFrame:HookScript(
    	"OnEnter",
    	function()
    		if isEnabled and (UnitAffectingCombat("player") or C_PetBattles.IsInBattle()) then
    			hcic:CombatStart()
    		end
    	end
    )

    function hcic:IsInArray(array, s)
    	for _, v in pairs(array) do
    		if (v == s) then
    			return true
    		end
    	end
    	return false
    end

    hooksecurefunc(
    	"FCF_Tab_OnClick",
    	function(self)
    		chatFrame = _G["ChatFrame" .. self:GetID()]
    		if (chatFrame.isDocked) then
    			HCIC1.Frames[1] = chatFrame
    		end
    	end
    )
    
    lib:RegisterSlider(ChatFrame1, "Fade Delay", "Fade Delay",
        function(newValue)
            t = newValue
        end,
        0, 3, 0.1)
end

