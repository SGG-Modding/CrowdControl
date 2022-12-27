-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControlHadesDraft" )
local doAction, shared

-- Effect Definitions

local triggers = {
	Instant = function( id, action ) return doAction( id, action ) end
}

local actions = {
	HelloWorld = function( id )
		ModUtil.Hades.PrintStack( "Hello World!" )
	end
}

local effectData = {
	HelloWorldInstant = { Trigger = triggers.Instant, Action = actions.HelloWorld }
}

-- Implementation

local effectsByID = { }
local effectQueue = { }

local function triggerEffect( id, result )
	return shared.TriggerEffect( id, result )
end

function doAction( id, action )
	if action( id ) ~= false then
		triggerEffect( id, "Success" )
		effectsByID[ id ] = nil
		return true
	end
	return false
end

local function prepareEffects( )
	for i = 1, #effectQueue do
		local id = effectQueue[ i ]
		local effect = effectsByID[ id ]
		local data = effectData[ effect ]
		if data.Trigger( id, data.Action ) then
			effectQueue[ i ] = nil
		end
	end
	CollapseTable( effectQueue )
end

local function effectLoop( )
	while true do
		wait( 0.25 )
		prepareEffects( )
	end
end

function queueEffect( id, effect )
	effectsByID[ id ] = effect
	table.insert( effectQueue, id )
end

local function initShared( )
	local root = StyxScribeShared.Root
	shared = root.CrowdControlHadesDraft
	if not shared then
		root.CrowdControlHadesDraft = { }
		shared = root.CrowdControlHadesDraft
	end
	shared.QueueEffect = queueEffect
end

-- Internal

CrowdControlHadesDraft.Internal = ModUtil.UpValues( function( )
	return doAction, actions, triggers, effectsByID, effectData, effectQueue, effectLoop, queueEffect, triggerEffect, prepareEffects, initShared
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControlHadesDraft )

initShared( )

thread( effectLoop )