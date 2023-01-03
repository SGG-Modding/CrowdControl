local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades, false )

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
	pack.Effects.helloworld = pack.Parametric.Actions.PrintStack( "Hello World!" )
	pack.Effects.delayedsuicide = cc.BindEffect( packs.Base.Parametric.Triggers.Delay( 5 ), pack.Actions.Suicide )
		
end

-- put our effects into the centralised Effects table, under the "hades.examples" path
ModUtil.Path.Set( "hades.examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )