-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControl" )

local requestTimes = { }
local idQueues = { }
local effectMaps = { }
local cancelled = { }
local timers = { }
local shared, notifyEffect

-- Helpers

local function handleEffects(effectMap, idQueue)
	table.insert( effectMaps, effectMap )
	if idQueue then idQueues[ effectMap ] = idQueue end
end

local function checkEffect( id )
	return not cancelled[ id ] and _worldTime - requestTimes[ id ] < CrowdControl.EffectTimeout
end

local function invokeEffect( id, effect, ... )
	if checkEffect( id ) then
		if effect then
			local args = table.pack( effect( id, ... ) )
			if args.n >= 1 and args[ 1 ] == true then
				if timers[ id ] then
					notifyEffect( id, "Finished" )
				else
					notifyEffect( id, "Success" )
				end
			end
			return table.unpack( args )
		end
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

local function timedEffect( duration, enable, disable )
	return function( id, ... )
		local args = table.pack( invokeEffect( id, enable, ... ) )
		requestTimes[ id ] = _worldTime
		timers[ id ] = duration
		notifyEffect( id, "Success", duration )
		thread( function( )
			wait( duration )
			invokeEffect( id, disable, table.unpack( args ) )
			timers[ id ] = nil
			requestTimes[ id ] = nil
		end )
		return table.unpack( args )
	end
end

-- Implementation

local function checkHandledEffects( )
	for id, duration in rawpairs( timers ) do
		duration = duration - _worldTime + requestTimes[ id ]
		timers[ id ] = duration
		if duration > 0 then
			notifyEffect( id, "Resumed", duration )
		end
	end
	for i, effectMap in rawipairs( effectMaps ) do
		local idQueue = idQueues[ effectMap ]
		if idQueue then
			for i, id in rawipairs( idQueue ) do
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
		waitScreenTime( CrowdControl.RoutineCheckPeriod )
		checkHandledEffects( )
	end
end

function notifyEffect( ... )
	return shared.NotifyEffect( ... )
end

local function requestEffect( id, effect )
	requestTimes[ id ] = _worldTime
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

local function cancelEffect( message )
	local id = tonumber( message )
	cancelled[ id ] = true
	for i, effectMap in rawipairs( effectMaps ) do
		local idQueue = idQueues[ effectMap ]
		if idQueue then
			for i, id in rawipairs( idQueue ) do
				idQueue[ i ] = nil
				effectMap[ id ] = nil
			end
		else
			for id in rawpairs( effectMap ) do
				effectMap[ id ] = nil
			end
		end
	end
end

-- API

CrowdControl.EffectTimeout = 20
CrowdControl.RoutineCheckPeriod = 2

CrowdControl.Shared = nil
CrowdControl.Effects = { }

CrowdControl.RequestEffect = requestEffect
CrowdControl.NotifyEffect = notifyEffect

CrowdControl.InvokeEffect = invokeEffect
CrowdControl.InvokeEffects = invokeEffects
CrowdControl.HandleEffects = handleEffects
CrowdControl.CheckEffect = checkEffect
CrowdControl.BindEffect = bindEffect
CrowdControl.TimedEffect = timedEffect

-- Internal

CrowdControl.Internal = ModUtil.UpValues( function( )
	return initShared, requestEffect, notifyEffect, invokeEffect, invokeEffects, timedEffect, cancelEffect,
		bindEffect, checkEffect, handleEffects, checkHandledEffects, routineCheckHandledEffects, cancelled
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControl )
StyxScribe.AddHook( cancelEffect, "StyxScribeShared: Cancel: ", CrowdControl )

initShared( )

thread( routineCheckHandledEffects )