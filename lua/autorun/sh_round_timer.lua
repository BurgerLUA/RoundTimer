AddCSLuaFile()

function RoundTimerStart(ply,cmd,args)

	if CLIENT then return end

	if type(tonumber(args[1])) ~= "number" then return end
	
	local RoundDelay = 60*args[1]
	local RoundLength = 60*args[2] + RoundDelay + 2

	RoundStart(RoundLength,RoundDelay)

	print("ROUND TIME IS " .. args[1] .. " MINUTES")

end

concommand.Add("starttimer",RoundTimerStart)



function RoundStart(RoundLength,RoundDelay)

	local World = game.GetWorld( )

	for k,v in pairs(player.GetAll()) do
		v:Freeze(false)
		v:Spawn()
		v:SetFrags(0)
		v:SetDeaths(0)
		v:UnSpectate()
	end
	
	local TimePassed = 0
	
	timer.Destroy("RTSecondTick")
	
	timer.Create("RTSecondTick",1,0,function()
	
		TimePassed = TimePassed + 1
		
		--print(TimePassed .. " out of " .. RoundLength)
		
		
	
		local RoundTimeLeft = RoundLength - TimePassed
		local RoundDelayTimeLeft = RoundDelay - TimePassed
	
		if RoundDelayTimeLeft > -2 then
			World:SetNWInt("RTCountdown",RoundDelayTimeLeft)
			World:SetNWBool("RTWarmup",true)
			print("Warmup: " .. RoundDelayTimeLeft .. " seconds left")
		else
			World:SetNWInt("RTCountdown",RoundTimeLeft)
			World:SetNWBool("RTWarmup",false)
			print("Deathmatch: " .. RoundTimeLeft .. " seconds left")
		end
		
		World:SetNWInt("NewCurTime",TimePassed)
		
		if TimePassed >= RoundLength then
			RoundEnd()
			timer.Destroy("RTSecondTick")
		end
	
	end)
	
end

function RoundEnd()
	
	local Winner = AskForWinner()
	
	print("THE WINNER IS ".. Winner:Nick())
	
	if Winner ~= Entity(0) then
		WinningEffects(Winner)
		CleanUpEnts()
	end

end

function AskForWinner()

	local PreviousFrags = 0
	local Winner = Entity(0)
 
	for k,v in pairs(player.GetAll()) do

		if PreviousFrags < v:Frags() then
			PreviousFrags = v:Frags()
			Winner = v
		end
		
	end
	
	return Winner

end

function WinningEffects(Winner)

	for k,v in pairs( player.GetAll() ) do
	
		if v:Alive() == false then
			v:Spawn()
		end
	
		v:StripWeapons()
		v:Freeze(true)
			
		if v ~= Winner then
			v:Spectate( OBS_MODE_CHASE )
			v:SpectateEntity( Winner )
		else
			v:ConCommand("act dance")
		end
		
		SendRoundSound(Winner)
		
		timer.Simple(10,function() RoundTimerStart(Entity(0),"anus",{"5","30"}) end)
		
		
	end
	
end

function CleanUpEnts()
	for k,v in pairs(ents.GetAll()) do
	
		if v:GetClass() == "ent_cs_droppedweapon" or v:GetClass() == "ent_cs_ammo_base" then
			v:Remove()
		end
		
	end
end

function SendRoundSound(winner)

	net.Start("SendRoundInfo")
		net.WriteEntity(winner)
	net.Broadcast()


	--v:EmitSound("ut/wildwastelandend"..Random2 .. ".wav")

	--

	--v:EmitSound("ut/Winner.wav")

end

if SERVER then
	util.AddNetworkString( "SendRoundInfo" )
end



if CLIENT then
	net.Receive( "SendRoundInfo", function( len )
		
		local winner = net.ReadEntity()
		
		print(winner)
		
		if winner == LocalPlayer() then
			winner:EmitSound("ut/Winner.wav")
		else
			winner:EmitSound("ut/lostmatch.wav")
		end

	end)
end







function RoundTimerHUD()
	if SERVER then return end
	
	local World = game.GetWorld( )
	
	local Seconds = math.max(0,World:GetNWInt("RTCountdown",0))
	local NewCurTime = World:GetNWInt("NewCurTime",0)
	
	--print(Seconds)
	
	--print(NewCurTime)
	
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
	
	
	
end

hook.Add("HUDPaint","Round Timer HUD", RoundTimerHUD)
 
 
 
 
 
 
 
 
 