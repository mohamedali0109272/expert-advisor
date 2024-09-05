//+------------------------------------------------------------------+
//|                                                       hammer.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

datetime lastOrderTime = 0;

int OnInit()
  {
//---
   
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
      if(iClose(_Symbol,PERIOD_CURRENT,2) - iLow(_Symbol,PERIOD_CURRENT,2) > (iOpen(_Symbol,PERIOD_CURRENT,2) - iClose(_Symbol,PERIOD_CURRENT,2)) * 2 && iClose(_Symbol,PERIOD_CURRENT,1) > iOpen(_Symbol,PERIOD_CURRENT,1))
        {

          pr();

         
        }

  }
//+------------------------------------------------------------------+

void pr(){
   datetime currentCandleTime = iTime(NULL, 0, 0);
   if(lastOrderTime != currentCandleTime)
     {
      Print("hammer .....");
      double tp = SymbolInfoDouble(_Symbol,SYMBOL_BID) - ((stop_loss_sell() - SymbolInfoDouble(_Symbol,SYMBOL_BID)) *2 ) ;
      trade.Sell(0.1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),stop_loss_sell(),tp);
      lastOrderTime = currentCandleTime;
     }

}


double stop_loss_sell()
  {
   //---
   int candle = 4;
   double c_candle[];
   ArrayResize(c_candle,candle);

   for(int i=0;i<candle;i++)
     {
      //   c_candle[i]=High[i];
      c_candle[i]=iHigh(Symbol(),PERIOD_CURRENT,i);
      //Print("candle "+(i+1)+" :cC = "+c_candle[i]);
     }
   int cC=ArrayMaximum(c_candle,0,WHOLE_ARRAY);
   //Print(c_candle[cC]);
   return c_candle[cC];
  }