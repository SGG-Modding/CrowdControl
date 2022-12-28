local cc = CrowdControl
local packs = setmetatable( ModUtil.Mod.Register( "Packs", cc ), nil )
local pack = ModUtil.Mod.Register( "Base", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	-- A trigger takes an effect id and an action
	-- The trigger must eventually invoke the action with the id passed in
	-- if the action specifically returns false, and it's possible to retry the action, eventually do so
	-- Triggers that don't immediately handle their actions may benefit from eventually using InvokeActions
	
	function pack.Triggers.Instant( id, action ) return action( id ) end
		
	function pack.Parametric.Triggers.Pipe( a, b )
		return function( id, action )
			return b( id, function( id ) return a( id, action ) end )
		end
	end
		
	function pack.Parametric.Triggers.Delay( s )
		return function( id, action )
			return thread( function( )
				wait( s )
				return action( id )
			end )
		end
	end
	
	-- Actions
	-- An action performs the actual mechanics of the effect
	-- Actions have a responsibility to call NotifyEffect if they 
	-- If an action specifically returns false it should be retried by its trigger
	-- Should not return false if you call NotifyEffect

	function pack.Parametric.Actions.Invoke( func, ... )
		local args = table.pack( ... )
		return function( id )
			func( table.unpack( args ) )
			return cc.NotifyEffect( id )
		end
	end
	
	-- Effects
	-- Named tuples of Trigger and Action
	-- When effects are requested, the ID and action is passed into the trigger
	-- The trigger is then responsible for eventually invoking that action
	-- The action is responsible for notifying CrowdControl when it triggers
end

-- put our effects into the centralised Effects table
-- new packs can nest their effects inside sub-tables to have unique paths
-- so for example these effects could start with "Base."
-- but since this is the default pack we merge directly
-- (but there are no effects in this pack)
-- it may be more convenient to keep all effects in a shared namespace
-- we will see what the convention ends up being

-- ModUtil.Table.Merge( cc.Effects, pack.Effects )