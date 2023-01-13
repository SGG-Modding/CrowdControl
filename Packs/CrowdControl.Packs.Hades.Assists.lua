local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Assists", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- =====================================================
	-- Triggers
	-- =====================================================
	function pack.Triggers.IfInCombat( id, action, ... )
		if not CurrentRun.Hero.IsDead then
			local currentEncounter = CurrentRun.CurrentRoom.Encounter
			if currentEncounter.InProgress and currentEncounter.EncounterType ~= "NonCombat" then
				cc.InvokeEffect( id, action, ... )
			end
		end
		return false
	end

	-- =====================================================
	-- Actions
	-- =====================================================

	-- Summon Dusa for 30 seconds (Companion Fidi)
	function pack.Actions.DusaAssist()
		DusaAssist({Duration = 30})
		return true
	end

	function pack.Actions.SkellyAssist()
		SkellyAssist()
		return true
	end


	-- =====================================================
	-- Effects
	-- =====================================================
	pack.Effects.DusaAssist = cc.RigidEffect(cc.BindEffect(pack.Triggers.IfInCombat, pack.Actions.DusaAssist))
	pack.Effects.SkellyAssist = cc.RigidEffect(cc.BindEffect(pack.Triggers.IfInCombat, pack.Actions.SkellyAssist))

end

-- put our effects into the centralised Effects table, under the "Hades.Cornucopia" path
ModUtil.Path.Set( "Hades.Assists", ModUtil.Table.Copy( pack.Effects ), cc.Effects )

-- For testing purposes
-- ModUtil.Path.Wrap( "BeginOpeningCodex", 
-- 	function(baseFunc)		
-- 		if not CanOpenCodex() then
-- 			ModUtil.Hades.PrintStack("Testing Codex function")
-- 			pack.Actions.DusaAssist()
-- 		end
-- 		baseFunc()
-- 	end
-- )