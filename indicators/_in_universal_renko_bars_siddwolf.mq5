//+------------------------------------------------------------------+
//|                                     UniversalRenkoBarsSiddWolf.mq5|
//|                                                       SiddWolf   |
//|                                             Converted for MQL5   |
//+------------------------------------------------------------------+
#property copyright "SiddWolf"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- 상하단 타겟 레벨 선 플롯 설정 (에러 방지를 위해 호환성 높은 DRAW_LINE으로 수정)
#property indicator_label1  "Brick Top Level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Brick Bottom Level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- 입력 매개변수 (Inputs) ---
input group "--- Calculation ---"
input string   InpCalcMethod       = "ATR Based";      // Calculation Method (ATR Based, Percentage, Auto)
input double   InpAtrMultiplier    = 0.15;             // ATR 14 Multiplier
input double   InpPercentSize      = 0.5;              // Percent Size (%)
input double   InpAutoSensitivity  = 1.0;              // Auto Sensitivity

input group "--- Parameters ---"
input int      InpTickTrend        = 2;                // Tick Trend
input int      InpTickReversal     = 4;                // Tick Reversal
input int      InpOpenOffset       = 0;                // Open Offset

input group "--- Visuals ---"
input bool     InpShowConfirmed    = true;             // Show Confirmed Renko
input color    InpBullColor        = C'38,166,154';    // Bullish Color
input color    InpBearColor        = C'239,83,80';     // Bearish Color
input bool     InpShowUnconfirmed  = true;             // Show Unconfirmed Renko
input color    InpUnconfBullColor  = C'38,166,154';    // Unconfirmed Bull Color
input color    InpUnconfBearColor  = C'239,83,80';     // Unconfirmed Bear Color
input bool     InpShowLevels       = true;             // Show Max/Min Levels
input bool     InpShowInfo         = true;             // Show Info Label

input group "--- Alert Configuration ---"
input bool     InpAlertConfRev     = true;             // 1. Confirmed Trend Reversal
input string   InpAlertBullRevMsg  = "Confirmed Bullish Reversal";
input string   InpAlertBearRevMsg  = "Confirmed Bearish Reversal";
input bool     InpAlertUnconfRev   = false;            // 2. Unconfirmed Trend Reversal (Live)
input string   InpAlertUnconfBull  = "POTENTIAL Bullish Reversal (Live Price Crossed Level)";
input string   InpAlertUnconfBear  = "POTENTIAL Bearish Reversal (Live Price Crossed Level)";
input bool     InpAlertCont        = false;            // 3. Confirmed Trend Continuation
input string   InpAlertBullContMsg = "Bullish Trend Continuation";
input string   InpAlertBearContMsg = "Bearish Trend Continuation";
input bool     InpAlertAnyBrick    = false;            // 4. Any New Confirmed Brick
input string   InpAlertAnyBrickMsg = "New Renko Brick Confirmed";

//--- 지표 버퍼 고유 배열
double BufferMax[];
double BufferMin[];

//--- 내부 상태 추적 전역 변수
double barOpen=0, barClose=0, barMax=0, barMin=0;
int barDirection=0, barStartIndex=0, barCount=0, barsSinceConfirmation=0;
int prevBarDirection=0;
bool initialized=false;
bool unconfirmedAlertFired=false;
datetime lastTime=0;
string lastSymbol="";
ENUM_TIMEFRAMES lastTimeframe=PERIOD_CURRENT;

//--- 내장 인디케이터 핸들 변수
int handleRSI, handleMFI, handleCCI, handleATR;

//+------------------------------------------------------------------+
//| 기술적 지표 초기화 함수 (OnInit)                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   // 지표 버퍼 바인딩
   SetIndexBuffer(0, BufferMax, INDICATOR_DATA);
   SetIndexBuffer(1, BufferMin, INDICATOR_DATA);

   // 에러 발생한 PlotIndexSetNullValue 함수 제거 후 하위 호환 구조로 대체
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   // 내장 지표 결합 핸들 생성 (iMFI 인자 개수 오류 수정 적용)
   handleRSI = iRSI(_Symbol, _Period, 14, PRICE_CLOSE);
   handleMFI = iMFI(_Symbol, _Period, 14, VOLUME_TICK); // 인자 개수 4개로 축소 수정
   handleCCI = iCCI(_Symbol, _Period, 20, PRICE_TYPICAL);
   handleATR = iATR(_Symbol, _Period, 14);

   if(handleRSI == INVALID_HANDLE || handleMFI == INVALID_HANDLE || handleCCI == INVALID_HANDLE || handleATR == INVALID_HANDLE)
   {
      Print("내장 지표 핸들 생성 실패");
      return(INIT_FAILED);
   }

   initialized = false;
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| 지표 제거시 청소 함수 (OnDeinit)                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handleRSI);
   IndicatorRelease(handleMFI);
   IndicatorRelease(handleCCI);
   IndicatorRelease(handleATR);
   ObjectsDeleteAll(0, "RenkoBox_");
   ObjectDelete(0, "RenkoInfoLabel");
}

//+------------------------------------------------------------------+
//| 동적 틱 크기(Tick Size) 연산 함수                                  |
//+------------------------------------------------------------------+
double getEffectiveTickSize(double priceRef)
{
   double tickSize = 0.0;
   if(InpCalcMethod == "Auto")
   {
      double p = MathMax(priceRef, 1e-8);
      double basePercent = 0.02;
      if(p >= 10000) basePercent = 0.002;
      else if(p >= 1000) basePercent = 0.0025;
      else if(p >= 100) basePercent = 0.003;
      else if(p >= 10) basePercent = 0.004;
      else if(p >= 1) basePercent = 0.005;
      else if(p >= 0.1) basePercent = 0.008;
      else if(p >= 0.01) basePercent = 0.012;

      tickSize = p * basePercent * InpAutoSensitivity;
   }
   else if(InpCalcMethod == "ATR Based")
   {
      double atrArr[];
      if(CopyBuffer(handleATR, 0, 0, 1, atrArr) > 0)
      {
         tickSize = atrArr[0] * InpAtrMultiplier;
      }
      else
      {
         tickSize = priceRef * 0.001;
      }
   }
   else // Percentage 방식
   {
      tickSize = priceRef * InpPercentSize / 100.0;
   }

   return MathMax(tickSize, SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
}

//+------------------------------------------------------------------+
//| 차트 사각형 박스 객체 드로잉 헬퍼 함수                              |
//+------------------------------------------------------------------+
void DrawRenkoBox(string name, datetime t1, double p1, datetime t2, double p2, color clr, bool isFilled)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   }
   else
   {
      ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
   }
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FILL, isFilled);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+
//| 메인 연산 루프 함수 (OnCalculate)                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 20) return(0);

   // --- SCRIPT RESET LOGIC (종목/타임프레임 변경 또는 최초 실행 시 리셋) ---
   if(_Symbol != lastSymbol || _Period != lastTimeframe || !initialized || prev_calculated == 0)
   {
      ObjectsDeleteAll(0, "RenkoBox_");
      initialized = false;
      int cur = 0;
      barOpen = close[cur];
      barClose = close[cur];
      barDirection = 0;
      double effSize = getEffectiveTickSize(close[cur]);
      barMax = close[cur] + (InpTickTrend * effSize);
      barMin = close[cur] - (InpTickTrend * effSize);
      barStartIndex = cur;
      barCount = 0;
      barsSinceConfirmation = 0;
      lastSymbol = _Symbol;
      lastTimeframe = _Period;
      prevBarDirection = 0;
      unconfirmedAlertFired = false;
      initialized = true;
   }

   // 이전 연산 지점부터 시뮬레이션 루프 진행
   int start_idx = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   for(int i = start_idx; i < rates_total; i++)
   {
      bool isLastBar = (i == rates_total - 1);
      double curClose = close[i];

      if(isLastBar && time[i] != lastTime)
      {
         lastTime = time[i];
      }

      bool maxExceeded = (curClose > barMax);
      bool minExceeded = (curClose < barMin);

      // --- A. BAR IS CONFIRMED (렌코 벽돌 확정 조건 충족) ---
      if(maxExceeded || minExceeded)
      {
         int newDirection = maxExceeded ? 1 : -1;
         bool isBullReversal = (newDirection > 0 && prevBarDirection < 0);
         bool isBearReversal = (newDirection < 0 && prevBarDirection > 0);
         bool isBullContinuation = (newDirection > 0 && prevBarDirection > 0);
         bool isBearContinuation = (newDirection < 0 && prevBarDirection < 0);
         string tickerPrefix = _Symbol + ": ";

         if(isLastBar)
         {
            if(InpAlertConfRev)
            {
               if(isBullReversal) Alert(tickerPrefix + InpAlertBullRevMsg);
               if(isBearReversal) Alert(tickerPrefix + InpAlertBearRevMsg);
            }
            if(InpAlertCont)
            {
               if(isBullContinuation) Alert(tickerPrefix + InpAlertBullContMsg);
               if(isBearContinuation) Alert(tickerPrefix + InpAlertBearContMsg);
            }
            if(InpAlertAnyBrick) Alert(tickerPrefix + InpAlertAnyBrickMsg);
         }

         prevBarDirection = newDirection;
         unconfirmedAlertFired = false;
         barsSinceConfirmation = 0;

         ObjectDelete(0, "RenkoBox_Unconfirmed");

         double thisClose = maxExceeded ? barMax : barMin;
         color boxColor = (thisClose > barOpen) ? InpBullColor : InpBearColor;

         if(InpShowConfirmed)
         {
            string boxName = "RenkoBox_Conf_" + IntegerToString(barCount);
            datetime t2 = (i + 1 < rates_total) ? time[i+1] : time[i] + PeriodSeconds(_Period);
            DrawRenkoBox(boxName, time[barStartIndex], MathMax(barOpen, thisClose), t2, MathMin(barOpen, thisClose), boxColor, true);
         }

         if(barCount > 250)
         {
            ObjectDelete(0, "RenkoBox_Conf_" + IntegerToString(barCount - 250));
         }

         barCount++;
         barDirection = newDirection;
         double nextTickSize = getEffectiveTickSize(thisClose);
         barOpen = thisClose - (InpOpenOffset * nextTickSize * barDirection);
         barClose = thisClose;
         barMax = (barDirection > 0) ? thisClose + (InpTickTrend * nextTickSize) : thisClose + (InpTickReversal * nextTickSize);
         barMin = (barDirection < 0) ? thisClose - (InpTickTrend * nextTickSize) : thisClose - (InpTickReversal * nextTickSize);
         barStartIndex = i;
      }
      // --- B. BAR IS LIVE / UNCONFIRMED (실시간 미확정 변동 상태) ---
      else
      {
         bool unconfirmedBullReversal = (barDirection < 0 && curClose > barMax && !unconfirmedAlertFired);
         bool unconfirmedBearReversal = (barDirection > 0 && curClose < barMin && !unconfirmedAlertFired);

         if(isLastBar && InpAlertUnconfRev && (unconfirmedBullReversal || unconfirmedBearReversal))
         {
            unconfirmedAlertFired = true;
            string tickerPrefix = _Symbol + ": ";
            string msg = unconfirmedBullReversal ? InpAlertUnconfBull : InpAlertUnconfBear;
            Alert(tickerPrefix + msg);
         }

         if(isLastBar)
         {
            barsSinceConfirmation++;
            barClose = curClose;

            if(InpShowUnconfirmed)
            {
               color boxColor = (barClose > barOpen) ? InpUnconfBullColor : InpUnconfBearColor;
               datetime t2 = time[i] + PeriodSeconds(_Period);
               DrawRenkoBox("RenkoBox_Unconfirmed", time[barStartIndex], MathMax(barOpen, barClose), t2, MathMin(barOpen, barClose), boxColor, false);
            }
            else
            {
               ObjectDelete(0, "RenkoBox_Unconfirmed");
            }
         }
      }

      BufferMax[i] = InpShowLevels ? barMax : EMPTY_VALUE;
      BufferMin[i] = InpShowLevels ? barMin : EMPTY_VALUE;
   }

   // --- 대시보드 인포 레이블 출력 ---
   if(InpShowInfo)
   {
      double rsi[], mfi[], cci[];
      ArraySetAsSeries(rsi, true); CopyBuffer(handleRSI, 0, 0, 1, rsi);
      ArraySetAsSeries(mfi, true); CopyBuffer(handleMFI, 0, 0, 1, mfi);
      ArraySetAsSeries(cci, true); CopyBuffer(handleCCI, 0, 0, 1, cci);

      double rsi_v = (ArraySize(rsi)>0) ? rsi[0] : 0.0;
      double mfi_v = (ArraySize(mfi)>0) ? mfi[0] : 0.0;
      double cci_v = (ArraySize(cci)>0) ? cci[0] : 0.0;

      string labelText = "🧱 Bricks: " + IntegerToString(barCount) + "\n" +
                         "⏳ Live: " + IntegerToString(barsSinceConfirmation) + " bars\n" +
                         "🌲 Tick Size: " + DoubleToString(getEffectiveTickSize(close[rates_total-1]), 2) + "\n\n" +
                         "--- Market Internals ---\n" +
                         "✳️ RSI (14): " + DoubleToString(rsi_v, 1) + "\n" +
                         "✳️ MFI (14): " + DoubleToString(mfi_v, 1) + "\n" +
                         "✳️ CCI (20): " + DoubleToString(cci_v, 1);

      if(ObjectFind(0, "RenkoInfoLabel") < 0)
      {
         ObjectCreate(0, "RenkoInfoLabel", OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, "RenkoInfoLabel", OBJPROP_CORNER, CORNER_RIGHT_UPPER);
         ObjectSetInteger(0, "RenkoInfoLabel", OBJPROP_XDISTANCE, 20);
         ObjectSetInteger(0, "RenkoInfoLabel", OBJPROP_YDISTANCE, 45);
         ObjectSetInteger(0, "RenkoInfoLabel", OBJPROP_COLOR, clrWhite);
         ObjectSetInteger(0, "RenkoInfoLabel", OBJPROP_FONTSIZE, 10);
      }
      ObjectSetString(0, "RenkoInfoLabel", OBJPROP_TEXT, labelText);
   }
   else
   {
      ObjectDelete(0, "RenkoInfoLabel");
   }

   return(rates_total);
}
