local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	-- Actions
	function pack.Actions.KillHero( id )
		return true, KillHero( { }, { }, { } )
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

	function pack.Parametric.Actions.PrintStack( ... )
		return packs.Base.Parametric.Actions.Invoke( ModUtil.Hades.PrintStack, ... )
	end
	
	-- Effects
	pack.Effects.HelloWorld = pack.Parametric.Actions.PrintStack( "Hello World!" )
	pack.Effects.TimedKillHero = cc.BindEffect( packs.Hades.Base.Triggers.IfCanMove, pack.Actions.KillHero )
	pack.Effects.TempMoney = cc.RigidEffect( cc.BindEffect( packs.Base.Parametric.Triggers.AntiCondition( "CurrentRun.Hero.IsDead" ),
		 cc.TimedEffect( pack.Parametric.Actions.AddMoney( 300 ), pack.Parametric.Actions.AddMoney( -300 ) ) ) )

end

-- put our effects into the centralised Effects table, under the "Hades.Examples" path
ModUtil.Path.Set( "Hades.Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )