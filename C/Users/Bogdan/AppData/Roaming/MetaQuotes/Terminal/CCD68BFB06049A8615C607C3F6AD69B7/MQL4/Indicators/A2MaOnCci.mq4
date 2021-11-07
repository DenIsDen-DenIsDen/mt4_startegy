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
int prev_h1_stoch,prev_h1_rsi,hilowD1_array[23][2];
int prev_h1_hi,prev_h1_low;
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
     if(!ObjectCreate(current_chart_id,"hilowD1"+symbols_array[i],OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
       return(0); 
      } 
   }   
  EventSetTimer(20);    
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
   

//--- перемещение объекта label и изменение его текста 
   for(i=0; i<23; i++) 
     { 
      //-- устанавливаем текст объекта 
      ObjectSetString(current_chart_id,"Cci"+symbols_array[i],OBJPROP_TEXT,StringFormat("2MaCci %s : %f",stoch_sorted_index(cci_array[i][0]),cci_array[i][1])); 
      //-- устанавливаем значение координаты Y 
      ObjectSet("Cci"+symbols_array[i],OBJPROP_YDISTANCE,i*15); 
      ObjectSet("Cci"+symbols_array[i],OBJPROP_XDISTANCE,5);
//--- устанавливаем цвет Red 
     if((cci_array[i][1]>-2 && cci_array[i][1]<0) || i==22)
     ObjectSetInteger(current_chart_id,"Cci"+symbols_array[i],OBJPROP_COLOR,clrAqua); else
     if((cci_array[i][1]<2 && cci_array[i][1]>0) || i==0)
     ObjectSetInteger(current_chart_id,"Cci"+symbols_array[i],OBJPROP_COLOR,clrRed); else
     ObjectSetInteger(current_chart_id,"Cci"+symbols_array[i],OBJPROP_COLOR,clrYellow); 
      //-- перерисовка графика 
      ChartRedraw(current_chart_id); 
     }      
 
 
//=============  P R E V B A R =======================


   for(i=0; i<23; i++){
     cci1_array[i][0]=i;
     ma_fast=ma_slow=iCCI(symbols_array[i],0,333,PRICE_TYPICAL,1);
     for(i1=2; i1<112; i1++)ma_slow=ma_slow+iCCI(symbols_array[i],0,333,PRICE_TYPICAL,i1);ma_slow=ma_slow/111.0;
     for(i1=2; i1<15; i1++)ma_fast=ma_fast+iCCI(symbols_array[i],0,333,PRICE_TYPICAL,i1);ma_fast=ma_fast/14.0;
     
     cci1_array[i][1]=ma_fast-ma_slow;//iRSI(symbols_array[i],0,333,PRICE_CLOSE,0);//iCCI(symbols_array[i],0,333,PRICE_TYPICAL,0);
   }
   double cci1_array_tmp[23][2];
   for(i=0; i<23; i++){
     cci1_array_tmp[i][0]=cci1_array[i][0];
     cci1_array_tmp[i][1]=cci1_array[i][1];
   }
   i0=0;
   for(i=0; i<23; i++){
     double i3=-99999;
     for(i1=0; i1<23; i1++){
       if( cci1_array_tmp[i1][1] > i3){
         i3 = cci1_array_tmp[i1][1];
         i2=i1;
       }
     }
     cci1_array[i0][0]=cci1_array_tmp[i2][0];
     cci1_array[i0][1]=cci1_array_tmp[i2][1];
     i0++;
     cci1_array_tmp[i2][1]=-100000;
   }   
//---- sort -----------------
   for(i=0; i<23; i++)for(i1=0; i1<23; i1++)if(cci1_array[i1][0]==cci_array[i][0]){
    tmp_array[i][1]=cci_array[i][1]-cci1_array[i1][1];
    tmp_array[i][0]=cci_array[i][0];
   }
   for(i=0; i<23; i++){
    cci1_array[i][0]=tmp_array[i][0];
    cci1_array[i][1]=tmp_array[i][1];
   }   

//--- перемещение объекта label и изменение его текста 
   for(i=0; i<23; i++) 
     { 
      //-- устанавливаем текст объекта 
      ObjectSetString(current_chart_id,"Cci1"+symbols_array[i],OBJPROP_TEXT,StringFormat("%.2f",cci1_array[i][1])); 
      //-- устанавливаем значение координаты Y 
      ObjectSet("Cci1"+symbols_array[i],OBJPROP_YDISTANCE,i*15); 
      ObjectSet("Cci1"+symbols_array[i],OBJPROP_XDISTANCE,195);
//--- устанавливаем цвет Red 
     if(cci1_array[i][1]>0)
     ObjectSetInteger(current_chart_id,"Cci1"+symbols_array[i],OBJPROP_COLOR,clrAqua); else
     if(cci1_array[i][1]<0)
     ObjectSetInteger(current_chart_id,"Cci1"+symbols_array[i],OBJPROP_COLOR,clrRed); else
     ObjectSetInteger(current_chart_id,"Cci1"+symbols_array[i],OBJPROP_COLOR,clrYellow); 
      //-- перерисовка графика 
      ChartRedraw(current_chart_id); 
     }      
 


//==================================================== 

//================== H I L O W D 1 ==================



   for(i=0; i<23; i++){
     hilowD1_array[i][0]=i;
     hilowD1_array[i][1]=(int)(iClose(symbols_array[i],1440,0)*MathPow(10,(int)MarketInfo(symbols_array[i],MODE_DIGITS))-iOpen(symbols_array[i],1440,0)*MathPow(10,(int)MarketInfo(symbols_array[i],MODE_DIGITS)));//iStochastic(symbols_array[i],0,8,3,3,MODE_SMA,0,MODE_MAIN,0);
   }
   double hilowD1_array_tmp[23][2];
   for(i=0; i<23; i++){
     hilowD1_array_tmp[i][0]=hilowD1_array[i][0];
     hilowD1_array_tmp[i][1]=hilowD1_array[i][1];
   }
   i0=0;
   for(i=0; i<23; i++){
     double i3=-99999;
     for(i1=0; i1<23; i1++){
       if( hilowD1_array_tmp[i1][1] > i3){
         i3 = hilowD1_array_tmp[i1][1];
         i2=i1;
       }
     }
     hilowD1_array[i0][0]=hilowD1_array_tmp[i2][0];
     hilowD1_array[i0][1]=hilowD1_array_tmp[i2][1];
     i0++;
     hilowD1_array_tmp[i2][1]=-100000;
   }   
   
    

//--- перемещение объекта label и изменение его текста 
   for(i=0; i<23; i++) 
     { 
      //-- устанавливаем текст объекта 
      ObjectSetString(current_chart_id,"hilowD1"+symbols_array[i],OBJPROP_TEXT,StringFormat("hilowD1 %s : %d",stoch_sorted_index(hilowD1_array[i][0]),hilowD1_array[i][1])); 
      //-- устанавливаем значение координаты Y 
      ObjectSet("hilowD1"+symbols_array[i],OBJPROP_YDISTANCE,360+i*15); 
      ObjectSet("hilowD1"+symbols_array[i],OBJPROP_XDISTANCE,5);
//--- устанавливаем цвет Red 
     if(hilowD1_array[i][1]>0)
     ObjectSetInteger(current_chart_id,"hilowD1"+symbols_array[i],OBJPROP_COLOR,clrAqua); else
     if(hilowD1_array[i][1]<0)
     ObjectSetInteger(current_chart_id,"hilowD1"+symbols_array[i],OBJPROP_COLOR,clrRed); else
     ObjectSetInteger(current_chart_id,"hilowD1"+symbols_array[i],OBJPROP_COLOR,clrYellow); 
      //-- перерисовка графика 
      ChartRedraw(current_chart_id); 
     }


//===================================================
     
     
  if(prev_h1_hi < hilowD1_array[0][1]){
   prev_h1_hi = hilowD1_array[0][1];
   PlaySound("hi.wav");
  }    
  if(prev_h1_low > hilowD1_array[22][1]){
   prev_h1_low = hilowD1_array[22][1];
   PlaySound("low.wav");
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