--AddCSLuaFile()

function RoundTimerStart(ply,cmd,args)

	local World = game.GetWorld( )

	if type(tonumber(args[1])) ~= "number" then return end
	
	local RoundDelay = 60*args[1]
	local RoundLength = 60*args[2] + RoundDelay + 2

	RoundStart(RoundLength,RoundDelay)

	print("ROUND TIME IS " .. args[1] .. " MINUTES")
	
	AdjustSounds()
	
	World:SetNWBool("RTScoreBoard",false)

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
			--print("Warmup: " .. RoundDelayTimeLeft .. " seconds left")
		else
			World:SetNWInt("RTCountdown",RoundTimeLeft)
			World:SetNWBool("RTWarmup",false)
			--print("Deathmatch: " .. RoundTimeLeft .. " seconds left")
		end
		
		World:SetNWInt("NewCurTime",TimePassed)
		
		if TimePassed >= RoundLength then
			timer.Destroy("RTSecondTick")
			AskForWinner()
		end
	
	end)
	
end

local nextsend = 0

--[[
function Debug()

	if CurTime() > nextsend then
		AskForWinner()
		nextsend = CurTime() + 5
	end
	 
end

hook.Add("Think","DEBUG",Debug)
--]]



function AskForWinner()

	local PreviousFrags = 0
 
	local scoretable = {}

	for k,v in pairs(player.GetAll()) do
		
		scoretable[v] = v:Frags()
		
		--table.Add(scoretable, v = v:Frags() )
	
	end

	scoretable = table.SortByKey(scoretable)
	winner = scoretable[1]
	

	WinningEffects(winner)
	SendRoundInfo(winner,scoretable)
	CleanUpEnts()
	
	
end

function WinningEffects(Winner)

	local World = game.GetWorld( )

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
		
		

	end
	
	World:SetNWBool("RTScoreBoard",true)
	
	
	timer.Simple(10,function() RoundTimerStart(Entity(0),"anus",{"0.1","5"}) end)
	
end

function CleanUpEnts()
	for k,v in pairs(ents.GetAll()) do
	
		if v:GetClass() == "ent_cs_droppedweapon" or v:GetClass() == "ent_cs_ammo_base" then
			v:Remove()
		end
		
	end
end

util.AddNetworkString( "SendRoundInfo" )

function SendRoundInfo(winner,scoretable)

	net.Start("SendRoundInfo")
		net.WriteEntity(winner)
		net.WriteTable(scoretable)
	net.Broadcast()

end

local num1 = 0
local num2 = 0
local num3 = 0
local rand1 = 0

function AdjustSounds()
	
	local World = game.GetWorld( )
	
	rand1 = math.random(1,100)
	
	--[[
	if num1 < 9 then
		num1 = num1 + 1
	else
		num1 = 1
	end
	
	if num2 < 9 then
		num2 = num2 + 1
	else
		num2 = 1
	end
	
	if num3 < 17 then
		num3 = num3 + 1
	else
		num3 = 1
	end
	--]]
	
	num1 = math.random(1,10)
	num2 = math.random(1,9)
	num3 = math.random(1,17)
	
	
	--print( num1 )
	--print( num2 )
	--print( num3 )
	
	World:SetNWInt("100Chance",rand1)
	World:SetNWInt("MusicTrack",num1)
	World:SetNWInt("LoseTrack",num2)
	World:SetNWInt("WinTrack",num3)

end

function RoundTimerEnableImmunity(ply,attacker)

	local World = game.GetWorld( )

	if World:GetNWBool("RTWarmup",false) == true then
		return false
	else
		return true
	end

end

hook.Add("PlayerShouldTakeDamage","Round Timer: Build Timer Immunity",RoundTimerEnableImmunity)


