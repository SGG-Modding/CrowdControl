local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "MyGoodShades", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	function pack.Triggers.IsRunActive()
		return not CurrentRun.Hero.IsDead
	end
	
	-- function pack.Triggers.DuringEncounter()
	-- 	if CurrentRun.Hero.IsDead then
	-- 		return false 
	-- 	end
	-- 	local currentEncounter = CurrentRun.CurrentRoom.Encounter
	-- 	return currentEncounter.EncounterType ~= "NonCombat" and currentEncounter.InProgress = true
	-- end

	-- function pack.Triggers.DuringNonCombat()
	-- 	return CanOpenCodex() and not CurrentRun.Hero.IsDead
	-- end

	function pack.Triggers.NextEncounter()
		-- TO FINISH
		return false
	end

	-- Actions
	function pack.Parametric.Actions.PrintStack( ... )
		return packs.Base.Parametric.Actions.Invoke( ModUtil.Hades.PrintStack, ... )
	end 

	function pack.Actions.Suicide( id )
		return true, KillHero( { }, { }, { } )
	end

	function pack.Actions.BuildSuperMeter()
		if IsSuperValid() then 
			BuildSuperMeter(CurrentRun, 50)
			return true
		end
		return false
	end	

	function pack.Parametric.Actions.AddMoney( amount )
		return function( )
			if CurrentRun.Hero.IsDead then return true end
			PlaySound({ Name = "/SFX/GoldCoinPickup", ManagerCap = 28 })
			CurrentRun.Money = CurrentRun.Money + amount
			ShowResourceUIs({ CombatOnly = false, UpdateIfShowing = true })
			UpdateMoneyUI( CurrentRun.Money )
			return true
		end
	end


	
	-- Effects
	pack.Effects.HelloWorld = pack.Parametric.Actions.PrintStack( "Hello World!" )
	pack.Effects.TimedSuicide = cc.TimedEffect( cc.BindEffect( packs.Hades.Base.Triggers.DisplayTimer, pack.Actions.Suicide ) )
	pack.Effects.BuildSuperMeter = cc.BindEffect( pack.Triggers.IsRunActive, pack.Actions.BuildSuperMeter )
	-- pack.Effects.BuildSuperMeter = pack.Actions.BuildSuperMeter 
	pack.Effects.TempMoney = cc.RigidEffect( cc.BindEffect( packs.Base.Parametric.Triggers.Condition( function( ) return not CurrentRun.Hero.IsDead end ),
		 cc.TimedEffect( pack.Parametric.Actions.AddMoney( 300 ), pack.Parametric.Actions.AddMoney( -300 ) ) ) )

end

-- put our effects into the centralised Effects table, under the "Hades.Examples" path
ModUtil.Path.Set( "Hades.MyGoodShades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )