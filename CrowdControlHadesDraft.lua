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

local function triggerEffect( id, result )
	return shared.TriggerEffect( id, result )
end

function doAction( id, action )
	if action( id ) ~= false then
		triggerEffect( id, "Success" )
		return true
	end
	return false
end

function queueEffect( id, effect )
	local data = effectData[ effect ]
	data.Trigger( id, data.Action )
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
	return doAction, actions, triggers, effectData, queueEffect, triggerEffect, initShared
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControlHadesDraft )

initShared( )