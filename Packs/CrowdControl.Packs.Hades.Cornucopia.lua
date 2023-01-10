local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Cornucopia", packs.Hades, false )

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

	-- Actions
	function pack.Actions.BuildSuperMeter()
		if IsSuperValid() then 
			BuildSuperMeter(CurrentRun, 50)
			return true
		end
		return false
	end	

	function pack.Actions.SpawnItem( dropItemName )
		local dropItemName = "RoomRewardHealDrop"
		GiveRandomConsumables({
			Delay = 0.5,
			NotRequiredPickup = true,
			LootOptions =
			{
				{
					Name = dropItemName,
					Chance = 1,
				}
			}
		})
		return true
	end

	function pack.Actions.SpawnHealDrop()
		DropHealth( "HealDropMinor", CurrentRun.Hero.ObjectId )
		return true
	end



	
	-- Effects
	pack.Effects.BuildSuperMeter = pack.Actions.BuildSuperMeter 
	pack.Effects.DropHeal = pack.Actions.SpawnHealDrop

end

-- put our effects into the centralised Effects table, under the "Hades.Examples" path
ModUtil.Path.Set( "Hades.Cornucopia", ModUtil.Table.Copy( pack.Effects ), cc.Effects )