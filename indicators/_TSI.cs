#region Using declarations
using System;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using System.Xml.Serialization;
using NinjaTrader.Gui;
using NinjaTrader.NinjaScript;
using NinjaTrader.Data;
#endregion

namespace NinjaTrader.NinjaScript.Indicators
{
    public class _TSI : Indicator
    {
        private double constant1, constant2, constant3, constant4;
        private Series<double> fastEma, fastAbsEma, slowEma, slowAbsEma;

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Description  = "True Strength Index - 최적화 버전";
                Name         = "_TSI";
                Calculate    = Calculate.OnPriceChange;
                IsOverlay    = false;

                Fast         = 12;
                Slow         = 26;
                ColorSlope   = true;
                UpColor      = Brushes.DodgerBlue;
                DnColor      = Brushes.Firebrick;

                AddPlot(new Stroke(Brushes.DimGray, 2), PlotStyle.Line, "_TSI");
                AddLine(Brushes.DimGray,  25, "Overbought");
                AddLine(Brushes.DimGray, -25, "Oversold");
                AddLine(Brushes.DarkGray,  0, "ZeroLine");
            }
            else if (State == State.DataLoaded)
            {
                constant1 = 2.0 / (1 + Slow);
                constant2 = 1 - constant1;
                constant3 = 2.0 / (1 + Fast);
                constant4 = 1 - constant3;

                fastAbsEma = new Series<double>(this);
                fastEma    = new Series<double>(this);
                slowAbsEma = new Series<double>(this);
                slowEma    = new Series<double>(this);
            }
        }

        protected override void OnBarUpdate()
        {
            // 인덱스 [0]과 [1]을 명확히 사용하여 연산 에러 해결
            if (CurrentBar < 1)
            {
                Value[0] = 0;
                fastEma[0] = 0;
                fastAbsEma[0] = 0;
                slowEma[0] = 0;
                slowAbsEma[0] = 0;
                return;
            }

            double momentum = Input[0] - Input[1];
            
            // 1단계 평활화 (Slow)
            slowEma[0]    = momentum * constant1 + constant2 * slowEma[1];
            slowAbsEma[0] = Math.Abs(momentum) * constant1 + constant2 * slowAbsEma[1];
            
            // 2단계 평활화 (Fast)
            fastEma[0]    = slowEma[0] * constant3 + constant4 * fastEma[1];
            fastAbsEma[0] = slowAbsEma[0] * constant3 + constant4 * fastAbsEma[1];
            
            // 결과 도출 및 분모 0 방어
            double den = fastAbsEma[0];
            Value[0] = (Math.Abs(den) > double.Epsilon) ? 100 * (fastEma[0] / den) : 0;

            // 기울기 색상 적용 (현재 값과 이전 값 비교)
            if (ColorSlope && CurrentBar > 0)
            {
                PlotBrushes[0][0] = (Value[0] >= Value[1]) ? UpColor : DnColor;
            }
        }

        #region Properties
        [Range(1, int.MaxValue), NinjaScriptProperty]
        [Display(Name = "Fast Period", GroupName = "Parameters", Order = 0)]
        public int Fast { get; set; }

        [Range(1, int.MaxValue), NinjaScriptProperty]
        [Display(Name = "Slow Period", GroupName = "Parameters", Order = 1)]
        public int Slow { get; set; }

        [NinjaScriptProperty]
        [Display(Name = "Enable Color Slope", GroupName = "Parameters", Order = 2)]
        public bool ColorSlope { get; set; }

        [XmlIgnore]
        [Display(Name = "Rising Color", GroupName = "Appearance", Order = 3)]
        public Brush UpColor { get; set; }

        [Browsable(false)]
        public string UpColorSerializable {
            get { return Serialize.BrushToString(UpColor); }
            set { UpColor = Serialize.StringToBrush(value); }
        }

        [XmlIgnore]
        [Display(Name = "Falling Color", GroupName = "Appearance", Order = 4)]
        public Brush DnColor { get; set; }

        [Browsable(false)]
        public string DnColorSerializable {
            get { return Serialize.BrushToString(DnColor); }
            set { DnColor = Serialize.StringToBrush(value); }
        }
        #endregion
    }
}

#region NinjaScript generated code. Neither change nor remove.

namespace NinjaTrader.NinjaScript.Indicators
{
	public partial class Indicator : NinjaTrader.Gui.NinjaScript.IndicatorRenderBase
	{
		private _TSI[] cache_TSI;
		public _TSI _TSI(int fast, int slow, bool colorSlope)
		{
			return _TSI(Input, fast, slow, colorSlope);
		}

		public _TSI _TSI(ISeries<double> input, int fast, int slow, bool colorSlope)
		{
			if (cache_TSI != null)
				for (int idx = 0; idx < cache_TSI.Length; idx++)
					if (cache_TSI[idx] != null && cache_TSI[idx].Fast == fast && cache_TSI[idx].Slow == slow && cache_TSI[idx].ColorSlope == colorSlope && cache_TSI[idx].EqualsInput(input))
						return cache_TSI[idx];
			return CacheIndicator<_TSI>(new _TSI(){ Fast = fast, Slow = slow, ColorSlope = colorSlope }, input, ref cache_TSI);
		}
	}
}

namespace NinjaTrader.NinjaScript.MarketAnalyzerColumns
{
	public partial class MarketAnalyzerColumn : MarketAnalyzerColumnBase
	{
		public Indicators._TSI _TSI(int fast, int slow, bool colorSlope)
		{
			return indicator._TSI(Input, fast, slow, colorSlope);
		}

		public Indicators._TSI _TSI(ISeries<double> input , int fast, int slow, bool colorSlope)
		{
			return indicator._TSI(input, fast, slow, colorSlope);
		}
	}
}

namespace NinjaTrader.NinjaScript.Strategies
{
	public partial class Strategy : NinjaTrader.Gui.NinjaScript.StrategyRenderBase
	{
		public Indicators._TSI _TSI(int fast, int slow, bool colorSlope)
		{
			return indicator._TSI(Input, fast, slow, colorSlope);
		}

		public Indicators._TSI _TSI(ISeries<double> input , int fast, int slow, bool colorSlope)
		{
			return indicator._TSI(input, fast, slow, colorSlope);
		}
	}
}

#endregion
