//+------------------------------------------------------------------+
//|                                                    DailyData.mq5 |
//|                                     Style Selectable Version     |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "Daily Data"
#property indicator_color1  Green, C'178,106,34', SlateGray

//--- 스타일 선택을 위한 열거형 정의
enum ENUM_CHART_STYLE
{
   STYLE_CANDLES = DRAW_COLOR_CANDLES, // 캔들 형태
   STYLE_BARS    = DRAW_COLOR_BARS     // 바 형태
};

//--- Input Parameters
input ENUM_CHART_STYLE InpStyle     = STYLE_CANDLES; // 차트 표시 스타일
input int              InpCount     = 3;             // 표시할 개수 (기본 3개)
input int              InpShift     = 5;             // 우측 이격 거리
input int              InpLineWidth = 1;             // 선 두께 (바 타입일 때 유용)

//--- Buffers
double openBuf[];
double highBuf[];
double lowBuf[];
double closeBuf[];
double colorBuf[];

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // 버퍼 연결
   SetIndexBuffer(0, openBuf,  INDICATOR_DATA);
   SetIndexBuffer(1, highBuf,  INDICATOR_DATA);
   SetIndexBuffer(2, lowBuf,   INDICATOR_DATA);
   SetIndexBuffer(3, closeBuf, INDICATOR_DATA);
   SetIndexBuffer(4, colorBuf, INDICATOR_COLOR_INDEX);

   // 선택한 스타일에 따라 그리기 모드 결정
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, InpStyle);
   PlotIndexSetInteger(0, PLOT_SHIFT, InpShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpLineWidth);

   // 기존 오브젝트 삭제
   // ObjectsDeleteAll(0, "DailyData");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // ObjectsDeleteAll(0, "DailyData");
}

//+------------------------------------------------------------------+
//| Calculation                                                      |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[])
{
   if (rates_total < InpCount + 1) return(0);

   // 버퍼 초기화
   ArrayInitialize(openBuf,  EMPTY_VALUE);
   ArrayInitialize(highBuf,  EMPTY_VALUE);
   ArrayInitialize(lowBuf,   EMPTY_VALUE);
   ArrayInitialize(closeBuf, EMPTY_VALUE);
   ArrayInitialize(colorBuf, EMPTY_VALUE);

   // 타임프레임 결정
   ENUM_TIMEFRAMES period = PERIOD_D1;
   if (Period() >= PERIOD_D1) period = PERIOD_W1;
   if (Period() >= PERIOD_W1) period = PERIOD_MN1;

   MqlRates rates_data[];
   ArraySetAsSeries(rates_data, true);

   if (CopyRates(_Symbol, period, 0, InpCount, rates_data) < InpCount) return(0);

   for (int k = 0; k < InpCount; k++)
   {
      int targetIndex = rates_total - 1 - k;
      if(targetIndex < 0) break;

      openBuf[targetIndex]  = rates_data[k].open;
      highBuf[targetIndex]  = rates_data[k].high;
      lowBuf[targetIndex]   = rates_data[k].low;
      closeBuf[targetIndex] = rates_data[k].close;

      // 색상 결정 (0:상승, 1:하락, 2:보합)
      if (rates_data[k].close > rates_data[k].open)      colorBuf[targetIndex] = 0;
      else if (rates_data[k].close < rates_data[k].open) colorBuf[targetIndex] = 1;
      else                                               colorBuf[targetIndex] = 2;
   }

   return(rates_total);
}
