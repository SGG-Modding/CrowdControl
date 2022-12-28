-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControlHadesDraft" )
local shared, doAction, dispatchActions

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

--[[
	Helper for implementing triggers
	
	actionMap - a map/dictionary from id to action
	idQueue - an array/sequence table of ids

--]]
function dispatchActions( actionMap, idQueue )
	if idQueue then
		-- if you provide an id queue then we will mutate that
		-- this way actions are invoked in insertion order
		local n = #idQueue
		if n == 0 then return end
		for i = 1, n do
			local id = idQueue[ i ]
			local action = actionMap[ id ]
			if doAction( id, action ) then
				idQueue[ i ] = nil
			end
		end
		CollapseTable( idQueue )
	else
		-- if you don't provide an id queue then we will mutate the map
		-- this means invocation order is implementation detail / undefined behaviour
		-- also I can't remember if it's safe to mutate while using the pairs iterator
		for id, action in pairs( actionMap ) do
			if doAction( id, action ) then
				actionMap[ id ] = nil
			end
		end
	end
end

-- Implementation

local function triggerEffect( id, result )
	return shared.TriggerEffect( id, result )
end

function doAction( id, action )
	local result = action( id )
	if result ~= false then
		triggerEffect( id, result )
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
	return doAction, actions, triggers, effectData, queueEffect, triggerEffect, initShared, dispatchActions
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControlHadesDraft )

initShared( )