surface.CreateFont("RoundTimerMedium", {
	font = "Tahoma", 
	size = 50, 
	weight = 500, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = true, 
	additive = false, 
	outline = false, 
})




local scoretable = {}

net.Receive( "SendRoundInfo", function( len )
	
	local winner = net.ReadEntity()
	
	scoretable = net.ReadTable()
	
	local World = game.GetWorld( )
	
	local Random = World:GetNWInt("100Chance",0)
	local WinTrack = World:GetNWInt("WinTrack",1)
	local LoseTrack = World:GetNWInt("LoseTrack",1)
	
	
	if winner == LocalPlayer() then

		--if Random < 40 then
		--	LocalPlayer():EmitSound("ut/Winner.wav")
		--else
			LocalPlayer():EmitSound("ut/win"..WinTrack..".mp3")
		--end

	else
		--if Random < 40 then
			--LocalPlayer():EmitSound("ut/lostmatch.wav")
		--else
			LocalPlayer():EmitSound("ut/lose".. LoseTrack ..".mp3")
		--end
		
	end

end)

function RoundTimerHUD()
	
	local World = game.GetWorld( )
	
	local Seconds = math.max(0,World:GetNWInt("RTCountdown",0))
	local NewCurTime = World:GetNWInt("NewCurTime",0)
	local MusicTrack = World:GetNWInt("MusicTrack",1)
	
	if not NextSound then 
		NextSound = 0
	end
	
	if NextSound <= NewCurTime then
		--print(Seconds)
		
		if Seconds >= 1 and Seconds <= 10 then
			--[[
			if Seconds == 10 then
				LocalPlayer():EmitSound("hl1/fvox/ten.wav")
			elseif Seconds == 9 then
				LocalPlayer():EmitSound("hl1/fvox/nine.wav")
			elseif Seconds == 8 then
				LocalPlayer():EmitSound("hl1/fvox/eight.wav")
			elseif Seconds == 7 then
				LocalPlayer():EmitSound("hl1/fvox/seven.wav")
			elseif Seconds == 6 then
				LocalPlayer():EmitSound("hl1/fvox/six.wav")
			if Seconds == 5 then
				LocalPlayer():EmitSound("vo/announcer_begins_5sec.mp3")
			elseif Seconds == 4 then
				LocalPlayer():EmitSound("vo/announcer_begins_4sec.mp3")
			elseif Seconds == 3 then
				LocalPlayer():EmitSound("vo/announcer_begins_3sec.mp3")
			elseif Seconds == 2 then
				LocalPlayer():EmitSound("vo/announcer_begins_2sec.mp3")
			elseif Seconds == 1	then	
				LocalPlayer():EmitSound("vo/announcer_begins_1sec.mp3")
			end
			--]]
			
			LocalPlayer():EmitSound("sound\ut\cd" .. Seconds .. ".wav")
			

			NextSound = NewCurTime + 1
		elseif Seconds == 300 then
			LocalPlayer():EmitSound("ut/cd5min.wav")
			NextSound = NewCurTime + 1
		elseif Seconds == 180 then
			LocalPlayer():EmitSound("ut/cd3min.wav")
			NextSound = NewCurTime + 1
		elseif Seconds == 60 then
			LocalPlayer():EmitSound("ut/cd1min.wav")
			
			if World:GetNWBool("RTWarmup",true) == false then
				LocalPlayer():EmitSound("ut/music" .. MusicTrack .. ".mp3")
			end
		
			NextSound = NewCurTime + 1
		elseif Seconds == 30 then
			LocalPlayer():EmitSound("ut/cd30sec.wav")
			NextSound = NewCurTime + 1
		elseif World:GetNWBool("RTWarmup",false) and Seconds == 0 then
			if math.random(1,2) == 2 then
				LocalPlayer():EmitSound("ut/prepare.wav")
			else
				LocalPlayer():EmitSound("ut/wildwastelandstart.wav")
			end
			
			NextSound = NewCurTime + 2
		else
			NextSound = 0
		end
	end
	
	--print(NextSound .. "vs" .. NewCurTime)
	
	
	if World:GetNWBool("RTWarmup",false) == true then
		Mode = "BUILD PERIOD"
	else
		Mode = "DEATHMATCH"
	end
	
	local Time = string.ToMinutesSeconds( Seconds )
	
	draw.DrawText( Mode, "RoundTimerMedium", ScrW() * 0.5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText( Time, "RoundTimerMedium", ScrW() * 0.5, 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	

	
	
	if World:GetNWBool("RTScoreBoard",false) == true then

		local Names = "Player\n"
		local Kills = "Kills\n"
		local Deaths = "Deaths\n"
	
		for k,v in pairs (scoretable) do
		
			if IsValid(v) then
		
				Names = Names .. v:Nick() .. "\n"
				Kills = Kills .. v:Frags() .. "\n"
				Deaths = Deaths .. v:Deaths() .. "\n"
				
			else
			
				Names = Names .. "Disconnected Player" .. "\n"
				Kills = Kills .. "?" .. "\n"
				Deaths = Deaths .. "?" .. "\n"
			
			end
			
		end
		
		
		
		
		
		draw.DrawText( Names, "Trebuchet24", ScrW() * 0.4, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( Kills, "Trebuchet24", ScrW() * 0.5, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( Deaths, "Trebuchet24", ScrW() * 0.6, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
	
	
end

hook.Add("HUDPaint","Round Timer HUD", RoundTimerHUD)
 
 
 
 
 
 
 
 
 