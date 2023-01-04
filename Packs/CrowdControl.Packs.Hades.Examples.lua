local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	function packs.Base.Parametric.Triggers.DisplayTimer( duration )
		return function( ... )
			thread( function( )
				while duration > 1 do
					ModUtil.Hades.PrintOverhead( duration, 1 )
					duration = duration - 1
					wait( 1 )
				end
				ModUtil.Hades.PrintOverhead( duration, duration )
				wait(duration)
				ModUtil.Hades.PrintOverhead( " ", 0.05 )
				cc.InvokeEffect( ... )
			end	)
		end
	end
	
	-- Actions
	function pack.Actions.Suicide( id )
		KillHero( { }, { }, { } )
		return cc.NotifyEffect( id )
	end

	function packs.Base.Parametric.Actions.DisplayTimer( duration )
		return function( id )
			cc.NotifyEffect( id, "Success", duration )
			thread( function( )
				while duration > 1 do
					ModUtil.Hades.PrintOverhead( duration, 1 )
					duration = duration - 1
					wait( 1 )
				end
				ModUtil.Hades.PrintOverhead( duration, duration )
				wait(duration)
				cc.NotifyEffect( id, "Finished" )
				ModUtil.Hades.PrintOverhead( " ", 0.05 )
			end	)
		end
	end

	function pack.Parametric.Actions.PrintStack( ... )
		return packs.Base.Parametric.Actions.Invoke( ModUtil.Hades.PrintStack, ... )
	end
	
	-- Effects
	pack.Effects.HelloWorld = pack.Parametric.Actions.PrintStack( "Hello World!" )
	pack.Effects.DelayedSuicide = cc.BindEffect( packs.Base.Parametric.Triggers.Delay( 5 ), pack.Actions.Suicide )
	pack.Effects.TimedSuicide = cc.BindEffect( pack.Parametric.Triggers.DisplayTimer( 5 ), pack.Actions.Suicide )
	pack.Effects.Display5SecTimer = packs.Base.Parametric.Actions.DisplayTimer( 5 )

end

-- put our effects into the centralised Effects table, under the "Hades.Examples" path
ModUtil.Path.Set( "Hades.Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )