if SERVER then
    util.AddNetworkString( "call_cl_playurl_validSound_net" )
end

if CLIENT then
	AddCSLuaFile( "cl_playurl.lua" )
	
end

local Sounds = {}




function isSoundStream( plyname , soundstream ) 
	local PlySounds = Sounds[plyname]
	local Sound = Sounds[soundstream]
	Sound = tab
	
	return true
end

function addSoundStream( plyname , soundstream, tab ) 
	Sounds[plyname] = {}
	local PlySounds = Sounds[plyname]
	Sounds[soundstream] = {}
	local Sound = Sounds[soundstream]
	tab["invalidURL"]=0
	tab["ply"]=plyname
	tab["soundstream"]=soundstream
	tab["clk"]=0
	Sound = tab
	
end

function addSoundStreamVariable( plyname , soundstream, name, value ) 
	local PlySounds = Sounds[plyname]
	local Sound = Sounds[soundstream]
	Sound[name]=value
	
end

function getSoundStream( plyname , soundstream ) 
	local PlySounds = Sounds[plyname]
	local Sound = Sounds[soundstream]
	
	return Sound
end





local function playurl( data )
	
	local name = data:ReadString()
	local url = data:ReadString()
	local steamid = data:ReadString()
	local localstation;
	local invalidURL;
	
	local tab = {}
	tab["IGModAudioChannel"]=nil
	tab["invalidURL"]=0
	tab["clk"]=0
	tab["ply"]=steamid
	--tab["setup"]=1
			
	addSoundStream( steamid, name, tab )
	
	sound.PlayURL ( url, "3d", function( station, errorID, errorName )
		if ( IsValid( station ) ) then
			LocalPlayer():ChatPrint( "[PlayURL]" .. " " .. "valid URL!" )
			
			station:SetPos( LocalPlayer():GetPos() )
			station:SetVolume( 1 )
			
			addSoundStreamVariable(steamid, name, "IGModAudioChannel", station)
			addSoundStreamVariable(steamid, name, "invalidURL", 1)
			addSoundStreamVariable(steamid, name, "clk", 1)
			addSoundStreamVariable(steamid, name, "setup", 0)
			
		else
			LocalPlayer():ChatPrint( "[PlayURL]" .. " " .. "Invalid URL!" )
			LocalPlayer():ChatPrint( "[PlayURL]" .. " " .. "Error: " .. errorName)
			LocalPlayer():ChatPrint( "[PlayURL]" .. " " .. "URL: " .. url)
			
			--local tab = {}
			--tab["IGModAudioChannel"]=nil
			--tab["invalidURL"]=0
			--tab["clk"]=0
			
			addSoundStreamVariable(steamid, name, "IGModAudioChannel", nil)
			addSoundStreamVariable(steamid, name, "invalidURL", 0)
			addSoundStreamVariable(steamid, name, "clk", 1)
			addSoundStreamVariable(steamid, name, "setup", 1)
			
			--addSoundStream( LocalPlayer():SteamID(), name, tab )
		end
	end )
	
	--net.Start( "call_cl_playurl_net" )
		--net.WriteTable(tab)
	--net.SendToServer()
	
end
usermessage.Hook( "call_cl_playurl", playurl, data)

local function sendSoundStream( steamid, name ) 
	if(isSoundStream( steamid, name )) then
		local tabel = getSoundStream( steamid, name )
		
		local tab = {}
		tab["ply"]=tabel["ply"]
		tab["invalidURL"]=tabel["ply"]
		tab["soundstream"]=tabel["soundstream"]
		tab["clk"]=tabel["clk"]
		
		net.Start( "call_cl_playurl_soundstream_net" )
			net.WriteTable(tab)
		net.SendToServer()
	end
end

local function sendStream( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		sendSoundStream( SteamID, String )
	end
end
usermessage.Hook( "call_cl_playurl_soundstream", sendStream, data)

local function testfor( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		net.Start( "call_cl_playurl_validSound_net" )
			--net.WriteFloat( invalidURL ) 
			net.WriteTable(tabel)
		net.SendToServer()
	end
end
usermessage.Hook( "call_cl_playurl_validSound", testfor, data)




local function enableLoopingSound( data )
	local String = data:ReadString()
	local Number = data:ReadFloat()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			if(Number == 1) then
				tabel["IGModAudioChannel"]:EnableLooping( true ) 
			end
			if(Number == 0) then
				tabel["IGModAudioChannel"]:EnableLooping( false ) 
			end
		end
	end
end
usermessage.Hook( "call_cl_playurl_enableLooping", enableLoopingSound, data)





local function isSetupedSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			if(tabel["setup"] == 0) then
				net.Start( "call_cl_playurl_isSetuped_net" )
					net.WriteString( SteamID )
					net.WriteString( String )
					net.WriteFloat( 0 )
				net.SendToServer()
			elseif(tabel["setup"] == 1) then
				net.Start( "call_cl_playurl_isSetuped_net" )
					net.WriteString( SteamID )
					net.WriteString( String )
					net.WriteFloat( 1 )
				net.SendToServer()
				
			end
			
			addSoundStreamVariable(SteamID, String, "setup", 1)
		end
	end
end
usermessage.Hook( "call_cl_playurl_isSetuped", isSetupedSound, data)



local function getPosSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		net.Start( "call_cl_playurl_isvalid_net" )
			net.WriteString( SteamID )
			net.WriteString( String )
			if(tabel["invalidURL"] == 1) then
				net.WriteFloat( 1 )
			end
			if(tabel["invalidURL"] == 0) then
				net.WriteFloat( 0 )
			end
		net.SendToServer()
	end
end
usermessage.Hook( "call_cl_playurl_isvalid", getPosSound, data)





local function getLengthSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			
			net.Start( "call_cl_playurl_getLength_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( tabel["IGModAudioChannel"]:GetLength() )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getLength", getLengthSound, data)

local function getTimeSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			
			net.Start( "call_cl_playurl_getTime_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( tabel["IGModAudioChannel"]:GetTime() )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getTime", getTimeSound, data)

local function setTimeSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	local Time = data:ReadFloat()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			if(Time >= tabel["IGModAudioChannel"]:GetTime()) then
				tabel["IGModAudioChannel"]:SetTime( tabel["IGModAudioChannel"]:GetLength() )
			elseif(Time < tabel["IGModAudioChannel"]:GetTime()) then
				tabel["IGModAudioChannel"]:SetTime( Time )
			end
		end
	end
end
usermessage.Hook( "call_cl_playurl_setTime", setTimeSound, data)




local function set3DFadeDistanceSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	local min = data:ReadFloat()
	local max = data:ReadFloat()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:Set3DFadeDistance(min, max)
		end
	end
end
usermessage.Hook( "call_cl_playurl_set3DFadeDistance", set3DFadeDistanceSound, data)



local function setPosSound( data )
	local String = data:ReadString()
	local Pos = data:ReadVector()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:SetPos( Pos )
		end
	end
end
usermessage.Hook( "call_cl_playurl_setPos", setPosSound, data)

local function getPosSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			
			net.Start( "call_cl_playurl_getPos_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteVector( tabel["IGModAudioChannel"]:GetPos() )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getPos", getPosSound, data)




local function getLevelSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			local left, right = tabel["IGModAudioChannel"]:GetLevel()
			
			net.Start( "call_cl_playurl_getLevel_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( left )
				net.WriteFloat( right )
			net.SendToServer()
		end
		
		if(tabel["invalidURL"] == 0) then
		
			net.Start( "call_cl_playurl_getLevel_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( 0 )
				net.WriteFloat( 0 )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getLevel", getLevelSound, data)

local function getLevelSound2( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			local left, right = tabel["IGModAudioChannel"]:GetLevel()
			
			net.Start( "call_cl_playurl_getLevel2_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( left )
				net.WriteFloat( right )
			net.SendToServer()
		end
		
		if(tabel["invalidURL"] == 0) then
		
			net.Start( "call_cl_playurl_getLevel2_net" )
				net.WriteString( SteamID )
				net.WriteString( String )
				net.WriteFloat( 0 )
				net.WriteFloat( 0 )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getLevel2", getLevelSound2, data)



local function setVolumeSound( data )
	local String = data:ReadString()
	local Number = data:ReadFloat()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:SetVolume( Number )
		end
	end
end
usermessage.Hook( "call_cl_playurl_setVolume", setVolumeSound, data)

local function getVolumeSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		local SoundStream=tabel["soundstream"]
		
		if(tabel["invalidURL"] == 1) then
			
			net.Start( "call_cl_playurl_getVolume_net" )
				net.WriteFloat( tabel["IGModAudioChannel"]:GetVolume() ) 
				net.WriteString( SteamID )
				net.WriteString( String )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getVolume", getVolumeSound, data)






local function stopSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String ) == true) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:Stop()
		end
	end
end
usermessage.Hook( "call_cl_playurl_stopsound", stopSound, data)

local function pauseSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:Pause()
		end 
	end
end
usermessage.Hook( "call_cl_playurl_pause", pauseSound, data)

local function playSound( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:Play()
		end
	end
end
usermessage.Hook( "call_cl_playurl_play", playSound, data)













---------------------------------- VGUI FUNCTION ----------------------------------

local function openVGUI( data )
	local Text = data:ReadString()
	local SoundStream = data:ReadString()
	
	local HintPanel = vgui.Create( "DFrame" )
	HintPanel:SetSize( 200, 200 )
	HintPanel:Center()
	HintPanel:ShowCloseButton( false )
	HintPanel:SetTitle( "[E2]PlayURL - HintBox" )
	HintPanel:SetDraggable( false )
	HintPanel:MakePopup()
	
	local TextEntry = vgui.Create( "DTextEntry", HintPanel ) 
	TextEntry:SetPos( 10, 30 )
	TextEntry:SetEditable( false )
	TextEntry:SetSize( 200-20, 170-60 )
	TextEntry:SetText( Text )
	TextEntry:SetWrap(true)
	TextEntry:CenterHorizontal()
	TextEntry:SetDrawBackground(true)
	TextEntry:SetDrawBorder(true)
	TextEntry:SetMultiline(true)
	
	--TextEntry:SetHighlightColor(Color(240, 96, 240))--Color(240, 96, 240)
	
	local closeButton = vgui.Create( "Button", HintPanel )
	closeButton:SetSize( 200-20, 25 )
	closeButton:SetPos( 10, 200-35 )
	closeButton:SetVisible( true )
	closeButton:SetText( "Close" )
	function closeButton:OnMousePressed()
		HintPanel:Close()
		
		net.Start( "call_cl_openVGUI_close" )
			net.WriteString( SoundStream )
		net.SendToServer()
	end
end
usermessage.Hook( "call_cl_openVGUI", openVGUI, data)



---------------------------------- MAIN FUNCTION ----------------------------------

local function getFFTChannels( data )
	local String = data:ReadString()
	local SteamID = data:ReadString()
	local FFT_Enum = data:ReadFloat()
	
	if(isSoundStream( SteamID, String )) then
		local tabel = getSoundStream( SteamID, String )
		
		local FFTChannelTabel = {}
		
		if(tabel["invalidURL"] == 1) then
			tabel["IGModAudioChannel"]:FFT( FFTChannelTabel , FFT_Enum )
			
			net.Start( "call_cl_playurl_FFTChannel_net" )
				net.WriteString( SteamID ) 
				net.WriteString( String )
				net.WriteTable( FFTChannelTabel )
			net.SendToServer()
		end
	end
end
usermessage.Hook( "call_cl_playurl_getFFT", getFFTChannels, data)