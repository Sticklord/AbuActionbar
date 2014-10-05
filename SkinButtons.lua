local _, ns = ...

local _G, pairs, unpack = _G, pairs, unpack

local Color = {
	Normal = { 1, 1, 1 , 1},
	OutOfRange = { 1, 0.2, 0.2 , 1},
	OutOfMana = { 0.3, 0.3, 1, 1},
	NotUsable = { 0.35, 0.35, 0.35, 1},
	HotKeyText = { 0.6, 0.6, 0.6, 1},
	CountText = { 1, 1, 1, 1},
	Background = { 1, 1, 1, 1},
	Shadow = { 0, 0, 0, 1},
}

local cfg = ns.Config
local Texture = cfg.IconTextures
local FONT = cfg.Fonts.Actionbar
local FONTSIZE = cfg.Actionbar.fontSize
local StyledButts = {}

local function IsSpecificButton(self, name)
	local sbut = self:GetName():match(name)
	if (sbut) then
		return true
	else
		return false
	end
end

local function CreateBackGround(button, makeBG, fBG)
	if not button then return; end

	-- Shadow
	if fBG and type(fBG) == 'table' and fBG:GetObjectType() == 'texture' then
		fBG:ClearAllPoints()
		fBG:SetPoint('TOPRIGHT', button, 5, 5)
		fBG:SetPoint('BOTTOMLEFT', button, -5, -5)
		fBG:SetTexture(Texture.Shadow)
		fBG:SetVertexColor(unpack(Color.Shadow))
		button.Shadow = fBG
	else
		local shadow = button:CreateTexture(nil, "BACKGROUND")
		shadow:SetParent(button)
		shadow:SetPoint('TOPRIGHT', button, 5, 5)
		shadow:SetPoint('BOTTOMLEFT', button, -5, -5)
		shadow:SetTexture(Texture.Shadow)
		shadow:SetVertexColor(unpack(Color.Shadow))
		button.Shadow = shadow
	end
	
	-- Background Texure
	if makeBG then
		local tex = button:CreateTexture(nil, "BACKGROUND", nil, -8)
		tex:SetPoint('TOPRIGHT', button, 3, 3)
		tex:SetPoint('BOTTOMLEFT', button, -3, -3)
		tex:SetTexture(Texture.Background)
		tex:SetVertexColor(unpack(Color.Background))
		button.BackGround = tex
	end
end

local function ActionButtonUpdateHotkey(self)
	local hotkey = _G[self:GetName()..'HotKey']
	local text = hotkey:GetText()
	if not hotkey then return end
	if (not IsSpecificButton(self, 'OverrideActionBarButton')) then
		if cfg.Actionbar.showKeybinds or ns.Binder:IsInBindingMode() then
			if text and text ~= '' then
				text = gsub(text, 's%-', 's');
				text = gsub(text, 'a%-', 'a');
				text = gsub(text, 'c%-', 'c');
				text = gsub(text, 'st%-', 'c');
				text = gsub(text, 'Mouse Button ', 'M');
				text = gsub(text, KEY_MOUSEWHEELUP, 'wU');
				text = gsub(text, KEY_MOUSEWHEELDOWN, 'wD');
				text = gsub(text, 'Middle Mouse', 'M3')

				text = gsub(text, KEY_NUMLOCK, 'nL');

				text = gsub(text, 'Num Pad ', 'n');
				text = gsub(text, KEY_PAGEUP, 'pU');
				text = gsub(text, KEY_PAGEDOWN, 'pD');
				text = gsub(text, KEY_SPACE, 'Sp');
				text = gsub(text, KEY_INSERT, 'Ins');
				text = gsub(text, KEY_HOME, 'Hm');
				text = gsub(text, KEY_DELETE, 'Del');
				hotkey:SetText(text)
			end
			hotkey:Show()
		else
			hotkey:Hide()
		end	
		if not StyledButts[self:GetName()] then return; end
		hotkey:ClearAllPoints()
		hotkey:SetPoint('TOPRIGHT', self, 0, -3)
		hotkey:SetFont(FONT, FONTSIZE - 1, 'OUTLINE')
		hotkey:SetVertexColor(unpack(Color.HotKeyText))
	else
		-- Update Vehicle button
		hotkey:ClearAllPoints()
		hotkey:SetFont(FONT, FONTSIZE + 2, 'OUTLINE')
		hotkey:SetPoint('TOPRIGHT', self, -5, -6)
		hotkey:SetVertexColor(unpack(Color.HotKeyText))
	end
end

local function ActionBarButton(button)
	if (not button) or (button and StyledButts[button:GetName()]) then return; end

	local name = button:GetName()
	local normal = _G[name..'NormalTexture'] or button:GetNormalTexture() --Sometimes it doesnt exist
	local icon = _G[name..'Icon']
	local flash = _G[name..'Flash']
	local count = _G[name..'Count']
	local macroname = _G[name..'Name']
	local cooldown = _G[name..'Cooldown']
	local buttonBg = _G[name..'FloatingBG']
	local border = _G[name..'Border']
	local flyoB = _G[name.."FlyoutBorder"]
	local flyoBS = _G[name.."FlyoutBorderShadow"]

	-- Flyouts
	if flyoB then flyoB:SetTexture(nil) end
	if flyoBS then flyoBS:SetTexture(nil) end

	-- Hide Macro name
	if (macroname) then macroname:Hide() end

	-- Button Count (feathers, monk roll)
	count:SetPoint('BOTTOMRIGHT', button, -2, 1)
	count:SetFont(FONT, FONTSIZE, 'OUTLINE')
	count:SetVertexColor(unpack(Color.CountText))

	-- Flash
	flash:SetTexture(Texture.Flash)

	-- Mod icon abit
	icon:SetTexCoord(.05, .95, .05, .95)

	-- Adjust cooldown
	cooldown:ClearAllPoints()
	cooldown:SetPoint('TOPRIGHT', button, -1, -1)
	cooldown:SetPoint('BOTTOMLEFT', button, 1, 1)

	-- Don't need to know what i've equipped
	border:SetTexture(nil)

	normal:ClearAllPoints()
	normal:SetPoint('TOPRIGHT', button, 2, 2)
	normal:SetPoint('BOTTOMLEFT', button, -2, -2)
	normal:SetVertexColor(unpack(Color.Normal))

	-- Apply textures
	button:SetNormalTexture(Texture.Normal)
	button:SetCheckedTexture(Texture.Checked)
	button:SetHighlightTexture(Texture.Highlight)
	button:SetPushedTexture(Texture.Pushed)

	button:GetCheckedTexture():SetAllPoints(normal)
	button:GetPushedTexture():SetAllPoints(normal)
	button:GetHighlightTexture():SetAllPoints(normal)

	if not button.BackGround then
		button.BackGround = CreateBackGround(button, true, buttonBg)
	end

	ActionButtonUpdateHotkey(button)
	StyledButts[name] = true
end

local function PetStancePossessButton(button)
	if not button then return; end
	button:SetNormalTexture(Texture.Normal)

	if StyledButts[button:GetName()] then return; end

	local name = button:GetName()
	local icon = _G[name..'Icon']
	local flash = _G[name..'Flash']
	local normal = _G[name..'NormalTexture2'] or _G[name..'NormalTexture']
	local cooldown = _G[name..'Cooldown']

	normal:ClearAllPoints()
	normal:SetPoint('TOPRIGHT', button, 1.5, 1.5)
	normal:SetPoint('BOTTOMLEFT', button, -1.5, -1.5)
	normal:SetVertexColor(unpack(Color.Normal))

	-- Apply textures
	button:SetCheckedTexture(Texture.Checked)
	button:SetHighlightTexture(Texture.Highlight)
	button:SetPushedTexture(Texture.Pushed)
	button:GetCheckedTexture():SetAllPoints(normal)
	button:GetPushedTexture():SetAllPoints(normal)
	button:GetHighlightTexture():SetAllPoints(normal)

	cooldown:ClearAllPoints()
	cooldown:SetPoint('TOPRIGHT', button, -1, -1)
	cooldown:SetPoint('BOTTOMLEFT', button, 1, 1)

	icon:SetTexCoord(.05, .95, .05, .95)
	icon:SetPoint('TOPRIGHT', button, 1, 1)
	icon:SetPoint('BOTTOMLEFT', button, -1, -1)

	flash:SetTexture(Texture.Flash)

	if IsSpecificButton(button, 'PetActionButton') then -- Pet bar sets normaltexture
		hooksecurefunc(button, "SetNormalTexture", function(self, texture)
			if texture and texture ~= Texture.Normal then
				self:SetNormalTexture(Texture.Normal)
			end
		end)
	end

	if not button.BackGround then
		button.BackGround = CreateBackGround(button, true)
	end

	ActionButtonUpdateHotkey(button)
	StyledButts[name] = true;
end

local function LeaveVehicleButton(button)
	if not button or (button and StyledButts[button:GetName()])then return; end

	if not button.BackGround then
		button.BackGround = CreateBackGround(button)
	end

	StyledButts[button:GetName()] = true;
end

local function MultiCastActionButton(button) -- OUTDATED
	if not button or (button and StyledButts[button:GetName()])then return; end

	button:SetNormalTexture(nil)
	local icon = _G[button:GetName()..'Icon']
	icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)

	if not button.BackGround then
		button.BackGround = CreateBackGround(button)
	end

	StyledButts[button:GetName()] = true
end

function _G.ActionButton_OnUpdate (self, elapsed)
	if ( ActionButton_IsFlashing(self) ) then
		local flashtime = self.flashtime;
		flashtime = flashtime - elapsed;
		 
		if ( flashtime <= 0 ) then
			local overtime = -flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;
 
			local flashTexture = _G[self:GetName().."Flash"];
			if ( flashTexture:IsShown() ) then
				flashTexture:Hide();
			else
				flashTexture:Show();
			end
		end
		 
		self.flashtime = flashtime;
	end
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if (rangeTimer) then
		rangeTimer = rangeTimer - elapsed
		if (rangeTimer <= 0.1) then
			local isInRange = false
			if (ActionHasRange(self.action) and IsActionInRange(self.action) == 0) then
				_G[self:GetName()..'Icon']:SetVertexColor(unpack(Color.OutOfRange))
				isInRange = true
			end
			if (self.isInRange ~= isInRange) then
				self.isInRange = isInRange
				ActionButton_UpdateUsable(self)
			end
			rangeTimer = TOOLTIP_UPDATE_TIME
		end
		self.rangeTimer = rangeTimer
	end
end

local function ShowGrid(self)
    local normal = _G[self:GetName()..'NormalTexture']
    if (normal) then
        normal:SetAlpha(1) 
    end
end

local function ActionButton_UpdateUseable(self)
    local normal = _G[self:GetName()..'NormalTexture']
    if (normal) then
        normal:SetVertexColor(unpack(Color.Normal)) 
    end

    local isUsable, notEnoughMana = IsUsableAction(self.action)
    if (isUsable) then
        _G[self:GetName()..'Icon']:SetVertexColor(1, 1, 1, 1)
    elseif (notEnoughMana) then
        _G[self:GetName()..'Icon']:SetVertexColor(unpack(Color.OutOfMana))
    else
        _G[self:GetName()..'Icon']:SetVertexColor(unpack(Color.NotUsable))
    end
end

local function ActionButton_Update(button)
	local name = button:GetName()
	if name:find('MultiCast') then
		return;
	elseif name:find('ExtraActionButton') then 
		return; 
	end
	button:SetNormalTexture(Texture.Normal)
end

-- For shwowing keybinds when entering binding mode
function ns.ToggleBindings()
	if cfg.Actionbar.showKeybinds == true then return; end -- No need to update
	for _, name in pairs({'PetActionButton','PossessButton','StanceButton','ActionButton',"MultiBarBottomLeftButton",
						"MultiBarBottomRightButton","MultiBarRightButton","MultiBarLeftButton"}) do
		for i = 1, 12 do
			if _G[name..i..'HotKey'] then
				ActionButtonUpdateHotkey(_G[name..i])
			end
		end
	end
end

local function LoadSkins()
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		ActionBarButton(_G["ActionButton"..i])
		ActionBarButton(_G["MultiBarBottomLeftButton"..i])
		ActionBarButton(_G["MultiBarBottomRightButton"..i])
		ActionBarButton(_G["MultiBarRightButton"..i])
		ActionBarButton(_G["MultiBarLeftButton"..i])
	end

	for i = 1, NUM_OVERRIDE_BUTTONS do
		ActionBarButton(_G["OverrideActionBarButton"..i])
	end
	--style leave button
	LeaveVehicleButton(OverrideActionBarLeaveFrameLeaveButton)
	--petbar buttons
	for i=1, NUM_PET_ACTION_SLOTS do
		PetStancePossessButton(_G["PetActionButton"..i])
	end
	--stancebar buttons
	for i=1, NUM_STANCE_SLOTS do
		PetStancePossessButton(_G["StanceButton"..i])
	end
	--possess buttons
	for i=1, NUM_POSSESS_SLOTS do
		PetStancePossessButton(_G["PossessButton"..i])
	end

	-- MulticastButtons - outdated
	--for i = 1, 12 do
	--	MultiCastActionButton(_G["MultiCastActionButton"..i])
	--end
	--MultiCastActionButton(_G['MultiCastRecallSpellButton'])
	--MultiCastActionButton(_G['MultiCastSummonSpellButton'])

--	LeaveVehicleButton()

	--StyleExtraActionButton(ExtraActionButton1)

	hooksecurefunc("ActionButton_Update", ActionButton_Update)

	hooksecurefunc("ActionButton_UpdateUsable", ActionButton_UpdateUseable)

	-- Showgrid hides border, lets fix
	hooksecurefunc("ActionButton_ShowGrid", ShowGrid)
	-- Update Hotkey	
	hooksecurefunc("ActionButton_UpdateHotkeys", ActionButtonUpdateHotkey)

	-- Detect Flyouts
	SpellFlyoutBackgroundEnd:SetTexture(nil)
	SpellFlyoutHorizontalBackground:SetTexture(nil)
	SpellFlyoutVerticalBackground:SetTexture(nil)
	local function DetectFlyouts(self)
		for i = 1, 10 do
			ActionBarButton(_G["SpellFlyoutButton"..i])
		end
	end
	SpellFlyout:HookScript("OnShow", DetectFlyouts)

end

ns.RegisterEvent("PLAYER_LOGIN", LoadSkins)