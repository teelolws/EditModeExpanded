local addonName, addon = ...

-- BW Skinning
local BWSkinEnabled = false
do
    local path = "Interface\\AddOns\\EditModeExpanded\\textures\\UIMicroMenu2x"

    local buttons = {
        {button = CharacterMicroButton, name = "CharacterInfo"},
        {button = ProfessionMicroButton, name = "SpellbookAbilities"},
        {button = PlayerSpellsMicroButton, name = "SpecTalents"},
        {button = AchievementMicroButton, name = "Achievements"},
        {button = QuestLogMicroButton, name = "Questlog"},
        {button = GuildMicroButton, name = "GuildCommunities"},
        {button = LFDMicroButton, name = "Groupfinder"},
        {button = CollectionsMicroButton, name = "Collections"},
        {button = EJMicroButton, name = "AdventureGuide"},
        {button = StoreMicroButton, name = "Shop"},  
        {button = MainMenuMicroButton, name = "GameMenu"},
    }

    -- from 10.1.0 version of framexml AtlasInfo.lua
    local atlasInfo = {
    	["UI-HUD-MicroMenu-Achievements-Disabled"]={19, 13, 0.785156, 0.933594, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-Achievements-Down"]={19, 13, 0.628906, 0.777344, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-Achievements-Mouseover"]={19, 13, 0.785156, 0.933594, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-Achievements-Up"]={19, 13, 0.628906, 0.777344, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-AdventureGuide-Disabled"]={19, 13, 0.316406, 0.464844, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-AdventureGuide-Down"]={19, 13, 0.785156, 0.933594, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-AdventureGuide-Mouseover"]={19, 13, 0.628906, 0.777344, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-AdventureGuide-Up"]={19, 13, 0.00390625, 0.152344, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-CharacterInfo-Disabled"]={19, 13, 0.00390625, 0.152344, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-CharacterInfo-Down"]={19, 13, 0.472656, 0.621094, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-CharacterInfo-Mouseover"]={19, 13, 0.316406, 0.464844, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-CharacterInfo-Up"]={19, 13, 0.00390625, 0.152344, 0.634766, 0.736328, false, false, "2x"},
    	["UI-HUD-MicroMenu-Collections-Disabled"]={19, 13, 0.472656, 0.621094, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-Collections-Down"]={19, 13, 0.00390625, 0.152344, 0.740234, 0.841797, false, false, "2x"},
    	["UI-HUD-MicroMenu-Collections-Mouseover"]={19, 13, 0.00390625, 0.152344, 0.845703, 0.947266, false, false, "2x"},
    	["UI-HUD-MicroMenu-Collections-Up"]={19, 13, 0.160156, 0.308594, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-Communities-Icon-Notification"]={10, 5, 0.00390625, 0.0820312, 0.951172, 0.994141, false, false, "2x"},
    	["UI-HUD-MicroMenu-GameMenu-Disabled"]={19, 13, 0.160156, 0.308594, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-GameMenu-Down"]={19, 13, 0.472656, 0.621094, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-GameMenu-Mouseover"]={19, 13, 0.628906, 0.777344, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-GameMenu-Up"]={19, 13, 0.785156, 0.933594, 0.423828, 0.525391, false, false, "2x"},
    	["UI-HUD-MicroMenu-Groupfinder-Disabled"]={19, 13, 0.160156, 0.308594, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-Groupfinder-Down"]={19, 13, 0.316406, 0.464844, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-Groupfinder-Mouseover"]={19, 13, 0.160156, 0.308594, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-Groupfinder-Up"]={19, 13, 0.00390625, 0.152344, 0.318359, 0.419922, false, false, "2x"},
    	["UI-HUD-MicroMenu-GuildCommunities-Disabled"]={19, 13, 0.785156, 0.933594, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-GuildCommunities-Down"]={19, 13, 0.00390625, 0.152344, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-GuildCommunities-Mouseover"]={19, 13, 0.160156, 0.308594, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-GuildCommunities-Up"]={19, 13, 0.160156, 0.308594, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-Highlightalert"]={33, 20, 0.472656, 0.730469, 0.740234, 0.896484, false, false, "2x"},
    	["UI-HUD-MicroMenu-Questlog-Disabled"]={19, 13, 0.160156, 0.308594, 0.740234, 0.841797, false, false, "2x"},
    	["UI-HUD-MicroMenu-Questlog-Down"]={19, 13, 0.472656, 0.621094, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-Questlog-Mouseover"]={19, 13, 0.160156, 0.308594, 0.845703, 0.947266, false, false, "2x"},
    	["UI-HUD-MicroMenu-Questlog-Up"]={19, 13, 0.785156, 0.933594, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-Shop-Disabled"]={19, 13, 0.160156, 0.308594, 0.634766, 0.736328, false, false, "2x"},
    	["UI-HUD-MicroMenu-Shop-Mouseover"]={19, 13, 0.472656, 0.621094, 0.634766, 0.736328, false, false, "2x"},
    	["UI-HUD-MicroMenu-Shop-Down"]={19, 13, 0.628906, 0.777344, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-Shop-Up"]={19, 13, 0.00390625, 0.152344, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpecTalents-Disabled"]={19, 13, 0.316406, 0.464844, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpecTalents-Down"]={19, 13, 0.316406, 0.464844, 0.529297, 0.630859, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpecTalents-Mouseover"]={19, 13, 0.316406, 0.464844, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpecTalents-Up"]={19, 13, 0.628906, 0.777344, 0.00195312, 0.103516, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpellbookAbilities-Disabled"]={19, 13, 0.00390625, 0.152344, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpellbookAbilities-Down"]={19, 13, 0.316406, 0.464844, 0.845703, 0.947266, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpellbookAbilities-Mouseover"]={19, 13, 0.738281, 0.886719, 0.845703, 0.947266, false, false, "2x"},
    	["UI-HUD-MicroMenu-SpellbookAbilities-Up"]={19, 13, 0.472656, 0.621094, 0.107422, 0.208984, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLGreen-Down"]={19, 13, 0.316406, 0.464844, 0.634766, 0.736328, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLGreen-Up"]={19, 13, 0.472656, 0.621094, 0.212891, 0.314453, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLRed-Down"]={19, 13, 0.316406, 0.464844, 0.740234, 0.841797, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLRed-Up"]={19, 13, 0.628906, 0.777344, 0.634766, 0.736328, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLYellow-Down"]={19, 13, 0.738281, 0.886719, 0.740234, 0.841797, false, false, "2x"},
    	["UI-HUD-MicroMenu-StreamDLYellow-Up"]={19, 13, 0.785156, 0.933594, 0.634766, 0.736328, false, false, "2x"},
    }

    local prefix = "UI-HUD-MicroMenu-";

    local function SkinMicroMenuBW()
        if not BWSkinEnabled then return end
        
        for _, data in pairs(buttons) do
            local self, name = data.button, data.name

            local info = atlasInfo[prefix..name.."-Up"]
            self:SetNormalTexture(path)
            local tex = self:GetNormalTexture()
            tex:SetTexCoord(info[3], info[4], info[5], info[6])
            if self == GuildMicroButton then
                self:GetNormalTexture():SetVertexColor(1, 1, 1)
            end
            
            info = atlasInfo[prefix..name.."-Down"]
            self:SetPushedTexture(path)
            tex = self:GetPushedTexture()
            tex:SetTexCoord(info[3], info[4], info[5], info[6])
            
        	info = atlasInfo[prefix..name.."-Disabled"]
            self:SetDisabledTexture(path)
            tex = self:GetDisabledTexture()
            tex:SetTexCoord(info[3], info[4], info[5], info[6])
            
            info = atlasInfo[prefix..name.."-Mouseover"]
            self:SetHighlightTexture(path)
            tex = self:GetHighlightTexture()
            tex:SetTexCoord(info[3], info[4], info[5], info[6])
        end
        CharacterMicroButton.Portrait:Hide()
        GuildMicroButton.Emblem:Hide()
        GuildMicroButton.HighlightEmblem:Hide()
    end

    function addon:EnableSkinMicroMenuBW()
        BWSkinEnabled = true
    end

    function addon:DisableSkinMicroMenuBW()
        BWSkinEnabled = false
    end

    MainMenuMicroButton:HookScript("OnUpdate", SkinMicroMenuBW)
end

-- Shadowlands skinning
local SLSkinEnabled = false
do
    local prefix = "hud-microbutton-"
    	
    local function replaceAtlases(self, name)
        if not SLSkinEnabled then return end
        -- code from 9.2 version of FrameXML\MainMenuBarMicroButtons.lua
        self:SetNormalAtlas(prefix..name.."-Up", true)
        self:SetPushedAtlas(prefix..name.."-Down", true)
        
        if self == GuildMicroButton then
            local tabard = GuildMicroButtonTabard;

            -- switch textures if the guild has a custom tabard
            local emblemFilename = select(10, GetGuildLogoInfo());
            if ( emblemFilename ) then
                self:SetNormalAtlas("hud-microbutton-Character-Up", true)
                self:SetPushedAtlas("hud-microbutton-Character-Down", true)
                self:GetNormalTexture():SetVertexColor(1, 1, 1)
                self:GetPushedTexture():SetVertexColor(1, 1, 1)
                self.Emblem:Hide()
                self.HighlightEmblem:Hide()
    			tabard:Show()
                SetSmallGuildTabardTextures("player", tabard.emblem, tabard.background)
            else
                self:SetNormalAtlas("hud-microbutton-Socials-Up", true)
                self:SetPushedAtlas("hud-microbutton-Socials-Down", true)
                self:SetDisabledAtlas("hud-microbutton-Socials-Disabled", true)
                tabard:Hide()
            end
        end
        
    	self:SetDisabledAtlas(prefix..name.."-Disabled", true)
    	self:SetHighlightAtlas("hud-microbutton-highlight")
        
        local normalTexture = self:GetNormalTexture();
    	if(normalTexture) then 
    		normalTexture:SetAlpha(1); 
    	end
        if(self.FlashContent) then 
    		self.FlashContent:SetAtlas(prefix..name.."-Up", true)
    	end
    end

    local buttons = {
        {button = CharacterMicroButton, name = "Character"},
        {button = ProfessionMicroButton, name = "Spellbook"},
        {button = PlayerSpellsMicroButton, name = "Talents"},
        {button = AchievementMicroButton, name = "Achievement"},
        {button = QuestLogMicroButton, name = "Quest"},
        {button = GuildMicroButton, name = "Socials"},
        {button = LFDMicroButton, name = "LFG"},
        {button = CollectionsMicroButton, name = "Mounts"},
        {button = EJMicroButton, name = "EJ"},
        {button = StoreMicroButton, name = "BStore"},  
        {button = MainMenuMicroButton, name = "MainMenu"},
    }

    local function replaceAllAtlases()
        if not SLSkinEnabled then return end
        for _, data in pairs(buttons) do
            replaceAtlases(data.button, data.name)
        end
    end

    MainMenuMicroButton:CreateTexture("MainMenuBarDownload", "OVERLAY")
    MainMenuBarDownload:SetPoint("BOTTOM", "MainMenuMicroButton", "BOTTOM", 0, 7)
    MainMenuBarDownload:SetSize(28, 28)
    MainMenuBarDownload:Hide()

    MainMenuMicroButton:HookScript("OnUpdate", function(self, elapsed)
        if not SLSkinEnabled then return end
        
        local status = GetFileStreamingStatus();
            if ( status == 0 ) then
        	MainMenuBarDownload:Hide();
        else
        	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
        	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Down");
        	self:SetDisabledTexture("Interface\\Buttons\\UI-MicroButtonStreamDL-Up");
        	if ( status == 1 ) then
        		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Green");
        	elseif ( status == 2 ) then
        		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Yellow");
        	elseif ( status == 3 ) then
        		MainMenuBarDownload:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Red");
        	end
        	MainMenuBarDownload:Show();
        end
        replaceAtlases(MainMenuMicroButton, "MainMenu")
    end)
    
    local eventTypes = {"OnEnter", "OnClick", "OnMouseDown", "OnMouseUp", "OnLeave"}
    for _, data in pairs(buttons) do
        for _, eventType in pairs(eventTypes) do
            data.button:HookScript(eventType, function()
                replaceAtlases(data.button, data.name)
            end)
        end
        hooksecurefunc(data.button, "SetPushed", replaceAllAtlases)
        hooksecurefunc(data.button, "SetNormal", replaceAllAtlases)     
    end

    CreateFrame("Frame", "GuildMicroButtonTabard", GuildMicroButton)
    GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1)
    GuildMicroButtonTabard:SetPoint("BOTTOMRIGHT", -3, -1)
    GuildMicroButtonTabard:Hide()

    GuildMicroButtonTabard.background = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardBackground", "ARTWORK")
    GuildMicroButtonTabardBackground:SetAtlas("hud-microbutton-Guild-Banner", true)
    GuildMicroButtonTabardBackground:SetPoint("CENTER", 0, 0)

    GuildMicroButtonTabard.emblem = GuildMicroButtonTabard:CreateTexture("GuildMicroButtonTabardEmblem", "OVERLAY")
    GuildMicroButtonTabardEmblem:SetMask("Interface\GuildFrame\GuildEmblems_01")
    GuildMicroButtonTabardEmblem:SetSize(14, 14)
    GuildMicroButtonTabardEmblem:SetPoint("CENTER", 0, 0)

    -- move tabard with button press
    local function updateButtons()
        if not SLSkinEnabled then return end
        
        if ( CommunitiesFrame and CommunitiesFrame:IsShown() ) or ( GuildFrame and GuildFrame:IsShown() ) then
    		GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
    		GuildMicroButtonTabard:SetAlpha(0.70);
    	else
    		GuildMicroButtonTabard:SetPoint("TOPLEFT", 3, 1);
    		GuildMicroButtonTabard:SetAlpha(1);
        end
    end

    hooksecurefunc("UpdateMicroButtons", updateButtons)

    -- this is needed because there is a slight delay between button press and guild frame being visible. Button appears pushed before the guild frame is visible, without this, the tabard doesn't move cleanly with the rest of the button.
    hooksecurefunc(GuildMicroButton, "SetPushed", function()
        if not SLSkinEnabled then return end
        
        GuildMicroButtonTabard:SetPoint("TOPLEFT", 0, -2);
    	GuildMicroButtonTabard:SetAlpha(0.70);
    end)
    
    function addon:EnableSkinMicroMenuSL()
        SLSkinEnabled = true
    end
    
    function addon:DisableSkinMicroMenuSL()
        SLSkinEnabled = false
    end
    
    replaceAllAtlases()
end
