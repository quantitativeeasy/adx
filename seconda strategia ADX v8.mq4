//+------------------------------------------------------------------+
//|                                     seconda strategia ADX v8.mq4 |
//|                                                             Max. |
//|                                                    semper_ca_mia |
//+------------------------------------------------------------------+
//V1 deriva dalla strategia ADX v13
//V2 introduco stop loss e secondo frattale oltre a messaggistica
//V3 riporto in ordersend anche SL e TP
//V3 inserisco il controllo market sulla distanza minima in punti

#property copyright "Max."
#property link      "semper_ca_mia"
#property version   "1.00"
#include <stderror.mqh>
#include <stdlib.mqh> 
//#include <Events_corretto.mq4>
#include <cancella ordini.mq4>
//#include <modifica stop loss.mq4>
#include <secondo fractal.mq4>
#include <ADX calcola ordini.mq4> //effettua le modifiche agli stop loss sul secondo ordine
//#include <modifica ordini TP.mq4>

extern int MagicNumber= 9;
extern double lotsize = 0.01;
extern int canc_down = 40;
extern int ADX_shift =1;//imposta lo schift dell'ADX la strategia originale prevede valore 1; 0 anticipa ordine
extern int pip_per = 1;//imposta il numero di pip che saranno il settaggio del valore di stop (buy o sell)
//extern int proc_min_sl = 0;//se messo a 1 abilita la procedura che blocca il guadagno
extern int min_profit = 4;//imposta il valore minimo di profitto per cui imposto lo stop loss bloccando il guadagno espresso in Pip
extern int min_profit_SL = 1;//imposta il valore minimo di stop loss bloccando il guadagno espresso in Pip
extern int proc_sec_fr = 0;//se messo a 1 abilita la pocedura secondo fractal
extern int point_min = 0;//inserire la distanza minima a seconda del valore richiesto dal simbolo Es. petrolio=5

static double takeprofit=50;
static double stoploss=50;
static int ord_long_ins=0;
static int ord_short_ins=0;
static double corr_TP=0.001;
static double corr_SL=0.001;
static int ticket1;
static int ticket2;
static int ticket3;
static int ticket4;
static int ticket5;
static int ticket6;
static int ticket7;//secondo ordine buy quando subentra un secondo fractal
static int ticket8;//secondo ordine short quando subentra un secondo fractal
static int pos_ap_long;
static int pos_ap_short;



static int sl_clr_l=0;
static int sl_clr_s=0;
static int tp_clr_l=0;
static int tp_clr_s=0;
static int set_clr_l=0;
static int set_clr_s=0;

static int ordine_TP;
static string data_stringa="1970.01.01 00:00:00";

static double ADXMinus= 0;
static double ADXPlus = 0;
static double ADXMain = 0;

static double ADXMinus_1= 0;
static double ADXPlus_1 = 0;
static double ADXMain_1 = 0;



static double Poin;
static int stop_40;
static int stop_main_short= 0;
static int stop_main_long = 0;
static int ordine_attivo_l=0;
static int ordine_attivo_s=0;
static int stop_loop_sl_l=0;
static int stop_loop_sl_s=0;
static string periodo=" ";    

static int tipo_cancellazione = 1;//1 buy, 2 sell, 3 all
static int ord_symbol_fl=0;

   static double max_setup;
   static double min_setup;
   static double TP_long;
   static double TP_short;
//   static double TP_long_m;
//   static double TP_short_m;
   static int n,UpperFractal_1,LowerFractal_1;//contiene il numero della candela
   static int n_fl,UpperFractal_fl,LowerFractal_fl;//contenuto nella procedura secondo fractal 
   static double val_upper,val_lower;//contiene il valore della candelarelativa al frattale individuato
   static double val_upper_fl,val_lower_fl;//contenuto nella procedura secondo fractal
   static int st_level;//contiene il valore dello stop level per sistemare il valore di ingresso degli ordini 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   double Poin1;if(Point==0.00001) Poin1=0.0001;
   else
      if(Point==0.0001) Poin1=0.0001;
   else
      if(Point==0.001) Poin1=0.001;
   else
      if(Point==0.01) Poin1=0.01;
   else
      if(Point==0.1) Poin1=0.1;
   else
      if(Point==1) Poin1=1;                    
;
   Poin=Poin1;
   

   int aia=Period();
   switch(aia)
     {
      case 1:
         periodo="M1";break;
      case 5:
         periodo="M5";break;
      case 15:
         periodo="M15";break;
      case 30:
         periodo="M30";break;                  
      case 60:
         periodo="H1";break;        
      case 240:
         periodo="H4";break;
      case 1440:
         periodo="D1";break;      
      case 10080:
         periodo="W1";break;         
      case 43200:
         periodo="MN1";break;                  
     }

}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   st_level=MarketInfo(Symbol(),MODE_STOPLEVEL);
   int ADX=14;//questo valore deve essere settato a 14 per il corretto calcolo dei valori
   set_clr_l=0;
   set_clr_s=0; 
         ADX_calcola_ordini(MagicNumber);//chiamata alla routine di sistemazione TP secondo ordine



   ADXMain=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_MAIN,ADX_shift); //Base indicator line  BLUE
   ADXMinus=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_MINUSDI,ADX_shift); //-DI indicator line RED
   ADXPlus=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_PLUSDI,ADX_shift); //+DI indicator line GREEN

   ADXMain_1=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_MAIN,ADX_shift+1); //Base indicator line  BLUE
   ADXMinus_1=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_MINUSDI,ADX_shift+1); //-DI indicator line RED
   ADXPlus_1=iADX(Symbol(),0,ADX,PRICE_CLOSE,MODE_PLUSDI,ADX_shift+1); //+DI indicator line GREEN
   
 //setto il parametro di setup prezzo per settare o meno il settaggio di SL al minimo sul guadagno
 //  if(proc_min_sl==1)modifica_ordini_sl(MagicNumber);
 //fine settaggio parametro 

//setto il parametro di setup prezzo per anticipare o mantenere la strategia
        if(ADX_shift==0)
            {
               max_setup=Ask+(Poin*pip_per);//valore ingresso Buystop
               min_setup=Bid-(Poin*pip_per);//valore ingresso Sellstop          
            }           
         else
            {               
               max_setup=iHigh(Symbol(),0,1);//massimo di Candela di setup dell'ADX
               min_setup=iLow(Symbol(),0,1);//minimo di Candela di setup dell'ADX                                      
            } 





//
// Cancello ordini se il blu è sopra 40 e scende oppure secondo parametrizzazione 
   if(ADXMain>canc_down && ADXMain<ADXMain_1 && stop_40==0)//Condizione per cancellazione ordini
     {
     
      Print("Main sopra il 40 e in discesa cancello ordini");
      stop_40=1;
      tipo_cancellazione=3;
      cancella_ordini(MagicNumber,tipo_cancellazione);
      stop_main_long=0;
      stop_main_short=0;
      pos_ap_long=0;
      pos_ap_short=0;
     }
// fine gestione cancellazione ordini su discesa blu   
//


   if(ADXPlus_1<ADXMinus_1 && ADXPlus>ADXMinus && ADXMain<=40 && ord_long_ins==0)//Incrocio long
     {
   Print ("sono in long:",Symbol());
      stop_40=0;//resetto il controllo sopra i 40
      stop_loop_sl_l=0;//resetto gestione stop loss


      //
      //--- finding the bar index of the first nearest lower fractal and take profit
      for(n=0; n<(Bars-1);n++)
        {
         if(iFractals(NULL,PERIOD_CURRENT,MODE_LOWER,n)!=NULL)
            break;
         LowerFractal_1=n+1;
        }
      val_lower=Low[LowerFractal_1];

      // fine zona calcolo frattale
      //
      ord_long_ins =1;  //setto a 1 per bloccare l'accesso alla routine Long
      ord_short_ins =0; // setto a 0 per abilitare la controparte Short qualora avesse già operato
      int total_l=OrdersTotal();


      // controllo se ci sono ordini aperti per Stop & Reverse e li chiudo
      //    Print("Orderstotal+++++++++++++++++++++++++++++++++++++++++++++++++= "+total_l);
      if(total_l>0)
        {
         tipo_cancellazione=2;//cancello gli ordini inversi
         cancella_ordini(MagicNumber,tipo_cancellazione);
         stop_main_long=0;
         pos_ap_long=0;
         pos_ap_short=0;
         
        }
            if(max_setup<Ask) set_clr_l=(Ask-max_setup);//correggo nel caso sia basso        
            TP_long=(max_setup-val_lower)+max_setup;
//            TP_long_m = max_setup+Poin+set_clr_l;           
      //-------------------------------------------------                             
      if(ADXMain<25)//Inserisco 2 ordini                                    
        {
        pos_ap_long=2;
        pos_ap_short=0;
        
         //-------------------------------------------------
      stop_main_long=1;//setto il controllo del take profit
         for(int ia=0;ia<5;ia++)
           {
            RefreshRates();
            ticket1=OrderSend(Symbol(),OP_BUYSTOP,lotsize,max_setup+Point+point_min+set_clr_l,2,val_lower-Poin+point_min+set_clr_l,TP_long+Poin+point_min+set_clr_l,("Str. ADX "+periodo+" 2ord"),MagicNumber,0,clrGreen);
                      Print("reali L_ticket1**Set="+(max_setup)+" SL="+(val_lower)+" TP="+TP_long+" Ask="+Ask+" Bid="+Bid);

            if(ticket1>0)
              {
               Alert("buystop order successful ticket1= "+ticket1);
               break;
              }
            else
              {
               Alert("error opening buy order, error code = ",ErrorDescription(GetLastError()),"  ticket1="+ticket1);
               Print("long error ticket1="+ticket1+"  Set="+(max_setup+Poin+set_clr_l)+" Ask="+Ask+" Bid="+Bid+" set_clr_l = "+set_clr_l);
              }
            Sleep(1000);
            RefreshRates();
           }
  
         //----------------------------------------------                             
         for(int ie=0;ie<5;ie++)
           {
            RefreshRates();
            if(max_setup<Ask) set_clr_l=(Ask-max_setup);//correggo nel caso sia basso                                                   
            ticket2=OrderSend(Symbol(),OP_BUYSTOP,lotsize,max_setup+Poin+point_min+set_clr_l,2,val_lower-Poin+point_min+set_clr_l,0,("Str. ADX "+periodo+" 2ord"),MagicNumber,0,clrGreen);




            //        Print(" L_ticket2**Set="+(max_setup)+" SL="+(val_lower)+" TP="+TP_long+" Ask="+Ask+" Bid="+Bid);
//            Print("reali L_ticket2**Set="+(max_setup)+" SL="+(val_lower)+" Ask="+Ask+" Bid="+Bid+" set_clr_l"+set_clr_l);

            if(ticket2>0)
              {
               Alert("buystop order successful ticket2= "+ticket2);
               break;
              }
            else
              {
               Alert("error opening buy order error code = ",ErrorDescription(GetLastError()),"  ticket2="+ticket2);
               Print("long error ticket2="+ticket2+"  Set="+(max_setup+Poin+set_clr_l)+" Ask="+Ask+" Bid="+Bid+" set_clr_l = "+set_clr_l);
              }
            Sleep(1000);
            RefreshRates();
           }

        }
      else if(ADXMain>25 && ADXMain<=40) //Inserisco 1 ordine
        {
        pos_ap_long=1;
        pos_ap_short=0;
         for(int ic=0;ic<5;ic++)
           {
            RefreshRates();
            if(max_setup<Ask) set_clr_l=(Ask-max_setup);//correggo nel caso sia basso                             
            ticket3=OrderSend(Symbol(),OP_BUYSTOP,lotsize,max_setup+Poin+point_min+set_clr_l,2,val_lower-Poin+point_min+set_clr_l,TP_long+Poin+point_min+set_clr_l,("Str. ADX "+periodo+" 1ord"),MagicNumber,0,clrGreen);

            Print("reali L_ticket3**Set="+(max_setup)+" SL="+(val_lower)+" TP="+TP_long+" Ask="+Ask+" Bid="+Bid+" set_clr_l"+set_clr_l);

            if(ticket3>0)
              {
               Alert("buystop order successful ticket3= "+ticket3);
               break;
              }
            else
              {
               Alert("error opening buy order, error code = ",ErrorDescription(GetLastError()),"  ticket3="+ticket3);
               Print("long error ticket3="+ticket3+"  Set="+(max_setup+Poin+set_clr_l)+" Ask="+Ask+" Bid="+Bid+" set_clr_l = "+set_clr_l);
              }
            Sleep(3000);
            RefreshRates();
           }

        }
     }
// fine ciclo long

// inizio ciclo short  
   else if(ADXPlus_1>ADXMinus_1 && ADXPlus<ADXMinus && ADXMain<=40 && ord_short_ins==0)//Incrocio short

     {
        Print ("sono in short:",Symbol());
      stop_40=0;//resetto il controllo sopra i 40
      stop_loop_sl_s=0;//resetto gestione stop loss

      //--- finding the bar index of the first nearest upper fractal and take profit
      for(n=0; n<(Bars-1);n++)
        {
         if(iFractals(NULL,PERIOD_CURRENT,MODE_UPPER,n)!=NULL)
            break;
         UpperFractal_1=n+1;
        }
      val_upper=High[UpperFractal_1];

            
      //---fine zona calcolo frattale     

      ord_short_ins =1; // setto a 1 per bloccare l'accesso alla routine Short    
      ord_long_ins =0;  // setto a 0 per abilitare la controparte Long qualora avesse già operato
      int total_s=OrdersTotal();

      // controllo se ci sono ordini aperti per il primo ordine
      if(total_s>0)
        {
         tipo_cancellazione=1;//cancello gli ordini inversi
         cancella_ordini(MagicNumber,tipo_cancellazione);
         stop_main_short=0;
         pos_ap_long=0;
         pos_ap_short=0;                                       
        }
      if(min_setup>Bid) set_clr_s=(min_setup-Bid);//correggo nel caso sia basso     
      TP_short=min_setup-(val_upper-min_setup);
//      TP_short_m = min_setup-Poin-set_clr_s;    

      //MessageBox("SHORT ADXMinus="+ADXMinus+"  ADXPlus="+ADXPlus+"  ADXMain"+ADXMain+"ADXMinus_1="+ADXMinus_1+"  ADXPlus_1="+ADXPlus_1+"  ADXMain_1"+ADXMain_1);
      //      Print("SHORT ADXMinus="+ADXMinus+"  ADXPlus="+ADXPlus+"  ADXMain"+ADXMain+"ADXMinus_1="+ADXMinus_1+"  ADXPlus_1="+ADXPlus_1+"  ADXMain_1"+ADXMain_1);

      if(ADXMain<25)//Inserisco 2 ordini

        {
        pos_ap_long=0;
        pos_ap_short=2;
      stop_main_short=1;//setto il controllo del take profit
         for(int ig=0;ig<5;ig++)
           {
            RefreshRates();

                            
            ticket4=OrderSend(Symbol(),OP_SELLSTOP,lotsize,min_setup-Poin-point_min-set_clr_s,2,val_upper+Poin+point_min-set_clr_s,TP_short-Poin-point_min-set_clr_l,("Str. ADX "+periodo+" 2ord"),MagicNumber,0,clrRed);


            //                 Print("reali S_ticket4**Set="+min_setup+" SL="+val_upper+" TP="+TP_short+" Ask="+Ask+" Bid="+Bid);
            Print("reali S_ticket4**Set="+min_setup+" SL="+val_upper+" TP="+TP_short+" Ask="+Ask+" Bid="+Bid+" set_clr_s="+set_clr_s);
            //                                                 Print ("ticket4 porca vacca"+ticket4);                 
            if(ticket4>0)
              {
               Alert("sellstop order successful ticket4= "+ticket4);
               break;
              }
            else
              {
               Alert("error opening sell order, error code = ",ErrorDescription(GetLastError()),"  ticket4="+ticket4);
               Print("short error ticket4="+ticket4+"  Set="+(min_setup-Poin-set_clr_s)+" Ask="+Ask+" Bid="+Bid+" set_clr_s = "+set_clr_s);
              }
            Sleep(3000);
            RefreshRates();
           }

         //---------------------------------------------- 
         for(int ih=0;ih<5;ih++)
           {
            RefreshRates();
            if(min_setup>Bid) set_clr_s=(min_setup-Bid);//correggo nel caso sia basso                             
            ticket5=OrderSend(Symbol(),OP_SELLSTOP,lotsize,min_setup-Poin-point_min-set_clr_s,2,val_upper+Poin+point_min,0,("Str. ADX "+periodo+" 2ord"),MagicNumber,0,clrRed);

 //           Print("reali S_ticket5**Set="+min_setup+" SL="+val_upper+" Ask="+Ask+" Bid="+Bid+" set_clr_s="+set_clr_s);
            //             Print("reali S_ticket5**Set="+min_setup+" SL="+val_upper+" Ask="+Ask+" Bid="+Bid);   

            if(ticket5>0)
              {
               Alert("sellstop order successful ticket5= "+ticket5);
               break;
              }
            else
              {
               Alert("error opening sell order, error code = ",ErrorDescription(GetLastError()),"  ticket5="+ticket5);
               Print("short error ticket5="+ticket5+"  Set="+(min_setup-Poin-set_clr_s)+" Ask="+Ask+" Bid="+Bid+" set_clr_s = "+set_clr_s);
              }
            Sleep(3000);
            RefreshRates();
           }

        }
      else if(ADXMain>25 && ADXMain<=40) //Inserisco 1 ordine
        {
        pos_ap_long=0;
        pos_ap_short=1;
         for(int il=0;il<5;il++)
           {
            RefreshRates();
            if(min_setup>Bid) set_clr_s=(min_setup-Bid);//correggo nel caso sia basso                           
            ticket6=OrderSend(Symbol(),OP_SELLSTOP,lotsize,min_setup-Poin-point_min-set_clr_s,2,val_upper+Poin+point_min-set_clr_s,TP_short-Poin-point_min-set_clr_l,("Str. ADX "+periodo+" 1ord"),MagicNumber,0,clrRed);

//            _ticket6=OrderTicket();
            Print("reali S_ticket6**Set="+min_setup+" SL="+val_upper+" TP="+TP_short+" Ask="+Ask+" Bid="+Bid+" set_clr_s="+set_clr_s);
            //                                                                              Print ("_ticket6 porca vacca"+_ticket6); //max                          
            if(ticket6>0)
              {
               Alert("sellstop order successful ticket6= "+ticket6);
               break;
              }
            else
              {
               Alert("error opening sell order, error code = ",ErrorDescription(GetLastError()),"  ticket6="+ticket6);
               Print("short error ticket6="+ticket6+"  Set="+(min_setup-Poin-set_clr_s)+" Ask="+Ask+" Bid="+Bid+" set_clr_s = "+set_clr_s);
              }
            Sleep(3000);
            RefreshRates();
           }

        }

     }
//end ADX
 //setto il parametro di setup prezzo per abilitare o meno la procedura secondo fractal
   if(proc_sec_fr==1)secondo_fractal(MagicNumber);
 //fine settaggio parametro

  }
//+------------------------------------------------------------------+
