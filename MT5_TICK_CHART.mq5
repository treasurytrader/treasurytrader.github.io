//+------------------------------------------------------------------+
//|                                              MT5  Tick Chart.mq5 |
//|                                             Abioye Israel Pelumi |
//|                             https://linktr.ee/abioyeisraelpelumi |
//+------------------------------------------------------------------+
#property copyright "Abioye Israel Pelumi"
#property link      "https://linktr.ee/abioyeisraelpelumi"
#property version   "1.00"

input string InpCustomSymbol = "TICK_101";   // Name of the custom symbol to create/use
input bool   InpOpenChart    = true;         // Whether to automatically open the chart
input int    InpTicksPerBar  = 30;          // Number of ticks that will form one candle

//+------------------------------------------------------------------+
//| Tick-based candle state                                          |
//+------------------------------------------------------------------+
int      tick_count    = 0;   // Counts how many ticks have formed the current bar
double   open_price    = 0;   // Open price of current bar
double   high_price    = 0;   // Highest price reached in current bar
double   low_price     = 0;   // Lowest price reached in current bar
double   close_price   = 0;   // Latest price (updates every tick)
datetime bar_time      = 0;   // Time assigned to the current bar
datetime last_bar_time = 0;   // Time of the last completed bar (used to ensure uniqueness)


//+------------------------------------------------------------------+
//| Create or prepare custom symbol                                  |
//+------------------------------------------------------------------+
bool CreateCustomSymbol()
  {
//--- If symbol already exists, just select it and continue
   if(SymbolInfoInteger(InpCustomSymbol, SYMBOL_EXIST))
     {
      SymbolSelect(InpCustomSymbol, true);  // Make it visible in Market Watch
      return true;
     }

//--- Create new custom symbol using current symbol as template
   if(!CustomSymbolCreate(InpCustomSymbol, "", _Symbol))
     {
      Print("Failed to create custom symbol: ", GetLastError());
      return false;
     }

//--- Copy important trading properties from the original symbol
   CustomSymbolSetInteger(InpCustomSymbol, SYMBOL_DIGITS, _Digits);  // Decimal precision
   CustomSymbolSetDouble(InpCustomSymbol, SYMBOL_POINT, _Point);     // Smallest price step
   CustomSymbolSetDouble(InpCustomSymbol, SYMBOL_TRADE_TICK_SIZE,SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));

//--- Set descriptive metadata
   CustomSymbolSetString(InpCustomSymbol, SYMBOL_DESCRIPTION, "Tick Chart – " + _Symbol);
   CustomSymbolSetString(InpCustomSymbol, SYMBOL_CURRENCY_BASE,SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
   CustomSymbolSetString(InpCustomSymbol, SYMBOL_CURRENCY_PROFIT,SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT));

   SymbolSelect(InpCustomSymbol, true);  // Make visible
   Print("Custom symbol created: ", InpCustomSymbol);

   return true;
  }

//+------------------------------------------------------------------+
//| Check if a chart is already open                                 |
//+------------------------------------------------------------------+
bool IsChartOpen(string symbol, ENUM_TIMEFRAMES tf)
  {
   long id = ChartFirst();  // Get first chart ID

//--- Loop through all open charts
   while(id != -1)
     {
      //--- If both symbol and timeframe match, chart is already open
      if(ChartSymbol(id) == symbol && ChartPeriod(id) == tf)
         return true;

      id = ChartNext(id);  // Move to next chart
     }

   return false;  // No matching chart found
  }

//+------------------------------------------------------------------+
//| Open custom chart if not already open                            |
//+------------------------------------------------------------------+
void OpenCustomChart()
  {
//--- Prevent opening multiple duplicate charts
   if(IsChartOpen(InpCustomSymbol, PERIOD_M1))
     {
      Print("Chart already open");
      return;
     }

//--- Open chart (M1 is just a container, not actually used for logic)
   long id = ChartOpen(InpCustomSymbol, PERIOD_M1);

   if(id == 0)
      Print("Failed to open chart: ", GetLastError());
  }

//+------------------------------------------------------------------+
//| Finalize and store completed candle                              |
//+------------------------------------------------------------------+
void CommitCompletedBar()
  {
//--- Ensure bar time is always increasing
   if(bar_time <= last_bar_time)
      bar_time = last_bar_time + 1;

   last_bar_time = bar_time;

   MqlRates rates[1];

//--- Final OHLC values for completed bar
   rates[0].time        = bar_time;
   rates[0].open        = open_price;
   rates[0].high        = high_price;
   rates[0].low         = low_price;
   rates[0].close       = close_price;
   rates[0].tick_volume = InpTicksPerBar;  // fixed tick count
   rates[0].spread      = 0;
   rates[0].real_volume = 0;

//--- Store final bar
   if(!CustomRatesUpdate(InpCustomSymbol, rates))
      Print("CommitCompletedBar failed: ", GetLastError());
  }

//+------------------------------------------------------------------+
//| Update current (forming) candle                                  |
//+------------------------------------------------------------------+
void UpdateCurrentBar()
  {
   MqlRates rates[1];

//--- Populate current candle structure
   rates[0].time        = bar_time;
   rates[0].open        = open_price;
   rates[0].high        = high_price;
   rates[0].low         = low_price;
   rates[0].close       = close_price;
   rates[0].tick_volume = (long)tick_count;  // number of ticks so far
   rates[0].spread      = 0;
   rates[0].real_volume = 0;

//--- Push update to chart (this redraws candle live)
   CustomRatesUpdate(InpCustomSymbol, rates);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Ensure custom symbol exists
   if(!CreateCustomSymbol())
      return INIT_FAILED;

//--- Optionally open chart
   if(InpOpenChart)
      OpenCustomChart();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlTick tick;

//--- Get latest tick from broker
   if(!SymbolInfoTick(_Symbol, tick))
      return;

//--- Ignore invalid price
   if(tick.bid <= 0)
      return;

   double   price = tick.bid;
   datetime now   = tick.time;

//--- If first tick of new bar, initialize OHLC
   if(tick_count == 0)
     {
      open_price = price;
      high_price = price;
      low_price  = price;
      bar_time   = now;  // starting time of this bar
     }

//--- Update High and Low
   if(price > high_price)
      high_price = price;
   if(price < low_price)
      low_price  = price;

//--- Always update Close
   close_price = price;

//--- Increase tick counter
   tick_count++;

//--- Update live (forming) candle
   UpdateCurrentBar();

//--- If tick limit reached, close bar
   if(tick_count >= InpTicksPerBar)
     {
      CommitCompletedBar();  // finalize candle
      tick_count = 0;        // reset for next bar
     }

  }
//+------------------------------------------------------------------+
