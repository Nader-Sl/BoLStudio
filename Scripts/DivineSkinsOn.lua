
function log(msg)
print("<font color=\"#e88ebc\">[Divine SkinsOn]</font> "..msg)
end

local sVersion = '1.01';
local rVersion = GetWebResult('raw.githubusercontent.com', '/Nader-Sl/BoLStudio/master/Versions/DivineSkinsOn.version?no-cache=' .. math.random(1, 25000));

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		log("A new version ("..rVersion..") has been found, updating, don't turn off the script. ...");
		DownloadFile('https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/DivineSkinsOn.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			log("Script has been updated to version "..rVersion);
		end);
		return;
	end;
else
	log("Update Error, hit double F9 or retry again later.");
end;

if (not VIP_USER) then
	log("Non-VIP Not Supported");
	return;
elseif ((string.find(GetGameVersion(), 'Releases/6.3') == nil) and ((string.find(GetGameVersion(), 'Releases/6.4') == nil))) then
	log("Game Version Not Supported, an update is required, please be patient and check forums");
		return;
end;

local skinsPB = {};
local skinObjectPos = nil;
local skinHeader = nil;
local dispellHeader = nil;
local skinH = nil;
local skinHPos = nil;
local skinnedObjects = {} --cache non-packet based skin setting for objects to avoid FPS drop (minions and wards)
local skinSetTime = os.clock()

if (string.find(GetGameVersion(), 'Releases/6.4') ~= nil) then
	skinsPB = {
		[1] = 0xD4,
		[10] = 0xE9,
		[8] = 0x2B,
		[4] = 0x6B,
		[12] = 0xEB,
		[5] = 0x28,
		[9] =  0xE8,
		[7] = 0x2A,
		[3] = 0x6A,
		[11] = 0xEA,
		[6] = 0x29,
		[2] = 0x69,
	};
	skinObjectPos = 14;
	skinHeader = 0xFB
	dispellHeader = 0xD5;
	skinH = 0x68;
	skinHPos = 6;
	header = 0xFB
  --[[["Blitzcrank"]   = {"Classic", "Rusty", "Goalkeeper", "Boom Boom", "Piltover Customs", "Definitely Not", "iBlitzcrank", "Riot", "Chroma Pack: Molten", "Chroma Pack: Cobalt", "Chroma Pack: Gunmetal", "Battle Boss"},]]--
elseif (string.find(GetGameVersion(), 'Releases/6.3') ~= nil) then
		skinsPB = {
			[1] = 0xC2,
			[10] = 0xB7,
			[8] = 0x61,
			[4] = 0x98,
			[12] = 0x83,
			[5] = 0x93,
			[9] = 0xDB,
			[7] = 0x8D,
			[3] = 0xB4,
			[11] = 0x3B,
			[6] = 0xF1,
			[2] = 0x3C,
		};
		skinObjectPos = 7;
		skinHeader = 0x43;
		dispellHeader = 0x8F;
		skinH = 0xC2;
		skinHPos = 31;
    header = 0x43
end;

local theMenu = nil;
local initBall = false;
local ballCreated = false;
local ballNetworkID = nil;
local lastFormSeen = nil;
local cougarForm = false;
local spiderForm = false;
local champsData = {}
local lastTimeTickCalled = 0;
local lastSkin = 0;

function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end

function OnLoad()
	InitMenu();
		if not theMenu.minions.store then
      theMenu.minions.change = false;
      theMenu.minions.selected = 1;
    end
    
    if not theMenu.wardsS1.store then
      theMenu.wardsS1.change = false;
      theMenu.wardsS1.selected = 1;
    end
    
    if not theMenu.wardsS2.store then
      theMenu.wardsS2.change = false;
      theMenu.wardsS2.selected = 1;
    end
    
     if not theMenu.wardsS3.store then
      theMenu.wardsS3change = false;
      theMenu.wardsS3.selected = 1;
    end
    
  for i = 1, heroManager.iCount do
      local hero = heroManager:GetHero(i)
      champsData[""..hero.networkID] = {initBall = false,ballCreated = false,ballNetworkID = nil,lastFormSeen = nil,cougarForm = false,spiderForm = false,lastSkin = 0}
      local data = champsData[""..hero.networkID]
      if (not theMenu.champs[hero.charName.."Menu"]['save' .. hero.charName .. 'Skin']) then
        theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin'] = false;
        theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName.. 'Skin'] = 1;
      elseif (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
          SendSkinPacket(hero.charName, skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
      end;
  
	if (hero.charName == 'Orianna') then
		for I = 1, objManager.maxObjects do
			local tempObject = objManager:getObject(I);
			if ((tempObject) and (tempObject.name == 'TheDoomBall') ) then
				data.initBall = true;
				data.ballCreated = true;
				data.ballNetworkID = tempObject.networkID;
				break;
			end;
		end;
	elseif (hero.charName == 'Nidalee') then
			if (hero:GetSpellData(_Q).name == 'Takedown') then
				data.cougarForm = true;
			end;
	elseif (hero.charName == 'Elise') then
			if (hero:GetSpellData(_Q).name == 'EliseSpiderQCast') then
				data.spiderForm = true;
			end;
	end;
end	
	log("Loaded Successfully.");
end;

function SetSkinsClient()
     -- Minions & Wards handling
    for I = 1, objManager.maxObjects do
          local obj = objManager:getObject(I)
          if obj and obj.name and obj.type == "obj_AI_Minion" then
            local currSkinID = nil
            if string.starts(obj.name,"Minion") then
                currSkinID = theMenu.minions.change and (theMenu.minions.selected - 1) or -1
            elseif obj.name:lower():find("ward") then --wards
                currSkinID = (theMenu.wardsS3.change and (47 + (theMenu.wardsS3.selected ))) or (theMenu.wardsS2.change and (23 + (theMenu.wardsS2.selected ))) or (theMenu.wardsS1.change and (theMenu.wardsS1.selected - 1)) or 1
            end
            if currSkinID then
               local cachedSkinID = skinnedObjects[obj.networkID] or - 999
               if currSkinID ~= cachedSkinID then SetSkin(obj,currSkinID) ; skinnedObjects[obj.networkID] = currSkinID               end
            end
          end         
    end
end

function OnUnload()
  
    theMenu.minions.change = false
    theMenu.wardsS1.change = false
    theMenu.wardsS2.change = false
    SetSkinsClient()
  for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
     local data = champsData[""..hero.networkID]
        if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
          if (hero.charName == 'Orianna') then
            if (data.ballCreated) then
              return log("Skin could not be unloaded because ball is active!");
            else
              SendSkinPacket('Orianna', nil, hero.networkID);
            end;
          elseif (hero.charName == 'Nidalee') then
              if (data.cougarForm) then
                return log("Skin could not be unloaded due to cougar form!");
              else
                SendSkinPacket('Nidalee', nil, hero.networkID);
              end;
          elseif (hero.charName == 'Elise') then
              if (data.spiderForm) then
                return log("Skin could not be unloaded due to spider form!");
              else
                SendSkinPacket('Elise', nil, hero.networkID);
              end;
          else
            SendSkinPacket(hero.charName, nil, hero.networkID);
          end;
        end
    end    
end;

function OnTick()

   
	if ((CurrentTimeInMillis() - lastTimeTickCalled) > 200) then
		lastTimeTickCalled = CurrentTimeInMillis();
  
  SetSkinsClient()
   for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
    local data = champsData[""..hero.networkID]
 
		if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
			if (theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin'] ~= data.lastSkin) then
				data.lastSkin = theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin'];
				if (hero.charName == 'Orianna') then
					if (data.ballCreated) then
						SendSkinPacket('OriannaNoBall', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						if (data.ballNetworkID ~= nil) then
							SendSkinPacket('OriannaBall', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], data.ballNetworkID);
						end;
					else
						SendSkinPacket('Orianna', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
					end;
				elseif (hero.charName == 'Nidalee') then
						if (data.cougarForm) then
							SendSkinPacket('NidaleeCougar', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						else
							SendSkinPacket('Nidalee', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						end;
				elseif (hero.charName == 'Elise') then
						if (data.spiderForm) then
							SendSkinPacket('EliseSpider', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						else
							SendSkinPacket('Elise', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						end;
				else
					SendSkinPacket(hero.charName, skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
				end;
			end;
		elseif (data.lastSkin ~= 0) then
			if (hero.charName == 'Orianna') then
				if ((data.ballCreated) and (data.ballNetworkID ~= nil)) then
					theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin'] = true;
					return log("You can\'t disable skin changer while the ball is active!");
				else
					SendSkinPacket('Orianna', nil, hero.networkID);
				end;
			elseif (hero.charName == 'Nidalee') then
					if (data.cougarForm) then
						theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin'] = true;
						return log("You can\'t disable skin changer while on cougar form!");
					else
						SendSkinPacket('Nidalee', nil, hero.networkID);
					end;
			elseif (hero.charName == 'Elise') then
					if (data.spiderForm) then
						theMenu.champ[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin'] = true;
						return log("You can\'t disable skin changer while on spider form!");
					else
						SendSkinPacket('Elise', nil, hero.networkID);
					end;
			else
				SendSkinPacket(hero.charName, nil, hero.networkID);
			end;
			data.lastSkin = 0;
		end;
	end;
end;
end
function OnRecvPacket(rPacket)
	if (rPacket.header == skinHeader) then
  --print(DumpPacket(rPacket).data)
  for i = 1, heroManager.iCount do
      local hero = heroManager:GetHero(i)
      local data = champsData[""..hero.networkID]
		if ((hero.charName == 'Orianna') or (hero.charName == 'Nidalee') or (hero.charName == 'Elise')) then
			rPacket.pos = 2;
			if (hero.networkID == rPacket:DecodeF()) then
				rPacket.pos = skinObjectPos;
				local pS1 = rPacket:Decode4();
				local pS2 = rPacket:Decode4();
				local pS3 = rPacket:Decode2();
				local pS4 = rPacket:Decode1();
				local pS5 = rPacket:Decode1();
				local pS6 = rPacket:Decode1();
				local pS7 = rPacket:Decode1();
				
				if (hero.charName == 'Orianna') then
					if ((pS1 == 0x6169724F) and (pS2 == 0x4E616E6E) and (pS3 == 0x426F) and (pS4 == 0x61) and (pS5 == 0x6C) and (pS5 == 0x6C)) then
						data.ballCreated = true;
						if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
							rPacket:Replace1(skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], skinHPos);
							rPacket:Replace1(skinH, skinHPos + 1);
							rPacket:Replace1(skinH, skinHPos + 2);
							rPacket:Replace1(skinH, skinHPos + 3);
						end;
					end;
				elseif (hero.charName == 'Nidalee') then
						if ((pS1 == 0x6164694E) and (pS2 == 0x4365656C) and (pS3 == 0x756F) and (pS4 == 0x67) and (pS5 == 0x61) and (pS6 == 0x72)) then
							data.cougarForm = true;
							if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
								rPacket:Replace1(skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], skinHPos);
								rPacket:Replace1(skinH, skinHPos + 1);
								rPacket:Replace1(skinH, skinHPos + 2);
								rPacket:Replace1(skinH, skinHPos + 3);
							end;
						else
							data.lastFormSeen = data.cougarForm;
						end;
				elseif (hero.charName == 'Elise') then
						if ((pS1 == 0x73696C45) and (pS2 == 0x69705365) and (pS3 == 0x6564) and (pS4 == 0x72)) then
							data.spiderForm = true;
							if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
								rPacket:Replace1(skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], skinHPos);
								rPacket:Replace1(skinH, skinHPos + 1);
								rPacket:Replace1(skinH, skinHPos + 2);
								rPacket:Replace1(skinH, skinHPos + 3);
							end;
						else
							data.lastFormSeen = data.spiderForm;
						end;
				end;
			end;
		end;
  end;
elseif (rPacket.header == dispellHeader) then

    for i = 1, heroManager.iCount do
      local hero = heroManager:GetHero(i)
      local data = champsData[""..hero.networkID]
			rPacket.pos = 2;
			if (hero.networkID == rPacket:DecodeF()) then
				if (hero.charName == 'Nidalee') then
					if (data.lastFormSeen ~= nil) then
						if (data.lastFormSeen) then
             
							if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
								SendSkinPacket('NidaleeCougar', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
							end;
							
							data.cougarForm = true;
						else
							if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
								SendSkinPacket('Nidalee', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
							end;
							
							data.cougarForm = false;
						end;
						
						data.lastFormSeen = nil;
					else
						if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
							SendSkinPacket('Nidalee', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
						end;
						
						data.cougarForm = false;
					end;
				elseif (hero.charName == 'Elise') then
						if (data.lastFormSeen ~= nil) then
							if (data.lastFormSeen) then
								if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
									SendSkinPacket('EliseSpider', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
								end;
								
								data.spiderForm = true;
							else
								if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
									SendSkinPacket('Elise', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
								end;
								
								data.spiderForm = false;
							end;
							
							data.lastFormSeen = nil;
						else
							if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
								SendSkinPacket('Elise', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
							end;
							
							data.spiderForm = false;
              end;
						end;
				end;
			end;
	end;
end;

function OnCreateObj(tObj)
 for i = 1, heroManager.iCount do
   local hero = heroManager:GetHero(i)
   local data = champsData[""..hero.networkID]
	if (hero.charName == 'Orianna') then
		if ((tObj.valid) and (tObj.name == 'TheDoomBall') ) then
			data.ballNetworkID = tObj.networkID;
			data.ballCreated = true;
			
			if (theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) then
				SendSkinPacket('OriannaBall', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], data.ballNetworkID);
			end;
		end;
	end;
 end;
end;


function OnApplyBuff(bSource, bUnit, tBuff)
   for i = 1, heroManager.iCount do
   local hero = heroManager:GetHero(i)
   local data = champsData[""..hero.networkID]
	if (hero.charName == 'Orianna') then
		if (bUnit and (tBuff.name == 'orianaghostself')) then
			if ((theMenu.champs[hero.charName.."Menu"]['change' .. hero.charName .. 'Skin']) and (data.ballCreated)) then
				SendSkinPacket('Orianna', skinsPB[theMenu.champs[hero.charName.."Menu"]['selected' .. hero.charName .. 'Skin']], hero.networkID);
			elseif (data.initBall) then
					SendSkinPacket('Orianna', nil, hero.networkID);
					data.initBall = false;
			end;
			
			data.ballCreated = false;
			data.ballNetworkID = nil;
		end;
	end;
  end
end;

function InitMenu()
	theMenu = scriptConfig('Divine SkinsOn', 'dSkinsOn');
  theMenu:addSubMenu("Champions","champs")
  for i = 1, heroManager.iCount do
    local hero = heroManager:GetHero(i)
    if theMenu.champs[hero.charName.."Menu"] == nil then
        theMenu.champs:addSubMenu(hero.charName,hero.charName.."Menu")
        theMenu.champs[hero.charName.."Menu"]:addParam('save' .. hero.charName .. 'Skin', 'Save Skin', SCRIPT_PARAM_ONOFF, false);
        theMenu.champs[hero.charName.."Menu"]:addParam('change' .. hero.charName .. 'Skin', 'Change Skin', SCRIPT_PARAM_ONOFF, false);
        theMenu.champs[hero.charName.."Menu"]:addParam('selected' .. hero.charName .. 'Skin', 'Selected Skin', SCRIPT_PARAM_LIST, 1,skinMeta.champs[hero.charName]);
    end
  end
  theMenu:addSubMenu("Minions","minions")
	theMenu.minions:addParam('store', 'Save Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.minions:addParam('change', 'Change Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.minions:addParam('selected', 'Selected Skin', SCRIPT_PARAM_LIST, 1,skinMeta.minions);
  
  theMenu:addSubMenu("Wards Set 1","wardsS1")
	theMenu.wardsS1:addParam('store', 'Save Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS1:addParam('change', 'Change Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS1:addParam('selected', 'Selected Skin', SCRIPT_PARAM_LIST, 1,skinMeta.wardsS1);
  
  theMenu:addSubMenu("Wards Set 2","wardsS2")
	theMenu.wardsS2:addParam('store', 'Save Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS2:addParam('change', 'Change Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS2:addParam('selected', 'Selected Skin', SCRIPT_PARAM_LIST, 1,skinMeta.wardsS2);
  
  theMenu:addSubMenu("Wards Set 3","wardsS3")
	theMenu.wardsS3:addParam('store', 'Save Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS3:addParam('change', 'Change Skin', SCRIPT_PARAM_ONOFF, false);
	theMenu.wardsS3:addParam('selected', 'Selected Skin', SCRIPT_PARAM_LIST, 1,skinMeta.wardsS3);
end;

function SendSkinPacket(mObject, skinPB, networkID)
	if (string.find(GetGameVersion(), 'Releases/6.4') ~= nil) then
		local mP = CLoLPacket(header);

		mP.vTable = 0xFB2978;

		mP:EncodeF(myHero.networkID);
		if (not skinPB or skinnedObject) then
			mP:Encode4(0x97979797);
		else
			mP:Encode1(skinPB);
			for I = 1, 3 do
				mP:Encode1(skinH);
			end;
		end
		mP:Encode4(0x00000000);
		for I = 1, string.len(mObject) do
			mP:Encode1(string.byte(string.sub(mObject, I, I)));
		end;

		for I = 1, (14 - string.len(mObject)) do
			mP:Encode1(0x00);
		end;
		mP:Encode2(0x0000);
		mP:Encode4(0x0000000D);
		mP:Encode4(0x0000000F);
     
		mP:Encode1(0x00);
		mP:Encode2(0x0000);
	 
		mP:Hide();
		RecvPacket(mP);
	elseif (string.find(GetGameVersion(), 'Releases/6.3') ~= nil) then
				local mP = CLoLPacket(header);
      
			mP.vTable = 0x10329EC;
			mP:EncodeF(networkID);

      	mP:Encode1(0x00);
			for I = 1, string.len(mObject) do
				mP:Encode1(string.byte(string.sub(mObject, I, I)));
			end;

			for I = 1, (14 - string.len(mObject)) do
				mP:Encode1(0x00);
			end;

  	mP:Encode2(0x0000);
		mP:Encode4(0x0000000D);
		mP:Encode4(0x0000000F);
       
      	if (not skinPB or skinnedObject) then
          mP:Encode4(0xACACACAC);
        else
          	mP:Encode1(skinPB);
			for I = 1, 3 do
				mP:Encode1(0xC2);
			end;
        end;
		mP:Encode4(0x00000000);
    mP:Encode2(0x0000);
    mP:Hide();

   RecvPacket(mP);
    end;
end;

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end;

skinMeta = {
champs = {
  -- A
["Aatrox"]       = {"Classic", "Justicar", "Mecha", "Sea Hunter"},
["Ahri"]         = {"Classic", "Dynasty", "Midnight", "Foxfire", "Popstar", "Challenger", "Academy"},
["Akali"]        = {"Classic", "Stinger", "Crimson", "All-star", "Nurse", "Blood Moon", "Silverfang", "Headhunter"},
["Alistar"]      = {"Classic", "Black", "Golden", "Matador", "Longhorn", "Unchained", "Infernal", "Sweeper", "Marauder"},
["Amumu"]        = {"Classic", "Pharaoh", "Vancouver", "Emumu", "Re-Gifted", "Almost-Prom King", "Little Knight", "Sad Robot", "Surprise Party"},
["Anivia"]       = {"Classic", "Team Spirit", "Bird of Prey", "Noxus Hunter", "Hextech", "Blackfrost", "Prehistoric"},
["Annie"]        = {"Classic", "Goth", "Red Riding", "Annie in Wonderland", "Prom Queen", "Frostfire", "Reverse", "FrankenTibbers", "Panda", "Sweetheart"},
["Ashe"]         = {"Classic", "Freljord", "Sherwood Forest", "Woad", "Queen", "Amethyst", "Heartseeker", "Marauder"},
["Azir"]         = {"Classic", "Galactic", "Gravelord"},
  -- B  
["Bard"]         = {"Classic", "Elderwood", "Chroma Pack: Marigold", "Chroma Pack: Ivy", "Chroma Pack: Sage"},
["Blitzcrank"]   = {"Classic", "Rusty", "Goalkeeper", "Boom Boom", "Piltover Customs", "Definitely Not", "iBlitzcrank", "Riot", "Chroma Pack: Molten", "Chroma Pack: Cobalt", "Chroma Pack: Gunmetal", "Battle Boss"},
["Brand"]        = {"Classic", "Apocalyptic", "Vandal", "Cryocore", "Zombie", "Spirit Fire"},
["Braum"]        = {"Classic", "Dragonslayer", "El Tigre", "Lionheart"},
  -- C  
["Caitlyn"]      = {"Classic", "Resistance", "Sheriff", "Safari", "Arctic Warfare", "Officer", "Headhunter", "Chroma Pack: Pink", "Chroma Pack: Green", "Chroma Pack: Blue","Lunar"},
["Cassiopeia"]   = {"Classic", "Desperada", "Siren", "Mythic", "Jade Fang", "Chroma Pack: Day", "Chroma Pack: Dusk", "Chroma Pack: Night"},
["Chogath"]      = {"Classic", "Nightmare", "Gentleman", "Loch Ness", "Jurassic", "Battlecast Prime", "Prehistoric"},
["Corki"]        = {"Classic", "UFO", "Ice Toboggan", "Red Baron", "Hot Rod", "Urfrider", "Dragonwing", "Fnatic"},
  -- D
["Darius"]       = {"Classic", "Lord", "Bioforge", "Woad King", "Dunkmaster", "Chroma Pack: Black Iron", "Chroma Pack: Bronze", "Chroma Pack: Copper", "Academy"},
["Diana"]        = {"Classic", "Dark Valkyrie", "Lunar Goddess"},
["DrMundo"]      = {"Classic", "Toxic", "Mr. Mundoverse", "Corporate Mundo", "Mundo Mundo", "Executioner Mundo", "Rageborn Mundo", "TPA Mundo", "Pool Party"},
["Draven"]       = {"Classic", "Soul Reaver", "Gladiator", "Primetime", "Pool Party"},
  -- E 
["Ekko"]         = {"Classic", "Sandstorm", "Academy"},
["Elise"]        = {"Classic", "Death Blossom", "Victorious", "Blood Moon"},
["Evelynn"]      = {"Classic", "Shadow", "Masquerade", "Tango", "Safecracker"},
["Ezreal"]       = {"Classic", "Nottingham", "Striker", "Frosted", "Explorer", "Pulsefire", "TPA", "Debonair", "Ace of Spades"},
  -- F 
["FiddleSticks"] = {"Classic", "Spectral", "Union Jack", "Bandito", "Pumpkinhead", "Fiddle Me Timbers", "Surprise Party", "Dark Candy", "Risen"},
["Fiora"]        = {"Classic", "Royal Guard", "Nightraven", "Headmistress", "PROJECT"},
["Fizz"]         = {"Classic", "Atlantean", "Tundra", "Fisherman", "Void", "Chroma Pack: Orange", "Chroma Pack: Black", "Chroma Pack: Red", "Cottontail"},
  -- G  
["Galio"]        = {"Classic", "Enchanted", "Hextech", "Commando", "Gatekeeper", "Debonair"},
["Gangplank"]    = {"Classic", "Spooky", "Minuteman", "Sailor", "Toy Soldier", "Special Forces", "Sultan", "Captain"},
["Garen"]        = {"Classic", "Sanguine", "Desert Trooper", "Commando", "Dreadknight", "Rugged", "Steel Legion", "Chroma Pack: Garnet", "Chroma Pack: Plum", "Chroma Pack: Ivory", "Rogue Admiral"},
["Gnar"]         = {"Classic", "Dino", "Gentleman"},
["Gragas"]       = {"Classic", "Scuba", "Hillbilly", "Santa", "Gragas, Esq.", "Vandal", "Oktoberfest", "Superfan", "Fnatic", "Caskbreaker"},
["Graves"]       = {"Classic", "Hired Gun", "Jailbreak", "Mafia", "Riot", "Pool Party", "Cutthroat"},
  -- H 
["Hecarim"]      = {"Classic", "Blood Knight", "Reaper", "Headless", "Arcade", "Elderwood"},
["Heimerdinger"] = {"Classic", "Alien Invader", "Blast Zone", "Piltover Customs", "Snowmerdinger", "Hazmat"},
  -- I 
["Illaoi"]       = {"Classic", "Void Bringer"},
["Irelia"]       = {"Classic", "Nightblade", "Aviator", "Infiltrator", "Frostblade", "Order of the Lotus"},
  -- J 
["Janna"]        = {"Classic", "Tempest", "Hextech", "Frost Queen", "Victorious", "Forecast", "Fnatic"},
["JarvanIV"]     = {"Classic", "Commando", "Dragonslayer", "Darkforge", "Victorious", "Warring Kingdoms", "Fnatic"},
["Jax"]          = {"Classic", "The Mighty", "Vandal", "Angler", "PAX", "Jaximus", "Temple", "Nemesis", "SKT T1", "Chroma Pack: Cream", "Chroma Pack: Amber", "Chroma Pack: Brick", "Warden"},
["Jayce"]        = {"Classic", "Full Metal", "Debonair", "Forsaken"},
["Jinx"]         = {"Classic", "Mafia", "Firecracker", "Slayer"},
  -- K 
["Kalista"]      = {"Classic", "Blood Moon", "Championship"},
["Karma"]        = {"Classic", "Sun Goddess", "Sakura", "Traditional", "Order of the Lotus", "Warden"},
["Karthus"]      = {"Classic", "Phantom", "Statue of", "Grim Reaper", "Pentakill", "Fnatic", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite"},
["Kassadin"]     = {"Classic", "Festival", "Deep One", "Pre-Void", "Harbinger", "Cosmic Reaver"},
["Katarina"]     = {"Classic", "Mercenary", "Red Card", "Bilgewater", "Kitty Cat", "High Command", "Sandstorm", "Slay Belle", "Warring Kingdoms"},
["Kayle"]        = {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot"},
["Kennen"]       = {"Classic", "Deadly", "Swamp Master", "Karate", "Kennen M.D.", "Arctic Ops"},
["Khazix"]       = {"Classic", "Mecha", "Guardian of the Sands"},
["Kindred"]      = {"Classic", "Shadowfire"},
["KogMaw"]       = {"Classic", "Caterpillar", "Sonoran", "Monarch", "Reindeer", "Lion Dance", "Deep Sea", "Jurassic", "Battlecast"},
  -- L 
["Leblanc"]      = {"Classic", "Wicked", "Prestigious", "Mistletoe", "Ravenborn"},
["LeeSin"]       = {"Classic", "Traditional", "Acolyte", "Dragon Fist", "Muay Thai", "Pool Party", "SKT T1", "Chroma Pack: Black", "Chroma Pack: Blue", "Chroma Pack: Yellow", "Knockout"},
["Leona"]        = {"Classic", "Valkyrie", "Defender", "Iron Solari", "Pool Party", "Chroma Pack: Pink", "Chroma Pack: Azure", "Chroma Pack: Lemon", "PROJECT"},
["Lissandra"]    = {"Classic", "Bloodstone", "Blade Queen"},
["Lucian"]       = {"Classic", "Hired Gun", "Striker", "Chroma Pack: Yellow", "Chroma Pack: Red", "Chroma Pack: Blue", "PROJECT"},
["Lulu"]         = {"Classic", "Bittersweet", "Wicked", "Dragon Trainer", "Winter Wonder", "Pool Party"},
["Lux"]          = {"Classic", "Sorceress", "Spellthief", "Commando", "Imperial", "Steel Legion", "Star Guardian"},
  -- M 
["Malphite"]     = {"Classic", "Shamrock", "Coral Reef", "Marble", "Obsidian", "Glacial", "Mecha", "Ironside"},
["Malzahar"]     = {"Classic", "Vizier", "Shadow Prince", "Djinn", "Overlord", "Snow Day"},
["Maokai"]       = {"Classic", "Charred", "Totemic", "Festive", "Haunted", "Goalkeeper"},
["MasterYi"]     = {"Classic", "Assassin", "Chosen", "Ionia", "Samurai Yi", "Headhunter", "Chroma Pack: Gold", "Chroma Pack: Aqua", "Chroma Pack: Crimson", "PROJECT"},
["MissFortune"]  = {"Classic", "Cowgirl", "Waterloo", "Secret Agent", "Candy Cane", "Road Warrior", "Mafia", "Arcade", "Captain"},
["Mordekaiser"]  = {"Classic", "Dragon Knight", "Infernal", "Pentakill", "Lord", "King of Clubs"},
["Morgana"]      = {"Classic", "Exiled", "Sinful Succulence", "Blade Mistress", "Blackthorn", "Ghost Bride", "Victorious", "Chroma Pack: Toxic", "Chroma Pack: Pale", "Chroma Pack: Ebony","Lunar"},
  -- N 
["Nami"]         = {"Classic", "Koi", "River Spirit", "Urf", "Chroma Pack: Sunbeam", "Chroma Pack: Smoke", "Chroma Pack: Twilight"},
["Nasus"]        = {"Classic", "Galactic", "Pharaoh", "Dreadknight", "Riot K-9", "Infernal", "Archduke", "Chroma Pack: Burn", "Chroma Pack: Blight", "Chroma Pack: Frostbite",},
["Nautilus"]     = {"Classic", "Abyssal", "Subterranean", "AstroNautilus", "Warden"},
["Nidalee"]      = {"Classic", "Snow Bunny", "Leopard", "French Maid", "Pharaoh", "Bewitching", "Headhunter", "Warring Kingdoms"},
["Nocturne"]     = {"Classic", "Frozen Terror", "Void", "Ravager", "Haunting", "Eternum"},
["Nunu"]         = {"Classic", "Sasquatch", "Workshop", "Grungy", "Nunu Bot", "Demolisher", "TPA", "Zombie"},
  -- O 
["Olaf"]         = {"Classic", "Forsaken", "Glacial", "Brolaf", "Pentakill", "Marauder"},
["Orianna"]      = {"Classic", "Gothic", "Sewn Chaos", "Bladecraft", "TPA", "Winter Wonder"},
  -- P 
["Pantheon"]     = {"Classic", "Myrmidon", "Ruthless", "Perseus", "Full Metal", "Glaive Warrior", "Dragonslayer", "Slayer"},
["Poppy"]        = {"Classic", "Noxus", "Lollipoppy", "Blacksmith", "Ragdoll", "Battle Regalia", "Scarlet Hammer"},
  -- Q 
["Quinn"]        = {"Classic", "Phoenix", "Woad Scout", "Corsair"},
  -- R 
["Rammus"]       = {"Classic", "King", "Chrome", "Molten", "Freljord", "Ninja", "Full Metal", "Guardian of the Sands"},
["Reksai"]       = {"Classic", "Eternum", "Pool Party"},
["Renekton"]     = {"Classic", "Galactic", "Outback", "Bloodfury", "Rune Wars", "Scorched Earth", "Pool Party", "Scorched Earth", "Prehistoric"},
["Rengar"]       = {"Classic", "Headhunter", "Night Hunter", "SSW"},
["Riven"]        = {"Classic", "Redeemed", "Crimson Elite", "Battle Bunny", "Championship", "Dragonblade", "Arcade"},
["Rumble"]       = {"Classic", "Rumble in the Jungle", "Bilgerat", "Super Galaxy"},
["Ryze"]         = {"Classic", "Human", "Tribal", "Uncle", "Triumphant", "Professor", "Zombie", "Dark Crystal", "Pirate", "Whitebeard"},
  -- S 
["Sejuani"]      = {"Classic", "Sabretusk", "Darkrider", "Traditional", "Bear Cavalry", "Poro Rider"},
["Shaco"]        = {"Classic", "Mad Hatter", "Royal", "Nutcracko", "Workshop", "Asylum", "Masked", "Wild Card"},
["Shen"]         = {"Classic", "Frozen", "Yellow Jacket", "Surgeon", "Blood Moon", "Warlord", "TPA"},
["Shyvana"]      = {"Classic", "Ironscale", "Boneclaw", "Darkflame", "Ice Drake", "Championship"},
["Singed"]       = {"Classic", "Riot Squad", "Hextech", "Surfer", "Mad Scientist", "Augmented", "Snow Day", "SSW"},
["Sion"]         = {"Classic", "Hextech", "Barbarian", "Lumberjack", "Warmonger"},
["Sivir"]        = {"Classic", "Warrior Princess", "Spectacular", "Huntress", "Bandit", "PAX", "Snowstorm", "Warden", "Victorious"},
["Skarner"]      = {"Classic", "Sandscourge", "Earthrune", "Battlecast Alpha", "Guardian of the Sands"},
["Sona"]         = {"Classic", "Muse", "Pentakill", "Silent Night", "Guqin", "Arcade", "DJ"},
["Soraka"]       = {"Classic", "Dryad", "Divine", "Celestine", "Reaper", "Order of the Banana"},
["Swain"]        = {"Classic", "Northern Front", "Bilgewater", "Tyrant"},
["Syndra"]       = {"Classic", "Justicar", "Atlantean", "Queen of Diamonds"},
  -- T 
["TahmKench"]    = {"Classic", "Master Chef"},
["Talon"]        = {"Classic", "Renegade", "Crimson Elite", "Dragonblade", "SSW"},
["Taric"]        = {"Classic", "Emerald", "Armor of the Fifth Age", "Bloodstone"},
["Teemo"]        = {"Classic", "Happy Elf", "Recon", "Badger", "Astronaut", "Cottontail", "Super", "Panda", "Omega Squad"},
["Thresh"]       = {"Classic", "Deep Terror", "Championship", "Blood Moon", "SSW"},
["Tristana"]     = {"Classic", "Riot Girl", "Earnest Elf", "Firefighter", "Guerilla", "Buccaneer", "Rocket Girl", "Chroma Pack: Navy", "Chroma Pack: Purple", "Chroma Pack: Orange", "Dragon Trainer"},
["Trundle"]      = {"Classic", "Lil' Slugger", "Junkyard", "Traditional", "Constable"},
["Tryndamere"]   = {"Classic", "Highland", "King", "Viking", "Demonblade", "Sultan", "Warring Kingdoms", "Nightmare"},
["TwistedFate"]  = {"Classic", "PAX", "Jack of Hearts", "The Magnificent", "Tango", "High Noon", "Musketeer", "Underworld", "Red Card", "Cutpurse"},
["Twitch"]       = {"Classic", "Kingpin", "Whistler Village", "Medieval", "Gangster", "Vandal", "Pickpocket", "SSW"},
  -- U 
["Udyr"]         = {"Classic", "Black Belt", "Primal", "Spirit Guard", "Definitely Not"},
["Urgot"]        = {"Classic", "Giant Enemy Crabgot", "Butcher", "Battlecast"},
  -- V 
["Varus"]        = {"Classic", "Blight Crystal", "Arclight", "Arctic Ops", "Heartseeker", "Swiftbolt"},
["Vayne"]        = {"Classic", "Vindicator", "Aristocrat", "Dragonslayer", "Heartseeker", "SKT T1", "Arclight", "Chroma Pack: Green", "Chroma Pack: Red", "Chroma Pack: Silver"},
["Veigar"]       = {"Classic", "White Mage", "Curling", "Veigar Greybeard", "Leprechaun", "Baron Von", "Superb Villain", "Bad Santa", "Final Boss"},
["Velkoz"]       = {"Classic", "Battlecast", "Arclight"},
["Vi"]           = {"Classic", "Neon Strike", "Officer", "Debonair", "Demon"},
["Viktor"]       = {"Classic", "Full Machine", "Prototype", "Creator"},
["Vladimir"]     = {"Classic", "Count", "Marquis", "Nosferatu", "Vandal", "Blood Lord", "Soulstealer", "Academy"},
["Volibear"]     = {"Classic", "Thunder Lord", "Northern Storm", "Runeguard", "Captain"},
  -- W 
["Warwick"]      = {"Classic", "Grey", "Urf the Manatee", "Big Bad", "Tundra Hunter", "Feral", "Firefang", "Hyena", "Marauder"},
["MonkeyKing"]   = {"Classic", "Volcanic", "General", "Jade Dragon", "Underworld","Radiant"},
  -- X 
["Xerath"]       = {"Classic", "Runeborn", "Battlecast", "Scorched Earth", "Guardian of the Sands"},
["XinZhao"]      = {"Classic", "Commando", "Imperial", "Viscero", "Winged Hussar", "Warring Kingdoms", "Secret Agent"},
  -- Y 
["Yasuo"]        = {"Classic", "High Noon", "PROJECT"},
["Yorick"]       = {"Classic", "Undertaker", "Pentakill"},
  -- Z 
["Zac"]          = {"Classic", "Special Weapon", "Pool Party", "Chroma Pack: Orange", "Chroma Pack: Bubblegum", "Chroma Pack: Honey"},
["Zed"]          = {"Classic", "Shockblade", "SKT T1", "PROJECT"},
["Ziggs"]        = {"Classic", "Mad Scientist", "Major", "Pool Party", "Snow Day", "Master Arcanist"},
["Zilean"]       = {"Classic", "Old Saint", "Groovy", "Shurima Desert", "Time Machine", "Blood Moon"},
["Zyra"]         = {"Classic", "Wildfire", "Haunted", "SKT T1"},
},
minions = {"Classic","Theme 1","Theme 2","Theme 3","Theme 4","Theme 5","Theme 6","Theme 7","Theme 8","Theme 9"},

wardsS1 = {"Classic","Bat-O-Lantern Ward","Haunting Ward","Widow Ward","Deadfall Ward","Tomb Angel Ward","Snowman Ward","Gingerbread Ward","Lantern of the Serpent Ward","Banner of the Serpent Ward","Starcall Ward","Ward of Draven","Luminosity Ward","Season 3 Victorious Ward","Season 3 Championship Ward","Candycane Ward","Banner of the Horse Ward","Gong Ward","Bouquet Ward","Fist Bump Ward","SKT T1 Ward","Dragonslayer Ward","All-Star 2014","Golden Goal Ward"},

wardsS2 = {"Mecha Ward","Armordillo Ward","Sad Mummy Ward","Sun Disk Ward","Season 4 Championship Ward","Conquering Ward","Triumphant Ward","Victorious Ward","Battlecast Ward","Poro Ward","Astro Poro Ward","Gentleman Poro Ward","Battlecast Poro Ward","Dragonslayer Poro Ward","Underworld Poro Ward","Firecracker Ward","Heatseeker Ward","Urf Triumphant Ward","Mother Serpent Ward","Slaughter Fleet Ward	","Optic Enhance Ward","Season 2015 Championship Ward","Conquering Ward 2","Triumphant Ward 2"}
,
wardsS3 = {"Victorious Ward 2","Dragon Trainer Riggle Ward","2015 All-Stars Team Fire","2015 All-Stars Team Ice","Penguin Skier Ward","Rising Dawn Ward","Love Harp Ward"}
}
