#include <Trade\Trade.mqh>
CTrade trade;
input ENUM_TIMEFRAMES timeframe1 = PERIOD_H1;
input ENUM_TIMEFRAMES timeframe2 = PERIOD_D1;
double highesthigh;
double lowestlow;
double currenthigh;
double currentlow;
double u123;
double d123;
double u138;
double d138;
double m50;
double sld;
input double tsl_perc = 0.05;
input double risk_perc = 0.01;
int lastTradeDay = -1;   // Variable to store the last trading day


int OnInit()
  {
   
   highesthigh = 0.0;
   lowestlow = DBL_MAX;
   currenthigh = 0.0;
   currentlow = DBL_MAX;
   u123 = 0.0;
   d123 = DBL_MAX;
   u138 = 0.0;
   d138 = DBL_MAX;
   m50  = 0.0;

   calculateval();
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
    //calculateval();
    checkfalsebreak();
    flip();
    calsl();
    //if(mover()==1){
    //  Print("111");
    //}

  }
  
  
void calculateval(){
   highesthigh = NormalizeDouble(iHigh(_Symbol,timeframe2, 1),_Digits);
   lowestlow   = NormalizeDouble(iLow(_Symbol,timeframe2, 1),_Digits);
   currenthigh = NormalizeDouble(iHigh(_Symbol,timeframe2, 0),_Digits);
   currentlow  = NormalizeDouble(iLow(_Symbol,timeframe2, 0),_Digits);
   u123        = NormalizeDouble(((highesthigh-lowestlow)*0.236)+highesthigh,_Digits);
   d123        = NormalizeDouble(lowestlow - ((highesthigh-lowestlow)*0.236),_Digits);
   u138        = NormalizeDouble(((highesthigh-lowestlow)*0.382)+highesthigh,_Digits);
   d138        = NormalizeDouble(lowestlow - ((highesthigh-lowestlow)*0.382),_Digits);
   m50         = NormalizeDouble(((highesthigh-lowestlow)*0.5)+lowestlow,_Digits);
   sld         = NormalizeDouble((MathAbs((highesthigh - lowestlow)*tsl_perc) / Point()),_Digits);
      
   //Print(highesthigh,"  ",lowestlow," --- ",currenthigh,"  ",currentlow);
}




void checkfalsebreak(){
   //Print("hhhhhhhhhhh");
   if(SymbolInfoDouble(_Symbol,SYMBOL_ASK) == iHigh(_Symbol,timeframe2, 1) && OrdersTotal() == 0)
     {
      calculateval();
      
      if(currenthigh > highesthigh && currenthigh < u123 && MathAbs(highesthigh - lowestlow) / Point() > 500)
        {
         double risk = AccountInfoDouble(ACCOUNT_BALANCE) * risk_perc;
         double lot = risk / (MathAbs(u123 - highesthigh) / Point());
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =NormalizeDouble(lot,2);                // volume of 0.1 lot
         request.type     =ORDER_TYPE_SELL;                       // order type
         request.price    =SymbolInfoDouble(_Symbol,SYMBOL_ASK);  // price for opening
         request.deviation=1;                                    // allowed deviation from the price
         request.magic    =123;                                     // MagicNumber of the order
         request.sl       =u123;
         request.tp       =0;
         request.comment  =sld;
         OrderSend(request,result);
         Print(result.retcode_external);
         //trade.Sell(NormalizeDouble(lot,2),_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),u138,m50,sld);
        }
      
     }
   if(SymbolInfoDouble(_Symbol,SYMBOL_BID) == iLow(_Symbol,timeframe2, 1) && OrdersTotal() == 0)
     {
      calculateval();
      if(currentlow < lowestlow && currentlow > d123 && MathAbs(highesthigh - lowestlow) / Point() > 500)
        {
         double risk = AccountInfoDouble(ACCOUNT_BALANCE) * risk_perc;
         double lot = risk / (MathAbs(lowestlow - d123) / Point());
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =NormalizeDouble(lot,2);                                   // volume of 0.1 lot
         request.type     =ORDER_TYPE_BUY;                        // order type
         request.price    =SymbolInfoDouble(_Symbol,SYMBOL_BID); // price for opening
         request.deviation=1;                                     // allowed deviation from the price
         request.magic    =123;                          // MagicNumber of the order
         request.sl       =d123;
         request.tp       =0;
         request.comment  =sld;
         OrderSend(request,result);
         Print(result.retcode_external);
         //trade.Buy(NormalizeDouble(lot,2),_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),d138,m50,sld);
        }

     }

}






void calsl(){
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong posticket=PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            double pospr = PositionGetDouble(POSITION_PRICE_OPEN);
            double possl = PositionGetDouble(POSITION_SL);
            double postp = PositionGetDouble(POSITION_TP);
            
            double ask   = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double bid   = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               double tsl = bid - StringToInteger(PositionGetString(POSITION_COMMENT)) * _Point;
               if(tsl > possl)
                 {
                  if(trade.PositionModify(posticket,tsl,postp))
                    {
                     Print("Posticket:",posticket,"  was modified");
                    }
                 }
              }else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               double tsl = ask + StringToInteger(PositionGetString(POSITION_COMMENT)) * _Point;
               if(tsl < possl)
                 {
                  if(trade.PositionModify(posticket,tsl,postp))
                    {
                     Print("Posticket:",posticket,"  was modified");
                    }
                 }
              }
           }
        }
     }

}




int mover(){
   int move=0;
   for(int i = 0; i < iBars(_Symbol,timeframe1); i++)
     {
      Print(iTime(_Symbol,timeframe1, i) , iTime(_Symbol,timeframe2, 1) , iTime(_Symbol,timeframe1, i) , iTime(_Symbol,timeframe2, 0) );
      if(iTime(_Symbol,timeframe1, i) > iTime(_Symbol,timeframe2, 1) && iTime(_Symbol,timeframe1, i) < iTime(_Symbol,timeframe2, 0) )
        {
         if(NormalizeDouble(iHigh(_Symbol,timeframe1, i),3) == NormalizeDouble(((highesthigh-lowestlow)*0.236)+lowestlow,3))
           {
            move = 1;
           }
        }
     }
    return move;
}

void flip(){
   for(int i = PositionsTotal()-1; i >= 0; i--)
     {
      ulong posticket=PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
           {
            double pospr = PositionGetDouble(POSITION_PRICE_OPEN);
            double possl = PositionGetDouble(POSITION_SL);
            double postp = PositionGetDouble(POSITION_TP);
            
            double ask   = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            double bid   = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               //double tsl = bid - StringToInteger(PositionGetString(POSITION_COMMENT)) * _Point;
               if(ask - possl / Point() < 5)
                 {
                  trade.Sell(0.01,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),lowestlow,0,sld);
                 }
              }else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               double tsl = ask + StringToInteger(PositionGetString(POSITION_COMMENT)) * _Point;
               if(possl - bid / Point() <5)
                 {
                  trade.Buy(0.01,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),highesthigh,0,sld);
                 }
              }
           }
        }
     }

}