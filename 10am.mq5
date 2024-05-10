#include <Trade\Trade.mqh>
CTrade trade;

datetime TimeOpen  =  iTime(Symbol(), PERIOD_D1, 0);
input int hour = 10;
input double tp_perc=1;
input double sl_perc=1;
input double risk_val=0.01;


int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   TimeOpen  =  iTime(Symbol(), PERIOD_D1, 0);
   trader();
   if(TimeCurrent() > TimeOpen + 60 * 60 * 12 )
     {
         for(int i = PositionsTotal()-1; i >= 0; i--)
          {
            ulong posticket=PositionGetTicket(i);
            Print(posticket);

            trade.OrderDelete(posticket);

          }
     }
}
  
  
void trader(){
   if(TimeCurrent() >= TimeOpen + 60 * 60 * 10 && TimeCurrent() <= TimeOpen + 60 * 60 * 11 &&OrdersTotal()==0)
     {
      if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) == iHigh(_Symbol,PERIOD_H1,1))
        {
         double risk = AccountInfoDouble(ACCOUNT_BALANCE) * risk_val;
         double lot = risk / (MathAbs(iHigh(_Symbol,PERIOD_H1,1) - iLow(_Symbol,PERIOD_H1,1)) / Point());
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =0.1;                                   // volume of 0.1 lot
         request.type     =ORDER_TYPE_SELL;                        // order type
         request.price    =SymbolInfoDouble(_Symbol,SYMBOL_ASK); // price for opening
         request.deviation=500000;                                     // allowed deviation from the price
         request.magic    =0;                          // MagicNumber of the order
         request.tp       =iLow(_Symbol,PERIOD_H1,1)-(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*sl_perc;
         request.sl       =iHigh(_Symbol,PERIOD_H1,1) +(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*tp_perc;
         OrderSend(request,result);
         //trade.Buy(0.01,iHigh(_Symbol,PERIOD_H1,1),_Symbol,iLow(_Symbol,PERIOD_H1,1)-(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*sl_perc,iHigh(_Symbol,PERIOD_H1,1) +(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*tp_perc);
        }else if(SymbolInfoDouble(_Symbol,SYMBOL_BID) == iLow(_Symbol,PERIOD_H1,1))
        {
         double risk = AccountInfoDouble(ACCOUNT_BALANCE) * risk_val;
         double lot = risk / (MathAbs(iHigh(_Symbol,PERIOD_H1,1) - iLow(_Symbol,PERIOD_H1,1)) / Point());
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =0.1;                                   // volume of 0.1 lot
         request.type     =ORDER_TYPE_BUY;                        // order type
         request.price    =SymbolInfoDouble(_Symbol,SYMBOL_BID); // price for opening
         request.deviation=5000000;                                     // allowed deviation from the price
         request.magic    =0;                          // MagicNumber of the order
         request.tp       =iHigh(_Symbol,PERIOD_H1,1) +(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*sl_perc;
         request.sl       =iLow(_Symbol,PERIOD_H1,1) -(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*tp_perc;

         OrderSend(request,result);
         //trade.Sell(0.01,iLow(_Symbol,PERIOD_H1,1),_Symbol,iHigh(_Symbol,PERIOD_H1,1) +(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*sl_perc,iLow(_Symbol,PERIOD_H1,1) -(iHigh(_Symbol,PERIOD_H1,1)-iLow(_Symbol,PERIOD_H1,1))*tp_perc);
         }

   
     }
}


