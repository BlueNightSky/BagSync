--[[
	tooltip.lua
		Tooltip module for BagSync

		BagSync - All Rights Reserved - (c) 2006-2023
		License included with addon.
--]]

local BSYC = select(2, ...) --grab the addon namespace
local Tooltip = BSYC:NewModule("Tooltip")
local Unit = BSYC:GetModule("Unit")
local Data = BSYC:GetModule("Data")
local Scanner = BSYC:GetModule("Scanner")
local L = LibStub("AceLocale-3.0"):GetLocale("BagSync")
local LibQTip = LibStub("LibQTip-1.0")

--https://github.com/tomrus88/BlizzardInterfaceCode/blob/classic/Interface/GlueXML/CharacterCreate.lua
RACE_ICON_TCOORDS = {
	["HUMAN_MALE"]		= {0, 0.25, 0, 0.25},
	["DWARF_MALE"]		= {0.25, 0.5, 0, 0.25},
	["GNOME_MALE"]		= {0.5, 0.75, 0, 0.25},
	["NIGHTELF_MALE"]	= {0.75, 1.0, 0, 0.25},
	["TAUREN_MALE"]		= {0, 0.25, 0.25, 0.5},
	["SCOURGE_MALE"]	= {0.25, 0.5, 0.25, 0.5},
	["TROLL_MALE"]		= {0.5, 0.75, 0.25, 0.5},
	["ORC_MALE"]		= {0.75, 1.0, 0.25, 0.5},
	["HUMAN_FEMALE"]	= {0, 0.25, 0.5, 0.75},
	["DWARF_FEMALE"]	= {0.25, 0.5, 0.5, 0.75},
	["GNOME_FEMALE"]	= {0.5, 0.75, 0.5, 0.75},
	["NIGHTELF_FEMALE"]	= {0.75, 1.0, 0.5, 0.75},
	["TAUREN_FEMALE"]	= {0, 0.25, 0.75, 1.0},
	["SCOURGE_FEMALE"]	= {0.25, 0.5, 0.75, 1.0},
	["TROLL_FEMALE"]	= {0.5, 0.75, 0.75, 1.0},
	["ORC_FEMALE"]		= {0.75, 1.0, 0.75, 1.0},
}
local FIXED_RACE_ATLAS = {
	["highmountaintauren"] = "highmountain",
	["lightforgeddraenei"] = "lightforged",
	["scourge"] = "undead",
	["zandalaritroll"] = "zandalari",
}

local function Debug(level, ...)
    if BSYC.DEBUG then BSYC.DEBUG(level, "Tooltip", ...) end
end

local function CanAccessObject(obj)
    return issecure() or not obj:IsForbidden();
end

local function comma_value(n)
	if not n or not tonumber(n) then return "?" end
	return tostring(BreakUpLargeNumbers(tonumber(n)))
end

--https://wowwiki-archive.fandom.com/wiki/User_defined_functions
local function RGBPercToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end

function Tooltip:HexColor(color, str)
	if type(color) == "table" then
		return string.format("|cff%s%s|r", RGBPercToHex(color.r, color.g, color.b), tostring(str))
	end
	if string.len(color) == 8 then
		return string.format("|c%s%s|r", tostring(color), tostring(str))
	else
		return string.format("|cff%s%s|r", tostring(color), tostring(str))
	end
end

function Tooltip:GetItemTypeString(itemType, itemSubType, classID, subclassID)
	if not itemType or not itemSubType then return nil end

	local typeString = "?"
	typeString = itemType.." | "..itemSubType

	if classID then
		--https://wowpedia.fandom.com/wiki/ItemType
		if classID == Enum.ItemClass.Questitem then
			typeString = Tooltip:HexColor('ffccef66', itemType).." | "..itemSubType

		elseif classID == Enum.ItemClass.Profession then
			typeString = Tooltip:HexColor('FF51B9E9', itemType).." | "..itemSubType

		elseif classID == Enum.ItemClass.Armor or classID == Enum.ItemClass.Weapon then
			typeString = Tooltip:HexColor('ff77ffff', itemType).." | "..itemSubType

		elseif classID == Enum.ItemClass.Consumable then
			typeString = Tooltip:HexColor('FF77F077', itemType).." | "..itemSubType

		elseif classID == Enum.ItemClass.Tradegoods then
			typeString = Tooltip:HexColor('FFFFD580', itemType).." | "..itemSubType

		elseif classID == Enum.ItemClass.Reagent then
			typeString = Tooltip:HexColor('ffff7777', itemType).." | "..itemSubType
		end
	end

	--name, isArmorType = GetItemSubClassInfo(classID, subClassID)
	--name = GetItemClassInfo(classID)

	return typeString
end

function Tooltip:GetSortIndex(unitObj)
	if unitObj then
		if not unitObj.isGuild and unitObj.realm == Unit:GetUnitInfo(true).realm then
			return 1
		elseif unitObj.isGuild and unitObj.realm == Unit:GetUnitInfo(true).realm then
			return 2
		elseif not unitObj.isGuild and unitObj.isConnectedRealm then
			return 3
		elseif unitObj.isGuild and unitObj.isConnectedRealm then
			return 4
		elseif not unitObj.isGuild then
			return 5
		end
	end
	return 6
end

function Tooltip:GetRaceIcon(race, gender, size, xOffset, yOffset, useHiRez)
	local raceString = ""
	if not race or not gender then return raceString end

	if BSYC.IsClassic then
		race = race:upper()
		local raceFile = "Interface/Glues/CharacterCreate/UI-CharacterCreate-Races"
		local coords = RACE_ICON_TCOORDS[race.."_"..(gender == 3 and "FEMALE" or "MALE")]
		local left, right, top, bottom = unpack(coords)

		raceString = CreateTextureMarkup(raceFile, 128, 128, size, size, left, right, top, bottom, xOffset, yOffset)
	else
		race = race:lower()
		race = FIXED_RACE_ATLAS[race] or race

		local formatingString = useHiRez and "raceicon128-%s-%s" or "raceicon-%s-%s"
		formatingString = formatingString:format(race, gender == 3 and "female" or "male")

		raceString =  CreateAtlasMarkup(formatingString, size, size, xOffset, yOffset)
	end

	return raceString
end

function Tooltip:GetClassColor(unitObj, switch, bypass, altColor)
	if not unitObj then return altColor or BSYC.options.colors.first end
	if not unitObj.data or not unitObj.data.class then return altColor or BSYC.options.colors.first end

	local doChk = false
	if switch == 1 then
		doChk = BSYC.options.enableUnitClass
	elseif switch == 2 then
		doChk = BSYC.options.itemTotalsByClassColor
	end

	if bypass or ( doChk and RAID_CLASS_COLORS[unitObj.data.class] ) then
		return RAID_CLASS_COLORS[unitObj.data.class]
	end
	return altColor or BSYC.options.colors.first
end

function Tooltip:ColorizeUnit(unitObj, bypass, showRealm, showSimple, showXRBNET)

	if not unitObj.data then return nil end

	local player = Unit:GetUnitInfo(true)
	local tmpTag = ""
	local realm = unitObj.realm
	local realmTag = ""
	local delimiter = " "

	--showSimple: returns only colorized name no images
	--bypass: shows colorized names, checkmark, and faction icons but no XR or BNET tags
	--showRealm: adds realm tags forcefully

	if not unitObj.isGuild then

		--first colorize by class color
		tmpTag = self:HexColor(self:GetClassColor(unitObj, 1, (bypass or showSimple)), unitObj.name)

		--ignore certain stuff if we only want to return simple colored units
		if not showSimple then

			--add green checkmark
			if unitObj.name == player.name and unitObj.realm == player.realm then
				if bypass or BSYC.options.enableTooltipGreenCheck then
					local ReadyCheck = [[|TInterface\RaidFrame\ReadyCheck-Ready:0|t]]
					tmpTag = ReadyCheck.." "..tmpTag
				end
			end

			--add race icons
			if bypass or BSYC.options.showRaceIcons then
				local raceIcon = self:GetRaceIcon(unitObj.data.race, unitObj.data.gender, 13, 0, 0)
				if raceIcon ~= "" then
					tmpTag = raceIcon.." "..tmpTag
				end
			end

		end

	else
		--is guild
		tmpTag = self:HexColor(BSYC.options.colors.guild, select(2, Unit:GetUnitAddress(unitObj.name)) )
	end

	--add faction icons
	if bypass or unitObj.isGuild or BSYC.options.enableFactionIcons then
		local FactionIcon = ""

		if BSYC.IsRetail then
			FactionIcon = [[|TInterface\Icons\Achievement_worldevent_brewmaster:13:13|t]]
			if unitObj.data.faction == "Alliance" then
				FactionIcon = [[|TInterface\FriendsFrame\PlusManz-Alliance:13:13|t]]
			elseif unitObj.data.faction == "Horde" then
				FactionIcon = [[|TInterface\FriendsFrame\PlusManz-Horde:13:13|t]]
			end
		else
			FactionIcon = [[|TInterface\Icons\ability_seal:18|t]]
			if unitObj.data.faction == "Alliance" then
				FactionIcon = [[|TInterface\FriendsFrame\PlusManz-Alliance:13:13|t]]
			elseif unitObj.data.faction == "Horde" then
				FactionIcon = [[|TInterface\FriendsFrame\PlusManz-Horde:13:13|t]]
			end
		end

		if FactionIcon ~= "" then
			tmpTag = FactionIcon.." "..tmpTag
		end
	end

	----------------
	--If we Bypass or showSimple none of the XR or BNET stuff will be shown
	----------------
	if bypass or showSimple then
		--since we Bypass don't show anything else just return what we got
		return tmpTag
	end
	----------------

	if BSYC.options.enableXR_BNETRealmNames then
		realm = unitObj.realm
	elseif BSYC.options.enableRealmAstrickName then
		realm = "*"
	elseif BSYC.options.enableRealmShortName then
		realm = string.sub(unitObj.realm, 1, 5)
	elseif showRealm then
		realm = unitObj.realm
	else
		realm = ""
		delimiter = ""
	end

	if (showXRBNET or BSYC.options.enableBNetAccountItems) and not unitObj.isConnectedRealm then
		realmTag = (showXRBNET or BSYC.options.enableRealmIDTags) and L.TooltipBattleNetTag..delimiter or ""
		if string.len(realm) > 0 or string.len(realmTag) > 0 then
			tmpTag = self:HexColor(BSYC.options.colors.bnet, "["..realmTag..realm.."]").." "..tmpTag
		end
	end

	if (showXRBNET or BSYC.options.enableCrossRealmsItems) and unitObj.isConnectedRealm and unitObj.realm ~= player.realm then
		realmTag = (showXRBNET or BSYC.options.enableRealmIDTags) and L.TooltipCrossRealmTag..delimiter or ""
		if string.len(realm) > 0 or string.len(realmTag) > 0 then
			tmpTag = self:HexColor(BSYC.options.colors.cross, "["..realmTag..realm.."]").." "..tmpTag
		end
	end

	--if it's a connected realm guild the player belongs to, then show the XR tag.  This option only true if the XR and BNET options are off.
	if unitObj.isXRGuild then
		realmTag = L.TooltipCrossRealmTag
		if string.len(realm) > 0 or string.len(realmTag) > 0 then
			--use an asterisk to denote that we are using a XRGuild Tag
			tmpTag = self:HexColor(BSYC.options.colors.cross, "[*"..realmTag..realm.."]").." "..tmpTag
		end
	end

	Debug(BSYC_DL.INFO, "ColorizeUnit", tmpTag, unitObj.realm, unitObj.isConnectedRealm, unitObj.isXRGuild, player.realm)
	Debug(BSYC_DL.SL2, "ColorizeUnit [Realm]", GetRealmName(), GetNormalizedRealmName())

	return tmpTag
end

function Tooltip:DoSort(tblData)

	--sort the list by our sortIndex then by realm and finally by name
	if BSYC.options.sortTooltipByTotals then
		table.sort(tblData, function(a, b)
			return a.count > b.count;
		end)
	elseif BSYC.options.sortByCustomOrder then
		table.sort(tblData, function(a, b)
			if a.unitObj.data.SortIndex and b.unitObj.data.SortIndex  then
				return  a.unitObj.data.SortIndex < b.unitObj.data.SortIndex;
			else
				if a.sortIndex  == b.sortIndex then
					if a.unitObj.realm == b.unitObj.realm then
						return a.unitObj.name < b.unitObj.name;
					end
					return a.unitObj.realm < b.unitObj.realm;
				end
				return a.sortIndex < b.sortIndex;
			end
		end)
	else
		table.sort(tblData, function(a, b)
			if a.sortIndex  == b.sortIndex then
				if a.unitObj.realm == b.unitObj.realm then
					return a.unitObj.name < b.unitObj.name;
				end
				return a.unitObj.realm < b.unitObj.realm;
			end
			return a.sortIndex < b.sortIndex;
		end)
	end

	return tblData
end

function Tooltip:AddItem(unitObj, itemID, target, countList)
	local total = 0
	if not unitObj or not itemID or not target or not countList then return total end
	if not unitObj.data then return total end

	local function getTotal(data)
		local iCount = 0
		for i=1, #data do
			if data[i] then
				local link, count = BSYC:Split(data[i], true)
				if link then
					if link == itemID then
						iCount = iCount + (count or 1)
					end
				end
			end
		end
		return iCount
	end

	if target == "bag" or target == "bank" or target == "reagents" then
		for bagID, bagData in pairs(unitObj.data[target] or {}) do
			total = total + getTotal(bagData)
		end

	elseif target == "auction" and BSYC.options.enableAuction then
		total = getTotal((unitObj.data[target] and unitObj.data[target].bag) or {})

	elseif target == "mailbox" and BSYC.options.enableMailbox then
		total = getTotal(unitObj.data[target] or {})

	elseif target == "equip" or target == "void" then
		total = getTotal(unitObj.data[target] or {})

	elseif target == "guild" and BSYC.options.enableGuild then
		countList.gtab = {}
		for tabID, tabData in pairs(unitObj.data.tabs) do
			local tabCount = getTotal(tabData)
			if tabCount > 0 then
				countList.gtab[tabID] = tabCount
			end
			total = total + tabCount
		end
	end

	countList[target] = total

	return total
end

function Tooltip:GetCountString(colorType, dispType, srcType, srcCount, addStr)
	local desc = self:HexColor(colorType, L[dispType..srcType])
	local count = self:HexColor(BSYC.options.colors.second, comma_value(srcCount))
	local tmp = string.format("%s: %s", desc, count)..(addStr or "")
	return tmp
end

function Tooltip:UnitTotals(unitObj, countList, unitList, advUnitList)
	local total = 0
	local tallyCount = {}
	local dispType = ""
	local colorType = self:GetClassColor(unitObj, 2)

	if BSYC.options.singleCharLocations then
		dispType = "TooltipSmall_"
	elseif BSYC.options.useIconLocations then
		dispType = "TooltipIcon_"
	else
		dispType = "Tooltip_"
	end

	if ((countList["bag"] or 0) > 0) then
		total = total + countList["bag"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "bag", countList["bag"]))
	end
	if ((countList["bank"] or 0) > 0) then
		total = total + countList["bank"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "bank", countList["bank"]))
	end
	if ((countList["reagents"] or 0) > 0) then
		total = total + countList["reagents"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "reagents", countList["reagents"]))
	end
	if ((countList["equip"] or 0) > 0) then
		total = total + countList["equip"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "equip", countList["equip"]))
	end
	if ((countList["mailbox"] or 0) > 0) then
		total = total + countList["mailbox"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "mailbox", countList["mailbox"]))
	end
	if ((countList["void"] or 0) > 0) then
		total = total + countList["void"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "void", countList["void"]))
	end
	if ((countList["auction"] or 0) > 0) then
		total = total + countList["auction"]
		table.insert(tallyCount, self:GetCountString(colorType, dispType, "auction", countList["auction"]))
	end
	if ((countList["guild"] or 0) > 0) then
		total = total + countList["guild"]
		local gTabStr = ""

		--check for guild tabs first
		if BSYC.options.showGuildTabs then
			table.sort(countList["gtab"], function(a, b) return a < b end)

			for k, v in pairs(countList["gtab"]) do
				gTabStr = gTabStr..","..tostring(k)
			end
			gTabStr = string.sub(gTabStr, 2)  -- remove comma

			--check for guild tab
			if string.len(gTabStr) > 0 then
				gTabStr = self:HexColor(BSYC.options.colors.guildtabs, " ["..L.TooltipGuildTabs.." "..gTabStr.."]")
			end
		end

		table.insert(tallyCount, self:GetCountString(colorType, dispType, "guild", countList["guild"], gTabStr))
	end

	if total < 1 then return end
	local tallyString = ""

    if (#tallyCount > 0) then
		--if we only have one entry, then display that and no need to sort or concat
		if #tallyCount == 1 then
			tallyString = tallyCount[1]
		else
			table.sort(tallyCount)
			tallyString = self:HexColor(BSYC.options.colors.second, comma_value(total)).." ("..table.concat(tallyCount, L.TooltipDelimiter.." ")..")"
		end
    end
	if #tallyCount <= 0 or string.len(tallyString) < 1 then return end

	--add to list
	local doAdv = (advUnitList and true) or false
	local unitData = {
		unitObj=unitObj,
		colorized=self:ColorizeUnit(unitObj, false, doAdv, false, doAdv),
		tallyString=tallyString,
		sortIndex=self:GetSortIndex(unitObj),
		count=total
	}
	table.insert(unitList, unitData)
	return unitData
end

function Tooltip:GetBottomChild()
	Debug(BSYC_DL.TRACE, "GetBottomChild", Tooltip.objTooltip, Tooltip.qTip)

	local frame, qTip = Tooltip.objTooltip, Tooltip.qTip
	if not qTip then return end

	local cache = {}

	qTip:ClearAllPoints()

	local function getMinLoc(top, bottom)
		if top and bottom then
			if top < bottom then
				return "top", top
			else
				return "bottom", bottom
			end
		elseif top then
			return "top", top
		elseif bottom then
			return "bottom", bottom
		end
	end

	--first do TradeSkillMaster
	if _G.IsAddOnLoaded("TradeSkillMaster") then
        for i=1, 20 do
            local t = _G["TSMExtraTip" .. i]
            if t and t:IsVisible() then
				local loc, pos = getMinLoc(t:GetTop(), t:GetBottom())
				table.insert(cache, {name="TradeSkillMaster", frame=t, loc=loc, pos=pos})
			elseif not t then
				break
            end
        end
    end

	--check for LibExtraTip (Auctioneer, Oribos Exchange Addon, etc...)
	if LibStub and LibStub.libs and LibStub.libs["LibExtraTip-1"] then
		local t = LibStub("LibExtraTip-1"):GetExtraTip(frame)
		if t and t:IsVisible() then
			local loc, pos = getMinLoc(t:GetTop(), t:GetBottom())
			table.insert(cache, {name="LibExtraTip-1", frame=t, loc=loc, pos=pos})
		end
	end

	--check for BattlePetBreedID addon (Fixes #231)
	if BPBID_BreedTooltip or BPBID_BreedTooltip2 then
		local t = BPBID_BreedTooltip or BPBID_BreedTooltip2
		if t and t:IsVisible() then
			local loc, pos = getMinLoc(t:GetTop(), t:GetBottom())
			table.insert(cache, {name="BattlePetBreedID", frame=t, loc=loc, pos=pos})
		end
	end

	--find closest to edge (closer to 0)
	local lastLoc
	local lastPos
	local lastAnchor
	local lastName

	for i=1, #cache do
		local data = cache[i]
		if data and data.frame and data.loc and data.pos then
			if not lastPos then lastPos = data.pos end
			if not lastLoc then lastLoc = data.loc end
			if not lastAnchor then lastAnchor = data.frame end
			if not lastName then lastName = data.name end

			if data.pos <  lastPos then
				lastPos = data.pos
				lastLoc = data.loc
				lastAnchor = data.frame
				lastName = data.name
			end
		end
	end

	if lastAnchor and lastLoc and lastPos then
		Debug(BSYC_DL.SL3, "GetBottomChild", lastAnchor, lastLoc, lastPos, lastName)
		if lastLoc == "top" then
			qTip:SetPoint("BOTTOM", lastAnchor, "TOP")
		else
			qTip:SetPoint("TOP", lastAnchor, "BOTTOM")
		end
		return
	end

	--failsafe
	self:SetQTipAnchor(frame, qTip)
end

function Tooltip:SetQTipAnchor(frame, qTip)
	Debug(BSYC_DL.SL2, "SetQTipAnchor", frame, qTip)

    local x, y = frame:GetCenter()

    if not x or not y then
        qTip:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
		return
    end

    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "LEFT" or (x < UIParent:GetWidth() / 3) and "RIGHT" or ""
	--adjust the 4 to make it less sensitive on the top/bottom.  The higher the number the closer to the edges it's allowed.
    local vhalf = (y > UIParent:GetHeight() / 4) and "TOP" or "BOTTOM"

	qTip:SetPoint(vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf)
end

function Tooltip:ResetCache()
	if Data.__cache and Data.__cache.tooltip then
		Data.__cache.tooltip = {}
	end
end

function Tooltip:ResetLastLink()
	self.__lastLink = nil
end

function Tooltip:CheckModifier()
	if BSYC.options.tooltipModifer then
		local modKey = BSYC.options.tooltipModifer
		if modKey == "ALT" and not IsAltKeyDown() then
			return false
		elseif modKey == "CTRL" and not IsControlKeyDown() then
			return false
		elseif modKey == "SHIFT" and not IsShiftKeyDown() then
			return false
		end
	end
	return true
end

function Tooltip:TallyUnits(objTooltip, link, source, isBattlePet)
	if not BSYC.options.enableTooltips then return end
	if not CanAccessObject(objTooltip) then return end
	if Scanner.isScanningGuild then return end --don't tally while we are scanning the Guildbank

	--check for modifier option
	if not self:CheckModifier() then return end

	local showQTip = false
	local skipTally = false

	Tooltip.objTooltip = objTooltip

	--create the extra tooltip (qTip) only if it doesn't already exist
	if BSYC.options.enableExtTooltip or isBattlePet then
		local doQTip = true
		--only show the external tooltip if we have the option enabled, otherwise show it inside the tooltip if isBattlePet
		if source == "ArkInventory" and not BSYC.options.enableExtTooltip then doQTip = false end
		if doQTip then
			if not Tooltip.qTip then
				Tooltip.qTip = LibQTip:Acquire("BagSyncQTip", 3, "LEFT", "CENTER", "RIGHT")
				Tooltip.qTip:SetClampedToScreen(true)

				Tooltip.qTip:SetScript("OnShow", function()
					Tooltip:GetBottomChild()
				end)
			end
			Tooltip.qTip:Clear()
			showQTip = true
		end
	end
	--release it if we aren't using the qTip
	if Tooltip.qTip and not showQTip then
		LibQTip:Release(Tooltip.qTip)
		Tooltip.qTip = nil
	end

	local tooltipOwner = objTooltip.GetOwner and objTooltip:GetOwner()
	local tooltipType = tooltipOwner and tooltipOwner.obj and tooltipOwner.obj.type

	--only show tooltips in search frame if the option is enabled
	if BSYC.options.tooltipOnlySearch and (not tooltipOwner or not tooltipType or tooltipType ~= "BagSyncInteractiveLabel")  then
		objTooltip:Show()
		return
	end

	local origLink = link --store the original unparsed link
	--remember when no count is provided to ParseItemLink, only the itemID is returned.  Integer or a string if it has bonusID
	link = BSYC:ParseItemLink(link)

	--make sure we have something to work with
	if not link then
		objTooltip:Show()
		return
	end

	link = BSYC:Split(link, true) --if we are parsing a database entry, return only the itemID portion

	--we do this because the itemID portion can be something like 190368::::::::::::5:8115:7946:6652:7579:1491::::::
	local shortID = BSYC:GetShortItemID(link)
	if isBattlePet then origLink = shortID end

	--if we already did the item, then display the previous information, use the unparsed link to verify
	if self.__lastLink and self.__lastLink == origLink then
		if self.__lastTally and #self.__lastTally > 0 then
			for i=1, #self.__lastTally do
				local color = self:GetClassColor(self.__lastTally[i].unitObj, 2, false, BSYC.options.colors.total)
				if showQTip then
					local lineNum = Tooltip.qTip:AddLine(self.__lastTally[i].colorized, string.rep(" ", 4), self.__lastTally[i].tallyString)
					Tooltip.qTip:SetLineTextColor(lineNum, color.r, color.g, color.b, 1)
				else
					objTooltip:AddDoubleLine(self.__lastTally[i].colorized, self.__lastTally[i].tallyString, color.r, color.g, color.b, color.r, color.g, color.b)
				end
			end
			objTooltip:Show()
			if showQTip then Tooltip.qTip:Show() end
		end
		objTooltip.__tooltipUpdated = true
		return
	end

	local permIgnore ={
		[6948] = "Hearthstone",
		[110560] = "Garrison Hearthstone",
		[140192] = "Dalaran Hearthstone",
		[128353] = "Admiral's Compass",
		[141605] = "Flight Master's Whistle",
	}
	--check blacklist
	if shortID and (permIgnore[tonumber(shortID)] or BSYC.db.blacklist[tonumber(shortID)]) then
		skipTally = true
	end
	--check whitelist
	if BSYC.options.enableWhitelist then
		if not BSYC.db.whitelist[tonumber(shortID)] then
			skipTally = true
		end
		--always display if we are showing tooltips in the search window of ANY kind when using whitelist
		if tooltipType and tooltipType == "BagSyncInteractiveLabel" then
			skipTally = false
		end
	end

	--short the shortID and ignore all BonusID's and stats
	if BSYC.options.enableShowUniqueItemsTotals and shortID then link = shortID end

	--store these in the addon itself not in the tooltip
	self.__lastTally = {}
	self.__lastLink = origLink

	local grandTotal = 0
	local unitList = {}
	local countList = {}
	local player = Unit:GetUnitInfo(false)

	local allowList = {
		bag = true,
		bank = true,
		reagents = true,
		equip = true,
		mailbox = true,
		void = true,
		auction = true,
	}

	--the true option for GetModule is to set it to silent and not return an error if not found
	--only display advanced search results in the BagSync search window
	local advUnitList = not skipTally and BSYC:GetModule("Search", true) and BSYC:GetModule("Search").advUnitList

	--DB TOOLTIP COUNTS
	-------------------
	if advUnitList or not skipTally then

		--OTHER PLAYERS AND GUILDS
		-----------------
		--CACHE CHECK
		--NOTE: This cache check is ONLY for units (guild, players) that isn't related to the current player.  Since that data doesn't really change we can cache those lines
		--For the player however, we always want to grab the latest information.  So once it's grabbed we can do a small local cache for that using __lastTally
		if not Data.__cache.tooltip[origLink] then

			--allow advance search matches if found, no need to set to true as advUnitList will default to dumpAll if found
			for unitObj in Data:IterateUnits(false, advUnitList) do

				countList = {}

				if not unitObj.isGuild then
					--Due to crafting items being used in reagents bank, or turning in quests with items in the bank, etc..
					--The cached item info for the current player would obviously be out of date until they returned to the bank to scan again.
					--In order to combat this, lets just get the realtime count for the currently logged in player every single time.
					--This is why we check for player name and realm below, we don't want to do anything in regards to the current player when the Database.

					local isCurrentPlayer = ((unitObj.name == player.name and unitObj.realm == player.realm) and true) or false
					if not isCurrentPlayer then
						for k, v in pairs(allowList) do
							grandTotal = grandTotal + self:AddItem(unitObj, link, k, countList)
						end
					end
				else
					--don't cache the players guild bank, lets get that in real time in case they put stuff in it
					if not player.guild or unitObj.realm ~= player.guildrealm or unitObj.name ~= player.guild then
						grandTotal = grandTotal + self:AddItem(unitObj, link, "guild", countList)
					end
				end

				--only process the totals if we have something to work with
				if grandTotal > 0 then
					--table variables gets passed as byRef
					self:UnitTotals(unitObj, countList, unitList, advUnitList)
				end
			end

			--store it in the cache, copy the tables don't reference them
			Data.__cache.tooltip[origLink] = Data.__cache.tooltip[origLink] or {}
			Data.__cache.tooltip[origLink].unitList = CopyTable(unitList)
			Data.__cache.tooltip[origLink].grandTotal = grandTotal

		else
			--use the cached results from previous DB searches, copy the table don't reference it
			unitList = CopyTable(Data.__cache.tooltip[origLink].unitList)
			grandTotal = Data.__cache.tooltip[origLink].grandTotal
			Debug(BSYC_DL.INFO, "TallyUnits", "|cFF09DBE0CacheUsed|r", origLink)
		end

		--CURRENT PLAYER
		-----------------
		if not advUnitList or (advUnitList and advUnitList[player.realm] and advUnitList[player.realm][player.name]) then
			countList = {}
			local playerObj = Data:GetCurrentPlayer()

			grandTotal = grandTotal + self:AddItem(playerObj, link, "equip", countList)
			--GetItemCount does not work in the auction, void bank or mailbox, grab manually
			grandTotal = grandTotal + self:AddItem(playerObj, link, "auction", countList)
			grandTotal = grandTotal + self:AddItem(playerObj, link, "void", countList)
			grandTotal = grandTotal + self:AddItem(playerObj, link, "mailbox", countList)

			--GetItemCount does not work on battlepet links
			if isBattlePet then
				grandTotal = grandTotal + self:AddItem(playerObj, link, "bag", countList)
				grandTotal = grandTotal + self:AddItem(playerObj, link, "bank", countList)
				grandTotal = grandTotal + self:AddItem(playerObj, link, "reagents", countList)

			elseif not isBattlePet then
				local equipCount = countList["equip"] or 0
				local carryCount, bagCount, bankCount, regCount = 0, 0, 0, 0

				carryCount = GetItemCount(origLink) or 0 --get the total amount the player is currently carrying (bags + equip)
				bagCount = carryCount - equipCount -- subtract the equipment count from the carry amount to get bag count

				if IsReagentBankUnlocked and IsReagentBankUnlocked() then
					--GetItemCount returns the bag count + reagent regardless of parameters.  So we have to subtract bag and reagents.  This does not include bank totals
					regCount = GetItemCount(origLink, false, false, true) or 0
					regCount = regCount - carryCount
					if regCount < 0 then regCount = 0 end
				end

				--bankCount = GetItemCount returns the bag + bank count + reagent regardless of parameters.  So we have to subtract the carry and reagent totals
				--it will always add the reagents totals regardless of whatever parameters are passed.  So we have to do some math to adjust for this
				bankCount = GetItemCount(origLink, true, false, false) or 0
				bankCount = (bankCount - regCount) - carryCount
				if bankCount < 0 then bankCount = 0 end

				-- --now assign the values
				countList.bag = bagCount
				countList.bank = bankCount
				countList.reagents = regCount
				grandTotal = grandTotal + (bagCount + bankCount + regCount)
			end

			if grandTotal > 0 then
				--table variables gets passed as byRef
				self:UnitTotals(playerObj, countList, unitList, advUnitList)
			end
		end

		--CURRENT PLAYER GUILD
		--We do this separately so that the guild has it's own line in the unitList and not included inline with the player character
		--We also want to do this in real time and not cache, otherwise they may put stuff in their guild bank which will not be reflected in a cache
		-----------------
		if player.guild then
			if not advUnitList or (advUnitList and advUnitList[player.guildrealm] and advUnitList[player.guildrealm][player.guild]) then
				countList = {}
				local guildObj = Data:GetPlayerGuild()
				grandTotal = grandTotal + self:AddItem(guildObj, link, "guild", countList)
				if grandTotal > 0 then
					--table variables gets passed as byRef
					self:UnitTotals(guildObj, countList, unitList, advUnitList)
				end
			end
		end

		--only sort items if we have something to work with
		if #unitList > 0 then
			unitList = self:DoSort(unitList)
		end
	end

	--EXTRA OPTIONAL DISPLAYS
	-------------------------
	local desc, value = '', ''
	local addSeparator = false

	--add [Total] if we have more than one unit to work with
	if not skipTally and BSYC.options.showTotal and grandTotal > 0 and #unitList > 1 then
		--add a separator after the character list
		table.insert(unitList, { colorized=" ", tallyString=" "} )

		desc = self:HexColor(BSYC.options.colors.total, L.TooltipTotal)
		value = self:HexColor(BSYC.options.colors.second, comma_value(grandTotal))
		table.insert(unitList, { colorized=desc, tallyString=value} )
	end

	--add ItemID
	if BSYC.options.enableTooltipItemID and shortID then
		desc = self:HexColor(BSYC.options.colors.itemid, L.TooltipItemID)
		value = self:HexColor(BSYC.options.colors.second, shortID)
		if isBattlePet then
			desc = string.format("|cFFCA9BF7%s|r ", L.TooltipFakeID)
		end
		if not addSeparator then
			table.insert(unitList, 1, { colorized=" ", tallyString=" "} )
			addSeparator = true
		end
		table.insert(unitList, 1, { colorized=desc, tallyString=value} )
	end

	--don't do expansion or itemtype information for battlepets
	if not isBattlePet then
		--add expansion
		if BSYC.IsRetail and BSYC.options.enableSourceExpansion and shortID then
			desc = self:HexColor(BSYC.options.colors.expansion, L.TooltipExpansion)

			local expacID = select(15, GetItemInfo(shortID))
			value = self:HexColor(BSYC.options.colors.second, (expacID and _G["EXPANSION_NAME"..expacID]) or "?")

			if not addSeparator then
				table.insert(unitList, 1, { colorized=" ", tallyString=" "} )
				addSeparator = true
			end
			table.insert(unitList, 1, { colorized=desc, tallyString=value} )
		end
		--add item types
		if BSYC.options.enableItemTypes and shortID then
			local itemType, itemSubType, _, _, _, _, classID, subclassID = select(6, GetItemInfo(shortID))
			local typeString = Tooltip:GetItemTypeString(itemType, itemSubType, classID, subclassID)

			if typeString then
				desc = self:HexColor(BSYC.options.colors.itemtypes, L.TooltipItemType)
				value = self:HexColor(BSYC.options.colors.second, typeString)

				if not addSeparator then
					table.insert(unitList, 1, { colorized=" ", tallyString=" "} )
					addSeparator = true
				end
				table.insert(unitList, 1, { colorized=desc, tallyString=value} )
			end
		end
	end

	--add debug info
	if BSYC.options.enableSourceDebugInfo and source then
		desc = self:HexColor(BSYC.options.colors.debug, L.TooltipDebug)
		value = self:HexColor(BSYC.options.colors.second, "1;"..source..";"..tostring(shortID or 0)..";"..tostring(isBattlePet or "false"))
		table.insert(unitList, 1, { colorized=" ", tallyString=" "} )
		table.insert(unitList, 1, { colorized=desc, tallyString=value} )
	end

	--add separator if enabled and only if we have something to work with
	if not showQTip and BSYC.options.enableTooltipSeparator and #unitList > 0 then
		table.insert(unitList, 1, { colorized=" ", tallyString=" "} )
	end

	--finally display it
	for i=1, #unitList do
		local color = self:GetClassColor(unitList[i].unitObj, 2, false, BSYC.options.colors.total)
		if showQTip then
			-- Add an new line, using all columns
			local lineNum = Tooltip.qTip:AddLine(unitList[i].colorized, string.rep(" ", 4), unitList[i].tallyString)
			Tooltip.qTip:SetLineTextColor(lineNum, color.r, color.g, color.b, 1)
		else
			objTooltip:AddDoubleLine(unitList[i].colorized, unitList[i].tallyString, color.r, color.g, color.b, color.r, color.g, color.b)
		end
	end

	--this is only a local cache for the current tooltip and will be reset on bag updates, it is not the same as Data.__cache.tooltip
	self.__lastTally = unitList

	objTooltip.__tooltipUpdated = true
	objTooltip:Show()

	if showQTip then
		if #unitList > 0 then
			Tooltip.qTip:Show()
		else
			Tooltip.qTip:Hide()
		end
	end

	local WLChk = (BSYC.options.enableWhitelist and "WL-ON") or "WL-OFF"
	Debug(BSYC_DL.INFO, "TallyUnits", shortID, source, isBattlePet, grandTotal, WLChk)
end

function Tooltip:CurrencyTooltip(objTooltip, currencyName, currencyIcon, currencyID, source)
	Debug(BSYC_DL.INFO, "CurrencyTooltip", currencyName, currencyIcon, currencyID, source)

	currencyID = tonumber(currencyID) --make sure it's a number we are working with and not a string
	if not currencyID then return end

	--loop through our characters
	local usrData = {}

	local permIgnore ={
		[2032] = "Trader's Tender", --shared across all characters
	}
	if permIgnore[currencyID] then return end

	for unitObj in Data:IterateUnits() do
		if not unitObj.isGuild and unitObj.data.currency and unitObj.data.currency[currencyID] and unitObj.data.currency[currencyID].count > 0 then
			table.insert(usrData, {
				unitObj=unitObj,
				colorized=self:ColorizeUnit(unitObj),
				sortIndex=self:GetSortIndex(unitObj),
				count=unitObj.data.currency[currencyID].count
			})
		end
	end

	--sort
	usrData = self:DoSort(usrData)

	if currencyName then
		objTooltip:AddLine(currencyName, 64/255, 224/255, 208/255)
		objTooltip:AddLine(" ")
	end

	for i=1, #usrData do
		if usrData[i].count then
			objTooltip:AddDoubleLine(usrData[i].colorized, comma_value(usrData[i].count), 1, 1, 1, 1, 1, 1)
		end
	end
	if #usrData <= 0 then
		objTooltip:AddDoubleLine(NONE, "", 1, 1, 1, 1, 1, 1)
	end

	if BSYC.options.enableTooltipItemID and currencyID then
		local desc = self:HexColor(BSYC.options.colors.itemid, L.TooltipCurrencyID)
		local value = self:HexColor(BSYC.options.colors.second, currencyID)
		objTooltip:AddDoubleLine(" ", " ", 1, 1, 1, 1, 1, 1)
		objTooltip:AddDoubleLine(desc, value, 1, 1, 1, 1, 1, 1)
	end

	if BSYC.options.enableSourceDebugInfo and source then
		local desc = self:HexColor(BSYC.options.colors.debug, L.TooltipDebug)
		local value = self:HexColor(BSYC.options.colors.second, "2;"..source..";"..tostring(currencyID or 0)..";"..tostring(currencyIcon or 0))
		objTooltip:AddDoubleLine(" ", " ", 1, 1, 1, 1, 1, 1)
		objTooltip:AddDoubleLine(desc, value, 1, 1, 1, 1, 1, 1)
	end

	objTooltip.__tooltipUpdated = true
	objTooltip:Show()
end

function Tooltip:HookTooltip(objTooltip)
	--if the tooltip doesn't exist, chances are it's the BattlePetTooltip and they are on Classic or WOTLK
	if not objTooltip then return end

	Debug(BSYC_DL.INFO, "HookTooltip", objTooltip)

	--MORE INFO (https://wowpedia.fandom.com/wiki/Category:API_namespaces/C_TooltipInfo)
	--https://wowpedia.fandom.com/wiki/Patch_10.0.2/API_changes#Tooltip_Changes
	--https://github.com/tomrus88/BlizzardInterfaceCode/blob/e4385aa29a69121b3a53850a8b2fcece9553892e/Interface/SharedXML/Tooltip/TooltipDataHandler.lua
	--https://wowpedia.fandom.com/wiki/Patch_10.0.2/API_changes

	objTooltip:HookScript("OnHide", function(self)
		self.__tooltipUpdated = false
		--we don't want to Release() the qTip until we aren't using it anymore because they disabled it.  Otherwise just hide it.
		if Tooltip.qTip then Tooltip.qTip:Hide() end
	end)
	--the battlepet tooltips don't use this, so check for it
	if objTooltip ~= BattlePetTooltip and objTooltip ~= FloatingBattlePetTooltip then
		objTooltip:HookScript("OnTooltipCleared", function(self)
			--this gets called repeatedly on some occasions. Do not reset Tooltip cache here at all
			self.__tooltipUpdated = false
		end)
	else
		--this is required for the battlepet tooltips, otherwise it will flood the tooltip with data
		objTooltip:HookScript("OnShow", function(self)
			if self.__tooltipUpdated then return end
		end)
	end

	if TooltipDataProcessor then

		--Note: tooltip data type corresponds to the Enum.TooltipDataType types
		--i.e Enum.TooltipDataType.Unit it type 2
		--see https://github.com/tomrus88/BlizzardInterfaceCode/blob/de20049d4dc15eb268fb959148220acf0a23694c/Interface/AddOns/Blizzard_APIDocumentationGenerated/TooltipInfoSharedDocumentation.lua

		local function OnTooltipSetItem(tooltip, data)
			if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip or tooltip == ItemRefTooltip) then
				if tooltip.__tooltipUpdated then return end

				local link

				--data.guid is given to items that have additional bonus stats and such and basically do not return a simple itemID #
				if data.guid then
					link = C_Item.GetItemLinkByGUID(data.guid)

				elseif data.hyperlink then
					link = data.hyperlink

					local shortID = tonumber(BSYC:GetShortItemID(link))

					if data.id and shortID and data.id ~= shortID then
						--if the data.id doesn't match the shortID it's probably a pattern, schematic, etc.. 
						--This is because the hyperlink is overwritten during the args process with TooltipUtil.SurfaceArgs.
						--Pattern hyperlinks are usally args3 but get overwritten when they get to args7 that has the hyperlink of the item being crafted.
						--Instead the pattern/recipe/schematic is returned in the data.id, because that is the only thing not overwritten
						link = data.id
					end
				end

				if link then
					Tooltip:TallyUnits(tooltip, link, "OnTooltipSetItem")
				end
			end
		end
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)

		local function OnTooltipSetCurrency(tooltip, data)

			if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip or tooltip == ItemRefTooltip) then
				if tooltip.__tooltipUpdated then return end

				local link = data.id or data.hyperlink
				local currencyID = BSYC:GetShortCurrencyID(link)

				if currencyID then
					local currencyData = C_CurrencyInfo.GetCurrencyInfo(currencyID)
					if currencyData then
						Tooltip:CurrencyTooltip(tooltip, currencyData.name, currencyData.iconFileID, currencyID, "OnTooltipSetCurrency")
					end
				end
			end
		end
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, OnTooltipSetCurrency)

		--add support for ArkInventory (Fixes #231)
		if ArkInventory and ArkInventory.API and ArkInventory.API.CustomBattlePetTooltipReady then
			hooksecurefunc(ArkInventory.API, "CustomBattlePetTooltipReady", function(tooltip, link)
				if tooltip.__tooltipUpdated then return end
				if link then
					Tooltip:TallyUnits(tooltip, link, "ArkInventory", true)
				end
			end)
		else
			--BattlePetToolTip_Show
			if objTooltip == BattlePetTooltip then
				hooksecurefunc("BattlePetToolTip_Show", function(speciesID, level, breedQuality, maxHealth, power, speed, name)
					if objTooltip.__tooltipUpdated then return end
					if speciesID then
						local fakeID = BSYC:CreateFakeID(nil, nil, speciesID, level, breedQuality, maxHealth, power, speed, name)
						if fakeID then
							Tooltip:TallyUnits(objTooltip, fakeID, "BattlePetToolTip_Show", true)
						end
					end
				end)
			end
			--FloatingBattlePet_Show
			if objTooltip == FloatingBattlePetTooltip then
				hooksecurefunc("FloatingBattlePet_Show", function(speciesID, level, breedQuality, maxHealth, power, speed, name)
					if objTooltip.__tooltipUpdated then return end
					if speciesID then
						local fakeID = BSYC:CreateFakeID(nil, nil, speciesID, level, breedQuality, maxHealth, power, speed, name)
						if fakeID then
							Tooltip:TallyUnits(objTooltip, fakeID, "FloatingBattlePet_Show", true)
						end
					end
				end)
			end
		end

	else

		objTooltip:HookScript("OnTooltipSetItem", function(self)
			if self.__tooltipUpdated then return end
			local name, link = self:GetItem()
			if link then
				--sometimes the link is an empty link with the name being |h[]|h, its a bug with GetItem()
				--so lets check for that
				local linkName = string.match(link, "|h%[(.-)%]|h")
				if not linkName or string.len(linkName) < 1 then return nil end  -- we don't want to store or process it

				Tooltip:TallyUnits(self, link, "OnTooltipSetItem")
			end
		end)

		hooksecurefunc(objTooltip, "SetQuestLogItem", function(self, itemType, index)
			if self.__tooltipUpdated then return end
			local link = GetQuestLogItemLink(itemType, index)
			if link then
				Tooltip:TallyUnits(self, link, "SetQuestLogItem")
			end
		end)
		hooksecurefunc(objTooltip, "SetQuestItem", function(self, itemType, index)
			if self.__tooltipUpdated then return end
			local link = GetQuestItemLink(itemType, index)
			if link then
				Tooltip:TallyUnits(self, link, "SetQuestItem")
			end
		end)

		--only parse CraftFrame when it's not the RETAIL but Classic and TBC, because this was changed to TradeSkillUI on retail
		hooksecurefunc(objTooltip, "SetCraftItem", function(self, index, reagent)
			if self.__tooltipUpdated then return end
			local _, _, count = GetCraftReagentInfo(index, reagent)
			--YOU NEED to do the above or it will return an empty link!
			local link = GetCraftReagentItemLink(index, reagent)
			if link then
				Tooltip:TallyUnits(self, link, "SetCraftItem")
			end
		end)

	end

end

function Tooltip:OnEnable()
	Debug(BSYC_DL.INFO, "OnEnable")

	self:HookTooltip(GameTooltip)
	self:HookTooltip(ItemRefTooltip)
	self:HookTooltip(EmbeddedItemTooltip)
	self:HookTooltip(BattlePetTooltip)
	self:HookTooltip(FloatingBattlePetTooltip)
end