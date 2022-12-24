ModUtil.Mod.Register( "CrowdControlHadesDraft" )

local conditions = {
	NextChamber = function( id )
		-- whatever it takes to make it trigger after the next chamber's entrance presentation ends
		local success = true
		return success
	end,
	NextEncounter = ...,
	Anywhere = ...,
	...	
}

-- possibly helpful internal things for the gritty of implementing some effects
local internalEffectCallbacks = { } -- map from id to function that cancels the effect
local internalEffectEndTimes = { } -- map from id to _screenTime beyond which the effect should cancel

local actions = {
	SpawnSkulls = function( id )
		-- spawn skulls
		local success -- if it succeeded
		return success
	end,
	...
}

local effectData = {
	SpawnSkulls = { Condition = conditions.NextChamber, Action = actions.SpawnSkulls },
	...
}

local effectsByID = { }

local effectQueue = { }

local function handleEffectRequest( message )
	-- split the message and marshal components if necessary
	-- any other information from the message?
	local effect = message
	-- make a new table so we get a unique ID
	-- if there's an ID system for effect instances from SDK or python,
	-- 		use that ID forwarded in the message instead of this id
	local id = { }
	effectsById[ id ] = effect
	table.insert( effectQueue, id )
end

local function respondSuccess( id )
	local effect = effectsById[ id ]
	-- assuming we're not using an ID system in the SDK at the moment
	-- if we were then we'd just send the ID instead of the effect name
	StyxScribe.Send( "CrowdControlHadesDraft: " .. effect )
end

local function triggerEffects( )
	for i = 1, #effectQueue do
		local id = effectQueue[ i ]
		local effect = effectsById[ id ]
		local data = effectData[ effect ]
		if data.Condition( id ) then
			if data.Action( id ) then 
				respondSuccess( id )
				effectQueue[ i ] = nil
				effectsById[ id ] = nil
			end
		end
	end
	CollapseTable( effectQueue )
end

local function effectLoop = function( )
	while true do
		wait( 0.5 ) -- whatever is necessary to make it not laggy when a lot of effects are requested
		triggerEffects( )
	end
end

CrowdControlHadesDraft.Internal = ModUtil.UpValues( function( )
	return actions, conditions, effectsByID, effectData, effectQueue, effectLoop, respondSuccess, triggerEffects, handleEffectRequest
end )

StyxScribe.AddHook( handleEffectRequest, "CrowdControlHadesDraft: ", CrowdControlHadesDraft )

thread( effectLoop )