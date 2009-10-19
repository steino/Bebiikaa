local db
local _G = getfenv(0)
local addon = CreateFrame"Frame"
local lclass, class = UnitClass"player"
local name = UnitName"player"

-- Default Paperdolls
local CLASSDEFAULTS = {
	["PRIEST"] = {
		[1] = "healing",
		[2] = "spellhaste",
		[3] = "holycrit",
		[4] = "spirit",
		[5] = "manaregen",
		[6] = "castingregen",
	},
}

local DEFAULTS = {
	["PLAYERSTAT_BASE_STATS"] = {
		[1] = "strength",
		[2] = "agility",
		[3] = "stamina",
		[4] = "intellect",
		[5] = "spirit",
		[6] = "armor",
	},
	["PLAYERSTAT_MELEE_COMBAT"] = {
		[1] = "melee",
		[2] = "attackspeed",
		[3] = "attackpower",
		[4] = "meleehit",
		[5] = "meleecrit",
		[6] = "expertise",
	},
	["PLAYERSTAT_RANGED_COMBAT"] = {
		[1] = "ranged",
		[2] = "rangedattackspeed",
		[3] = "rangedattackpower",
		[4] = "rangedhit",
		[5] = "rangedcrit",
		[6] = "hide",
	},
	["PLAYERSTAT_SPELL_COMBAT"] = {
		[1] = "spell",
		[2] = "healing",
		[3] = "spellhit",
		[4] = "spellcrit",
		[5] = "spellhaste",
		[6] = "manaregen",
	},
	["PLAYERSTAT_DEFENSES"] = {
		[1] = "armor",
		[2] = "defense",
		[3] = "dodge",
		[4] = "parry",
		[5] = "block",
		[6] = "resilience",
	},
}


addon.ADDON_LOADED = function(self, event, addon)
	if(addon == "Bebiikaa") then
		db = _G.BebiikaaDB
		if(not db) then
			db = {
				--playerstats = DEFAULTS,
				char = {}
			}
			_G.BebiikaaDB = db
		end
		if(not db.char[name]) then
			if CLASSDEFAULTS[class] then
				db.char[name] = CLASSDEFAULTS[class]
			end
		end
	end
end

addon.PLAYER_LOGIN = function(self, event)
	if db.char[name] then
		PLAYERSTAT_DROPDOWN_OPTIONS[6] = "PLAYERSTAT_CHAR"
		PLAYERSTAT_CHAR = name
	end
end


PAPERDOLL_CLASS_STATS = {
	-- Stats
	["strength"] = function(frame)
		PaperDollFrame_SetStat(frame, 1)
	end,
	["agility"] = function(frame)
		PaperDollFrame_SetStat(frame, 2)
	end,
	["stamina"] = function(frame)
		PaperDollFrame_SetStat(frame, 3)
	end,
	["intellect"] = function(frame)
		PaperDollFrame_SetStat(frame, 4)
	end,
	["spirit"] = function(frame)
		PaperDollFrame_SetStat(frame, 5)
	end,

	-- Custom
	["hide"] = function(frame) frame:Hide() end,
	["holycrit"] = function(frame)
		_G[frame:GetName().."Label"]:SetText"Holy Crit:"
		local text = _G[frame:GetName().."StatText"]
		local holy = GetSpellCritChance(2)
		frame.spellCrit = {}
		frame.spellCrit[2] = holy
		holy = format("%.2f%%", holy)
		local crit
		for i = 3, MAX_SPELL_SCHOOLS do
			crit = GetSpellCritChance(i)
			frame.spellCrit[i] = crit
		end
		text:SetText(holy)
		frame:Show()
		frame:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
	end,
	["castingregen"] = function(frame)
		_G[frame:GetName().."Label"]:SetText"Casting Regen:"
		local text = _G[frame:GetName().."StatText"]
		if not UnitHasMana"player" then text:SetText(NOT_APPLICABLE) frame.tooltip = nil return end
		local base, casting = GetManaRegen()
		base = floor(base * 5.0)
		casting = floor(casting * 5.0)
		text:SetText(casting)
		frame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE
		frame.tooltip2 = format(MANA_REGEN_TOOLTIP, base, casting)
		frame:Show()
	end,

	-- Blizzard Functions
	["healing"] = PaperDollFrame_SetSpellBonusHealing,
	["spellhaste"] = PaperDollFrame_SetSpellHaste,
	["manaregen"] = PaperDollFrame_SetManaRegen,
	["armor"] = PaperDollFrame_SetArmor,
	["defense"] = PaperDollFrame_SetDefense,
	["dodge"] = PaperDollFrame_SetDodge,
	["parry"] = PaperDollFrame_SetParry,
	["block"] = PaperDollFrame_SetBlock,
	["resilience"] = PaperDollFrame_SetResilience,
	["attackspeed"] = PaperDollFrame_SetAttackSpeed,
	["attackpower"] = PaperDollFrame_SetAttackPower,
	["rangedattackspeed"] = PaperDollFrame_SetRangedAttackSpeed,
	["rangedattackpower"] = PaperDollFrame_SetRangedAttackPower,
	["expertise"] = PaperDollFrame_SetExpertise,
	["meleecrit"] = PaperDollFrame_SetMeleeCritChance,
	["rangedcrit"] = PaperDollFrame_SetRangedCritChance,

	-- Blizzard Functions w/SetScripts
	["melee"] = function(frame)
		PaperDollFrame_SetDamage(frame)
		frame:SetScript("OnEnter", CharacterDamageFrame_OnEnter)
	end,
	["ranged"] = function(frame)
		PaperDollFrame_SetRangedDamage(frame)
		frame:SetScript("OnEnter", CharacterRangedDamageFrame_OnEnter)
	end,
	["spell"] = function(frame)
		PaperDollFrame_SetSpellBonusDamage(frame)
		frame:SetScript("OnEnter", CharacterSpellBonusDamage_OnEnter)
	end,
	["spellcrit"] = function(frame)
		PaperDollFrame_SetSpellCritChance(frame)
		frame:SetScript("OnEnter", CharacterSpellCritChance_OnEnter)
	end,

	-- Blizzard Hit Functions
	["meleehit"] = function(frame)
		PaperDollFrame_SetRating(frame, CR_HIT_MELEE)
	end,
	["rangedhit"] = function(frame)
		PaperDollFrame_SetRating(frame, CR_HIT_RANGED)
	end,
	["spellhit"] = function(frame)
		PaperDollFrame_SetRating(frame, CR_HIT_SPELL)
	end,
}

function SetPaperdollStats(prefix, index, isclass)
	local info
	if isclass then
		info = db.char[name]
	else
		info = DEFAULTS[index]
	end
	local stats = PAPERDOLL_CLASS_STATS
	if not info then return end

	for slot, stat in pairs(info) do
		if not stats[stat] then 
			print("Stat \""..stat.."\" not found. Try fixing your config!")
		else
			stats[stat](_G[prefix..slot])
		end
	end
end


hooksecurefunc("UpdatePaperdollStats", function(prefix, index)
	-- Remove any OnEnter set on the frames.
	for i = 1,6 do
		_G[prefix..i]:SetScript("OnEnter", PaperDollStatTooltip)
	end

	-- Show the sixth frame.
	_G[prefix.."6"]:Show()

	if ( index == "PLAYERSTAT_BASE_STATS" ) then
		SetPaperdollStats(prefix, index)
	elseif ( index == "PLAYERSTAT_MELEE_COMBAT" ) then
		SetPaperdollStats(prefix, index)
	elseif ( index == "PLAYERSTAT_RANGED_COMBAT" ) then
		SetPaperdollStats(prefix, index)
	elseif ( index == "PLAYERSTAT_SPELL_COMBAT" ) then
		SetPaperdollStats(prefix, index)
	elseif ( index == "PLAYERSTAT_DEFENSES" ) then
		SetPaperdollStats(prefix, index)
	elseif ( index == "PLAYERSTAT_CHAR" ) then
		if not db.char[name] then return end
		SetPaperdollStats(prefix, index, 1)
	end
end)

addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

addon:RegisterEvent"PLAYER_LOGIN"
addon:RegisterEvent"ADDON_LOADED"

SlashCmdList['BEBIIKAA_CONFIG'] = function(slot, stat)
	if (slot == "list") then
		print"List of possible stats to show:"
		for i in pairs(PAPERDOLL_CLASS_STATS) do
			print(i)
		end
	elseif (type(slot) == "number") AND (slot > 6) then return print"You can only have up to 6 stats shown." 
	elseif (type(slot) == "number") then
		if PAPERDOLL_CLASS_STATS[stat] then
			BebiikaaDB.char[slot] = stat
		else
			print"Stat not valid, please check the list for valid stats"
		end
	else
		print"USAGE"
	end
end

SLASH_BEBIIKAA_CONFIG1 = '/bebiikaa'
SLASH_BEBIIKAA_CONFIG2 = '/bk'

--_G["Bebiikaa"] = addon
