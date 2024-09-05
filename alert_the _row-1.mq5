//+------------------------------------------------------------------+
//|                                               alert_the _row.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot row
string line_name = "MyHorizontalLine";
double price_level = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Create a horizontal line
   //string line_name = "MyHorizontalLine";
   if(!ObjectCreate(0, line_name, OBJ_HLINE, 0, 0, SymbolInfoDouble(_Symbol,SYMBOL_ASK)))
     {
      Print("Failed to create the horizontal line!");
      return(INIT_FAILED);
     }
   
   // Set the line properties
   ObjectSetInteger(0, line_name, OBJPROP_COLOR, clrRed);         // Set color
   ObjectSetInteger(0, line_name, OBJPROP_WIDTH, 2);              // Set width
   ObjectSetInteger(0, line_name, OBJPROP_RAY_RIGHT, true);       // Extend to the right
   ObjectSetInteger(0, line_name, OBJPROP_SELECTABLE, true);      // Make the line selectable
   ObjectSetInteger(0, line_name, OBJPROP_SELECTED, true);        // Make the line editable
   
   // Set the initial price level (Y coordinate)
   //double price_level = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   ObjectSetDouble(0, line_name, OBJPROP_PRICE, price_level);

   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   // Delete the horizontal line when the Expert is removed
   ObjectDelete(0, line_name);
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
//---
   //Print(ObjectGetDouble(0,"MyHorizontalLine",OBJPROP_PRICE));
   //ObjectSetDouble(0, line_name, OBJPROP_PRICE, price_level);
   if(price_level == ObjectGetDouble(0,line_name,OBJPROP_PRICE))
     {
      Print(price_level);
      return 0;
     }
   else if(price_level > ObjectGetDouble(0,line_name,OBJPROP_PRICE))
          {
           if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) > ObjectGetDouble(0,line_name,OBJPROP_PRICE))
             {
              price_level = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
              ObjectSetDouble(0, line_name, OBJPROP_PRICE, price_level);
              Alert("line reached");
              
             }
          }
    else if(price_level < ObjectGetDouble(0,line_name,OBJPROP_PRICE))
           {
            if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) < ObjectGetDouble(0,line_name,OBJPROP_PRICE))
              {
               
               price_level = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + spread[1];
               ObjectSetDouble(0, line_name, OBJPROP_PRICE, price_level);
               Alert("line reached");
              }
           }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnnxGetInputName()