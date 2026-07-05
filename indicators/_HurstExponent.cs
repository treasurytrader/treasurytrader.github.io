using System;
using System.ComponentModel.DataAnnotations;
using System.Windows.Media;
using NinjaTrader.Gui;
using NinjaTrader.Gui.Chart;
using NinjaTrader.Data;
using NinjaTrader.NinjaScript;

namespace NinjaTrader.NinjaScript.Indicators
{
    public class _HurstExponent : Indicator
    {
        private Series<double> logReturns;

        protected override void OnStateChange()
        {
            if (State == State.SetDefaults)
            {
                Name = "_HurstExponent";
                Calculate = Calculate.OnBarClose;
                IsOverlay = false;
                Period = 100;
                
                AddPlot(new Stroke(Brushes.DodgerBlue, 2), PlotStyle.Line, "HurstValue");
                AddLine(Brushes.Gray, 0.5, "MidLine");
            }
            else if (State == State.DataLoaded)
            {
                logReturns = new Series<double>(this);
            }
        }

        protected override void OnBarUpdate()
        {
            if (CurrentBar < Period + 1) return;

            // 로그 수익률 계산 (이전 봉 대비 현재 봉)
            logReturns[0] = Math.Log(Close[0] / Close[1]);

            double avgLogReturn = 0;
            for (int i = 0; i < Period; i++) avgLogReturn += logReturns[i];
            avgLogReturn /= Period;

            double cumDeviation = 0, maxDev = double.MinValue, minDev = double.MaxValue, sumSqDev = 0;

            for (int i = 0; i < Period; i++)
            {
                double dev = logReturns[i] - avgLogReturn;
                cumDeviation += dev;
                maxDev = Math.Max(maxDev, cumDeviation);
                minDev = Math.Min(minDev, cumDeviation);
                sumSqDev += (dev * dev);
            }

            double R = maxDev - minDev;
            double S = Math.Sqrt(sumSqDev / Period);

            Value[0] = (R > 0 && S > 0) ? Math.Log(R / S) / Math.Log(Period) : 0.5;
        }

        [NinjaScriptProperty]
        [Range(10, int.MaxValue)]
        [Display(Name="Period", GroupName="Parameters", Order=1)]
        public int Period { get; set; }
    }
}
