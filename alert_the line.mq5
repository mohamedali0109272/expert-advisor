//+------------------------------------------------------------------+
//|                                               alert_the line.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
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
   Print(ObjectsTotal(0,0,OBJ_HLINE));
   for(int i = 0; i < ObjectsTotal(0,0,OBJ_HLINE); i++){
      string name = ObjectName(0,i,0,OBJ_HLINE);
      Print(name);
      Print(ObjectGetDouble(0,name,OBJPROP_PRICE));
      
      if(ObjectGetDouble(0,name,OBJPROP_PRICE) > name && name != "passed up" && name != "passed down")
        {
         if(SymbolInfoDouble(_Symbol,SYMBOL_BID) >  ObjectGetDouble(0,name,OBJPROP_PRICE))
           {
            ObjectSetString(0,name,OBJPROP_NAME,"passed up");
            Alert("passed up");
           }
        }
      if(ObjectGetDouble(0,name,OBJPROP_PRICE) < name && name != "passed up" && name != "passed down")
        {
         if(SymbolInfoDouble(_Symbol,SYMBOL_BID) <  ObjectGetDouble(0,name,OBJPROP_PRICE))
           {
            ObjectSetString(0,name,OBJPROP_NAME,"passed down");
            Alert("passed down");
           }
        }
      //ObjectSetString(0,name,OBJPROP_NAME,SymbolInfoDouble(_Symbol,SYMBOL_BID));
   
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_OBJECT_DRAG) 
      {
         ObjectSetString(0,sparam,OBJPROP_NAME,SymbolInfoDouble(_Symbol,SYMBOL_BID));
         //Print(sparam);
      }
  }

 
 