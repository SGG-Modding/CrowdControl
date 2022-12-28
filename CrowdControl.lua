-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControl" )

local shared

--[[
	Helper for implementing triggers
	
	actionMap - a map/dictionary from id to action
	idQueue - an array/sequence table of ids

--]]
local function invokeActions( actionMap, idQueue, ... )
	if idQueue then
		-- if you provide an id queue then we will mutate that as well
		-- this way actions are invoked in insertion order
		local n = #idQueue
		if n == 0 then return end
		for i = 1, n do
			local id = idQueue[ i ]
			local action = actionMap[ id ]
			if action( id, ... ) ~= false then
				idQueue[ i ] = nil
				actionMap[ id ] = nil
			end
		end
		CollapseTable( idQueue )
	else
		-- if you don't provide an id queue then we will just mutate the map
		-- this means invocation order is implementation detail / undefined behaviour
		-- also I can't remember if it's safe to mutate while using the pairs iterator
		for id, action in pairs( actionMap ) do
			if action( id, ... ) ~= false then
				actionMap[ id ] = nil
			end
		end
	end
end

-- Implementation

local function notifyEffect( id, result )
	return shared.NotifyEffect( id, result )
end

function requestEffect( id, effect )
	if ModUtil.Callable( effect ) then
		return effect( id )
	end
	local data = CrowdControl.Effects[ effect ]
	if not data and type( effect ) == "string" then
		data = ModUtil.Path.Get( CrowdControl.Effects, effect )
	end
	return data.Trigger( id, data.Action )
end

local function initShared( )
	local root = StyxScribeShared.Root
	shared = root.CrowdControl
	if not shared then
		root.CrowdControl = { }
		shared = root.CrowdControl
	end
	CrowdControl.Shared = shared
	shared.RequestEffect = requestEffect
	shared.InvokeActions = invokeActions
end

-- API

CrowdControl.Shared = nil
CrowdControl.Effects = { }
CrowdControl.RequestEffect = requestEffect
CrowdControl.InvokeActions = invokeActions
CrowdControl.NotifyEffect = notifyEffect

-- Internal

CrowdControl.Internal = ModUtil.UpValues( function( )
	return requestEffect, notifyEffect, initShared, invokeActions
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControl )

initShared( )