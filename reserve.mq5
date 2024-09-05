//+------------------------------------------------------------------+
//|                                                      reserve.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade trade;
input int reserv = 1;
int OnInit()
  {
//---
   //Sleep(444);
   //trade.Sell(1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),SymbolInfoDouble(_Symbol,SYMBOL_BID) + (200 * Point()) );
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
//---
   reserve();
  }
//+------------------------------------------------------------------+



void reserve(){
   for(int i=0;i<PositionsTotal();i++)
     {
      ulong tik = PositionGetTicket(i);
      if(POSITION_TYPE == 1)
        {
         double nsl = PositionGetDouble(POSITION_PRICE_OPEN) + ((PositionGetDouble(POSITION_PRICE_OPEN) - PositionGetDouble(POSITION_SL)) * reserv);
         if(NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT),4) ==  NormalizeDouble(nsl,4))
           {
            trade.PositionModify(tik,PositionGetDouble(POSITION_PRICE_OPEN),0);
           }
         Print("buy");
        }else if(POSITION_TYPE == 2)
                {
                 double nsl = PositionGetDouble(POSITION_PRICE_OPEN) - ((PositionGetDouble(POSITION_SL) - PositionGetDouble(POSITION_PRICE_OPEN))* reserv);
                 Print(nsl);
                 if(NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT),4) ==  NormalizeDouble(nsl,4))
                   {
                    trade.PositionModify(tik,PositionGetDouble(POSITION_PRICE_OPEN),0);
                   }
                 Print("sell");
                }
      //Print(POSITION_TYPE);
     }

}