local cc, within, packs = CrowdControl, ModUtil.Context.Data, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Examples", packs )

within( cc, function( ) within( pack, function( )

	Parametric = { }
	
	-- Triggers
	Triggers = within( { }, function( )
		
	end )
	
	Parametric.Triggers = within( { }, function( )
		
	end )
	
	-- Actions
	Actions = within( { }, function( )
	
		if StyxScribeREPL then
			function Quit( id )
				NotifyEffect( id )
				return StyxScribeREPL.RunPython( "end()" )
			end
		end
	
	end )
	Parametric.Actions = within( { }, function( )
		
		if StyxScribeREPL then
			function RunPython( code )
				return function( id )
					NotifyEffect( id )
					return StyxScribeREPL.RunPython( code )
				end
			end
		end
		
	end )
	
	-- Effects
	Effects = within( { }, function( )
	
		HelloWorld = { Trigger = packs.Base.Triggers.Instant, Action = packs.Base.Actions.Parametric.Invoke( ModUtil.Print, "Hello World!" ) }
		if StyxScribeREPL then
			DelayedQuit = { Trigger = packs.Base.Parametric.Triggers.Delay( 5 ), Action = Actions.Quit }
		end
		
	end )
		
end ) end )

-- put our effects into the centralised Effects table

ModUtil.Path.Set( "Hades.Examples", ModUtil.Table.Copy( pack.Effects ), cc.Effects )