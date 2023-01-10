local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "MyGoodShades", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- Triggers
	function pack.Triggers.IsRunActive()
		return not CurrentRun.Hero.IsDead
	end
	
	-- function pack.Triggers.DuringEncounter()
	-- 	if CurrentRun.Hero.IsDead then
	-- 		return false 
	-- 	end
	-- 	local currentEncounter = CurrentRun.CurrentRoom.Encounter
	-- 	return currentEncounter.EncounterType ~= "NonCombat" and currentEncounter.InProgress = true
	-- end

	-- function pack.Triggers.DuringNonCombat()
	-- 	return CanOpenCodex() and not CurrentRun.Hero.IsDead
	-- end

	-- function pack.Triggers.NextEncounter()
	-- 	-- TO FINISH
	-- 	return false
	-- end

	-- Actions
	function pack.Actions.BuildSuperMeter()
		if IsSuperValid() then 
			BuildSuperMeter(CurrentRun, 50)
			return true
		end
		return false
	end	

	
	-- Effects
	pack.Effects.BuildSuperMeter =  pack.Actions.BuildSuperMeter 

end


-- put our effects into the centralised Effects table, under the "Hades.MyGoodShades" path
ModUtil.Path.Set( "Hades.MyGoodShades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )