#include <Trade\Trade.mqh>
CTrade trade;

// Global variables
double highestHigh;
double lowestLow;
double u123;
double d123;

// Session times (in server time)
datetime TimeOpen =  iTime(Symbol(), PERIOD_D1, 0); // open time
datetime TimeClose =  iTime(Symbol(), PERIOD_D1, 0); // close time

int OnInit()
  {
   Print("timeOpen:",TimeOpen,"  timeClose",TimeClose);
   // Initialize highest high and lowest low for each session
   highestHigh = 0.0;
   lowestLow = DBL_MAX;
   u123 = 0.0;
   d123 = DBL_MAX;
   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   
  }
void OnTick()
  {
  TimeOpen  =  iTime(Symbol(), PERIOD_D1, 0); // open time
  TimeClose =  iTime(Symbol(), PERIOD_D1, 0); // close time
  if(TimeCurrent() == TimeOpen + 10 * PERIOD_H1 && OrdersTotal()==0)
    {
     Print("hhhhhhhhhhhhhh");
     FindHighLow();
     double risk = AccountInfoDouble(ACCOUNT_BALANCE) * 0.01;
     double lot = risk / (MathAbs(highestHigh - lowestLow) / Point());
     double tp=NormalizeDouble((highestHigh - lowestLow)*1.5,_Digits);
     trade.SellLimit(NormalizeDouble(lot,2),lowestLow,_Symbol,highestHigh,0,(TimeOpen + 19 * PERIOD_H1));
     trade.BuyLimit(NormalizeDouble(lot,2),highestHigh,_Symbol,lowestLow,0,(TimeOpen + 19 * PERIOD_H1));
    }
    
   highestHigh = 0.0;
   lowestLow = DBL_MAX; 
   u123 = 0.0;
   d123 = DBL_MAX;
  }
  
  
  
  
  
  
  
void FindHighLow()
{
   // Iterate through bars to find the highest high and lowest low within the 2am -- 3am session
   for(int i = 0; i < iBars(_Symbol,PERIOD_CURRENT); i++)
   {
      if(iTime(_Symbol,PERIOD_CURRENT, i) >= TimeOpen + 2 * PERIOD_H1 && iTime(_Symbol,PERIOD_CURRENT, i) <= TimeOpen + 3 * PERIOD_H1  )
      {
         if(iHigh(_Symbol,PERIOD_CURRENT, i) >= highestHigh)
         {
            highestHigh = iHigh(_Symbol,PERIOD_CURRENT, i);
         }
         if(iLow(_Symbol,PERIOD_CURRENT, i) <= lowestLow)
         {
            lowestLow = iLow(_Symbol,PERIOD_CURRENT, i);
         }
      }
   }
}