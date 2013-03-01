------------------------------
-- BEGIN POINTS DECLARATION --
------------------------------

local animations = {
	onLoad = function(self)
		self.regionParent = self:GetRegionParent()
	end,
	scale = function(self)
		local p = self:GetProgress()
		local progress = self:GetParent():GetLoopState() == "REVERSE" and (1 - p) or p

		if progress < 0 then progress = 0
		elseif progress > 1 then progress = 1
		end

		local scale = 1 + ((self.pulseTarget - 1) * progress)
		self.regionParent:SetScale(scale)
	end,
	alpha = function(self)
		self.regionParent:SetAlpha(self:GetProgress())
	end,
	alphaIn = function(self)
		self.regionParent:SetAlpha(1 - self:GetProgress())
	end,
	scaleIn = function(self)
		local scale = 1 + ((1 - self:GetProgress()) * 0.5)
		self.regionParent:SetScale(scale)
	end,
	hide = function(self)
	   self.regionParent:Hide()
	end,
}

local textureLookup = {
	diamond    = [[Interface\TARGETINGFRAME\UI-RAIDTARGETINGICON_3.BLP]],
	star       = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_1.blp]],
	circle     = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_2.blp]],
	triangle   = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_4.blp]],
	moon       = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_5.blp]],
	square     = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_6.blp]],
	cross      = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_7.blp]],
	skull      = [[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_8.blp]],
	cross2     = [[Interface\RAIDFRAME\ReadyCheck-NotReady.blp]],
	check      = [[Interface\RAIDFRAME\ReadyCheck-Ready.blp]],
	question   = [[Interface\RAIDFRAME\ReadyCheck-Waiting.blp]],
	targeting  = [[Interface\Minimap\Ping\ping5.blp]],
	glow       = [[Interface\GLUES\MODELS\UI_Tauren\gradientCircle]],
	party      = [[Interface\MINIMAP\PartyRaidBlips]],
	ring       = [[SPELLS\CIRCLE]],
	rune1      = [[SPELLS\AURARUNE256.BLP]],
	rune2      = [[SPELLS\AURARUNE9.BLP]],
	rune3      = [[SPELLS\AURARUNE_A.BLP]],
	rune4      = [[SPELLS\AURARUNE_B.BLP]],
	paw        = [[SPELLS\Agility_128.blp]],
	cyanstar   = [[SPELLS\CYANSTARFLASH.BLP]],
	summon     = [[SPELLS\DarkSummon.blp]],
	reticle    = [[SPELLS\Reticle_128.blp]],
	fuzzyring  = [[SPELLS\WHITERINGTHIN128.BLP]],
	fatring    = [[SPELLS\WhiteRingFat128.blp]],
	swords     = [[SPELLS\Strength_128.blp]],
	tank       = [[Interface\LFGFrame\LFGRole_BW]],
	dps        = [[Interface\LFGFrame\LFGRole_BW]],
	healer     = [[Interface\LFGFrame\LFGRole_BW]]
}

local texBlending = {
	highlight  = "ADD",
	targeting  = "ADD",
	glow       = "ADD",
	ring       = "ADD",
	rune1      = "ADD",
	rune2      = "ADD",
	rune3      = "ADD",
	rune4      = "ADD",
	paw        = "ADD",
	reticle    = "ADD",
	cyanstar   = "ADD",
	summon     = "ADD",
	fuzzyring  = "ADD",
	fatring    = "ADD",
	swords     = "ADD"
}

local texCoordLookup = {
	party = {0.525, 0.6, 0.04, 0.2},
	tank = {0.5, 0.75, 0, 1},
	dps = {0.75, 1, 0, 1},
	healer = {0.25, 0.5, 0, 1},
	paw = {0.124, 0.876, 0.091, 0.903},
	rune4 = {0.032, 0.959, 0.035, 0.959},
	reticle = {0.05, 0.95, 0.05, 0.95}
}

local overlays = { }

Overlay = { }
function Overlay:SetTexture(texfile, blend)
  local tex = self.texture
  texfile = texfile or "glow"
  tex:SetTexture(textureLookup[texfile] or texfile or [[Interface\GLUES\MODELS\UI_Tauren\gradientCircle]])
  if texCoordLookup[texfile] then
  	tex:SetTexCoord(unpack(texCoordLookup[texfile]))
  else
  	tex:SetTexCoord(0, 1, 0, 1)
  end
  blend = blend or texBlending[texfile] or "BLEND"
  tex:SetBlendMode(blend)

  return self
end

function Overlay:SetPosition(anchor, x, y)
	self.frame:SetPoint(anchor, x, y)
	return self
end

function Overlay:Scale(scaling)
    self.frame:SetSize(scaling * self.size, scaling * self.size)
    return self
end

function Overlay:SetColor(r, g, b, a)
	self.texture:SetVertexColor(r, g, b, a)
	return self
end

function Overlay:Appear()
	self.fadeInGroup:Play()
	return self
end

function Overlay:Update()
   if not self.lifetime or self.lifetime > 0 and self.lifetime < GetTime() then
		self:Free()
	end
end

function Overlay:Free(noAnimate)
		if self.freed then
			return nil
		end
		
		self.freed = true

		if noAnimate then
			self.frame:Hide()
		else
			self.fadeOutGroup:Play()
		end

		self.size = nil
		self.lifetime = nil

		local todel
		for i, overlay in ipairs(overlays) do
			if overlay == self then
			   todel = i
			end
		end
		table.remove(overlays, todel)

		return nil
	end

function Overlay:New(anchor, x, y, lifetime, texfile, size, blend, r, g, b, a)

	o = setmetatable({}, {__index = self})

	o.size = size
	o.lifetime = lifetime and (GetTime() + lifetime) or -1

	o.frame = CreateFrame("Frame", nil, UIParent)
	o.frame:SetFrameStrata("TOOLTIP")
	o.frame:SetPoint(anchor, x, y)
	o.frame:SetSize(size or 20, size or 20)
	o.frame:Show()

	o.texture = o.frame:CreateTexture()
	o.texture:SetAllPoints(o.frame)
	o.texture:SetVertexColor(r, g, b, a)
	Overlay.SetTexture(o, texfile, blend)
	

	do
		o.fadeInGroup = o.frame:CreateAnimationGroup()

		local scaleOut = o.fadeInGroup:CreateAnimation("scale")
		scaleOut:SetDuration(0)
		scaleOut:SetScale(1.5, 1.5)
		scaleOut:SetOrder(1)

		o.fadeIn = o.fadeInGroup:CreateAnimation()
		o.fadeIn:SetDuration(1.5)
		o.fadeIn:SetScript("OnPlay", animations.onLoad)
		o.fadeIn:SetScript("OnUpdate", animations.alpha)
		o.fadeIn:SetOrder(2)

		local scaleIn = o.fadeInGroup:CreateAnimation("scale")
		scaleIn:SetDuration(0.5)
		scaleIn:SetScale(1 / 1.5, 1 / 1.5)
		scaleIn:SetOrder(2)
	
		o.fadeOutGroup = o.frame:CreateAnimationGroup()
		
		o.fadeOut = o.fadeOutGroup:CreateAnimation()
		o.fadeOut:SetDuration(lifetime and lifetime / 2 or 1)
		o.fadeOut:SetScript("OnPlay", animations.onLoad)
		o.fadeOut:SetScript("OnUpdate", animations.alphaIn)
		o.fadeOut:SetScript("OnFinished", animations.hide)
	end

   table.insert(overlays, o)

	return o
end

----------------------------
-- END POINTS DECLARATION --
----------------------------

---------------------
-- BEGIN VIZ ADDON --
---------------------

local enabled = true
local duration = 6
local screenWidth, screenHeight
local healthpool, powerpool

function WoWViz_Message(message)
	DEFAULT_CHAT_FRAME:AddMessage("[" .. addonName .. "] " .. message, 1.0, 1.0, 0.0)
end

local function getSchoolColour(school)
	local schools = {
		physical = {1, 1, 1, 0},
		holy		= {2, 1, .9, .5},
		fire		= {4, 1, .5, 0},
		nature   = {8, .3, 1, .3},
		frost    = {16, .5, 1, 1},
		shadow   = {32, .5, .5, 1},
		arcane   = {64, 1, .5, 1},
	}

	r, g, b = 0, 0, 0
	matches = 0
	for name, sch in pairs(schools) do
		if bit.band(school, sch[1]) ~= 0 then
      	r = r + sch[2]
			g = g + sch[3]
			b = b + sch[4]
      	matches = matches + 1
		end
	end
	
	if matches == 0 then
	   return 1, 0, 0
	else
		return r/matches, g/matches, b/matches
	end
end

local function getRadius(area)
	return sqrt(area / math.pi)
end

-- returns diameter for a circle which has:
--     area : screen area <-> hitpoints : UnitHealthMax("player")
local function getSize(hitpoints)
	return 2 * getRadius(hitpoints / UnitHealthMax("player") * screenWidth * screenHeight)
end

function WoWViz_TakeDamage(damage, overkill, school)
	-- WoWViz_Message("TAKE Damage: " .. damage .. " Overkill: " .. overkill .. " School: " .. school)
	
	r, g, b = getSchoolColour(school)
	
	if enabled then
		x, y = random(screenWidth) - screenWidth / 2, random(screenHeight) - screenHeight / 2
		Overlay:New("CENTER", x, y, duration, "cyanstar", 6 * getSize(damage), "ADD", 1, 0, 0, 0.5):Appear()
		Overlay:New("CENTER", x, y, duration, "cyanstar", 3 * getSize(damage), "ADD", r, g, b, 1):Appear()
	end
end

function WoWViz_DealDamage(damage, overkill, school)
	-- WoWViz_Message("DEAL Damage: " .. damage .. " Overkill: " .. overkill .. " School: " .. school)

	r, g, b = getSchoolColour(school)

	if enabled then
		x, y = random(screenWidth) - screenWidth / 2, random(screenHeight) - screenHeight / 2
		Overlay:New("CENTER", x, y, duration, "cyanstar", 6 * getSize(damage), "ADD", 1, 0, 0, 0.5):Appear()
		Overlay:New("CENTER", x, y, duration, "cyanstar", 3 * getSize(damage), "ADD", r, g, b, 1):Appear()
	end
end

function WoWViz_TakeHeal(heal, overheal, absorb)
	-- WoWViz_Message("Heal: " .. heal .. " Overheal: " .. overheal .. " Absorbed: " .. absorb)
	if enabled then
		x, y = random(screenWidth) - screenWidth / 2, random(screenHeight) - screenHeight / 2
		Overlay:New("CENTER", x, y, duration, "glow", 4 * getSize(heal), "ADD", 0, 1, 0, 0.5):Appear()
		Overlay:New("CENTER", x, y, duration, "glow", 2 * getSize(heal), "ADD", 0, 1, 0, 1):Appear()
	end
end

function WoWViz_GiveHeal(heal, overheal, absorb)
	-- WoWViz_Message("Heal: " .. heal .. " Overheal: " .. overheal .. " Absorbed: " .. absorb)
	if enabled then
		x, y = random(screenWidth) - screenWidth / 2, random(screenHeight) - screenHeight / 2
		Overlay:New("CENTER", x, y, duration, "glow", 4 * getSize(heal), "ADD", 0, 1, 0, 0.5):Appear()
		Overlay:New("CENTER", x, y, duration, "glow", 2 * getSize(heal), "ADD", 0, 1, 0, 1):Appear()
	end
end

------------------------------------------------------------------------
-- the event handler
------------------------------------------------------------------------
function WoWViz_OnUpdate(this, t)
	for _, overlay in ipairs(overlays) do
		overlay:Update()
	end
end

------------------------------------------------------------------------
-- the event handler
------------------------------------------------------------------------
function WoWViz_OnEvent(this, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, ...)

	if event == "PLAYER_LOGIN" then

        healthpool = Overlay:New("CENTER",250,0, nil, "glow", 1500, "ADD", 0, 1, 0, 0.5):Appear()
        powerpool = Overlay:New("CENTER",-250,0, nil, "glow", 1500, "ADD", 0, 0, 1, 0.5):Appear()

   elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then


      local srcB = tonumber(arg3:sub(5,5), 16);
      local srcMaskedB = srcB % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0x
      
      local dstB = tonumber(arg6:sub(5,5), 16);
      local dstMaskedB = dstB % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0x

      -- if we are the destination of the event
      if dstMaskedB == 0 and arg7 == GetUnitName("player", false) then
        -- if we are damaged
        if arg2 == "SWING_DAMAGE" then
           WoWViz_TakeDamage(arg9, arg10, arg11)
        elseif arg2 == "RANGE_DAMAGE" or (arg2:find("SPELL_") and arg2:find("_DAMAGE")) then
           WoWViz_TakeDamage(arg12, arg13, arg14)
        -- if we are healed
        elseif arg2:find("_HEAL") then
           WoWViz_TakeHeal(arg12, arg13, arg14)
        end
      -- if we are the source of the event
		elseif srcMaskedB == 0 and arg4 == GetUnitName("player", false) then
			-- if we deal damage
        if arg2 == "SWING_DAMAGE" then
           WoWViz_DealDamage(arg9, arg10, arg11)
        elseif arg2 == "RANGE_DAMAGE" or (arg2:find("SPELL_") and arg2:find("_DAMAGE")) then
           WoWViz_DealDamage(arg12, arg13, arg14)
        -- if we heal
        elseif arg2:find("_HEAL") then
           WoWViz_GiveHeal(arg12, arg13, arg14)
        end
      end

	elseif event == "UNIT_MANA" or event == "UNIT_HEALTH" or event == "UNIT_RUNIC_POWER" or event == "UNIT_ENERGY" or event == "UNIT_RAGE" then

	   -- update unit power and health

		-- TODO do this on shapeshift as well
		
		powerType = UnitPowerType("player")

		if powerType == 0 then
		   powerpool:SetColor(0,0,1,0.7)
		elseif powerType == 1 then
		   powerpool:SetColor(1,0,0,0.7)
		elseif powerType == 3 then
		   powerpool:SetColor(1,0.8,0,0.7)
		elseif powerType == 6 then
			powerpool:SetColor(0.2,0.9,0.8,0.7)
		end

		powerpool:Scale(UnitPower("player") / UnitPowerMax("player"))
		healthpool:Scale(UnitHealth("player") / UnitHealthMax("player"))
   end
end

------------------------------------------------------------------------
-- the /viztoggle command handler: toggles display of the visualization
------------------------------------------------------------------------
function WoWViz_Toggle(cmd)
	WoWViz_Message("Toggled " .. addonName .. ".")
	
	enabled = not enabled
	
	if enabled then
	   for _, overlay in ipairs(overlays) do
			overlay.frame:Show()
		end
	
	else

	   for _, overlay in ipairs(overlays) do
			overlay.frame:Hide()
		end
	
	end
end

------------------------------------------
-- SlashCmdList
------------------------------------------
function SlashCmdList_AddSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = select(i, ...)
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end

------------------------------------------
-- START
------------------------------------------

addonName = "WoWViz"

WoWViz_Message("Starting " .. addonName .. ".")


screenWidth, screenHeight = string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x(%d+)")

SlashCmdList_AddSlashCommand("WoWVizToggle", WoWViz_Toggle, "viz")

local frame = CreateFrame("Frame", "WoWVizFrame")
frame:SetScript("OnEvent", WoWViz_OnEvent)
frame:SetScript("OnUpdate", WoWViz_OnUpdate)

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--frame:RegisterEvent("COMBAT_TEXT_UPDATE")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MANA")
frame:RegisterEvent("UNIT_RUNIC_POWER")
frame:RegisterEvent("UNIT_ENERGY")
frame:RegisterEvent("UNIT_RAGE")