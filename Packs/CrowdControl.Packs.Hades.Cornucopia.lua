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

	-- =====================================================
	-- Actions
	-- =====================================================
	-- Builds up the call gauge

	-- Spawn Item Consumable action
	function pack.Actions.SpawnMoney()
		local dropItemName = "MinorMoneyDrop"
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

	-- Spawns a small heal drop (heals for 10)
	function pack.Actions.SpawnHealDrop()
		DropHealth( "HealDropMinor", CurrentRun.Hero.ObjectId )
		return true
	end
	
	-- Effects
	pack.Effects.DropHeal = pack.Actions.SpawnHealDrop
	pack.Effects.DropMoney = pack.Actions.SpawnMoney

end

-- put our effects into the centralised Effects table, under the "Hades.Cornucopia" path
ModUtil.Path.Set( "Hades.Cornucopia", ModUtil.Table.Copy( pack.Effects ), cc.Effects )