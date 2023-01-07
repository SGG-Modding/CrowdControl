local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	function pack.Parametric.Triggers.DisplayTimer( duration )
		return function( ... )
			local duration = duration
			local args = table.pack( ... )
			thread( function( )
				while duration > 1 do
					ModUtil.Hades.PrintOverhead( duration, 1 )
					duration = duration - 1
					wait( 1 )
				end
				ModUtil.Hades.PrintOverhead( duration, duration )
				wait( duration )
				ModUtil.Hades.PrintOverhead( " ", 0.05 )
				return cc.InvokeEffect( table.unpack( args ) )
			end	)
		end
	end
	
	-- Actions
	function pack.Actions.Suicide( id )
		return true, KillHero( { }, { }, { } )
	end

	function pack.Parametric.Actions.PrintStack( ... )
		return packs.Base.Parametric.Actions.Invoke( ModUtil.Hades.PrintStack, ... )
	end
	
	-- Effects
	pack.Effects.HelloWorld = pack.Parametric.Actions.PrintStack( "Hello World!" )
	pack.Effects.TimedSuicide = cc.TimedEffect( 5, pack.Parametric.Triggers.DisplayTimer( 5 ), pack.Actions.Suicide )

end

-- put our effects into the centralised Effects table, under the "Hades.Examples" path
ModUtil.Path.Set( "Hades.Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )