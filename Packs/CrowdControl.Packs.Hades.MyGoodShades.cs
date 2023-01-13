using System;
using System.Collections.Generic;
using CrowdControl.Common;
using JetBrains.Annotations;
using ConnectorType = CrowdControl.Common.ConnectorType;

namespace CrowdControl.Games.Packs
{
    [UsedImplicitly]
    public class Hades : SimpleTCPPack
    {
        public override string Host => "127.0.0.1";

        public override ushort Port => 58430;

        public override SITimeSpan ResponseTimeout => 20;

        public Hades(IPlayer player, Func<CrowdControlBlock, bool> responseHandler, Action<object> statusUpdateHandler) : base(player, responseHandler, statusUpdateHandler) { }

        public override Game Game { get; } = new(5, "Hades", "Hades", "PC", ConnectorType.SimpleTCPConnector);

        public override List<Effect> Effects { get; } = new()
        {
            new Effect("Hello World", "Hades.MyGoodShades.HelloWorld"),
            new Effect("No Escape", "Hades.MyGoodShades.TimedKillHero"){ Duration = 5 },
			// new Effect("300 Temporary Money", "Hades.Examples.TempMoney"){ Duration = 10 },
            new Effect("Add Death Defiance", "Hades.MyGoodShades.DDAdd"),
            new Effect("Remove Death Defiance", "Hades.MyGoodShades.DDRemove"),
            new Effect("Flashbang", "Hades.MyGoodShades.Flashbang"),
           

            // Assist pack
            new Effect("Dusa Assist", "Hades.Assists.DusaAssist"),
            new Effect("Skelly Assist", "Hades.Assists.SkellyAssist"),
            
            // Cornucopia pack
            new Effect("Build Call", "Hades.MyGoodShades.BuildSuperMeter"),
            new Effect("Healing Aid", "Hades.Cornucopia.DropHeal"),
            new Effect("Money Aid", "Hades.Cornucopia.DropMoney"),
            new Effect("Nectar Aid", "Hades.Cornucopia.DropNectar"),
            new Effect("Poison Cure", "Hades.Cornucopia.PoisonCure"),

            // Legion pack
            new Effect("Numbskulls", "Hades.Legion.SpawnNumbskull"),
            new Effect("Flamewheels", "Hades.Legion.SpawnFlameWheel"),
            new Effect("Pests", "Hades.Legion.SpawnPest" ),
            new Effect("Voidstone", "Hades.Legion.SpawnVoidstone" ),
            new Effect("Snakestone", "Hades.Legion.SpawnSnakestone" ),
            new Effect("Satyr", "Hades.Legion.SpawnSatyr" ),



        };
    }
}
