local cc = CrowdControl
local packs = ModUtil.Mod.Register( "Hades", cc.Packs, false )
local pack = ModUtil.Mod.Register( "Base", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

local onTrigger
do
	-- Triggers

	-- use any of the base game's triggers as effect triggers
	-- might have issues with triggers that take extra arguments
	onTrigger = { }
	function pack.Parametric.Triggers.OnTrigger( trigger, ... )
		if type( trigger ) == "string" then
			trigger = ModUtil.Path.Get( trigger )
		end
		local toTrigger = onTrigger[ trigger ]
		if not toTrigger then
			toTrigger = { ids = { }, actions = { } }
			onTrigger[ trigger ] = toTrigger
			cc.HandleEffects( toTrigger.actions, toTrigger.ids )
			local function runTriggers( ... )
				cc.InvokeEffects( toTrigger.actions, toTrigger.ids, ... )
			end
			trigger( { runTriggers, ... } )
		end
		
		return function( id, action )
			toTrigger.actions[ id ] = action
			return table.insert( toTrigger.ids, id )
		end
	end
		
	-- trigger on entering the next valid room according to a predicate
	function pack.Parametric.Triggers.NextValidRoom( predicate )
		-- stub
	end
	
	-- Actions
	
	-- Effects
end

-- put our effects into the centralised Effects table, under the "Hades" path
-- (but there are no effects in this pack)
-- ModUtil.Path.Set( "Hades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )

-- Internal

pack.Internal = ModUtil.UpValues( function( ) return onTrigger end )