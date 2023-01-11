local cc, packs = CrowdControl, CrowdControl.Packs
local pack = ModUtil.Mod.Register( "Legion", packs.Hades, false )

pack.Effects = { }; pack.Actions = { }; pack.Triggers = { }
pack.Parametric = { Actions = { }, Triggers = { } }

do
	-- =====================================================
	-- Triggers
	-- =====================================================


	-- =====================================================
	-- Actions
	-- =====================================================

	function pack.Actions.SpawnEnemy(selection)
		local enemyData = EnemyData[selection]
		local newEnemy = DeepCopyTable( enemyData )
		newEnemy.AIOptions = enemyData.AIOptions
		newEnemy.BlocksLootInteraction = false
		local invaderSpawnPoint = 40000
		newEnemy.ObjectId = SpawnUnit({
				Name = enemyData.Name,
				Group = "Standing",
				DestinationId = invaderSpawnPoint, OffsetX = 400, OffsetY = 200 })
		SetupEnemyObject( newEnemy, CurrentRun )
		return true
	end

	function pack.Actions.SpawnFlameWheel()
		local enemy = "ChariotSuicide"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)

		for i=1, 5 do
			pack.Actions.SpawnEnemy(enemy)
		end
		return true
	end

	function pack.Actions.SpawnNumbskull()
		local enemy = "SwarmerHelmeted"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)
		for i=1, 5 do
			pack.Actions.SpawnEnemy(enemy)
		end
		return true
	end

	function pack.Actions.SpawnVoidstone()
		local enemy = "ShieldRanged"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)
		return pack.Actions.SpawnEnemy(enemy)
	end

	function pack.Actions.SpawnPest()
		local enemy = "ThiefMineLayer"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)
		for i=1, 5 do
			pack.Actions.SpawnEnemy(enemy)
		end
		return true
	end

	function pack.Actions.SpawnSnakestone()
		local enemy = "HeavyRangedForked"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)
		return pack.Actions.SpawnEnemy(enemy)
	end

	function pack.Actions.SpawnSatyr()
		local enemy = "SatyrRanged"
		-- ModUtil.Hades.PrintStack("Trying to spawn enemy : "..enemy)
		return pack.Actions.SpawnEnemy(enemy)
	end



	-- =====================================================
	-- Effects
	-- =====================================================
	pack.Effects.SpawnFlameWheel = pack.Actions.SpawnFlameWheel
	pack.Effects.SpawnNumbskull = pack.Actions.SpawnNumbskull
	pack.Effects.SpawnVoidstone = pack.Actions.SpawnVoidstone
	pack.Effects.SpawnPest = pack.Actions.SpawnPest
	pack.Effects.SpawnSnakestone = pack.Actions.SpawnSnakestone
	pack.Effects.SpawnSatyr = pack.Actions.SpawnSatyr

end

-- put our effects into the centralised Effects table, under the "Hades.Cornucopia" path
ModUtil.Path.Set( "Hades.Legion", ModUtil.Table.Copy( pack.Effects ), cc.Effects )


-- For testing purposes
-- ModUtil.Path.Wrap( "BeginOpeningCodex", 
-- 	function(baseFunc)		
-- 		if not CanOpenCodex() then
-- 			ModUtil.Hades.PrintStack("Testing Codex function")
-- 			pack.Actions.SpawnFlameWheel()
-- 		end
-- 		baseFunc()
-- 	end
-- )
