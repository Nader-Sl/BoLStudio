-- Developers: 
    --Divine (http://forum.botoflegends.com/user/86308-divine/)
    --PvPSuite (http://forum.botoflegends.com/user/76516-pvpsuite/)

local sVersion = '2.8';
local rVersion = GetWebResult('raw.githubusercontent.com', '/Nader-Sl/BoLStudio/master/Versions/p_masterFlash.version?no-cache=' .. math.random(1, 25000));

if ((rVersion) and (tonumber(rVersion) ~= nil)) then
	if (tonumber(sVersion) < tonumber(rVersion)) then
		print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FFFF00">An update has been found and it is now downloading!</font>');
		DownloadFile('https://raw.githubusercontent.com/Nader-Sl/BoLStudio/master/Scripts/p_masterFlash.lua?no-cache=' .. math.random(1, 25000), (SCRIPT_PATH.. GetCurrentEnv().FILE_NAME), function()
			print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#00FF00">Script has been updated, please reload!</font>');
		end);
		return;
	end;
else
	print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FF0000">Update Error</font>');
end;

if ((string.find(GetGameVersion(), 'Releases/6.1') == nil) and (string.find(GetGameVersion(), 'Releases/6.2') == nil)) then
	print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FF0000">Game Version Not Supported</font>');
	return;
end;

local theMenu = nil;
local flashSpell = nil;
local spellHeader = nil;
local slotPos = nil;
local s1H = nil;
local s2H = nil;
local flashH = nil;
local canBeUsed = false;
local lastKP = 0;

if (string.find(GetGameVersion(), 'Releases/6.1') ~= nil) then
	spellHeader = 0x7E;
	slotPos =  14 ;
	s1H = 0x9D;
	s2H = 0x54;
elseif (string.find(GetGameVersion(), 'Releases/6.2') ~= nil) then
		spellHeader = 0x12B;
		slotPos = 27;
		s1H = 0xDF;
		s2H = 0xD7;
end;


function OnLoad()
	if (GetSpellName(SUMMONER_1) == 'summonerflash') then
		flashSpell = SUMMONER_1;
		flashH = s1H;
	elseif (GetSpellName(SUMMONER_2) == 'summonerflash') then
			flashSpell = SUMMONER_2;
			flashH = s2H;
	end;
	
	if (flashSpell ~= nil) then
		canBeUsed = true;
	else
		print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#FF0000">Flash Not Found</font>');
		return;
	end;
	
	InitMenu();
	
	print('<font color="#FF1493"><b>[p_masterFlash]</b> </font><font color="#00EE00">Loaded Successfully</font>');
end;

function OnDraw()
	if (canBeUsed) then
		if (theMenu.showFlashRange) then
			if (myHero:CanUseSpell(flashSpell) == READY) then
				local maxLocation = GetMaxLocation(450);
				DrawCircle3D(myHero.x, myHero.y, myHero.z, 400, 3, RGBA(200, 200, 0, 254), 100);
				
				local circleColor = RGBA(200, 80, 0, 255);
				
				if (theMenu.flashMaxDistanceIfWall) then
					if (IsBehindWall()) then
						circleColor = RGBA(0, 255, 0, 255);
					else
						circleColor = RGBA(255, 0, 0, 255);
					end;
				end;
				
				DrawCircle3D(maxLocation.x, maxLocation.y, maxLocation.z, 50, 3, circleColor, 100);
			end;
		end;
	end;
end;

function OnTick()
	if (canBeUsed) then
		if ((theMenu.flashKey) and ((not VIP_USER) or (not theMenu.replaceOriginal))) then
      
			if ((CurrentTimeInMillis() - lastKP) > 250) then
				lastKP = CurrentTimeInMillis();
				if (myHero:CanUseSpell(flashSpell) == READY) then
					MasterFlash();
				end;
			end;
		end;
	end;
end;

function OnSendPacket(sPacket)
  --if sPacket.header == 0x6A or sPacket.header == 0xB6 or sPacket.header == 0xAC then return end
  if sPacket.header == spellHeader then
    --print(string.format("%02X",sPacket.header));
    --print(DumpPacket(sPacket).data)
  end
	if (canBeUsed) then
		if ((theMenu.replaceOriginal) and (VIP_USER)) then
			if (sPacket.header == spellHeader) then		
				if (myHero:CanUseSpell(flashSpell) == READY) then
					sPacket.pos = slotPos;
					if (sPacket:Decode1() == flashH) then
						if (not flashPlease) then
							sPacket:Block();
							 MasterFlash();
						else
							flashPlease = false;
						end;
					end;
				end;
			end;
		end
	end;
end;

function InitMenu()
	theMenu = scriptConfig('p_masterFlash', 'p_masterFlash');
	theMenu:addParam('flashKey', 'Master Flash Key', SCRIPT_PARAM_ONKEYDOWN, false, GetKey('G'));
	if (VIP_USER) then
		theMenu:addParam('replaceOriginal', 'Replace Original Flash', SCRIPT_PARAM_ONOFF, true);
	end;
	theMenu:addParam('flashMaxDistanceIfWall', 'Max Distance Only If Wall', SCRIPT_PARAM_ONOFF, false);
	theMenu:addParam('showFlashRange', 'Show Flash Range', SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey('T'));
end;

function MasterFlash()
	local maxLocation = GetMaxLocation(425);
	flashPlease = true;
	if (theMenu.flashMaxDistanceIfWall) then
		if (not IsBehindWall()) then
			return CastSpell(flashSpell, mousePos.x, mousePos.z);
		end;
	end;
	
	return CastSpell(flashSpell, maxLocation.x, maxLocation.z);
end;

function IsBehindWall()
	for I = 250, 450, 50 do
		local maxLocation = GetMaxLocation(I);
		if (CalculatePath(myHero, D3DXVECTOR3(maxLocation.x, maxLocation.y, maxLocation.z)).count ~= 2) and (IsWall(D3DXVECTOR3(maxLocation.x, maxLocation.y, maxLocation.z))) then
			return true;
		end;
	end;
	
	return false;
end;

function GetSpellName(whatSpell)
	local theSpell = myHero:GetSpellData(whatSpell);
	if (theSpell ~= nil) then
		return theSpell.name;
	end;
	
	return nil;
end;

function GetMaxLocation(tR)
	local mVector = Vector(mousePos.x, mousePos.z, mousePos.y);
	local hVector = Vector(myHero.x, myHero.z, myHero.y);
	local bVector = ((mVector - hVector):normalized() * tR) + hVector;
	
	local theX, theZ, theY = bVector:unpack();
	return {x = theX, y = theY, z = theZ};
end;

function CurrentTimeInMillis()
	return (os.clock() * 1000);
end;