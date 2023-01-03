local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers

	-- Actions
	if StyxScribeREPL then
		function pack.Actions.Quit( id )
			StyxScribeREPL.RunPython( "end()" )
			return cc.NotifyEffect( id )
		end
		function pack.Parametric.Actions.RunPython( code )
			return function( id )
				StyxScribeREPL.RunPython( code )
				return cc.NotifyEffect( id )
			end
		end
	end

	-- Effects
	pack.Effects.helloworld = packs.Base.Parametric.Actions.Invoke( ModUtil.Print, "Hello World!" )
	if StyxScribeREPL then
		pack.Effects.delayedquit = cc.BindEffect( packs.Base.Parametric.Triggers.Delay( 5 ), pack.Actions.Quit )
	end
end

-- put our effects into the centralised Effects table, under the "examples" path
ModUtil.Path.Set( "examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )