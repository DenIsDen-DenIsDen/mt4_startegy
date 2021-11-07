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
string signals[4][4][30][6]; int signalscount[4][4];
string signals1[4][30][6]; int signalscount1[4];
int tperiods[4];
int period_ma_slow,period_ma_fast;
string signals3[4][30][6];int signalscount3[4];
int firststart;
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

  
  
firststart=1;
if(Period()==1){tperiods[0]=1;tperiods[1]=15;tperiods[2]=30;tperiods[3]=60;}else
if(Period()==15){tperiods[0]=15;tperiods[1]=30;tperiods[2]=60;tperiods[3]=240;}else
if(Period()==30){tperiods[0]=30;tperiods[1]=60;tperiods[2]=240;tperiods[3]=1440;}else
if(Period()==60){tperiods[0]=60;tperiods[1]=240;tperiods[2]=1440;tperiods[3]=10080;}
//--- indicator buffers mapping
prev_h1_stoch=0;prev_h1_rsi=0;
int i;
current_chart_id=ChartID();

ObjectCreate(current_chart_id,"ObjDTime",OBJ_LABEL,0,0,0);
ObjectSet("ObjDTime",OBJPROP_YDISTANCE,0); 
ObjectSet("ObjDTime",OBJPROP_XDISTANCE,10);
ObjectSetInteger(current_chart_id,"ObjDTime",OBJPROP_COLOR,clrYellow); 
   for(int tperiod1=0; tperiod1<4; tperiod1++) 
   for(i=0; i<30; i++) 
     { 
      if(!ObjectCreate(current_chart_id,"Obj"+tperiod1+"_"+i,OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
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
int DeltaMasLength(string tsymbol,int tperiod){
  int i,i1;
  double tmp1,ma_fast,ma_slow;
  double prevtmp1=999999.0;
  for(i=0; i<200; i++){
     ma_fast=ma_slow=iCCI(tsymbol,tperiods[tperiod],333,PRICE_TYPICAL,i);
     for(i1=1; i1<period_ma_slow; i1++)ma_slow=ma_slow+iCCI(tsymbol,tperiods[tperiod],333,PRICE_TYPICAL,i1+i);
     ma_slow=ma_slow/period_ma_slow;
     for(i1=1; i1<period_ma_fast; i1++)ma_fast=ma_fast+iCCI(tsymbol,tperiods[tperiod],333,PRICE_TYPICAL,i1+i);
     ma_fast=ma_fast/period_ma_fast;
     
     tmp1=MathAbs(ma_fast-ma_slow);
     if(prevtmp1<tmp1)return (i);
     prevtmp1=tmp1;
  }
  return (0);
}  
//+------------------------------------------------------------------+
void OnTimer() 
  { 
  
   int i,i0,i1,i2,u,u1,u2,u3; 
   double ma_slow, ma_fast;
   
   for(i1=0; i1<4; i1++)for(i=0; i<23; i++) ma_slow=iClose(symbols_array[i],tperiods[i1],0);
   
   if(firststart==0){
    if( (((TimeMinute(TimeLocal())>15)&&(TimeMinute(TimeLocal())<18)) || ((TimeMinute(TimeLocal())>30)&&(TimeMinute(TimeLocal())<33)) || ((TimeMinute(TimeLocal())>45)&&(TimeMinute(TimeLocal())<48)) || ((TimeMinute(TimeLocal())>=2)&&(TimeMinute(TimeLocal())<4)) )
    &&((TimeSeconds(TimeLocal())==0)||(TimeSeconds(TimeLocal())==20)||(TimeSeconds(TimeLocal())==40)) ){;}else{ChartRedraw(current_chart_id); return;}
   }

for(int tperiod1=0; tperiod1<4; tperiod1++)   
for(u=0; u<4; u++){signalscount[tperiod1][u]=0;signalscount1[u]=0;}

for(int tperiod1=0; tperiod1<4; tperiod1++)   
for(u=0; u<4; u++){
   if(u==0){period_ma_fast=14;period_ma_slow=111;}else
   if(u==1){period_ma_fast=21;period_ma_slow=167;}else
   if(u==2){period_ma_fast=32;period_ma_slow=250;}else
   if(u==3){period_ma_fast=48;period_ma_slow=376;}
   
   //if(u==0){period_ma_fast=14;period_ma_slow=77;}else
   //if(u==1){period_ma_fast=21;period_ma_slow=77;}else
   //if(u==2){period_ma_fast=32;period_ma_slow=77;}else
   //if(u==3){period_ma_fast=48;period_ma_slow=77;}

//if(u==0){period_ma_fast=14;period_ma_slow=111;}else
//if(u==1){period_ma_fast=14;period_ma_slow=111;}else
//if(u==2){period_ma_fast=14;period_ma_slow=111;}else
//if(u==3){period_ma_fast=14;period_ma_slow=111;}


//================ C C I ===================

   for(i=0; i<23; i++){
     cci_array[i][0]=i;
     ma_fast=ma_slow=iCCI(symbols_array[i],tperiods[tperiod1],333,PRICE_TYPICAL,0);
     for(i1=1; i1<period_ma_slow; i1++)ma_slow=ma_slow+iCCI(symbols_array[i],tperiods[tperiod1],333,PRICE_TYPICAL,i1);ma_slow=ma_slow/period_ma_slow;
     for(i1=1; i1<period_ma_fast; i1++)ma_fast=ma_fast+iCCI(symbols_array[i],tperiods[tperiod1],333,PRICE_TYPICAL,i1);ma_fast=ma_fast/period_ma_fast;
     
     cci_array[i][1]=ma_fast-ma_slow;
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
     cci2_array[i][1]=DeltaMasLength(symbols_array[i],tperiod1);
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
   
//==========================
   for(i=0; i<23; i++) 
     { 
     double tmp01,tmp02;string tmp_symbol;
     for(i1=0;i1<23;i1++)if(cci_array[i1][0]==cci2_array[i][0]){tmp01=cci_array[i1][1];tmp02=cci2_array[i][1];tmp_symbol=stoch_sorted_index(cci_array[i1][0]);}
     
        if(tmp02>30){
          signals[tperiod1][u][signalscount[tperiod1][u]][0]=tperiods[tperiod1];
          signals[tperiod1][u][signalscount[tperiod1][u]][1]=tmp_symbol;
          signals[tperiod1][u][signalscount[tperiod1][u]][3]=(string)(int)tmp02;
          signals[tperiod1][u][signalscount[tperiod1][u]][4]=StringSetChar("0000",u,'1');
          signals[tperiod1][u][signalscount[tperiod1][u]][5]=(string)(int)MathAbs(tmp01);
  
          if(tmp01<0)signals[tperiod1][u][signalscount[tperiod1][u]][2]="BUY";
                else signals[tperiod1][u][signalscount[tperiod1][u]][2]="SELL";
                
          signalscount[tperiod1][u]=signalscount[tperiod1][u]+1;if(signalscount[tperiod1][u]>29)signalscount[tperiod1][u]=29;
        }
     }      
 
}
int findedsymbol,findedsymbol1,signals1index;
for(int tperiod1=0; tperiod1<4; tperiod1++)   
for(u=0; u<4; u++){
   for(u3=0; u3<signalscount[tperiod1][u];u3++){
      findedsymbol=-1;
      for(u2=0; u2<signalscount1[tperiod1];u2++)if(signals[tperiod1][u][u3][1]==signals1[tperiod1][u2][1]){findedsymbol=u3;findedsymbol1=u2;}
      if(findedsymbol>-1){
          signals1[tperiod1][findedsymbol1][3]=IntegerToString( MathMax(StringToInteger(signals1[tperiod1][findedsymbol1][3]),StringToInteger(signals[tperiod1][u][findedsymbol][3]) ) );
          signals1[tperiod1][findedsymbol1][4]=StringSetChar(signals1[tperiod1][findedsymbol1][4],u,'1');
          signals1[tperiod1][findedsymbol1][5]=IntegerToString( (int)MathMax(MathAbs(StringToDouble(signals1[tperiod1][findedsymbol1][5])),MathAbs(StringToDouble(signals[tperiod1][u][findedsymbol][5])) ) );       
      }else{
          signals1[tperiod1][signalscount1[tperiod1]][0]=signals[tperiod1][u][u3][0];
          signals1[tperiod1][signalscount1[tperiod1]][1]=signals[tperiod1][u][u3][1];
          signals1[tperiod1][signalscount1[tperiod1]][2]=signals[tperiod1][u][u3][2];
          signals1[tperiod1][signalscount1[tperiod1]][3]=signals[tperiod1][u][u3][3];
          signals1[tperiod1][signalscount1[tperiod1]][4]=signals[tperiod1][u][u3][4];
          signals1[tperiod1][signalscount1[tperiod1]][5]=signals[tperiod1][u][u3][5];
          signalscount1[tperiod1]=signalscount1[tperiod1]+1;        
      }
   }
}
//=========== S O R T =============== 

 string signals2[4][30][6];
 for(int tperiod1=0; tperiod1<4; tperiod1++){
   for(i=0; i<signalscount1[tperiod1]; i++){
     signals2[tperiod1][i][0]=signals1[tperiod1][i][0];
     signals2[tperiod1][i][1]=signals1[tperiod1][i][1];
     signals2[tperiod1][i][2]=signals1[tperiod1][i][2];
     signals2[tperiod1][i][3]=signals1[tperiod1][i][3];
     signals2[tperiod1][i][4]=signals1[tperiod1][i][4];
     signals2[tperiod1][i][5]=signals1[tperiod1][i][5];
   }
   i0=0;
   for(i=0; i<signalscount1[tperiod1]; i++){
     double i3=-99999;
     for(i1=0; i1<signalscount1[tperiod1]; i1++){
       if( StringToDouble(signals2[tperiod1][i1][3]) > i3){
         i3 = StringToDouble(signals2[tperiod1][i1][3]);
         i2=i1;
       }
     }
     signals1[tperiod1][i0][0]=signals2[tperiod1][i2][0];
     signals1[tperiod1][i0][1]=signals2[tperiod1][i2][1];
     signals1[tperiod1][i0][2]=signals2[tperiod1][i2][2];
     signals1[tperiod1][i0][3]=signals2[tperiod1][i2][3];
     signals1[tperiod1][i0][4]=signals2[tperiod1][i2][4];
     signals1[tperiod1][i0][5]=signals2[tperiod1][i2][5];     
     i0++;
     signals2[tperiod1][i2][3]=DoubleToString(-100000);
   }   
  } 
//=========== B A C K U P ===============   
if(firststart==0){
 string signal_alert="";
 for(int tperiod1=0; tperiod1<4; tperiod1++){
   for(i=0; i<signalscount3[tperiod1]; i++){
      int finded_symbol=0;
      for(i1=0; i1<signalscount1[tperiod1]; i1++)
        if( (signals3[tperiod1][i][1]==signals1[tperiod1][i1][1]) //&&
            //(signals3[tperiod1][i][2]==signals1[tperiod1][i1][2])
            ){
              int finded_symbol3=0;
              for(i2=0;i2<4;i2++)
              if(StringGetChar(signals3[tperiod1][i][4],i2) == StringGetChar(signals1[tperiod1][i1][4],i2))
              finded_symbol3 = 1;
              else
              if(StringGetChar(signals3[tperiod1][i][4],i2) == '0')finded_symbol3 = 1;
              finded_symbol = finded_symbol3;
            }
      if(finded_symbol==0)
       signal_alert=signals3[tperiod1][i][0]+" "+signals3[tperiod1][i][1]+" "+signals3[tperiod1][i][2]+" : "+signals3[tperiod1][i][3]+" "+signals3[tperiod1][i][4]+" "+signals3[tperiod1][i][5]+"\r\n"+signal_alert;
   }
 } 
 if(StringLen(signal_alert)>3){
   Alert(signal_alert);
   int filehandle=FileOpen("signals.txt",FILE_READ|FILE_WRITE|FILE_TXT);
   FileSeek(filehandle,0,SEEK_END); 
   FileWriteString(filehandle,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)+ "\r\n"+signal_alert+"\r\n");
   FileClose(filehandle);
 }
} 
firststart=0;
 for(int tperiod1=0; tperiod1<4; tperiod1++){
   for(i=0; i<signalscount1[tperiod1]; i++){
     signals3[tperiod1][i][0]=signals1[tperiod1][i][0];
     signals3[tperiod1][i][1]=signals1[tperiod1][i][1];
     signals3[tperiod1][i][2]=signals1[tperiod1][i][2];
     signals3[tperiod1][i][3]=signals1[tperiod1][i][3];
     signals3[tperiod1][i][4]=signals1[tperiod1][i][4];
     signals3[tperiod1][i][5]=signals1[tperiod1][i][5];   
   }
   signalscount3[tperiod1]=signalscount1[tperiod1];
 }

  
//====================================================
ObjectSetString(current_chart_id,"ObjDTime",OBJPROP_TEXT,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS));

 for(i=0; i<30; i++)for(i1=0; i1<4; i1++)ObjectSet("Obj"+i1+"_"+i,OBJPROP_XDISTANCE,2180);
 
 //--- перемещение объекта label и изменение его текста 
   for(int tperiod1=0; tperiod1<4; tperiod1++) 
   for(i=0; i<signalscount1[tperiod1]; i++) 
     { 
      if(!ObjectCreate(current_chart_id,"Obj"+tperiod1+"_"+i,OBJ_LABEL,0,0,0)) 
      { 
       Print("Ошибка создания объекта: code #",GetLastError()); 
      } 
      //-- устанавливаем текст объекта 
      ObjectSetString(current_chart_id,"Obj"+tperiod1+"_"+i,OBJPROP_TEXT,signals1[tperiod1][i][0]+" "+StringFormat(" %s :",signals1[tperiod1][i][1] ) + " " + signals1[tperiod1][i][3]+ " " + signals1[tperiod1][i][4]+ " " + signals1[tperiod1][i][5] ); //signals1[tperiod1][i][1]
      //-- устанавливаем значение координаты Y 
      ObjectSet("Obj"+tperiod1+"_"+i,OBJPROP_YDISTANCE,15+i*15); 
      ObjectSet("Obj"+tperiod1+"_"+i,OBJPROP_XDISTANCE,tperiod1*180);
//--- устанавливаем цвет Red 
     
       if(signals1[tperiod1][i][2]=="BUY"){
          ObjectSetInteger(current_chart_id,"Obj"+tperiod1+"_"+i,OBJPROP_COLOR,clrAqua); 
        }
       else {
          ObjectSetInteger(current_chart_id,"Obj"+tperiod1+"_"+i,OBJPROP_COLOR,clrRed);    
       }
  
     
      //-- перерисовка графика 
      ChartRedraw(current_chart_id); 
     }      
     

  // Sleep(1);
  // return(0); 
  }