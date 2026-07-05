#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;
#endregion

namespace NinjaTrader.NinjaScript.Indicators
{
	public class _SqueezeMomentum : Indicator
	{
		private Series<double> data;

		protected override void OnStateChange()
		{
			if (State == State.SetDefaults)
			{
				Description		= @"최적화된 스퀴즈 모멘텀 지표";
				Name			= "_SqueezeMomentum";
				Calculate		= Calculate.OnPriceChange;
				IsOverlay		= false;

				// 파라미터 기본값
				Period			= 20;
				MultBB			= 2.0;
				MultKC			= 1.5;

				// 시각화 기본색상
				BrushUpBegin	= Brushes.Silver;
				BrushUpEnd		= Brushes.DimGray;
				BrushDownBegin	= Brushes.Silver;
				BrushDownEnd	= Brushes.DimGray;
				IsSqueeze		= Brushes.Red;
				NoSqueeze		= Brushes.Green;

				// 플롯 설정 (0: 히스토그램, 1: 스퀴즈 점)
				AddPlot(new Stroke(Brushes.Gray, 2), PlotStyle.Bar, "SqueezeDef");
				AddPlot(new Stroke(Brushes.Gray, 1), PlotStyle.Dot, "SqueezeDot");
			}
			else if (State == State.DataLoaded)
			{
				data = new Series<double>(this);
			}
		}

		protected override void OnBarUpdate()
		{
			// 전봉 참조([1])를 위해 계산에 필요한 최소 바 수 확보
			int lookback = Math.Max(Period, Period);
			if (CurrentBar < lookback + 1) return;

			// 1. 변동성 비교 (Squeeze 로직 단순화)
			double sd  = StdDev(Period)[0] * MultBB;
			double atr = ATR(Period)[0] * MultKC;
			bool sqzOn = (sd < atr); 

			// 2. 모멘텀 계산
			double hi = High[HighestBar(High, Period)];
			double lo = Low[LowestBar(Low, Period)];
			double sma = EMA(Period)[0];
			
			data[0] = Close[0] - ((hi + lo) / 2 + sma) / 2;
			
			double currentSqz = LinReg(data, Period)[0];
			double priorSqz   = LinReg(data, Period)[1];

			SqueezeDef[0] = currentSqz;
			SqueezeDot[0] = 0; 

			// 3. 히스토그램 색상 입히기
			if (currentSqz > 0)
				PlotBrushes[0][0] = (currentSqz > priorSqz) ? BrushUpBegin : BrushUpEnd;
			else
				PlotBrushes[0][0] = (currentSqz < priorSqz) ? BrushDownBegin : BrushDownEnd;

			// 4. 스퀴즈 상태 점 색상 입히기
			PlotBrushes[1][0] = sqzOn ? IsSqueeze : NoSqueeze;
		}

		#region Properties (생략 가능하나 설정창 노출을 위해 유지)
		[Range(1, int.MaxValue), NinjaScriptProperty]
		[Display(Name="Period", GroupName="Parameters", Order=1)]
		public int Period { get; set; }

		[Range(0.1, double.MaxValue), NinjaScriptProperty]
		[Display(Name="BB Mult", GroupName="Parameters", Order=2)]
		public double MultBB { get; set; }

		[Range(0.1, double.MaxValue), NinjaScriptProperty]
		[Display(Name="KC Mult", GroupName="Parameters", Order=3)]
		public double MultKC { get; set; }

		[XmlIgnore] [Display(Name="Up Strong", GroupName="Colors", Order=1)]
		public Brush BrushUpBegin { get; set; }

		[XmlIgnore] [Display(Name="Up Weak", GroupName="Colors", Order=2)]
		public Brush BrushUpEnd { get; set; }

		[XmlIgnore] [Display(Name="Down Strong", GroupName="Colors", Order=3)]
		public Brush BrushDownBegin { get; set; }

		[XmlIgnore] [Display(Name="Down Weak", GroupName="Colors", Order=4)]
		public Brush BrushDownEnd { get; set; }

		[XmlIgnore] [Display(Name="Squeeze On", GroupName="Colors", Order=5)]
		public Brush IsSqueeze { get; set; }

		[XmlIgnore] [Display(Name="Squeeze Off", GroupName="Colors", Order=6)]
		public Brush NoSqueeze { get; set; }

        [Browsable(false)]
        [XmlIgnore]
        public Series<double> SqueezeDef
        {
            get { return Values[0]; }
        }

        [Browsable(false)]
        [XmlIgnore]
        public Series<double> SqueezeDot
        {
            get { return Values[1]; }
        }

		#endregion
	}
}

#region NinjaScript generated code. Neither change nor remove.

namespace NinjaTrader.NinjaScript.Indicators
{
	public partial class Indicator : NinjaTrader.Gui.NinjaScript.IndicatorRenderBase
	{
		private _SqueezeMomentum[] cache_SqueezeMomentum;
		public _SqueezeMomentum _SqueezeMomentum(int period, double multBB, double multKC)
		{
			return _SqueezeMomentum(Input, period, multBB, multKC);
		}

		public _SqueezeMomentum _SqueezeMomentum(ISeries<double> input, int period, double multBB, double multKC)
		{
			if (cache_SqueezeMomentum != null)
				for (int idx = 0; idx < cache_SqueezeMomentum.Length; idx++)
					if (cache_SqueezeMomentum[idx] != null && cache_SqueezeMomentum[idx].Period == period && cache_SqueezeMomentum[idx].MultBB == multBB && cache_SqueezeMomentum[idx].MultKC == multKC && cache_SqueezeMomentum[idx].EqualsInput(input))
						return cache_SqueezeMomentum[idx];
			return CacheIndicator<_SqueezeMomentum>(new _SqueezeMomentum(){ Period = period, MultBB = multBB, MultKC = multKC }, input, ref cache_SqueezeMomentum);
		}
	}
}

namespace NinjaTrader.NinjaScript.MarketAnalyzerColumns
{
	public partial class MarketAnalyzerColumn : MarketAnalyzerColumnBase
	{
		public Indicators._SqueezeMomentum _SqueezeMomentum(int period, double multBB, double multKC)
		{
			return indicator._SqueezeMomentum(Input, period, multBB, multKC);
		}

		public Indicators._SqueezeMomentum _SqueezeMomentum(ISeries<double> input , int period, double multBB, double multKC)
		{
			return indicator._SqueezeMomentum(input, period, multBB, multKC);
		}
	}
}

namespace NinjaTrader.NinjaScript.Strategies
{
	public partial class Strategy : NinjaTrader.Gui.NinjaScript.StrategyRenderBase
	{
		public Indicators._SqueezeMomentum _SqueezeMomentum(int period, double multBB, double multKC)
		{
			return indicator._SqueezeMomentum(Input, period, multBB, multKC);
		}

		public Indicators._SqueezeMomentum _SqueezeMomentum(ISeries<double> input , int period, double multBB, double multKC)
		{
			return indicator._SqueezeMomentum(input, period, multBB, multKC);
		}
	}
}

#endregion
