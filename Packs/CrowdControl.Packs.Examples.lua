local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers

	-- Actions
	if StyxScribeREPL then
		function pack.Actions.Quit( id )
			cc.NotifyEffect( id )
			return StyxScribeREPL.RunPython( "end()" )
		end
	end

	-- Effects
	pack.Effects.HelloWorld = { Trigger = packs.Base.Triggers.Instant, Action = packs.Base.Parametric.Actions.Invoke( ModUtil.Print, "Hello World!" ) }
	if StyxScribeREPL then
		pack.Effects.DelayedQuit = { Trigger = packs.Base.Parametric.Triggers.Delay( 5 ), Action = pack.Actions.Quit }
	end
end

-- put our effects into the centralised Effects table
ModUtil.Path.Set( "Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )