if SERVER then -- Tell the server to send these files to the client.
	AddCSLuaFile()
	resource.AddSingleFile("materials/icon64/fgtradio.png")
end

if CLIENT then -- Only load the lua on the client
local hasBeenChatNagged = false -- Have I already printed to your chat?
g_fgtRadioMainWindow = nil	-- Main derma window object
g_fgtRadioList = nil		-- DListView object
g_fgtRadioChannel = nil		-- Handle to the currently playing song
g_fgtRadioVolume = 50		-- Default volume
g_fgtRadioPlaying = false	-- Currently playing a song?
g_fgtRadioWaitSong = false	-- Are we waiting for sound.PlayURL to callback?
g_fgtRadioWaitList = false	-- Are we waiting for http.Fetch to callback?
g_fgtRadioCurrentSong = ""	-- Current song title
g_fgtRadioSongsTbl = {}		-- Table of tables(rows) { ["title"] = title, ["artist"] = artist, ["genre"] = genre, ["url"] = url }

local function httpFetchCallback( body, len, header, code )
	if !g_fgtRadioList:IsValid() then print("Error! The g_fgtRadioList is undefined!") return end -- We somehow managed to call http.Fetch() before the gui was initialized.
	if code != 200 then print("Error downloading the songs list!!! Please tell Derpy Hooves / mcd1992") return end -- My server could be broken. 
	table.Empty(g_fgtRadioSongsTbl) -- Empty the table of tables, each table in this table corresponds to a row in the DList.
	g_fgtRadioList:Clear() -- Clear the DList.
	
	for _, line in pairs( string.Explode( "\n", body ) ) do -- list.php returns a newline seperated list, each line is tab seperated of id,title,artist,genre,url.
		local songInfo = string.Explode( "\t", line ) -- split the line by \t
		if #songInfo < 5 then break end -- End of song list, this happens because its trying to parse just the last newline.
		g_fgtRadioSongsTbl[ tonumber(songInfo[1]) ] = { 	["title"] = songInfo[2], -- g_fgtRadioSongsTbl[ songId ] will contain a table of the songs info.
												["artist"] = songInfo[3],
												["genre"] = songInfo[4],
												["url"] = songInfo[5] }
												
		g_fgtRadioList:AddLine( songInfo[1], songInfo[2], songInfo[3], songInfo[4] ) -- id, title, artist, genre
	end
	g_fgtRadioWaitList = false
end

local function httpFetchError( err )
	print( "http.Fetch ERROR! " .. err )
	g_fgtRadioWaitList = false
end

local function populateDList( list )
	list:Clear()
	for id, songInfo in pairs( g_fgtRadioSongsTbl ) do
		g_fgtRadioList:AddLine( id, songInfo.title, songInfo.artist, songInfo.genre ) -- id, title, artist, genre
	end
end

local function playSong( id )
	if (table.Count(g_fgtRadioSongsTbl) > 0) and !g_fgtRadioWaitSong and !(g_fgtRadioSongsTbl[id] == nil) then -- Make sure the songsTable is populated and the last song has already calledback.
		if g_fgtRadioChannel and g_fgtRadioChannel:IsValid() then -- Stop the currently playing song, if any.
			g_fgtRadioChannel:Stop()
		end
		g_fgtRadioWaitSong = true -- We're now waiting for the below song to load. This avoids a race condition where we try to load a new song before the old one has loaded.
		sound.PlayURL( g_fgtRadioSongsTbl[id].url, "", function( chan )
			if( !IsValid(chan) ) then -- Unable to play this audio with PlayURL
				print("Failed to load! " .. g_fgtRadioSongsTbl[id].url)
				g_fgtRadioWaitSong = false
				return
			end
			g_fgtRadioWaitSong = false -- Done waiting for this song to load.
			chan:SetVolume( g_fgtRadioVolume/100 )
			g_fgtRadioChannel = chan
			g_fgtRadioPlaying = true
		end )
		--print("Now playing: "..g_fgtRadioSongsTbl[id].url)
	else
		if( table.Count(g_fgtRadioSongsTbl) < 1 ) then print("g_fgtRadioSongsTbl is empty!") end
		if( g_fgtRadioWaitSong ) then print("Please wait. We're waiting on the last PlayURLs callback...") end
	end
end

local function createFgtRadioFrame( ply, cmd, args ) -- When called from the console we need to make the initial dframe like the DesktopWindows does for us.
	local newv = list.Get( "DesktopWindows" ).FgtRadio
	
	local window = vgui.Create( "DFrame" )
		window:SetSize( newv.width, newv.height )
		window:SetTitle( newv.title )
		window:Center()
		window:SetDraggable( true )
		window:ShowCloseButton( true )
		window:MakePopup()
		window:SetKeyboardInputEnabled( false )
	newv.init( nil, window )
end

list.Set( "DesktopWindows", "FgtRadio", {
	title	= "Fgt Radio" .. g_fgtRadioCurrentSong,
	icon	= "icon64/fgtradio.png",
	width	= 960,
	height	= 700,
	onewindow = true,
	init	= function( icon, window )
		g_fgtRadioMainWindow = window
		window:SetTitle( "Fgt Radio" .. g_fgtRadioCurrentSong )
		
		local settingsBtn = window:Add( "DImageButton" )
			settingsBtn:SetPos( 846, 5 )
			settingsBtn:SetSize( 16, 16 )
			settingsBtn:SetImage( "icon16/wrench.png" )
			settingsBtn.DoClick = function()
				local menu = DermaMenu()
					menu:AddOption( "- Fgt Radio Options:", function() end )
					menu:AddOption( "      - Reload List.", function()
						if !g_fgtRadioWaitList then
							g_fgtRadioWaitList = true
							http.Fetch( "http://fgtradio.fgthou.se/list.php", httpFetchCallback, httpFetchError )
						end
					end )
				menu:Open()
			end
		
		local helpBtn = window:Add( "DImageButton" )
			helpBtn:SetPos( 828, 5 )
			helpBtn:SetSize( 16, 16 )
			helpBtn:SetImage( "icon16/help.png" )
			helpBtn.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=177192540" )
			end
		
		local pausePlay = window:Add( "DButton" )
			pausePlay:SetPos( 5, 676 )
			pausePlay:SetSize( 100, 20 )
			pausePlay:SetText( g_fgtRadioPlaying and "Pause" or "Play" )
			pausePlay.DoClick = function()
				if g_fgtRadioChannel and g_fgtRadioChannel:IsValid() then
					if g_fgtRadioPlaying then
						g_fgtRadioChannel:Pause()
						g_fgtRadioPlaying = false
						pausePlay:SetText( "Play" )
					else
						g_fgtRadioChannel:Play()
						g_fgtRadioPlaying = true
						pausePlay:SetText( "Pause" )
					end
				end
			end

		local volumeSlider = window:Add( "Slider" )
			volumeSlider:SetPos( 675, 670 )
			volumeSlider:SetWidth( 300 )
			volumeSlider:SetMin( 0 )
			volumeSlider:SetMax( 100 )
			volumeSlider:SetDecimals( 0 )
			volumeSlider:SetValue( math.floor(g_fgtRadioVolume) )
			volumeSlider.OnValueChanged = function( panel, value )
				g_fgtRadioVolume = value
				if g_fgtRadioChannel and g_fgtRadioChannel:IsValid() then
					g_fgtRadioChannel:SetVolume( value/100 )
				end
			end

		local list = window:Add( "DListView" ) -- Create the songs list. (DList)
		if list:IsValid() then g_fgtRadioList = list end -- Make sure the derma was created properly
			list:SetMultiSelect( false )
			list:SetPos( 5, 25 )
			list:SetSize( 950, 650 )
			list:AddColumn( "ID" ):SetMaxWidth( 40 )
			list:AddColumn( "Title" )
			list:AddColumn( "Artist" )
			list:AddColumn( "Genre" )
			list:AddLine( "", "Loading...", "Please Wait!", "" )
			list.DoDoubleClick = function( parent, index, list )
				playSong( tonumber(list:GetValue(1)) )
				g_fgtRadioCurrentSong = " - Now Playing: " .. list:GetValue(2)
				window:SetTitle( "Fgt Radio" .. g_fgtRadioCurrentSong )
				pausePlay:SetText( "Pause" )
			end
			list.OnRowRightClick = function( parent, index, list )
				local menu = DermaMenu()
				menu:AddOption( "- Options for " .. list:GetValue(2) .. ":", function() end )
					menu:AddOption("      - Report as broken.", function()
						http.Post("http://fgtradio.fgthou.se/report.php", { id = list:GetValue(1) } )
					end )
				menu:Open()
			end
			if (table.Count(g_fgtRadioSongsTbl) > 1) then -- We've already loaded the songs list. Just populate the list with g_fgtRadioSongsTbl data.
				populateDList( list )
			else	-- First time loading the songs list.
				table.Empty(g_fgtRadioSongsTbl)
				g_fgtRadioWaitList = true
				http.Fetch("http://fgtradio.fgthou.se/list.php", httpFetchCallback, httpFetchError)
			end
	end
} )

if !game.SinglePlayer() then -- Shameless chat notification so people know its in their context menu.
	hook.Add( "KeyPress", "FgtRadioShoutout", function( ply, key )
		if !hasBeenChatNagged and (key == IN_FORWARD) then
			timer.Simple( 5, function()
				chat.AddText( Color(0,255,0), "This server has Fgt Radio installed.\nHold C and click 'Fgt Radio' in the top left to open.\nVisit http://fgtradio.fgthou.se to add your own music!")
			end )
			hasBeenChatNagged = true
			hook.Remove( "KeyPress", "FgtRadioShoutout" )
		end
	end )
end
	
concommand.Add("fgt_radio", createFgtRadioFrame)
end -- if CLIENT end