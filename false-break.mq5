//+------------------------------------------------------------------+
//|                                                 false-break.mq5  |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include <Trade\Trade.mqh>
CTrade trade;

// Global variables
double highestHigh;
double lowestLow;
double currenthigh;
double currentlow;
double u123;
double d123;
double u138;
double d138;



// Session times (in server time)
datetime TimeOpen  =  iTime(Symbol(), PERIOD_D1, 0); // open time
datetime TimeClose =  iTime(Symbol(), PERIOD_D1, 0); // close time

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("false-break started: ",_Symbol,"balance: ",AccountInfoDouble(ACCOUNT_BALANCE));

   Print("timeOpen:",TimeOpen- 60 * 60 * 24,"timeClose",TimeClose);

   // Initialize highest high and lowest low for each session
   highestHigh = 0.0;
   lowestLow = DBL_MAX;
   currenthigh = 0.0;
   currentlow = DBL_MAX;

   // Call the function to find highest high and lowest low for each session
   //FindHighLowstart();

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // No deinitialization needed
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   TimeOpen  =  iTime(Symbol(), PERIOD_D1, 0); // open time
   TimeClose =  iTime(Symbol(), PERIOD_D1, 0); // close time
   FindHighLowlast();
   //Print("highesthigh: ",highestHigh," lowestlow: ",lowestLow);
   FindHighLowCurrent();
   //Print("currenthigh: ",currenthigh," currentlow: ",currentlow);
   CheckFalseBreak();
   
   
   highestHigh = 0.0;
   lowestLow = DBL_MAX;   
   currenthigh = 0.0;
   currentlow = DBL_MAX;
   u123 = 0.0;
   d123 = DBL_MAX;
   u138 = 0.0;
   d138 = DBL_MAX;
}

//+------------------------------------------------------------------+
//| Function to find highest high and lowest low                     |
//+------------------------------------------------------------------+
void FindHighLowlast()
{
   // Iterate through bars to find the highest high and lowest low within the Tokyo session
   for(int i = 0; i < iBars(_Symbol,PERIOD_CURRENT); i++)
   {
      if(iTime(_Symbol,PERIOD_CURRENT, i) >= TimeOpen - 60 * 60 * 24 && iTime(_Symbol,PERIOD_CURRENT, i) <= TimeClose)
      {
         if(iHigh(_Symbol,PERIOD_CURRENT, i) >= highestHigh)
         {
            highestHigh = NormalizeDouble(iHigh(_Symbol,PERIOD_CURRENT, i),_Digits);
         }
         if(iLow(_Symbol,PERIOD_CURRENT, i) <= lowestLow)
         {
            lowestLow = NormalizeDouble(iLow(_Symbol,PERIOD_CURRENT, i),_Digits);
         }
        u123=NormalizeDouble(((highestHigh-lowestLow)*0.236)+highestHigh,_Digits);
        d123=NormalizeDouble(lowestLow - ((highestHigh-lowestLow)*0.236),_Digits);
        u138=NormalizeDouble(((highestHigh-lowestLow)*0.382)+highestHigh,_Digits);
        d138=NormalizeDouble(lowestLow - ((highestHigh-lowestLow)*0.382),_Digits);
        //Print("Highest High: ", highestHigh, ", Lowest Low: ", lowestLow,", u123:",u123,", d123:",d123);
      }
   }
}


void FindHighLowCurrent()
{
   // Iterate through bars to find the highest high and lowest low within the Tokyo session
   for(int i = 0; i < iBars(_Symbol,PERIOD_CURRENT); i++)
   {
      if(iTime(_Symbol,PERIOD_CURRENT, i) > TimeClose && iTime(_Symbol,PERIOD_CURRENT, i) <= TimeCurrent())
      {
         if(iHigh(_Symbol,PERIOD_CURRENT, i) >= currenthigh)
         {
            currenthigh = NormalizeDouble(iHigh(_Symbol,PERIOD_CURRENT, i),_Digits);
         }
         if(iLow(_Symbol,PERIOD_CURRENT, i) <= currentlow)
         {
            currentlow = NormalizeDouble(iLow(_Symbol,PERIOD_CURRENT, i),_Digits);
         }
      }
   }
}



void CheckFalseBreak(){
   //Print("--falsebreak--");
   if(currenthigh > highestHigh && currenthigh < u123 && SymbolInfoDouble(_Symbol,SYMBOL_BID) == NormalizeDouble(highestHigh,_Digits)){
      double m50 = lowestLow + ((highestHigh-lowestLow)*0.5);
      double risk = AccountInfoDouble(ACCOUNT_BALANCE) * 0.1;
      double lot = risk / (MathAbs(u123-highestHigh) / Point());
      Print("lot: ",NormalizeDouble(lot,2));
      Print(currenthigh,"--------falsebreak----high------",SymbolInfoDouble(_Symbol,SYMBOL_BID));
      if(OrdersTotal() == 0){
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =NormalizeDouble(lot,2);                                   // volume of 0.1 lot
         request.type     =ORDER_TYPE_SELL;                        // order type
         request.price    =NormalizeDouble(highestHigh,_Digits); // price for opening
         request.deviation=5;                                     // allowed deviation from the price
         request.magic    =0;                          // MagicNumber of the order
         request.sl       =NormalizeDouble(u123,_Digits);
         request.tp       =NormalizeDouble(lowestLow,_Digits);
         OrderSend(request,result);
        }
      
   }
   if(currentlow > d123 && currentlow < lowestLow && SymbolInfoDouble(_Symbol,SYMBOL_ASK) == NormalizeDouble(lowestLow,_Digits)){
      Print(TimeCurrent());
      Print(currentlow,"--------falsebreak----low------",SymbolInfoDouble(_Symbol,SYMBOL_ASK));
      //Print(pipDifference);
      double m50 = lowestLow + ((highestHigh-lowestLow)*0.5);
      double risk = AccountInfoDouble(ACCOUNT_BALANCE) * 0.1;
      double lot = risk / (MathAbs(lowestLow-d123) / Point());
      Print("lot: ",NormalizeDouble(lot,2));
      if(OrdersTotal() == 0){
         MqlTradeResult result={};
         MqlTradeRequest request={};
         //--- parameters of request
         request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
         request.symbol   =Symbol();                              // symbol
         request.volume   =NormalizeDouble(lot,2);                                   // volume of 0.1 lot
         request.type     =ORDER_TYPE_BUY;                        // order type
         request.price    =NormalizeDouble(lowestLow,_Digits); // price for opening
         request.deviation=5;                                     // allowed deviation from the price
         request.magic    =0;                          // MagicNumber of the order
         request.sl       =NormalizeDouble(d123,_Digits);
         request.tp       =NormalizeDouble(highestHigh,_Digits);
         OrderSend(request,result);
        }
   }

}