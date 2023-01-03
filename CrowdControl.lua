-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControl" )

local shared

-- Helpers

--[[
	effectMap - a map/dictionary from id to effect
	idQueue - an array/sequence table of ids
--]]
local function invokeEffects( effectMap, idQueue, ... )
	if idQueue then
		-- if you provide an id queue then we will mutate that as well
		-- this way effects are invoked in insertion order
		local n = #idQueue
		if n == 0 then return end
		for i = 1, n do
			local id = idQueue[ i ]
			local effect = effectMap[ id ]
			if effect( id, ... ) ~= false then
				idQueue[ i ] = nil
				effectMap[ id ] = nil
			end
		end
		CollapseTable( idQueue )
	else
		-- if you don't provide an id queue then we will just mutate the map
		-- this means invocation order is implementation detail / undefined behaviour
		-- also I can't remember if it's safe to mutate while using the pairs iterator
		for id, effect in pairs( effectMap ) do
			if effect( id, ... ) ~= false then
				effectMap[ id ] = nil
			end
		end
	end
end

local function bindEffect( effect, value )
	return function( id, ... )
		return effect( id, value, ... )
	end
end

-- TODO: timed effect helpers

-- Implementation

local function notifyEffect( id, result )
	return shared.NotifyEffect( id, result )
end

local function requestEffect( id, effect )
	if ModUtil.Callable( effect ) then
		return effect( id )
	end
	local func = CrowdControl.Effects[ effect ]
	if not ModUtil.Callable( func ) and type( effect ) == "string" then
		func = ModUtil.Path.Get( effect, CrowdControl.Effects )
	end
	if not ModUtil.Callable( func ) then
		return notifyEffect( id, "Unavailable" )
	end
	return func( id )
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
end

-- API

CrowdControl.Shared = nil
CrowdControl.Effects = { }

CrowdControl.RequestEffect = requestEffect
CrowdControl.NotifyEffect = notifyEffect

CrowdControl.InvokeEffects = invokeEffects
CrowdControl.BindEffect = bindEffect

-- Internal

CrowdControl.Internal = ModUtil.UpValues( function( )
	return initShared, requestEffect, notifyEffect, invokeEffects, bindEffect
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControl )

initShared( )