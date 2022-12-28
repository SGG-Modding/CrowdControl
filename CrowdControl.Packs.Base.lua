local cc, within = CrowdControl, ModUtil.Context.Data
local packs = setmetatable( ModUtil.Mod.Register( "Packs", cc ) )
local pack = setmetatModUtil.Mod.Register( "Base", packs )

within( cc, function( ) within( pack, function( )

	Parametric = { }

	-- Triggers
	-- A trigger takes an effect id and an action
	-- The trigger must eventually invoke the action with the id passed in
	-- if the action specifically returns false, and it's possible to retry the action, eventually do so
	-- Triggers that don't immediately handle their actions may benefit from eventually using InvokeActions
	
	Triggers = within( { }, function( )
	
		Instant = function( id, action ) return action( id ) end
		
	end )
	Parametric.Triggers = within( { }, function( )
	
		function Pipe( a, b )
			return function( id, action )
				return b( id, function( id ) return a( id, action ) end )
			end
		end
		
		function Delay( s )
			return function( id, action )
				return thread( function( )
					wait( s )
					return action( id )
				end )
			end
		end
		
	end )
	
	-- Actions
	-- An action performs the actual mechanics of the effect
	-- Actions have a responsibility to call CrowdControl.NotifyEffect if they 
	-- If an action specifically returns false it should be retried its trigger
	-- Should not return false if you call CrowdControl.NotifyEffect
	
	Actions = within( { }, function( )
	
	end )
	Parametric.Actions = within( { }, function( )
	
		function Invoke( func, ... )
			return function( id )
				func( ... )
				return NotifyEffect( id )
			end
		end
	
	end )
	
	-- Effects
	-- Named tuples of Trigger and Action
	-- When effects are requested, the ID and action is passed into the trigger
	-- The trigger is then responsible for eventually invoking that action
	-- The action is responsible for notifying CrowdControl when it triggers
	
	Effects = within( { }, function( )

	end )
		
end ) end )

-- put our effects into the centralised Effects table
-- new packs can nest their effects inside sub-tables to have unique paths
-- so for example these effects could start with "Base."
-- but since this is the default pack we merge directly
-- it may be more convenient to keep all effects in a shared namespace
-- we will see what the convention ends up being

ModUtil.Table.Merge( CrowdControl.Effects, pack.Effects )