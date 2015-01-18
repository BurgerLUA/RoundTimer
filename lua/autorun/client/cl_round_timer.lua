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
			LocalPlayer():EmitSound("ut/cd".. Seconds ..".wav")
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
	
	draw.DrawText( Mode, "Trebuchet24", ScrW() * 0.5, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText( Time, "Trebuchet24", ScrW() * 0.5, 24, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	

	
	
	if World:GetNWBool("RTScoreBoard",false) == true then

		local Names = "Player\n"
		local Kills = "Kills\n"
		local Deaths = "Deaths\n"
	
		for k,v in pairs (scoretable) do
			Names = Names .. v:Nick() .. "\n"
			Kills = Kills .. v:Frags() .. "\n"
			Deaths = Deaths .. v:Deaths() .. "\n"
		end
		
		
		
		
		
		draw.DrawText( Names, "Trebuchet24", ScrW() * 0.4, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( Kills, "Trebuchet24", ScrW() * 0.5, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		draw.DrawText( Deaths, "Trebuchet24", ScrW() * 0.6, ScrH() * 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		
	end
	
	
	
end

hook.Add("HUDPaint","Round Timer HUD", RoundTimerHUD)
 
 
 
 
 
 
 
 
 