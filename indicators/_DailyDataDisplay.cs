#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript.DrawingTools;
#endregion

namespace NinjaTrader.NinjaScript.Indicators
{
	public class _DailyDataDisplay : Indicator
	{
		protected override void OnStateChange()
		{
			if (State == State.SetDefaults)
			{
				Description	= "일봉 데이터를 차트 우측에 표시";
				Name		= "_DailyDataDisplay";
				Calculate	= Calculate.OnPriceChange;
				IsOverlay	= true;

				InpCount	= 2;
				InpShift	= 7;

				// 기본값 설정
				UpColor		= Brushes.MediumSeaGreen;
				DownColor	= Brushes.PaleVioletRed;
				CandleWidth	= 5;
			}
			else if (State == State.Configure)
			{
				AddDataSeries(BarsPeriodType.Minute, 1440);
			}
		}

		protected override void OnBarUpdate()
		{
			// 데이터 확인 및 안정성 체크
			if (BarsInProgress != 0 || CurrentBars[0] < 1 || CurrentBars[1] < InpCount) return;

			// 이전 객체 삭제 (메모리 및 겹침 방지)
			RemoveDrawObjects(); 

			for (int i = 0; i < InpCount; i++)
			{
				double o = Opens[1][i];
				double h = Highs[1][i];
				double l = Lows[1][i];
				double c = Closes[1][i];

				int chartIndex = -InpShift + i; 
				Brush color = (c >= o) ? UpColor : DownColor;
				string tag = "Daily_" + i;

				// 1. 꼬리 그리기
				Draw.Line(this, tag + "_wick", false, chartIndex, h, chartIndex, l, color, DashStyleHelper.Solid, 1);

				// 2. 몸통 그리기 (사용자 설정 CandleWidth 적용)
				Draw.Line(this, tag + "_body", false, chartIndex, o, chartIndex, c, color, DashStyleHelper.Solid, CandleWidth);
			}
		}

		#region Properties

		[Range(1, 100)]
		[NinjaScriptProperty]
		[Display(Name = "표시 개수", Order = 1, GroupName = "Parameters")]
		public int InpCount { get; set; }

		[Range(0, 100)]
		[NinjaScriptProperty]
		[Display(Name = "오른쪽 여백 시프트", Order = 2, GroupName = "Parameters")]
		public int InpShift { get; set; }

		// --- 색상 및 굵기 설정 추가 ---
		[XmlIgnore]
		[Display(Name = "상승 색상", Order = 3, GroupName = "Parameters")]
		public Brush UpColor { get; set; }

		[Browsable(false)]
		public string UpColorSerializable
		{
			get { return Serialize.BrushToString(UpColor); }
			set { UpColor = Serialize.StringToBrush(value); }
		}

		[XmlIgnore]
		[Display(Name = "하락 색상", Order = 4, GroupName = "Parameters")]
		public Brush DownColor { get; set; }

		[Browsable(false)]
		public string DownColorSerializable
		{
			get { return Serialize.BrushToString(DownColor); }
			set { DownColor = Serialize.StringToBrush(value); }
		}

		[Range(1, 50)]
		[NinjaScriptProperty]
		[Display(Name = "캔들 몸통 굵기", Order = 5, GroupName = "Parameters")]
		public int CandleWidth { get; set; }

		#endregion
	}
}

#region NinjaScript generated code. Neither change nor remove.

namespace NinjaTrader.NinjaScript.Indicators
{
	public partial class Indicator : NinjaTrader.Gui.NinjaScript.IndicatorRenderBase
	{
		private _DailyDataDisplay[] cache_DailyDataDisplay;
		public _DailyDataDisplay _DailyDataDisplay(int inpCount, int inpShift, int candleWidth)
		{
			return _DailyDataDisplay(Input, inpCount, inpShift, candleWidth);
		}

		public _DailyDataDisplay _DailyDataDisplay(ISeries<double> input, int inpCount, int inpShift, int candleWidth)
		{
			if (cache_DailyDataDisplay != null)
				for (int idx = 0; idx < cache_DailyDataDisplay.Length; idx++)
					if (cache_DailyDataDisplay[idx] != null && cache_DailyDataDisplay[idx].InpCount == inpCount && cache_DailyDataDisplay[idx].InpShift == inpShift && cache_DailyDataDisplay[idx].CandleWidth == candleWidth && cache_DailyDataDisplay[idx].EqualsInput(input))
						return cache_DailyDataDisplay[idx];
			return CacheIndicator<_DailyDataDisplay>(new _DailyDataDisplay(){ InpCount = inpCount, InpShift = inpShift, CandleWidth = candleWidth }, input, ref cache_DailyDataDisplay);
		}
	}
}

namespace NinjaTrader.NinjaScript.MarketAnalyzerColumns
{
	public partial class MarketAnalyzerColumn : MarketAnalyzerColumnBase
	{
		public Indicators._DailyDataDisplay _DailyDataDisplay(int inpCount, int inpShift, int candleWidth)
		{
			return indicator._DailyDataDisplay(Input, inpCount, inpShift, candleWidth);
		}

		public Indicators._DailyDataDisplay _DailyDataDisplay(ISeries<double> input , int inpCount, int inpShift, int candleWidth)
		{
			return indicator._DailyDataDisplay(input, inpCount, inpShift, candleWidth);
		}
	}
}

namespace NinjaTrader.NinjaScript.Strategies
{
	public partial class Strategy : NinjaTrader.Gui.NinjaScript.StrategyRenderBase
	{
		public Indicators._DailyDataDisplay _DailyDataDisplay(int inpCount, int inpShift, int candleWidth)
		{
			return indicator._DailyDataDisplay(Input, inpCount, inpShift, candleWidth);
		}

		public Indicators._DailyDataDisplay _DailyDataDisplay(ISeries<double> input , int inpCount, int inpShift, int candleWidth)
		{
			return indicator._DailyDataDisplay(input, inpCount, inpShift, candleWidth);
		}
	}
}

#endregion
