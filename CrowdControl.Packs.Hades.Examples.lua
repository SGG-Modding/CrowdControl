local cc, within, packs = CrowdControl, ModUtil.Context.Data, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades )

within( cc, function( ) within( pack, function( )

	Parametric = { }
	
	-- Triggers
	Triggers = within( { }, function( )
		
	end )
	
	Parametric.Triggers = within( { }, function( )
		
	end )
	
	-- Actions
	Actions = within( { }, function( )
	
		function Suicide( id )
			KillHero( { }, { }, { }
			return NotifyEffect( id )
		end
	
	end )
	Parametric.Actions = within( { }, function( )
		
		function PrintStack( ... )
			return function( id )
				ModUtil.Hades.PrintStack( ... )
				return NotifyEffect( id )
			end
		end
		
	end )
	
	-- Effects
	Effects = within( { }, function( )
	
		HelloWorld = { Trigger = packs.Base.Triggers.Instant, Action = Actions.Parametric.PrintStack( "Hello World!" ) }
		DelayedSuicide = { Trigger = packs.Base.Parametric.Triggers.Delay( 5 ), Action = Actions.Suicide }
		
	end )
		
end ) end )

-- put our effects into the centralised Effects table

ModUtil.Path.Set( "Hades.Examples.Effects", ModUtil.Table.Copy( pack.Effects ), cc.Effects )