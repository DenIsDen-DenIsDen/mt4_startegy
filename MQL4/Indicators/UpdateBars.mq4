//+------------------------------------------------------------------+
//|                                                   UpdateBars.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string config[200][9];
int cindex,cindex1=0,cindex2=1;
int bars;
bool barsupdated=true;
bool filessaved=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
string GetElement(string str, int index){

   string arr[];
   StringSplit(str,' ',arr);
   return arr[index];
}
int OnInit()
  {
//--- indicator buffers mapping
   int filehandle;
   string str1;
   filehandle=FileOpen("settings.txt",FILE_READ|FILE_TXT);
   FileSeek(filehandle,0,SEEK_SET);
   str1=FileReadString(filehandle);
   FileClose(filehandle);
   bars=StringToInteger(GetElement(str1,0));
   filehandle=FileOpen(GetElement(str1,2),FILE_READ|FILE_TXT);
   FileSeek(filehandle,0,SEEK_SET);
   string tmp01;
   int tmp02=0;
   if(filehandle!=INVALID_HANDLE)
     {
      while(tmp02==0)
        {
         if(!FileIsEnding(filehandle))
           {
            config[cindex1][cindex2]=FileReadString(filehandle);
            cindex2++;
            config[cindex1][0]="0";
            tmp01="1";
            while(StringLen(tmp01)>0)
              {
               tmp01=FileReadString(filehandle);
               if(StringLen(tmp01)>0)
                 {
                  config[cindex1][cindex2]=tmp01;
                  cindex2++;
                  config[cindex1][0]=IntegerToString(StringToInteger(config[cindex1][0])+1);
                 }
              }
            if(FileIsEnding(filehandle))tmp02=1;
               cindex1++;cindex2=1;
               
           }
        }
        cindex=cindex1;
     }
     FileClose(filehandle);  
//---
   double i3;
   for(int i2=0;i2<cindex;i2++)
   for(int i5=0;i5<StringToInteger(config[i2][0]);i5++)
   {for(int i4=0;i4<=bars;i4++)i3=iClose(config[i2][1],StringToInteger(GetElement(config[i2][i5+2],0)),i4);}
   
   EventSetTimer(60); 
   return(INIT_SUCCEEDED);
  }
void FilesDelete() 
  { 
   string   file_name;      // переменная для хранения имен файлов 
   string   filter="hst\\*.hst"; // фильтр для поиска файлов 
   datetime create_date;    // дата создания файла 
   string   files[];        // список имен файлов 
   int      def_size=2500;    // размер массива по умолчанию 
   int      size=0;         // количество файлов 
//--- выдели память для массива 
   ArrayResize(files,def_size); 
//--- получение хэндла поиска в корне локальной папки 
   long search_handle=FileFindFirst(filter,file_name); 
//--- проверим, успешно ли отработала функция FileFindFirst() 
   if(search_handle!=INVALID_HANDLE) 
     { 
      do 
        { 
         files[size]=file_name; 
         size++; 
         if(size==def_size) 
           { 
            def_size+=25; 
            ArrayResize(files,def_size); 
           } 
         ResetLastError(); 
         FileDelete("hst\\"+file_name); 

        } 
      while(FileFindNext(search_handle,file_name)); 
      FileFindClose(search_handle); 
     } 
   else 
     { 
      return; 
     } 
  }
void SaveHistory(string sm, int period0){
  int digits=MarketInfo(sm,MODE_DIGITS);
  int ExtHandle=-1;
SymbolSelect(sm,true);
   
   
   //return;
   
   ExtHandle=FileOpen("hst\\"+sm+period0+".hst",FILE_BIN|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   FileWriteInteger(ExtHandle,digits);
   for(int i=bars-1;i>=0;i--){
      FileWriteInteger(ExtHandle,iTime(sm,period0,i));
      FileWriteDouble(ExtHandle,iOpen(sm,period0,i));
      FileWriteDouble(ExtHandle,iHigh(sm,period0,i));
      FileWriteDouble(ExtHandle,iLow(sm,period0,i));
      FileWriteDouble(ExtHandle,iClose(sm,period0,i));
      FileWriteDouble(ExtHandle,iVolume(sm,period0,i));
   }
   FileClose(ExtHandle);
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
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---


   barsupdated=true;
   int i,i1,i2,i4;double i3;string mode;int x=0,y=0;
   for(i=0;i<cindex;i++){
      for(i2=0;i2<StringToInteger(config[i][0]);i2++)
      {
         mode=""+config[i][1]; SymbolSelect(mode,true);
         if(ObjectFind(ChartID(),mode)<0)ObjectCreate(mode, OBJ_LABEL, 0,0,0);
         ObjectSet(mode, OBJPROP_CORNER, 0);
         ObjectSet(mode, OBJPROP_XDISTANCE, x*100);
         ObjectSet(mode, OBJPROP_YDISTANCE, 20+y*15);
         
         i1=0;
         //while(i1<bars){
            for(i4=0;i4<=bars;i4++)i3=iClose(mode,StringToInteger(GetElement(config[i][i2+2],0)),i4);//iMA(mode,tfs[i2],3,0,MODE_SMA,PRICE_CLOSE,bars+1);
            i1=StringToInteger(iBars(mode,GetElement(config[i][i2+2],0)));
            if(i1>=bars){ObjectSetText(mode,mode+" : "+GetElement(config[i][i2+2],0)+" "+i1, 8, "Arial Narrow", clrGreen);
            
            }
            else {
               ObjectSetText(mode,mode+" : "+GetElement(config[i][i2+2],0)+" "+i1, 8, "Arial Narrow", clrGray);
               barsupdated=false;
               break;
           //    Sleep(1000);
            }
         //}
         
      }
      y=y+1; if(y==30){y=0;x=x+1;}
   }
   if(barsupdated&&!filessaved){
     //FilesDelete();
     //for(i=0;i<cindex;i++)
     // for(i2=0;i2<ArraySize(tfs);i2++)
     //   SaveHistory(config[i],tfs[i2]); filessaved=true;
     
      mode="Status";
      if(ObjectFind(ChartID(),mode)<0)ObjectCreate(mode, OBJ_LABEL, 0,0,0);
      ObjectSet(mode, OBJPROP_CORNER, 0);
      ObjectSet(mode, OBJPROP_XDISTANCE, 110);
      ObjectSet(mode, OBJPROP_YDISTANCE, 0);

      ObjectSetText(mode,"saved "+TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS), 8, "Arial Narrow", clrRed);
     
   }   
  }
//+------------------------------------------------------------------+
