E2Lib.RegisterExtension("playurl", false)

local sbox_E2_PlayURL_FFTMax = CreateConVar( "sbox_E2_PlayURL_FFTMax", 2, FCVAR_ARCHIVE )

if SERVER then
      AddCSLuaFile("autorun/client/cl_playurl.lua")
	  
	  util.AddNetworkString( "call_cl_playurl_soundstream_net" )
	  util.AddNetworkString( "call_cl_playurl_validSound_net" )
	  util.AddNetworkString( "call_cl_playurl_getVolume_net" )
	  util.AddNetworkString( "call_cl_playurl_isSetuped_net" )
	  util.AddNetworkString( "call_cl_playurl_getPos_net" )
	  util.AddNetworkString( "call_cl_playurl_getLevel_net" )
	  util.AddNetworkString( "call_cl_playurl_getLevel2_net" )
	  util.AddNetworkString( "call_cl_playurl_isvalid_net" )
	  util.AddNetworkString( "call_cl_playurl_getLength_net" )
	  util.AddNetworkString( "call_cl_playurl_getTime_net" )
	  
	  ------ MAIN FUNCTION NETWORKSTRING ------
	  util.AddNetworkString( "call_cl_playurl_FFTChannel_net" )
	  util.AddNetworkString( "call_cl_openVGUI_close" )
	  ------ END ------
	  
else
      include("autorun/client/cl_playurl.lua")
	  
end

local FFT_256	=0
local FFT_512	=1
local FFT_1024	=2
local FFT_2048	=3
local FFT_4096	=4
local FFT_8192	=5
local FFT_16384	=6
local FFT_32768	=7

local FFTChannelTabel = {}
FFTChannelTabel[0]="FFT_256"
FFTChannelTabel[1]="FFT_512"
FFTChannelTabel[2]="FFT_1024"
FFTChannelTabel[3]="FFT_2048"
FFTChannelTabel[4]="FFT_4096"
FFTChannelTabel[5]="FFT_8192"
FFTChannelTabel[6]="FFT_16384"
FFTChannelTabel[7]="FFT_32768"


E2Lib.registerConstant( "FFT_256", FFT_256 )
E2Lib.registerConstant( "FFT_512", FFT_512 )
E2Lib.registerConstant( "FFT_1024", FFT_1024 )
E2Lib.registerConstant( "FFT_2048", FFT_2048 )
E2Lib.registerConstant( "FFT_4096", FFT_4096 )
E2Lib.registerConstant( "FFT_8192", FFT_8192)
E2Lib.registerConstant( "FFT_16384", FFT_16384 )
E2Lib.registerConstant( "FFT_32768", FFT_32768 )

local NetworkSystem = {}

registerType("playurl", "xpu", {},
	nil,
	nil,
	function(retval)
		if retval == nil then return end
		local _type = type(retval)
		if _type~="XPlayURL" then error("Return value is neither nil nor a XPlayURL, but a "..type(retval).."!",0) end
	end,
	function(v)
		return type(v)~="XPlayURL"
	end
)

__e2setcost(120) 

e2function playurl playURL(string name, string url)
	local tab = {}
	
	tab["name"]=name
	tab["url"]=url
	
	umsg.Start( "call_cl_playurl", self.player );
		umsg.String( name );
		umsg.String( url );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	return tab
end

registerOperator("ass", "xpu", "xpu", function(self, args)
	local op1, op2, scope = args[2], args[3], args[4]
	local      rv2 = op2[1](self, op2)
	self.Scopes[scope][op1] = rv2
	self.Scopes[scope].vclk[op1] = true
	return rv2
end)

registerOperator("is", "xpu", "xpu", function(self, args)
	local op1 = args[1]
	local op2 = args[2]
	local rv1 = op1[1](self, op1)
	if op1[1](self, op1) == op1[1](self, op2) then return 1 else return 0 end
end)

__e2setcost(20) 

e2function number clkPlayURL(string name)
	
	umsg.Start( "call_cl_playurl_soundstream", self.player );
		umsg.String( name ); 
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_soundstream_net", function( len, pl )
		local tab=net.ReadTable()
		
		if ( IsValid( pl ) and pl:IsPlayer() and tab["ply"] == self.player:SteamID() and tab["soundstream"] == name ) then
			
			return tab["clk"]
		else
			return 0
		end
	end )
end

e2function void playurl:play()
	
	umsg.Start( "call_cl_playurl_play", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
end

e2function void playurl:pause()
	
	umsg.Start( "call_cl_playurl_pause", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
end

e2function void playurl:stop()
	
	umsg.Start( "call_cl_playurl_stopsound", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
end


--[[e2function void playurl:enableLooping(number bool)
	umsg.Start( "call_cl_playurl_enableLooping", self.player );
		umsg.String( this["name"] );
		umsg.Float( bool );
		umsg.String( self.player:SteamID() );
	umsg.End();
end]]--

e2function number playurl:isSetuped()
	umsg.Start( "call_cl_playurl_isSetuped", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	NetworkSystem[self.player:SteamID().."_"..this["name"].."_setup"]=0
	
	net.Receive( "call_cl_playurl_isSetuped_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Setup=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_setup"]=Setup
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_setup"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_setup"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_setup"]
end



e2function void playurl:setPos(vector pos)
	umsg.Start( "call_cl_playurl_setPos", self.player );
		umsg.String( this["name"] );
		umsg.Vector( pos );
		umsg.String( self.player:SteamID() );
	umsg.End();
end

e2function vector playurl:getPos()
	umsg.Start( "call_cl_playurl_getPos", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getPos_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Pos=net.ReadVector()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_pos"]=Pos
		end
	end )
	
	if(isvector(NetworkSystem[self.player:SteamID().."_"..this["name"].."_pos"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_pos"]=Vector( 0, 0, 0 )
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_pos"]
end



e2function number playurl:isValidSound()
	umsg.Start( "call_cl_playurl_isvalid", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]=0
	
	net.Receive( "call_cl_playurl_isvalid_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Valid=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]= Valid
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]
end

e2function number playurl:isPlaying()
	umsg.Start( "call_cl_playurl_isvalid", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]=0
	
	net.Receive( "call_cl_playurl_isvalid_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Valid=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]= Valid
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_valid"]
end




e2function number playurl:getLeftLevel()
	umsg.Start( "call_cl_playurl_getLevel", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getLevel_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local LeftLevel=net.ReadFloat()
		local RightLevel=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_leftlevel"]= LeftLevel
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_leftlevel"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_leftlevel"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_leftlevel"]
end

e2function number playurl:getRightLevel()
	umsg.Start( "call_cl_playurl_getLevel2", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getLevel2_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local LeftLevel=net.ReadFloat()
		local RightLevel=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_rightlevel"]=RightLevel
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_rightlevel"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_rightlevel"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_rightlevel"]
end

e2function number playurl:getLevel()
	umsg.Start( "call_cl_playurl_getLevel", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getLevel_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local LeftLevel=net.ReadFloat()
		local RightLevel=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_level"]=(LeftLevel+RightLevel)/2
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_level"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_level"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_level"]
end

e2function table playurl:getLevelArray()
	umsg.Start( "call_cl_playurl_getLevel", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getLevel_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local LeftLevel=net.ReadFloat()
		local RightLevel=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			local Tab={n={},ntypes={},s={},stypes={},size=0}
			Tab["size"]=2
			
			local N={}
			local NTypes={}
			
			N[1]=LeftLevel NTypes[1]="n"
			N[2]=RightLevel NTypes[2]="n"
			
			Tab["n"]=N
			Tab["ntypes"]=NTypes
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_levelar"]=Tab
		end
	end )
	
	if(istable(NetworkSystem[self.player:SteamID().."_"..this["name"].."_levelar"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_levelar"]={n={},ntypes={},s={},stypes={},size=0}
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_levelar"]
end






e2function number playurl:getLength()
	umsg.Start( "call_cl_playurl_getLength", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getLength_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Length=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]=Length
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]
end

e2function number playurl:getTime()
	umsg.Start( "call_cl_playurl_getTime", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getTime_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local Length=net.ReadFloat()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]=Length
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_length"]
end

e2function void playurl:setTime(number Time)
	umsg.Start( "call_cl_playurl_setTime", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
		umsg.Float( Time )
	umsg.End();
end



e2function void playurl:set3DFadeDistance(number min, number max)
	umsg.Start( "call_cl_playurl_set3DFadeDistance", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
		umsg.Float( min )
		umsg.Float( max )
	umsg.End();
end



e2function void playurl:setVolume(number volume)
	umsg.Start( "call_cl_playurl_setVolume", self.player );
		umsg.String( this["name"] );
		umsg.Float( volume );
		umsg.String( self.player:SteamID() );
	umsg.End();
end

e2function number playurl:getVolume()
	
	umsg.Start( "call_cl_playurl_getVolume", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
	umsg.End();
	
	net.Receive( "call_cl_playurl_getVolume_net", function( len, pl )
		local Volume=net.ReadFloat()
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_Volume"]=Volume
		end
	end )
	
	if(isnumber(NetworkSystem[self.player:SteamID().."_"..this["name"].."_Volume"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_Volume"]=0
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_Volume"]
end 


--[[e2function void analyse(table tab)
	PrintTable( tab )
end]]--


---------------------------------- VGUI FUNCTION ----------------------------------

local OpenHints = {}

function openHintN( ply, hint )
	
	if(OpenHints[ply:SteamID()] == 0) then
		OpenHints[ply:SteamID()] = 1
		
		umsg.Start( "call_cl_openVGUI", ply );
			umsg.String( hint );
		umsg.End();
		
	end
	
end
function openHint( ply, hint, soundstream )
	
	if(OpenHints[ply:SteamID()] == 0) then
		OpenHints[ply:SteamID()] = 1
		
		umsg.Start( "call_cl_openVGUI", ply );
			umsg.String( hint );
			umsg.String( soundstream );
		umsg.End();
		
	end
	
end

net.Receive( "call_cl_openVGUI_close", function( len, pl )
	OpenHints[pl:SteamID()] = 0
	
	umsg.Start( "call_cl_playurl_stopsound", pl );
		umsg.String( net.ReadString() );
		umsg.String( pl:SteamID() );
	umsg.End();
end )


---------------------------------- MAIN FUNCTION ----------------------------------

__e2setcost(5) 

e2function table playurl:getFFT(number fft_enum)

	local FFT_Enum = fft_enum
	
	if(isnumber(OpenHints[self.player:SteamID()]) == false) then
		OpenHints[self.player:SteamID()]=0
		
	end
	
	if(FFT_Enum > GetConVarNumber("sbox_E2_PlayURL_FFTMax")) then--sbox_E2_PlayURL_FFTMax
		FFT_Enum = GetConVarNumber("sbox_E2_PlayURL_FFTMax")
		
		openHint( self.player, "Error! You reached the maximum from the getFFT.\nThe Maximun is " .. "_" .. FFTChannelTabel[GetConVarNumber("sbox_E2_PlayURL_FFTMax")] .. ". Please ask for help the server owner or Kronos9247.", this["name"])
		
		umsg.Start( "call_cl_playurl_stopsound", self.player );
			umsg.String( this["name"] );
			umsg.String( self.player:SteamID() );
		umsg.End();
		
		error("You reached the maximum from the getFFT()", 0)
	end
	
	umsg.Start( "call_cl_playurl_getFFT", self.player );
		umsg.String( this["name"] );
		umsg.String( self.player:SteamID() );
		umsg.Float( FFT_Enum )
	umsg.End();
	
	net.Receive( "call_cl_playurl_FFTChannel_net", function( len, pl )
		local Ply=net.ReadString()
		local SoundStream=net.ReadString()
		local FFTChannels=net.ReadTable()
		
		if ( IsValid( pl ) and pl:IsPlayer() and Ply == self.player:SteamID() and SoundStream == this["name"] ) then
			
			local LocalTable = {n={},ntypes={},s={},stypes={},size=0}
			local LocalN = {}
			local LocalNTypes={}
			
			local lenght = 0;
			table.foreach( FFTChannels, function( key, value )
				lenght=lenght+1;
				
				LocalN[key]=value
				LocalNTypes[key]="n"
				
			end )
			
			LocalTable["n"]=LocalN
			LocalTable["ntypes"]=LocalNTypes
			
			LocalTable["size"]=lenght
			
			NetworkSystem[self.player:SteamID().."_"..this["name"].."_fftchannels"]=LocalTable
		end
	end )
	
	if(istable(NetworkSystem[self.player:SteamID().."_"..this["name"].."_fftchannels"]) == false) then
		NetworkSystem[self.player:SteamID().."_"..this["name"].."_fftchannels"]={n={},ntypes={},s={},stypes={},size=0}
	end
	
	return NetworkSystem[self.player:SteamID().."_"..this["name"].."_fftchannels"]
end