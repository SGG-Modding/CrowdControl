local cc, within = CrowdControl, ModUtil.Context.Data
local packs = setmetatable( ModUtil.Mod.Register( "Hades", cc.Packs ) )
local pack = ModUtil.Mod.Register( "Base", packs )

within( cc, function( ) within( pack, function( )

	Parametric = { }

	-- Triggers
	-- A trigger takes an effect id and an action
	-- The trigger must eventually invoke the action with the id passed in
	-- if the action specifically returns false, and it's possible to retry the action, eventually do so
	-- Triggers that don't immediately handle their actions may benefit from eventually using InvokeActions
	
	Triggers = within( { }, function( )
		
	end )
	Parametric.Triggers = within( { }, function( )
		
		-- use any of the base game's triggers as effect triggers
		local onTrigger = { }
		function OnTrigger( name, ... )

			local toTrigger = onTrigger[ name ]
			if not toTrigger then
				toTrigger = { ids = { }, actions = { } }
				onTrigger[ name ] = toTrigger
				local function runTriggers( ... )
					InvokeActions( toTrigger.actions, toTrigger.ids, ... )
				end
				ModUtil.Path.Get( name ){ runTriggers, ... }
			end
			
			return function( id, action )
				toTrigger.actions[ id ] = action
				return table.insert( toTrigger.ids, id )
			end
		end
		
		-- trigger on entering the next valid room according to a predicate
		function NextValidRoom( predicate )
			-- stub
		end
		
	end )
	
	-- Actions
	
	Actions = within( { }, function( )
	
	end )
	Parametric.Actions = within( { }, function( )
	
	end )
	
	-- Effects
	
	Effects = within( { }, function( )

	end )
		
end ) end )

-- put our effects into the centralised Effects table

ModUtil.Path.Set( "Hades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )