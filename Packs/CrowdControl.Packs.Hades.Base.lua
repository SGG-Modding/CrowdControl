local cc = CrowdControl
local packs = setmetatable( ModUtil.Mod.Register( "Hades", cc.Packs ), nil )
local pack = ModUtil.Mod.Register( "Base", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

local onTrigger
do
	-- Triggers

	-- use any of the base game's triggers as effect triggers
	onTrigger = { }
	function pack.Parametric.Triggers.OnTrigger( name, ... )

		local toTrigger = onTrigger[ name ]
		if not toTrigger then
			toTrigger = { ids = { }, actions = { } }
			onTrigger[ name ] = toTrigger
			local function runTriggers( ... )
				cc.InvokeActions( toTrigger.actions, toTrigger.ids, ... )
			end
			ModUtil.Path.Get( name ){ runTriggers, ... }
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

-- put our effects into the centralised Effects table
-- (but there are no effects in this pack)
-- ModUtil.Path.Set( "Hades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )

-- Internal

pack.Internal = ModUtil.UpValues( function( ) return onTrigger end )