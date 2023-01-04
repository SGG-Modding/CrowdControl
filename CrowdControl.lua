-- Depends on ModUtil, StyxScribe, StyxScribeShared, StyxScribeActive

ModUtil.Mod.Register( "CrowdControl" )

local requestTimes = { }
local idQueues = { }
local effectMaps = { }
local shared

-- Helpers

local function handleEffects(effectMap, idQueue)
	table.insert( effectMaps, effectMap )
	if idQueue then idQueues[ effectMap ] = idQueue end
end

local function checkEffect( id )
	--print(id, StyxScribeActive.Time, requestTimes[ id ], StyxScribeActive.Time - requestTimes[ id ])
	return StyxScribeActive.Time - requestTimes[ id ] < CrowdControl.EffectTimeout
end

local function invokeEffect( id, effect, ... )
	if checkEffect( id ) then
		return effect( id, ... )
	end
end

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
			if invokeEffect( id, effect, ... ) ~= false then
				idQueue[ i ] = nil
				effectMap[ id ] = nil
			end
		end
		CollapseTable( idQueue )
	else
		-- if you don't provide an id queue then we will just mutate the map
		-- this means invocation order is implementation detail / undefined behaviour
		for id, effect in pairs( effectMap ) do
			if invokeEffect( id, effect, ... ) ~= false then
				effectMap[ id ] = nil
			end
		end
	end
end

local function bindEffect( effect, value )
	return function( id, ... )
		return invokeEffect( id, effect, value, ... )
	end
end

-- TODO: timed effect helpers

-- Implementation

local function checkHandledEffects( )
	for i, effectMap in rawipairs( effectMaps ) do
		local idQueue = idQueues[ effectMap ]
		if idQueue then
			for i, id in rawipairs( idQueues ) do
				if not checkEffect( id ) then
					idQueue[ i ] = nil
					effectMap[ id ] = nil
				end
			end
			CollapseTable( idQueue )
		else
			for id in rawpairs( effectMap ) do
				if not checkEffect( id ) then
					effectMap[ id ] = nil
				end
			end
		end
	end
end

local function routineCheckHandledEffects( )
	while true do
		wait(CrowdControl.EffectTimeout/2)
		checkHandledEffects( )
	end
end

local function notifyEffect( id, result )
	return shared.NotifyEffect( id, result )
end

local function requestEffect( id, effect, sentTime )
	requestTimes[ id ] = sentTime or StyxScribeActive.Time
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
	return invokeEffect( id, func )
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

CrowdControl.EffectTimeout = 5

CrowdControl.Shared = nil
CrowdControl.Effects = { }

CrowdControl.RequestEffect = requestEffect
CrowdControl.NotifyEffect = notifyEffect

CrowdControl.InvokeEffects = invokeEffect
CrowdControl.InvokeEffects = invokeEffects
CrowdControl.HandleEffects = handleEffects
CrowdControl.CheckEffect = checkEffect
CrowdControl.BindEffect = bindEffect

-- Internal

CrowdControl.Internal = ModUtil.UpValues( function( )
	return initShared, requestEffect, notifyEffect, invokeEffect, invokeEffects,
		bindEffect, checkEffect, handleEffects, checkHandledEffects, routineCheckHandledEffects
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControl )

initShared( )

thread( routineCheckHandledEffects )