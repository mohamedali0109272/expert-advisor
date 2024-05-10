//+------------------------------------------------------------------+
//|                                                 false-break.mq4  |
//|                        Copyright 2024, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input int timePeriod = 1440; // Time period in minutes (1 day by default)

// Global variables
double highestHigh;
double lowestLow;
double currenthigh;
double currentlow;
double u123;
double d123;



// Session times (in server time)
datetime TimeOpen =  StringToTime("00:00"); // open time
datetime TimeClose =  StringToTime("00:00"); // close time


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


   Print("false-break started: ",_Symbol);

   Print("timeOpen:",TimeOpen- 60 * 60 * 24,"timeClose",TimeClose);
   

// Initialize highest high and lowest low for each session
   highestHigh = 0.0;
   lowestLow = DBL_MAX;
   currenthigh = 0.0;
   currentlow = DBL_MAX;


// Call the function to find highest high and lowest low for each session

   
   FindHighLowstart();
   //u123=((highestHigh-lowestLow)*0.23)+highestHigh;
// Print the results
   //Print("Highest High: ", highestHigh, ", Lowest Low: ", lowestLow,", u123:",u123);

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
   TimeOpen =  StringToTime("00:00"); // open time
   TimeClose =  StringToTime("00:00"); // close time
   FindHighLowstart();
   FindHighLow();
   //Print("currenthigh: ",currenthigh," > highesthigh: ",highestHigh," && Ask: ",Ask," < u123: ",u123);
   //Print("currentlow: ",currentlow," > lowestlow: ",lowestLow," && Bid: ",Bid," < d123: ",d123);
   CheckFalseBreak();
   //Print(TimeCurrent()); 
   highestHigh = 0.0;
   lowestLow = DBL_MAX;   
   currenthigh = 0.0;
   currentlow = DBL_MAX;
   u123 = 0.0;
   d123 = DBL_MAX;
   
// No need to do anything on tick
  }
//+------------------------------------------------------------------+
//| Function to find highest high and lowest low                     |
//+------------------------------------------------------------------+
void FindHighLowstart()
  {
// Iterate through bars to find the highest high and lowest low within the Tokyo session
   for(int i = 0; i < Bars; i++)
     {
      if(Time[i] >= TimeOpen - 60 * 60 * 24 && Time[i] <= TimeClose)
        {
         if(High[i] >= highestHigh){
            highestHigh = High[i];
            }
         if(Low[i] <= lowestLow){
            lowestLow = Low[i];
            }
        }
        u123=((highestHigh-lowestLow)*0.23)+highestHigh;
        d123=lowestLow - ((highestHigh-lowestLow)*0.23);
     }
   //Print("Highest High: ", highestHigh, ", Lowest Low: ", lowestLow,", u123:",u123,", d123:",d123);
  }

void FindHighLow()
  {
// Iterate through bars to find the highest high and lowest low within the Tokyo session
   for(int i = 0; i < Bars; i++)
     {
      if(Time[i] > TimeClose && Time[i] <= TimeCurrent())
        {
         //Print("timeOpen:",TimeOpen,"timeClose",TimeClose);
         if(High[i] >= currenthigh){
            currenthigh = High[i];
            //Print(currenthigh," ---",TimeCurrent());
            }
         if(Low[i] <= currentlow){
            currentlow = Low[i];
            //Print(currentlow);
            }
        }
     }

  }
  
  
void CheckFalseBreak(){

   double pipDifference = MathAbs(highestHigh - lowestLow) / Point;
   

   
   if(currenthigh > u123 && SymbolInfoDouble(_Symbol,SYMBOL_BID) == highestHigh && pipDifference > 500){
      //Print("currenthigh: ",currenthigh," > highesthigh: ",highestHigh," && lowestlow: ",lowestLow," < u123: ",u123);
      //Print(TimeCurrent());
      //Print(currenthigh,"--------falsebreak-----high-----",SymbolInfoDouble(_Symbol,SYMBOL_BID));
      //Print(pipDifference);
      double risk = AccountBalance() * 0.005;
      double lot = risk / (u123-highestHigh);
      //Print("risk:",risk," lot:",lot," stoploss:",u123," takeprofit:",lowestLow," sell:",SymbolInfoDouble(_Symbol,SYMBOL_ASK));
      if(OrdersTotal()==0){
         RefreshRates();
         OrderSend(Symbol(),OP_SELL,lot,SymbolInfoDouble(_Symbol,SYMBOL_BID),1,u123,lowestLow);
        }
   }
   if(currentlow < d123 && SymbolInfoDouble(_Symbol,SYMBOL_ASK) == lowestLow && pipDifference > 500){
      //Print(TimeCurrent());
      //Print(currentlow,"--------falsebreak----low------",SymbolInfoDouble(_Symbol,SYMBOL_ASK));
      //Print(pipDifference);
      double risk = AccountBalance() * 0.005;
      double lot = risk / (d123-lowestLow);
      //Print("risk:",risk," lot:",lot," stoploss:",d123," takeprofit:",highestHigh," buy:",SymbolInfoDouble(_Symbol,SYMBOL_BID));
      if(OrdersTotal()==0){
         RefreshRates();
         OrderSend(Symbol(),OP_BUY,lot,SymbolInfoDouble(_Symbol,SYMBOL_ASK),1,d123,highestHigh);
        }
   }

}


double CalculatePips(double price1, double price2) {
    return MathAbs(price1 - price2) / Point;
}
