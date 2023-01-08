--[[ Effect Pack Terminology

	Pack: (AKA Effect Pack, Module...)
	* Adds effects to the CrowdControl.Effects table
	* New packs can nest their effects inside sub-tables to have unique paths
	* It may be more convenient to keep all effects in a shared namespace
	* We will see what the convention ends up being used

	Effects: (AKA Effect Functions)
	* Keys in the CrowdControl.Effects table must always be purely lowercase strings, for technical reasons 
	* Can be of any 'order':
		- A function that directly affects the game is a first order effect
		- A function that dynamically delegates to another function to affect the game is a second order effect
		- etc...
	* Effects have a responsibility to eventually call NotifyEffect on their id
	* Return a boolean to automatically call NotifyEffect by the surrounding call of InvokeEffect (true for success/finished, false for retry/failure)
	* Any time an effect is invoked, it should be via InvokeEffect in case of timeouts and to automatically notify
	* An effect can be formed by binding a trigger with an action via BindEffect (see below for triggers and actions)
	* Timed effects can be formed via TimedEffect by providing a duration, enable function and corresponding disable function
	* If an effect should fail when it returns false instead of being retried, use RigidEffect

	The following are optional abstractions:

	Actions: (AKA Child Effect Functions)
	* An action usually performs the actual mechanics of the effect
	* An action may be the final step for an effect instance, if so it should call NotifyEffect or return a boolean

	Triggers: (AKA Parent Effect Functions)
	* A trigger is a higher order effect that takes an effect id and an action (child effect)
	* The trigger must eventually invoke the action with the id passed in
	* Triggers that handle their actions in batches may benefit from using InvokeEffects

	Parametric: (for Parametric.Actions and Parametric.Triggers)
	* Not directly a trigger or action, until called with some arguments (one step removed to be more general)
]]

local cc, invoke = CrowdControl, CrowdControl.InvokeEffect
local packs = ModUtil.Mod.Register( "Packs", cc, false )
local pack = ModUtil.Mod.Register( "Base", packs )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	
	function pack.Parametric.Triggers.Condition( check )
		return function( ... )
			if check( ... ) then
				return invoke( ... )
			end
			return false
		end
	end

	function pack.Parametric.Triggers.Delay( s )
		return function( ... )
			local args = table.pack( ... )
			return thread( function( )
				wait( s )
				return invoke( table.unpack( args ) )
			end )
		end
	end
	
	-- Actions

	function pack.Parametric.Actions.Invoke( func, ... )
		local args = table.pack( ... )
		return function( )
			return true, func( table.unpack( args ) )
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