-- Developers: 
    --Divine (http://forum.botoflegends.com/user/86308-divine/)
    --PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)
--

local sVersion = '2.73';
local rVersion = GetWebResult('raw.githubusercontent.com', '/Nader-Sl/BoLStudio/master/Versions/p_modelChanger.version?no-cache=' .. math.random(1, 25000)); 

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FFFF00">An update has been found and it is now downloading!</font>');
		DownloadFile('https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/p_modelChanger.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#00FF00">Script has been updated, please reload!</font>');
		end);
		return;
	end;
else
	print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FF0000">Update Error</font>');
end;

if (not VIP_USER) then
	print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FF0000">Non-VIP Not Supported</font>');
	return;
elseif ((string.find(GetGameVersion(), 'Releases/6.5') == nil) and ((string.find(GetGameVersion(), 'Releases/6.6') == nil))) then
		print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FF0000">Game Version Not Supported</font>');
		return;
end;

local skinHeader = nil;

if (string.find(GetGameVersion(), 'Releases/6.6') ~= nil) then
	skinHeader = 0x142;
elseif (string.find(GetGameVersion(), 'Releases/6.5') ~= nil) then
		skinHeader = 0x59;
end;

local orderedTable = {};

function orderedTable.insert(theTable, theKey, theValue)
    if (not rawget(theTable._values, theKey)) then
        theTable._keys[#theTable._keys + 1] = theKey;
    end;

    if (theValue == nil) then
        orderedTable.remove(theTable, theKey);
    else
        theTable._values[theKey] = theValue;
    end;
end;

local function tableFind(theTable, theValue)
    for I, tV in ipairs(theTable) do
        if (tV == theValue) then
            return I;
        end
    end
end;

function orderedTable.remove(theTable, theKey)
    local theValue = theTable._values[theKey];

    if (theValue ~= nil) then
        table.remove(theTable._keys, tableFind(theTable._keys, theKey));
        theTable._values[theKey] = nil;
    end;

    return theValue;
end;

function orderedTable.index(theTable, theKey)
    return rawget(theTable._values, theKey);
end;

function orderedTable.pairs(theTable)
    local I = 0;

    return function()
        I = I + 1;

        local theKey = theTable._keys[I];

        if (theKey ~= nil) then
            return theKey, theTable._values[theKey];
        end;
    end;
end;

function orderedTable.new(theInit)
    theInit = (theInit or {});
    local theTable = {_keys = {}, _values = {}};
    local tN = #theInit;

    if ((tN % 2) ~= 0) then
        print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FF0000">Ordered Table Error (TN) (' .. tN .. ')!</font>');
        return;
    end;

    for I = 1, (tN / 2) do
        local theKey = theInit[I * 2 - 1]
        local theValue = theInit[I * 2]

        if (theTable._values[theKey] ~= nil) then
            print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#FF0000">Ordered Table Error (DK) (' .. theKey .. ')!</font>');
            return;
        end;
        
        theTable._keys[#theTable._keys + 1]  = theKey;
        theTable._values[theKey] = theValue;
    end;
    
    return setmetatable(theTable, {__newindex = orderedTable.insert, __len = function(theTable) return #theTable._keys; end, __pairs = orderedTable.pairs, __index = theTable._values});
end;

local championTransformObjects = orderedTable.new{
	'OFF', 'OFF',
	'Big Gnar', 'GnarBig',
	'Spider Elise', 'EliseSpider',
	'Egg Anivia', 'AniviaEgg',
	'Raven Swain', 'SwainRaven',
	'Cougar Nidalee', 'NidaleeCougar',
	'Quinn\'s Valor', 'QuinnValor',
	'Zed\'s Shadow', 'ZedShadow',
};
local championExtraObjects = orderedTable.new{
	'OFF', 'OFF',
	'Annie\'s Tibbers', 'AnnieTibbers',
	'Azir\'s Soldier', 'AzirSoldier',
	'Bard\'s Follower', 'BardFollower',
	'Azir\'s Ultimate Soldier', 'AzirUltSoldier',
	'Caitlyn\'s Trap', 'CaitlynTrap',
	'Jinx\'s Mine', 'JinxMine',
	'Heimer\'s Tower (Big)', 'HeimerTBlue',
	'Heimer\'s Tower (Small)', 'HeimerTYellow',
	'Elise\'s Spiderling', 'EliseSpiderling',
	'Olaf\'s Axe', 'OlafAxe',
	'Orianna\'s Ball', 'OriannaBall',
	'Swain\'s Beam', 'SwainBeam',
	'Shaco\'s Box', 'ShacoBox',
	'Teemo\'s Mushroom', 'TeemoMushroom',
};
local cuteObjects = orderedTable.new{
	'OFF', 'OFF',
	'Poro', 'HA_AP_Poro',
	'King Poro', 'KingPoro',
	'Cupcake', 'LuluCupcake',
	'Little Dragon', 'LuluDragon',
	'Fairy', 'LuluFaerie',
	'Kitty', 'LuluKitty',
	'Ladybug', 'LuluLadybug',
	'Snowman', 'LuluSnowman',
	'Squill', 'LuluSquill',
	'Dragonfly', 'Sru_Dragonfly',
	'Ironback', 'BW_Ironback',
	'Ocklepod', 'BW_Ocklepod',
	'Plundercrab', 'BW_Plundercrab',
	'Razorfin', 'BW_Razorfin',
	'Tree', 'TT_Tree_A',
	'Urf', 'Urf',
	'Duck', 'Sru_Duckie',
};
local monsterObjects = orderedTable.new{
	'OFF', 'OFF',
	'Baron', 'SRU_Baron',
	'Dragon', 'SRU_Dragon',
	'Blue Buff', 'SRU_Blue',
	'Red Buff', 'SRU_Red',
	'Crab', 'Sru_Crab',
	'Gromp', 'SRU_Gromp',
	'Mini Krug', 'SRU_KrugMini',
	'Murkwolf', 'SRU_Murkwolf',
	'Razorbeak', 'SRU_Razorbeak',
	'Cyan Golem', 'TT_NGolem',
	'Baron (Old)', 'Worm',
	'Dragon (Old)', 'Dragon',
	'Blue Buff (Old)', 'AncientGolem',
	'Red Buff (Old)', 'LizardElder',
	'Golem (Old)', 'Golem',
	'Lizard (Old)', 'Lizard',
	'Young Lizard (Old)', 'YoungLizard',
	'Great Wraith (Old)', 'GreatWraith',
	'Wraith (Old)', 'TT_NWraith',
	'Lesser Wraith (Old)', 'LesserWraith',
	'Giant Wolf (Old)', 'GiantWolf',
	'Wolf (Old)', 'TT_NWolf',
	'Small Wolf (Old)', 'wolf',
};
local itemObjects = orderedTable.new{
	'OFF', 'OFF',
	'Ghost Ward', 'GhostWard',
	'Sight Ward', 'SightWard',
	'Vision Ward', 'VisionWard',
	'Void Spawn', 'VoidSpawn',
	'Blue Trinket', 'BlueTrinket',
	'Yellow Trinket', 'YellowTrinket',
};
local otherObjects = orderedTable.new{
	'OFF', 'OFF',
	'Shopkeeper', 'ShopMale',
	'Spooky Shopkeeper', 'TT_Shopkeeper',
	'Turret', 'TT_ChaosTurret1',
	'Turret (Old)', 'ChaosTurretWorm',
	'Huge Rock Saw', 'OdinRockSaw',
	'Shield Relic', 'OdinShieldRelic',
	'Flag', 'SummonerBeacon',
};
local theMenu = nil;
local initPacketSent = true;
local lastTimeTickCalled = 0;
local lastActiveOption = 1;
local lastMenuOption = 0;

function OnLoad()
	InitMenu();
	
	if (not theMenu.saveModel) then
		theMenu.changeModel = false;
		resetActiveOptions(nil);
	end;
	
	print('<font color="#FF1493"><b>[p_modelChanger]</b> </font><font color="#00EE00">Loaded Successfully</font>');
end;

function OnUnload()
	if (theMenu.changeModel) then
		if (lastActiveOption ~= 0) then
			SendModelPacket(myHero.charName, true);
		end;
	end;
end;

function OnTick()
	if ((CurrentTimeInMillis() - lastTimeTickCalled) > 200) then
		lastTimeTickCalled = CurrentTimeInMillis();
		if (theMenu.changeModel) then
			local activeOption, menuOption = getActiveMenuSelection();
			if (activeOption ~= 1) then
				if ((activeOption ~= lastActiveOption) or ((activeOption == lastActiveOption) and (menuOption ~= lastMenuOption))) then
					initPacketSent = false;
					lastActiveOption = activeOption;
					lastMenuOption = menuOption;
          --print("AA");
					SendModelPacket(getModelObject(activeOption, menuOption), false);
				end;
			end;
			
			if (theMenu.castSpells.castStatus) then
				if (theMenu.castSpells.Q) then
					CastSpell(_Q);
				end;
				
				if (theMenu.castSpells.W) then
					CastSpell(_W);
				end;
				
				if (theMenu.castSpells.E) then
					CastSpell(_E);
				end;
				
				if (theMenu.castSpells.R) then
					CastSpell(_R);
				end;
			end;
		elseif (lastActiveOption ~= 1) then
			initPacketSent = false;
			lastActiveOption = 1;
			lastMenuOption = 0;
			if (not theMenu.saveModel) then
				resetActiveOptions(nil);
			end;
			SendModelPacket(myHero.charName, true);
		end;
	end;
end;

function OnRecvPacket(sPacket)
  
  --if sPacket.header == 0x58 or sPacket.header == 117 or sPacket.header == 0xAC then return end
    if sPacket.size > 5 then
      sPacket.pos = 2;
      local nID = sPacket:DecodeF();
      if nID == myHero.networkID then
      --if sPacket.header == 0x142 then
       --print(string.format("%02X",sPacket.header));
	--	print(string.format("%02X",sPacket.vTable))
		--print(DumpPacket(sPacket).data)
     --   
    -- end
  end
end
	if (sPacket.header == skinHeader) then
     --print(string.format("%02X",sPacket.vTable));
   --  print(DumpPacket(sPacket).data)
		if (theMenu.changeModel) then
			local activeOption, menuOption = getActiveMenuSelection();
	    	DelayAction(function() SendModelPacket(getModelObject(activeOption, menuOption), false); end, 0.01);
		end;
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_modelChanger', 'p_modelChanger');
	theMenu:addParam('saveModel', 'Save Model', SCRIPT_PARAM_ONOFF, false);
	theMenu:addParam('changeModel', 'Change Model', SCRIPT_PARAM_ONOFF, false);
	theMenu:addSubMenu('Cast Spells', 'castSpells');
	theMenu.castSpells:addParam('castStatus', 'Cast Status', SCRIPT_PARAM_ONOFF, true);
	theMenu.castSpells:addParam('Q', 'Cast Q', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('Q'));
	theMenu.castSpells:addParam('W', 'Cast W', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('W'));
	theMenu.castSpells:addParam('E', 'Cast E', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('E'));
	theMenu.castSpells:addParam('R', 'Cast R', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('R'));
	theMenu:addParam('championTransforms', 'Champion Transforms', SCRIPT_PARAM_LIST, 1, getTableKeys(championTransformObjects));
	theMenu:addParam('championExtras', 'Champion Extras', SCRIPT_PARAM_LIST, 1, getTableKeys(championExtraObjects));
	theMenu:addParam('cutenessOverload', 'Cuteness Overload', SCRIPT_PARAM_LIST, 1, getTableKeys(cuteObjects));
	theMenu:addParam('coolMonsters', 'Monsters', SCRIPT_PARAM_LIST, 1, getTableKeys(monsterObjects));
	theMenu:addParam('coolItems', 'Items', SCRIPT_PARAM_LIST, 1, getTableKeys(itemObjects));
	theMenu:addParam('coolOthers', 'Others', SCRIPT_PARAM_LIST, 1, getTableKeys(otherObjects));
end;

function getModelObject(eOption, mOption)
	if (eOption == 0) then
		return myHero.charName;
	end;

	local theObjects = {};
	
	if (mOption == 1) then
		theObjects = getTableValues(championTransformObjects);
	elseif (mOption == 2) then
			theObjects = getTableValues(championExtraObjects);
	elseif (mOption == 3) then
			theObjects = getTableValues(cuteObjects);
	elseif (mOption == 4) then
			theObjects = getTableValues(monsterObjects);
	elseif (mOption == 5) then
			theObjects = getTableValues(itemObjects);
	elseif (mOption == 6) then
			theObjects = getTableValues(otherObjects);
	end;
	
	if (theObjects[eOption] ~= nil) then
		return theObjects[eOption];
	else
		return myHero.charName;
	end;
end;

function getActiveMenuSelection()
	local activeOption = lastActiveOption;
	local menuOption = lastMenuOption;
	
	if ((theMenu.championTransforms ~= 1) and ((lastActiveOption ~= theMenu.championTransforms) or ((lastActiveOption == theMenu.championTransforms) and (lastMenuOption ~= 1)))) then
		activeOption = theMenu.championTransforms;
		menuOption = 1;
	elseif ((theMenu.championExtras ~= 1) and ((lastActiveOption ~= theMenu.championExtras) or ((lastActiveOption == theMenu.championExtras) and (lastMenuOption ~= 2)))) then
			activeOption = theMenu.championExtras;
			menuOption = 2;
	elseif ((theMenu.cutenessOverload ~= 1) and ((lastActiveOption ~= theMenu.cutenessOverload) or ((lastActiveOption == theMenu.cutenessOverload) and (lastMenuOption ~= 3)))) then
			activeOption = theMenu.cutenessOverload;
			menuOption = 3;
	elseif ((theMenu.coolMonsters ~= 1) and ((lastActiveOption ~= theMenu.coolMonsters) or ((lastActiveOption == theMenu.coolMonsters) and (lastMenuOption ~= 4)))) then
			activeOption = theMenu.coolMonsters;
			menuOption = 4;
	elseif ((theMenu.coolItems ~= 1) and ((lastActiveOption ~= theMenu.coolItems) or ((lastActiveOption == theMenu.coolItems) and (lastMenuOption ~= 5)))) then
			activeOption = theMenu.coolItems;
			menuOption = 5;
	elseif ((theMenu.coolOthers ~= 1) and ((lastActiveOption ~= theMenu.coolOthers) or ((lastActiveOption == theMenu.coolOthers) and (lastMenuOption ~= 6)))) then
			activeOption = theMenu.coolOthers;
			menuOption = 6;
	end;
	
	if (menuOption ~= lastMenuOption) then
		resetActiveOptions(menuOption);
	end;
	
	if ((activeOption == lastActiveOption) and (not initPacketSent)) then
		if ((theMenu.championTransforms == 1) and (theMenu.championExtras == 1) and (theMenu.cutenessOverload == 1) and (theMenu.coolMonsters == 1) and (theMenu.coolItems == 1) and (theMenu.coolOthers == 1)) then
			initPacketSent = true;
			lastActiveOption = 1;
			lastMenuOption = 0;
			activeOption = 1;
			menuOption = 0;
			SendModelPacket(myHero.charName, true);
		end;
	end;
	
	return activeOption, menuOption;
end;

function resetActiveOptions(mO)
	if (mO ~= 1) then
		theMenu.championTransforms = 1;
	end;
	
	if (mO ~= 2) then
		theMenu.championExtras = 1;
	end;
	
	if (mO ~= 3) then
		theMenu.cutenessOverload = 1;
	end;
	
	if (mO ~= 4) then
		theMenu.coolMonsters = 1;
	end;
	
	if (mO ~= 5) then
		theMenu.coolItems = 1;
	end;
	
	if (mO ~= 6) then
		theMenu.coolOthers = 1;
	end;
end;

function getTableKeys(theTable)
	return gTKV(theTable, 1);
end;

function getTableValues(theTable)
	return gTKV(theTable, 2);
end;

function gTKV(theTable, rMode)
	local newTable = {};
	
	for tK, tV in pairs(theTable) do
		if (rMode == 1) then
			newTable[#newTable + 1] = tK;
		elseif (rMode == 2) then
			newTable[#newTable + 1] = tV;
		else
			break;
		end;
	end;
	
	return newTable;
end;

function SendModelPacket(mObject, skinnedObject)
  
	if (string.find(GetGameVersion(), 'Releases/6.6') ~= nil) then
		local mP = CLoLPacket(skinHeader);

		mP.vTable = 0xE91EAC

		mP:EncodeF(myHero.networkID);
		mP:Encode2(0x0000);
		mP:Encode1(0x00);
		for I = 1, string.len(mObject) do
			mP:Encode1(string.byte(string.sub(mObject, I, I)));
		end;
		
		for I = 1, (16 - string.len(mObject)) do
			mP:Encode1(0x00);
		end;
		mP:Encode4(0x0000000D);
		mP:Encode4(0x0000000F);
		mP:Encode4(0x00000000);
		if (skinnedObject) then
			mP:Encode4(0x77777777);
		else
			mP:Encode4(0x78787878);
		end
	 
		mP:Hide();
		RecvPacket(mP);
    
	elseif (string.find(GetGameVersion(), 'Releases/6.5') ~= nil) then
			local mP = CLoLPacket(skinHeader);
      
			mP.vTable = 0xF5CA0C;
			mP:EncodeF(myHero.networkID);
      
      for I = 1, string.len(mObject) do
				mP:Encode1(string.byte(string.sub(mObject, I, I)));
			end;

			for I = 1, (14 - string.len(mObject)) do
				mP:Encode1(0x00);
			end;
      
  	mP:Encode2(0x0000);
		mP:Encode4(0x0000000D);
		mP:Encode4(0x0000000F);
    mP:Encode4(0x00000000);
    mP:Encode2(0x0000);
    mP:Encode1(0x00);
       
      	if (skinnedObject) then
          mP:Encode4(0xECECECEC);
        else
          mP:Encode4(0xC1C1C1C1);
        end;
    mP:Hide();
   -- print(string.format("%02X",mP.vTable));
    --print(DumpPacket(mP).data)
   RecvPacket(mP);
	end;
end;

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end;
