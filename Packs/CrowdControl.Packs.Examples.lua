local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers

	-- Actions
	if StyxScribeREPL then
		function pack.Actions.Quit( )
			return true, StyxScribeREPL.RunPython( "end()" )
		end
		function pack.Parametric.Actions.RunPython( code )
			return function( )
				return true, StyxScribeREPL.RunPython( code )
			end
		end
	end

	-- Effects
	pack.Effects.HelloWorld = packs.Base.Parametric.Actions.Invoke( ModUtil.Print, "Hello World!" )
	if StyxScribeREPL then
		pack.Effects.DelayedQuit = cc.BindEffect( packs.Base.Parametric.Triggers.Delay( 5 ), pack.Actions.Quit )
	end
end

-- put our effects into the centralised Effects table, under the "Examples" path
ModUtil.Path.Set( "Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )