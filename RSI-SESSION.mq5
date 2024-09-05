#property strict
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CTrade trade;
// Input parameters
input int Period = 14; // RSI period

// Global variables
int RSiHandle;
string trade_signal = "booom";
input double riskperc = 0.01;
input bool fixed_lot = false;
input double fixed_lot_value = 0.1;
input double ratio = 1;
datetime lastOrderTime = 0;
double margin;
datetime start_of_day = iTime(Symbol(), PERIOD_D1, 0);
input int start_hour = 15;
input int end_hour = 16;
// OnInit function - initialization
int OnInit() {
   Print("spread : " ,SymbolInfoInteger(Symbol(), SYMBOL_SPREAD));
  // Create RSI indicator
  RSiHandle = iRSI(_Symbol, PERIOD_M1, Period, PRICE_CLOSE);
  
  if(RSiHandle == INVALID_HANDLE) {
    Print("Failed to create RSI indicator!");
    return(INIT_FAILED);
  }
  
  // Print confirmation message
  Print("RSI indicator created successfully (Period=", Period, ")");
  
  return(INIT_SUCCEEDED);
}

// OnTick function - called on every new tick
void OnTick() {
  // Get RSI value
  start_of_day = iTime(Symbol(), PERIOD_D1, 0);
  datetime start = start_of_day + start_hour * 60 * 60;
  datetime end = start_of_day + end_hour * 60 * 60;
  //Print(start);
  double rsi[1];
  CopyBuffer(RSiHandle, 0, 0, 1, rsi);
  if(TimeCurrent() > start && TimeCurrent() < end)
    {
    //Print(start);
    //reserve_1r();
    find_signal();
    if(trade_signal == "sell")
      {
       sell();
      }
    else if(trade_signal== "buy")
           {
            buy();
           }
    }
    

}


void find_signal(){
     double rsi[1];
     CopyBuffer(RSiHandle, 0, 0, 1, rsi);
     if(rsi[0] >= 70)
      {
         //Print("rsi >= 70");
         trade_signal = "sell";
      }
     else if(rsi[0] <= 30)
         {
          //Print("rsi < 30");
          trade_signal = "buy";
         }

}

void sell( ){
   if(iClose(_Symbol,PERIOD_CURRENT,4) > iOpen(_Symbol,PERIOD_CURRENT,4) && iClose(_Symbol,PERIOD_CURRENT,3) > iOpen(_Symbol,PERIOD_CURRENT,3) && iClose(_Symbol,PERIOD_CURRENT,2) > iOpen(_Symbol,PERIOD_CURRENT,2) && iOpen(_Symbol,PERIOD_CURRENT,1) > iClose(_Symbol,PERIOD_CURRENT,1) )
     {
      double perc50 = (iClose(_Symbol,PERIOD_CURRENT,2) - iOpen(_Symbol,PERIOD_CURRENT,2))*0.50;
      double perc200 = (iClose(_Symbol,PERIOD_CURRENT,2) - iOpen(_Symbol,PERIOD_CURRENT,2))*2;
      double perc_1 = iOpen(_Symbol,PERIOD_CURRENT,1) - iClose(_Symbol,PERIOD_CURRENT,1);
      if(perc200 > perc_1 && perc_1 > perc50 && PositionsTotal() == 0)
        {
          //Print("sellll trade--------------------------------------------");
          //stop_sell();
          //Print(perc50,"--" , perc_1);
          double risk = AccountInfoDouble(ACCOUNT_BALANCE) * riskperc;
          double sp = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - SymbolInfoDouble(_Symbol,SYMBOL_BID);
          double lot = risk / (MathAbs(stop_loss_sell() + sp - SymbolInfoDouble(_Symbol,SYMBOL_BID)) / Point());
          double tp = SymbolInfoDouble(_Symbol,SYMBOL_BID) - ((stop_loss_sell() - SymbolInfoDouble(_Symbol,SYMBOL_BID))*ratio);
          if(fixed_lot == true)
            {
             lot=fixed_lot_value;
            }
          datetime currentCandleTime = iTime(NULL, 0, 0);
          

          if(lastOrderTime != currentCandleTime)
            {
             bool required_margin = OrderCalcMargin(ORDER_TYPE_SELL,_Symbol,lot ,SymbolInfoDouble(_Symbol,SYMBOL_BID),margin);
             Print("required margin: ",margin);
             trade.Sell(NormalizeDouble(lot,2),_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID),stop_loss_sell() + (SymbolInfoDouble(_Symbol,SYMBOL_ASK) - SymbolInfoDouble(_Symbol,SYMBOL_BID)),tp);
             lastOrderTime = currentCandleTime;
            }

        }
     }
}


void buy(){
   if(iOpen(_Symbol,PERIOD_CURRENT,4) > iClose(_Symbol,PERIOD_CURRENT,4) && iOpen(_Symbol,PERIOD_CURRENT,3) > iClose(_Symbol,PERIOD_CURRENT,3) && iOpen(_Symbol,PERIOD_CURRENT,2) > iClose(_Symbol,PERIOD_CURRENT,2) && iClose(_Symbol,PERIOD_CURRENT,1) > iOpen(_Symbol,PERIOD_CURRENT,1) )
     {
      double perc50 = (iOpen(_Symbol,PERIOD_CURRENT,2) - iClose(_Symbol,PERIOD_CURRENT,2))*0.50;
      double perc200 = (iOpen(_Symbol,PERIOD_CURRENT,2) - iClose(_Symbol,PERIOD_CURRENT,2))*2;
      double perc_1 = iClose(_Symbol,PERIOD_CURRENT,1) - iOpen(_Symbol,PERIOD_CURRENT,1);
      if(perc200 > perc_1 && perc_1 > perc50 && PositionsTotal() == 0)
        {
         //Print("buy trade--------------------------------------------");
         //Print(perc50,"--" , perc_1);
         double risk = AccountInfoDouble(ACCOUNT_BALANCE) * riskperc;
         double lot = risk / (MathAbs(SymbolInfoDouble(_Symbol,SYMBOL_ASK) - stop_loss_buy()) / Point());
         double tp = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + ((SymbolInfoDouble(_Symbol,SYMBOL_ASK) - stop_loss_buy())*ratio);
           if(fixed_lot == true)
            {
             lot=fixed_lot_value;
            }
         datetime currentCandleTime = iTime(NULL, 0, 0);
         if(lastOrderTime != currentCandleTime)
           {
            bool required_margin = OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lot ,SymbolInfoDouble(_Symbol,SYMBOL_ASK),margin);
            Print("required margin: ",margin);
            trade.Buy(NormalizeDouble(lot,2),_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK),stop_loss_buy(),tp);
            lastOrderTime = currentCandleTime;
           } 
        }
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
  
double stop_loss_buy()
  {
   //---
   int candle = 4;
   double c_candle[];
   ArrayResize(c_candle,candle);

   for(int i=0;i<candle;i++)
     {
      //   c_candle[i]=High[i];
      c_candle[i]=iLow(Symbol(),PERIOD_CURRENT,i);
      //Print("candle "+(i+1)+" :cC = "+c_candle[i]);
     }
   int cC=ArrayMinimum(c_candle,0,WHOLE_ARRAY);
   //Print(c_candle[cC]);
   return c_candle[cC];
  }
  