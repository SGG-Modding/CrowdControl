--[[ Effect Pack Terminology

	Pack: (AKA Effect Pack, Module...)
	* Adds effects to the CrowdControl.Effects table
	* New packs can nest their effects inside sub-tables to have unique paths
	* It may be more convenient to keep all effects in a shared namespace
	* We will see what the convention ends up being used

	Effects: (AKA Effect Functions)
	* Can be of any 'order':
		- A function that directly affects the game is a first order effect
		- A function that dynamically delegates to another function to affect the game is a second order effect
		- etc...
	* Effects have a responsibility to eventually call NotifyEffect on their id (by default this reports success)
	* An effect can be formed by binding a trigger with an action via BindEffect (see below for triggers and actions)

	The following are optional abstractions:

	Actions: (AKA Child Effect Functions)
	* An action usually performs the actual mechanics of the effect
	* If an action that has a trigger (parent effect) specifically returns false, the trigger may attempt to retry the action
	* Only return false if NotifyEffect has not yet been called for that instance of the effect
	* An action may be the final step for an effect instance, if so it should call NotifyEffect

	Triggers: (AKA Parent Effect Functions)
	* A trigger is a higher order effect that takes an effect id and an action (child effect)
	* The trigger must eventually invoke the action with the id passed in
	* Ideally if the action specifically returns false, and it's possible to retry the action, eventually do so
	* Triggers that handle their actions in batches may benefit from using InvokeEffects
	* If an action that returns false can't be retried, report "RETRY" via NotifyEffect so it can start from the top

	Parametric: (for Parametric.Actions and Parametric.Triggers)
	* Not directly a trigger or action, until called with some arguments (one step removed to be more general)
]]

local cc = CrowdControl
local packs = ModUtil.Mod.Register( "Packs", cc, false )
local pack = ModUtil.Mod.Register( "Base", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	function pack.Triggers.Instant( id, action, ... )
		return action( id, ... )
	end
		
	function pack.Parametric.Triggers.Pipe( a, b )
		return function( id, ... )
			local args = table.pack( ... )
			return b( id, function( id ) 
				return a( id, table.unpack( args ) )
			end )
		end
	end
		
	function pack.Parametric.Triggers.Delay( s )
		return function( id, action, ... )
			local args = table.pack( ... )
			return thread( function( )
				wait( s )
				return action( id, table.unpack( args ) )
			end )
		end
	end
	
	-- Actions

	function pack.Parametric.Actions.Invoke( func, ... )
		local args = table.pack( ... )
		return function( id )
			func( table.unpack( args ) )
			return cc.NotifyEffect( id )
		end
	end
	
	-- Effects

	-- ...

end

-- Example of how to put effects into the centralised Effects table:

-- since this is the default pack we would merge directly (but there are no effects in this pack)
-- ModUtil.Table.Merge( cc.Effects, pack.Effects )

-- Internal

-- If you have internal components (local variables and functions: i.e. local1, local2, local3 etc.)
-- You can add a global interface for them with this snippet:

-- pack.Internal = ModUtil.UpValues( function( ) return local1, local2, local3 end )

-- This allows for them to be manipulated by the REPL (interactive console / terminal), for example:
-- PathToPackHere.Internal.valueA = 5 -- sets the local valueA to 5 from the REPL
-- PathToPackHere.Internal.runTestB( ) -- calls the local function runTestB from the REPL