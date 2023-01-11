local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "MyGoodShades", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- =====================================================
	-- Triggers
	-- =====================================================
	function pack.Triggers.IfRunActive( id, action, ... )
		if not CurrentRun.Hero.IsDead then
			cc.InvokeEffect( id, action, ... )
		end
		return false
	end

	
	-- Experimental Triggers 

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

	-- =====================================================
	-- Actions
	-- =====================================================

	-- Hope you enjoyed the show, my good Shade!
	function pack.Actions.KillHero( id )

		local HelloVoiceLines = {
			{
				-- PlayOnceFromTableThisRun = true,
				RequiredFalseFlags = { "InFlashback" },
				PreLineWait = 1.0,
				BreakIfPlayed = true,

				-- Hope you enjoyed the show, my good Shade!
				{ Cue = "/VO/ZagreusField_3345"},
			},
		}
	
		local playedSomething = PlayVoiceLines(HelloVoiceLines, false)
		return true, KillHero( { }, { }, { } )
	end


	-- Hello World! Zagreus says hello!
	function pack.Actions.SayHello()
		local HelloVoiceLines = {
			{
				-- PlayOnceFromTableThisRun = true,
				RequiredFalseFlags = { "InFlashback" },
				PreLineWait = 1.0,
				BreakIfPlayed = true,
				RandomRemaining = true,
				-- SuccessiveChanceToPlay = 0.33,

				-- Greetings everyone! Just visiting...
				{ Cue = "/VO/ZagreusHome_2077"}, 

				-- Hello, I'll only be a moment!
				{ Cue = "/VO/ZagreusHome_2079"},

				-- Just thought I'd say hello!
				{ Cue = "/VO/ZagreusHome_2081"},

				-- That was for you, good Shade!
				{ Cue = "/VO/ZagreusField_3344"},
				
				
			},
		}
		-- ModUtil.Hades.PrintStack("Hello World!")
		-- thread( PlayVoiceLines, HelloVoiceLines, false)
		local playedSomething = PlayVoiceLines(HelloVoiceLines, false)
		return playedSomething
	end

	-- Calling Aid. Add 50 to the call gauge
	function pack.Actions.BuildSuperMeter()
		if IsSuperValid() then 
			BuildSuperMeter(CurrentRun, 50)
			return true
		end
		return false
	end	

	-- =====================================================
	-- Effects
	-- =====================================================
	pack.Effects.HelloWorld = pack.Actions.SayHello
	pack.Effects.BuildSuperMeter = cc.RigidEffect( cc.BindEffect( pack.Triggers.IfRunActive, pack.Actions.BuildSuperMeter ) )

end


-- put our effects into the centralised Effects table, under the "Hades.MyGoodShades" path
ModUtil.Path.Set( "Hades.MyGoodShades", ModUtil.Table.Copy( pack.Effects ), cc.Effects )

-- For testing purposes
-- ModUtil.Path.Wrap( "BeginOpeningCodex", 
-- 	function(baseFunc)		
-- 		if not CanOpenCodex() then
-- 			pack.Actions.SayHello()
-- 		end
-- 		baseFunc()
-- 	end
-- )