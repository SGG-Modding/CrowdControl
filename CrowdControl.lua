-- Depends on ModUtil, StyxScribe, StyxScribeShared

ModUtil.Mod.Register( "CrowdControl" )

local requestTimes = { }
local idQueues = { }
local effectMaps = { }
local cancelled = { }
local timers = { }
local rigid = { }
local ignore = { }
local stacks = { }
local shared, notifyEffect

-- Helpers

local function handleEffects(effectMap, idQueue)
	table.insert( effectMaps, effectMap )
	if idQueue then idQueues[ effectMap ] = idQueue end
end

local function checkEffect( id )
	return not cancelled[ id ]
end

local function invokeEffect( id, effect, ... )
	if not checkEffect( id ) or not effect then return end
	local args = table.pack( effect( id, ... ) )
	if not checkEffect( id ) then return end
	if args.n >= 1 then
		local final = true
		if not ignore[ id ] and args[ 1 ] == true then
			if timers[ id ] then
				notifyEffect( id, "Finished" )
				timers[ id ] = nil
			else
				notifyEffect( id, "Success" )
			end
		elseif args[ 1 ] == false then
			if rigid[ id ] then
				notifyEffect( id, "Failure" )
				rigid[ id ] = nil
			else
				notifyEffect( id, "Retry" )
			end
		else
			final = false
		end
		if final then
			cancelled[ id ] = true
			requestTimes[ id ] = nil
			ignore[ id ] = nil
		end
	end
	return table.unpack( args )
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
			invokeEffect( id, effect, ... )
			idQueue[ i ] = nil
			effectMap[ id ] = nil
		end
		OverwriteAndCollapseTable( idQueue )
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

local function pipeEffect( a, b )
	return function( id, ... )
		return invokeEffect( id, b, invokeEffect( id, a, ... ) )
	end
end

local function bindEffect( effect, value )
	return function( id, ... )
		return invokeEffect( id, effect, value, ... )
	end
end

local function rigidEffect( effect )
	return function( id, ... )
		rigid[ id ] = true
		return invokeEffect( id, effect, ... )
	end
end

local function softEffect( effect )
	return function( id, ... )
		rigid[ id ] = false
		return invokeEffect( id, effect, ... )
	end
end

local function effectTimes( id )
	local width = timers[ id ]
	if not width then return end
	local start = requestTimes[ id ]
	local spent = _worldTime - start
	local final = start + width
	local ensue = width - spent
	return spent, ensue, start, final, width
end

local function timedEffect( enable, disable )
	return function( id, duration, ... )
		local ig = ignore[ id ]
		ignore[ id ] = true
		local args = table.pack( invokeEffect( id, enable, duration, ... ) )
		if not checkEffect( id ) then return end
		ignore[ id ] = ig
		requestTimes[ id ] = _worldTime
		timers[ id ] = duration
		notifyEffect( id, "Success", duration )
		thread( function( )
			wait( duration )
			if disable then
				invokeEffect( id, disable, table.unpack( args ) )
			end
			timers[ id ] = nil
		end )
	end
end

setmetatable( stacks, {
	__call = function( self, label )
		local ids = self[ label ]
		return ids and #ids or 0
	end
} )

local function stackedEffectEnable( label, id )
	local s = stacks[ label ] or { }
	stacks[ label ] = s
	table.insert( s, id )
	return true
end

local function stackedEffectDisable( label, id )
	-- slow remove used so getting length is fast
	local s = stacks[ label ]
	for k, v in pairs( s ) do
		if v == id then
			s[ k ] = nil
		end
	end
	OverwriteAndCollapseTable( s )
	return true
end

local function stackedEffect( label, enable, disable )
	if enable then
		enable = ModUtil.Wrap( enable, function( base, id, ... )
			stackedEffectEnable( label, id )
			return base( id, ... )
		end, CrowdControl )
	else
		enable = function( id ) return stackedEffectEnable( label, id ) end
	end
	if disable then
		disable = ModUtil.Wrap( disable, function( base, id, ... )
			stackedEffectDisable( label, id )
			return base( id, ... )
		end, CrowdControl )
	else
		disable = function( id ) return stackedEffectDisable( label, id ) end
	end
	return timedEffect( enable, disable )
end

-- Implementation

local function checkHandledEffects( )
	for id, duration in rawpairs( timers ) do
		duration = duration - _worldTime + requestTimes[ id ]
		timers[ id ] = duration
		notifyEffect( id, "Resumed", duration )
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
			OverwriteAndCollapseTable( idQueue )
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

function notifyEffect( id, ... )
	if not checkEffect( id ) then return end
	return shared.NotifyEffect( id, ... )
end

local function requestEffect( id, effect, ... )
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
	return invokeEffect( id, func, ... )
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
CrowdControl.PipeEffect = pipeEffect
CrowdControl.RigidEffect = rigidEffect
CrowdControl.SoftEffect = softEffect
CrowdControl.StackedEffect = stackedEffect

CrowdControl.EffectStacks = stacks
CrowdControl.EffectTimes = effectTimes

-- Internal

CrowdControl.Internal = ModUtil.UpValues( function( )
	return initShared, requestEffect, notifyEffect, invokeEffect, invokeEffects, timedEffect, cancelEffect, pipeEffect,
		rigidEffect, softEffect, bindEffect, checkEffect, handleEffects, checkHandledEffects, routineCheckHandledEffects,
		cancelled, rigid, ignore, timers, stackedEffect, stacks, effectTimes, stackedEffectEnable, stackedEffectDisable
end )

StyxScribe.AddHook( initShared, "StyxScribeShared: Reset", CrowdControl )
StyxScribe.AddEarlyHook( cancelEffect, "StyxScribeShared: Cancel: ", CrowdControl )

initShared( )

thread( routineCheckHandledEffects )