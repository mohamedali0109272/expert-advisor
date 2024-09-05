#include <Trade\Trade.mqh>
CTrade trade;

int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
  }
void OnTick()
  {
   daybuy();
  }
  
  
void daybuy(){
   if(iHigh(_Symbol,PERIOD_D1,1) > iHigh(_Symbol,PERIOD_D1,2) && iClose(_Symbol,PERIOD_D1,1) > iHigh(_Symbol,PERIOD_D1,2) ) //check if the high of day 1 > day 2 and close day 1 > day2
     {
      //Print("buy signal");
      double perc50 = iLow(_Symbol,PERIOD_D1,1) + ((iHigh(_Symbol,PERIOD_D1,1) - iLow(_Symbol,PERIOD_D1,1)) / 2);
      if(iClose(_Symbol,PERIOD_D1,1) > perc50){ // check if the close of day 1 higher than it's 50 percent
         hourbuy();
      }
     }
   else if(iLow(_Symbol,PERIOD_D1,1) < iLow(_Symbol,PERIOD_D1,2) && iOpen(_Symbol,PERIOD_D1,1) > iLow(_Symbol,PERIOD_D1,2)) // check if the low of day 1 < the low of day2 and the open of day1 > day2
          {
           double perc50 = iLow(_Symbol,PERIOD_D1,1) + ((iHigh(_Symbol,PERIOD_D1,1) - iLow(_Symbol,PERIOD_D1,1)) / 2);
           if(iClose(_Symbol,PERIOD_D1,1) > perc50)
             {
              hourbuy();
             }
          }

}



void daysell(){
   if(iLow(_Symbol,PERIOD_D1,1) < iLow(_Symbol,PERIOD_D1,2) && iClose(_Symbol,PERIOD_D1,1) < iLow(_Symbol,PERIOD_D1,2) )
     {
        //Print("sell signal");
        if(iLow(_Symbol,PERIOD_H1,1) < iLow(_Symbol,PERIOD_H1,2) && iClose(_Symbol,PERIOD_H1,1) < iLow(_Symbol,PERIOD_H1,2) )
           {
            
           }
     }

}


void hourbuy(){
   //Print("buy signal");
   if(iHigh(_Symbol,PERIOD_H1,1) > iHigh(_Symbol,PERIOD_H1,2) && iClose(_Symbol,PERIOD_H1,1) > iHigh(_Symbol,PERIOD_H1,2) )// check if the high of hour1 > the high of hour2 and the close of hour 1 > the high of hour2 
     {
       double perc50 = iLow(_Symbol,PERIOD_H1,1) + ((iHigh(_Symbol,PERIOD_H1,1) - iLow(_Symbol,PERIOD_H1,1))*0.50);
       if(iClose(_Symbol,PERIOD_H1,1) > perc50) // check if the close of hour1 > 50 percent
         {
           if(SymbolInfoDouble(_Symbol,SYMBOL_BID) == perc50 && OrdersTotal() == 0) //check if the price == 50 percent to enter a trade
             {
               Print("hour buy");
               Print(OrdersTotal());
               MqlTradeResult result={};
               MqlTradeRequest request={};
               //--- parameters of request
               request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
               request.symbol   =Symbol();                              // symbol
               request.volume   =0.1;                // volume of 0.1 lot
               request.type     =ORDER_TYPE_BUY;                       // order type
               request.price    =SymbolInfoDouble(_Symbol,SYMBOL_ASK);  // price for opening
               request.deviation=1;                                    // allowed deviation from the price
               //request.magic    =123;                                     // MagicNumber of the order
               request.sl       =iLow(_Symbol,PERIOD_H1,1);        // stop loss == low of the last hour
               request.tp       =iHigh(_Symbol,PERIOD_H1,1);       // take profit == high of the last hour
               request.comment  ="buy hourly";
               if(!OrderSend(request,result)){
                  Print("error OrderSend = ",__FUNCTION__,": ",result.comment," answer code ",result.retcode);
                  }
               //OrderSend(request,result);
               //trade.Buy(0.1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),iLow(_Symbol,PERIOD_H1,1),iHigh(_Symbol,PERIOD_H1,1));
              
              }
           }
    else if(iLow(_Symbol,PERIOD_H1,1) < iLow(_Symbol,PERIOD_H1,2) && iOpen(_Symbol,PERIOD_H1,1) > iLow(_Symbol,PERIOD_H1,2))
           {
            double perc50 = iLow(_Symbol,PERIOD_H1,1) + ((iHigh(_Symbol,PERIOD_H1,1) - iLow(_Symbol,PERIOD_H1,1))*0.50);
       if(iClose(_Symbol,PERIOD_H1,1) > perc50) // check if the close of hour1 > 50 percent
         {
           if(SymbolInfoDouble(_Symbol,SYMBOL_BID) == perc50 && OrdersTotal() == 0) //check if the price == 50 percent to enter a trade
             {
               Print("hour buy");
               Print(OrdersTotal());
               MqlTradeResult result={};
               MqlTradeRequest request={};
               //--- parameters of request
               request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
               request.symbol   =Symbol();                              // symbol
               request.volume   =0.1;                // volume of 0.1 lot
               request.type     =ORDER_TYPE_BUY;                       // order type
               request.price    =SymbolInfoDouble(_Symbol,SYMBOL_ASK);  // price for opening
               request.deviation=1;                                    // allowed deviation from the price
               //request.magic    =123;                                     // MagicNumber of the order
               request.sl       =iLow(_Symbol,PERIOD_H1,1);        // stop loss == low of the last hour
               request.tp       =iHigh(_Symbol,PERIOD_H1,1);       // take profit == high of the last hour
               request.comment  ="buy hourly";
               if(!OrderSend(request,result)){
                  Print("error OrderSend = ",__FUNCTION__,": ",result.comment," answer code ",result.retcode);
                  }
               //OrderSend(request,result);
               //trade.Buy(0.1,_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),iLow(_Symbol,PERIOD_H1,1),iHigh(_Symbol,PERIOD_H1,1));
              
              }
           }
           }
   }
}