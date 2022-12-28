local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	-- Actions
	function pack.Actions.Suicide( id )
		KillHero( { }, { }, { } )
		return cc.NotifyEffect( id )
	end

	function pack.Parametric.Actions.PrintStack( ... )
		return packs.Base.Parametric.Actions.Invoke( ModUtil.Hades.PrintStack, ... )
	end
	
	-- Effects
	pack.Effects.HelloWorld = { Trigger = packs.Base.Triggers.Instant, Action = pack.Parametric.Actions.PrintStack( "Hello World!" ) }
	pack.Effects.DelayedSuicide = { Trigger = packs.Base.Parametric.Triggers.Delay( 5 ), Action = pack.Actions.Suicide }
		
end

-- put our effects into the centralised Effects table

ModUtil.Path.Set( "Hades.Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )