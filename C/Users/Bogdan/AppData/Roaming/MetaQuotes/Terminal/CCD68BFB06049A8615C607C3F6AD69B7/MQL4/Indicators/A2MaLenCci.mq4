//+------------------------------------------------------------------+
//|                                                    ArraySort.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string symbols_array[23]={"USDCHF","GBPUSD","EURUSD","USDJPY","USDCAD","AUDUSD","EURGBP","EURAUD","EURCHF","EURJPY","GBPCHF","CADJPY","GBPJPY","AUDNZD","AUDCAD","AUDCHF","AUDJPY","CHFJPY","EURNZD","EURCAD","CADCHF","NZDJPY","NZDUSD"}; 
double cci_array[23][2],cci1_array[23][2],cci2_array[23][2];
double tmp_array[23][2];
long current_chart_id;
int prev_h1_stoch,prev_h1_rsi;
string signals[60][2]; int signalscount;
int tperiod;
int tperiods[4];
string stoch_sorted_index(int i0){
  int i;
  for(i=0; i<23; i++)if(i==i0)return symbols_array[i];
  return 0;
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//if(Period()==1)tperiods[4]=[1,15,30,60];else
//if(Period()==15)tperiods[4]={15,30,60,240};else
//if(Period()==30)tperiods[4]={30,60,240,1440};else
//if(Period()==60)tperiods[4]={60,240,1440,10080};
//--- indicator buffers mapping
prev_h1_stoch=0;prev_h1_rsi=0;
int i;
current_chart_id=ChartID();

//--- создаем объект типа label 
   for(i=0; i<23; i++){
     if(!ObjectCreate(current_chart_id,"Cci"+symbols_array[i],OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
       return(0); 
      } 
   }   
   for(i=0; i<23; i++){
     if(!ObjectCreate(current_chart_id,"Cci1"+symbols_array[i],OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
       return(0); 
      } 
   } 
   for(i=0; i<23; i++){
     if(!ObjectCreate(current_chart_id,"Cci2"+symbols_array[i],OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
       return(0); 
      } 
   } 
  EventSetTimer(1);    
//---
   return(INIT_SUCCEEDED);
  }
  void OnDeinit(){
    EventKillTimer();
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
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
int DeltaMasLength(string tsymbol){
  int i,i1;
  double tmp1,ma_fast,ma_slow;
  double prevtmp1=999999.0;
  for(i=0; i<200; i++){
     ma_fast=ma_slow=iCCI(tsymbol,0,333,PRICE_TYPICAL,i);//iClose(tsymbol,0,i);//iMA(tsymbol,0,22,0,MODE_SMA,PRICE_CLOSE,i);//
     for(i1=1; i1<111; i1++)ma_slow=ma_slow+iCCI(tsymbol,0,333,PRICE_TYPICAL,i1+i);//iClose(tsymbol,0,i+i1);//iMA(tsymbol,0,22,0,MODE_SMA,PRICE_CLOSE,i+i1);//
     ma_slow=ma_slow/111.0;
     for(i1=1; i1<14; i1++)ma_fast=ma_fast+iCCI(tsymbol,0,333,PRICE_TYPICAL,i1+i);//iClose(tsymbol,0,i+i1);//iMA(tsymbol,0,22,0,MODE_SMA,PRICE_CLOSE,i+i1);//
     ma_fast=ma_fast/14.0;
     
     tmp1=MathAbs(ma_fast-ma_slow);
     if(prevtmp1<tmp1)return (i);
     prevtmp1=tmp1;
  }
  return (0);
}  
//+------------------------------------------------------------------+
void OnTimer() 
  { 
   int i,i0,i1,i2; 
   double ma_slow, ma_fast;
   signalscount=0;
//================ C C I ===================

   for(i=0; i<23; i++){
     cci_array[i][0]=i;
     ma_fast=ma_slow=iCCI(symbols_array[i],0,333,PRICE_TYPICAL,0);
     for(i1=1; i1<111; i1++)ma_slow=ma_slow+iCCI(symbols_array[i],0,333,PRICE_TYPICAL,i1);ma_slow=ma_slow/111.0;
     for(i1=1; i1<14; i1++)ma_fast=ma_fast+iCCI(symbols_array[i],0,333,PRICE_TYPICAL,i1);ma_fast=ma_fast/14.0;
     
     cci_array[i][1]=ma_fast-ma_slow;//iRSI(symbols_array[i],0,333,PRICE_CLOSE,0);//iCCI(symbols_array[i],0,333,PRICE_TYPICAL,0);
   }
   double cci_array_tmp[23][2];
   for(i=0; i<23; i++){
     cci_array_tmp[i][0]=cci_array[i][0];
     cci_array_tmp[i][1]=cci_array[i][1];
   }
   i0=0;
   for(i=0; i<23; i++){
     double i3=-99999;
     for(i1=0; i1<23; i1++){
       if( cci_array_tmp[i1][1] > i3){
         i3 = cci_array_tmp[i1][1];
         i2=i1;
       }
     }
     cci_array[i0][0]=cci_array_tmp[i2][0];
     cci_array[i0][1]=cci_array_tmp[i2][1];
     i0++;
     cci_array_tmp[i2][1]=-100000;
   }   
       

//============== C C I 2 =============================

//================ C C I ===================

   for(i=0; i<23; i++){
     cci2_array[i][0]=i;
     cci2_array[i][1]=DeltaMasLength(symbols_array[i]);
   }
   double cci2_array_tmp[23][2];
   for(i=0; i<23; i++){
     cci2_array_tmp[i][0]=cci2_array[i][0];
     cci2_array_tmp[i][1]=cci2_array[i][1];
   }
   i0=0;
   for(i=0; i<23; i++){
     double i3=-99999;
     for(i1=0; i1<23; i1++){
       if( cci2_array_tmp[i1][1] > i3){
         i3 = cci2_array_tmp[i1][1];
         i2=i1;
       }
     }
     cci2_array[i0][0]=cci2_array_tmp[i2][0];
     cci2_array[i0][1]=cci2_array_tmp[i2][1];
     i0++;
     cci2_array_tmp[i2][1]=-100000;
   }   
   

//--- перемещение объекта label и изменение его текста 
   for(i=0; i<23; i++) 
     { 
      //-- устанавливаем текст объекта 
      ObjectSetString(current_chart_id,"Cci2"+symbols_array[i],OBJPROP_TEXT,StringFormat(Period()+" %s : %d",stoch_sorted_index(cci2_array[i][0]),(int)cci2_array[i][1])); 
      //-- устанавливаем значение координаты Y 
      ObjectSet("Cci2"+symbols_array[i],OBJPROP_YDISTANCE,i*15); 
      ObjectSet("Cci2"+symbols_array[i],OBJPROP_XDISTANCE,5);
//--- устанавливаем цвет Red 
     double tmp01,tmp02;
     for(i1=0;i1<23;i1++)if(cci_array[i1][0]==cci2_array[i][0]){tmp01=cci_array[i1][1];tmp02=cci2_array[i][1];}
     
     if(i<5 || tmp02>=9){  
       if(tmp01<0){
          ObjectSetInteger(current_chart_id,"Cci2"+symbols_array[i],OBJPROP_COLOR,clrAqua); 
          signals[signalscount][0]=Period()+" "+symbols_array[i]+" BUY";
          signals[signalscount][1]=(string)(int)cci2_array[i][1];
        }
       else {
          ObjectSetInteger(current_chart_id,"Cci2"+symbols_array[i],OBJPROP_COLOR,clrRed);
          signals[signalscount][0]=Period()+" "+symbols_array[i]+" SELL";
          signals[signalscount][1]=(string)(int)cci2_array[i][1];          
       }
       signalscount=signalscount+1;if(signalscount>59)signalscount=59;
     } else
       ObjectSetInteger(current_chart_id,"Cci2"+symbols_array[i],OBJPROP_COLOR,clrYellow); 
     
     
      //-- перерисовка графика 
      ChartRedraw(current_chart_id); 
     }      
 



//==================================================== 
 
 
     
  //if(prev_h1_stoch != stoch_array[0][0]){
  // prev_h1_stoch = stoch_array[0][0];
  // if(Period()==60)PlaySound("h1_stoch.wav");else
  // if(Period()==240)PlaySound("h4_stoch.wav");
  //}    
  //if(prev_h1_rsi != cci_array[0][0]){
  // prev_h1_rsi = cci_array[0][0];
  // if(Period()==60)PlaySound("h1_rsi.wav");else
  // if(Period()==240)PlaySound("h4_rsi.wav");
  //}  
  // Sleep(1);
  // return(0); 
  }