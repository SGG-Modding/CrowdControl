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
            new Effect("Hello World", "Hades.Examples.HelloWorld"),
            new Effect("Timed Suicide", "Hades.Examples.TimedSuicide"){ Duration = 20 },
			new Effect("300 Temporary Money", "Hades.Examples.TempMoney"){ Duration = 10 },
        };
    }
}
