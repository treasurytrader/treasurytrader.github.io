#region Using declarations
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Cbi;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Gui.SuperDom;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
using NinjaTrader.Core.FloatingPoint;
using NinjaTrader.NinjaScript.Indicators;
using NinjaTrader.NinjaScript.DrawingTools;
#endregion

//This namespace holds Strategies in this folder and is required. Do not change it.
namespace NinjaTrader.NinjaScript.Strategies
{
	public class StartAtmStrategyExample : Strategy
	{	
		private Account account;
   		private Order entryOrder;

		protected override void OnStateChange()
		{
			if (State == State.SetDefaults)
			{
				Description	= NinjaTrader.Custom.Resource.NinjaScriptStrategyDescriptionSampleATMStrategy;
				Name		= "StartAtmStrategyExample";
				// This strategy has been designed to take advantage of performance gains in Strategy Analyzer optimizations
				// See the Help Guide for additional information
				IsInstantiatedOnEachOptimizationIteration = false;
				
				// Find our Sim101 account
        		lock (Account.All)
              		account = Account.All.FirstOrDefault(a => a.Name == "Sim101");
			}
		}

		protected override void OnBarUpdate()
		{
			if (CurrentBar < BarsRequiredToTrade)
				return;

			if(State == State.Historical)
				return;

			if (account != null)
        	{
              	entryOrder = account.CreateOrder(Cbi.Instrument.GetInstrument("ES 09-21"), OrderAction.Buy, OrderType.Market,
                  TimeInForce.Day, 1, 0, 0, string.Empty, "Entry", null);
 
              	// Submits our entry order with the ATM strategy named "myAtmStrategyName"
              	NinjaTrader.NinjaScript.AtmStrategy.StartAtmStrategy("myAtmStrategyName", entryOrder);
        	}
		}
	}
}
