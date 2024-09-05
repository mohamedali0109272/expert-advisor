//+------------------------------------------------------------------+
//|                                                PriceTouchMA.mq5  |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                        https://www.mql5.com      |
//+------------------------------------------------------------------+
#property indicator_chart_window

// Input parameters
input int MA_Period = 14;
input ENUM_MA_METHOD MA_Method = MODE_SMA;
input ENUM_APPLIED_PRICE Applied_Price = PRICE_CLOSE;
datetime lastalert = TimeCurrent() - 180;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("notify-ma - ",_Symbol);
   // Set up the indicator
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup code if needed
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   // Calculate the Moving Average
   double ama[];
   double MA_Value = iMA(_Symbol, PERIOD_CURRENT, MA_Period, 0, MODE_SMA, PRICE_CLOSE);
   CopyBuffer(MA_Value,0,0,1,ama);
   Print(NormalizeDouble(ama[0],4) ," - " ,NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),4) );
   // Check if the price touches the MA
   //datetime lastalert;
   Print(lastalert + 180);
   if (NormalizeDouble(ama[0],4) == NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),4) && TimeCurrent() > lastalert + 180)
     {
      lastalert = TimeCurrent();
      Alert("Price touched the Moving Average!");
     }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
