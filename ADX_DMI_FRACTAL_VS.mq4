//+------------------------------------------------------------------+
//|                                                adx_corso_tsa.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Ale"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

#include <funzioni_fractals.mqh>

#import "user32.dll"
   int MessageBoxW(int Ignore, string Caption, string Title, int Icon);
#import


double   lineaADX = 0.0;  // Valore dell' ADX sull'ultima candela chiusa

double   lineaDIMinus[10]; // Valore indicatore D-
double   lineaDIPlus[10];  // Valore indicatore D+

extern int periodoADX = 14;
extern double  numeroLotti= 0.2;
extern int valoreMassimoADX = 50;
extern int  numeroPip = 3;
extern int numeroMagico = 123;


datetime oldTime = Time[0] ;


int OnInit()
  {
               


   return(INIT_SUCCEEDED);
  }



void OnTick()
  {
     if (NuovaCandela())   // C'è una nuova candela ??? si ! allora entra a mercato ( stop, pending etc...)
      {
      
         Print("Nuova Candela ");
         
         lineaADX  = iADX(NULL,0,periodoADX,PRICE_CLOSE,MODE_MAIN,1); // Funzione che mi restituisce il valore dell' ADX
         Print("ADX = ",lineaADX);
         
         
         
       
         
         
       //  Print("cerco il Primo fractal per stop loss posizione long  = ",ritracciamentoFractal(MODE_LOWER));
       //  Print("cerco ilPrimo fractal per stop loss posizione Short  = ",ritracciamentoFractal(MODE_UPPER));
       
       
       
         
       // ----------------------SPOSTO STOP LOSS SEGUENDO FRACTAL----------------------------------------
       
           
         if(TotaleOrdiniAperti() > 0)
           {
            Print(" Spostiamo sl a nuovo fractal");
              
               int ordiniAperti = OrdersTotal(); // Valorizzo tutti gli ordini aperti 
               
               for (int i=ordiniAperti-1; i>=0; i--)
                { 
                     OrderSelect(i, SELECT_BY_POS,MODE_TRADES); // Seleziono l' ordine prima di lavorarci sopra

                     if (OrderMagicNumber() == numeroMagico && OrderType() ==OP_BUY && OrderStopLoss() != ritracciamentoFractal(MODE_LOWER)) 
                        {
                           Print(" Modifico SL long");
                           OrderModify(OrderTicket(),OrderLots(),ritracciamentoFractal(MODE_LOWER),0,Red);    // Sposto SL nuovo Fractal
                        
                        }
                      else if(OrderMagicNumber() == numeroMagico && OrderType() ==OP_SELL && OrderStopLoss() != ritracciamentoFractal(MODE_UPPER))
                             {
                             Print(" Modifico SL Short");
                              OrderModify(OrderTicket(),OrderLots(),ritracciamentoFractal(MODE_UPPER),0,Red);    // Sposto SL nuovo Fractal
                             }                         
               } // Fine Ciclo FOR
            
            
            
           }
         
         
         
         
         
         //------------------------------------------------------------------
         
         
         // Stop and Reversal -> Chiudo posizioni aperte e apro le nuove
         // -----------------------------------------------------------------
         
         
         // Qui gestiamo la chiusura delle operazioni in essere lineaADX > 30 && 
           
           if(
               
                TotaleOrdiniAperti()>0 &&
                 (
                
                   (lineaADX > valoreMassimoADX && UscitaADX()) || Cross() == "short"
                
                  ) 
              )  // Chiudiamo posizione Long perchè c'è un incrocio contrario
             
             {
               Print("Totale ORdini aperti = ",TotaleOrdiniAperti(), " UscitaADx " ,UscitaADX()," Linea ADX = ",lineaADX);
               Print("incrocio ? " +Cross()); 
               Print(" Chiudiamo posizione Long");  
               int ordiniAperti = OrdersTotal(); // Valorizzo tutti gli ordini aperti 
               
               for (int i=ordiniAperti-1; i>=0; i--)
                { 
                     OrderSelect(i, SELECT_BY_POS,MODE_TRADES); // Seleziono l' ordine prima di lavorarci sopra

                     if (OrderMagicNumber() == numeroMagico && OrderType() == OP_BUY) 
                        OrderClose(OrderTicket(),OrderLots(),Bid,0,Red);    // Chiudo buy
                     else if (OrderMagicNumber() == numeroMagico && OrderType() == OP_BUYSTOP) 
                        OrderDelete(OrderTicket(),Red);

               } // Fine Ciclo FOR
            } // Fine if Chiudo posizioni long
            
            
           else  if(TotaleOrdiniAperti()>0 &&
                 (
                
                   (lineaADX > valoreMassimoADX && UscitaADX()) || Cross() == "long"
                
                  )
                )  // Chiudiamo posizione Short perchè c'è un incrocio contrario
             
             
             {
                Print("Totale ORdini aperti = ",TotaleOrdiniAperti(), " UscitaADx " ,UscitaADX()," Linea ADX = ",lineaADX);
               Print("incrocio ? "+ Cross());  
               Print(" Chiudiamo posizione Short");  
               int ordiniAperti = OrdersTotal(); // Valorizzo tutti gli ordini aperti 
               
               for (int i=ordiniAperti-1; i>=0; i--)
                { 
                     OrderSelect(i, SELECT_BY_POS,MODE_TRADES); // Seleziono l' ordine prima di lavorarci sopra

                     if (OrderMagicNumber() == numeroMagico && OrderType() == OP_SELL) 
                        OrderClose(OrderTicket(),OrderLots(),Ask,0,Red);    // Chiudo Sell
                      else if (OrderMagicNumber() == numeroMagico && OrderType() == OP_SELLSTOP)
                        OrderDelete(OrderTicket(),Red);

               } // Fine Ciclo FOR
            } // Fine if Chiudo posizioni long
         
         
         
         
         
         
         
         
         
         
         // -----------------------------------------------------------------
         
         
         
         
         
          if((lineaADX > 25 && lineaADX <valoreMassimoADX) && Cross() == "long" && TotaleOrdiniAperti()== 0 ) // ADX Compreso tra 25 e 40, incrocio long e nessun ordine aperto
           {
               Print("Entriamo Long con 1/2 posizione ");
              OrderSend(NULL,OP_BUYSTOP,(numeroLotti/2),High[1]+numeroPip*Point,0,ritracciamentoFractal(MODE_LOWER),0,NULL,numeroMagico,0,clrNONE);
           }
         
           if((lineaADX > 25 && lineaADX <valoreMassimoADX) && Cross() == "short" && TotaleOrdiniAperti()== 0) // ADX Compreso tra 25 e 40, incrocio short e nessun ordine aperto
           {
           
            Print("Entriamo Short con 1/2 posizione");
               OrderSend(NULL,OP_SELLSTOP,(numeroLotti/2),Low[1]-numeroPip*Point,0,ritracciamentoFractal(MODE_UPPER),0,NULL,numeroMagico,0,clrNONE);
           }
           
            if((lineaADX < 25) && Cross() == "long" && TotaleOrdiniAperti()== 0 )// ADX < 25, incrocio long e nessun ordine aperto
           {
               Print("Entriamo Long con 1 posizione");
              OrderSend(NULL,OP_BUYSTOP,numeroLotti,High[1]+numeroPip*Point,0,ritracciamentoFractal(MODE_LOWER),0,NULL,numeroMagico,0,clrNONE);
           }
           
         
         if((lineaADX < 25 ) && Cross() == "short" && TotaleOrdiniAperti()== 0)// ADX < 25 , incrocio short e nessun ordine aperto
           {
           
            Print("Entriamo Short con 1 posizione");
               OrderSend(NULL,OP_SELLSTOP,numeroLotti,Low[1]-numeroPip*Point,0,ritracciamentoFractal(MODE_UPPER),0,NULL,numeroMagico,0,clrNONE);
           }
           
           
            
            
            
            
     
      } // Fine if NuovaCandela()
 
  }

bool  NuovaCandela()

{
 if(oldTime!= Time[0])
        {
         oldTime = Time[0];
         Print("Ora ho cambiato il valore di Oldtime col valore corrente = " , oldTime);
         
         return true;
         
        }
   return false;
}


string   Cross()
{
   

   for(int i=1;i<=2;i++)
           {
            
            lineaDIMinus[i] = iADX(NULL,0,periodoADX,PRICE_CLOSE,MODE_MINUSDI,i); // funzione che restituisce il valore del DI-
            
            lineaDIPlus[i] = iADX(NULL,0,periodoADX,PRICE_CLOSE,MODE_PLUSDI,i);// funzione che restituisce il valore del DI+
            
             //Print("DI - ", lineaDIMinus[i], " " , " DI+ ",lineaDIPlus[i]);
            
           }
    
    if((lineaDIPlus[2] < lineaDIMinus[2] ) && (lineaDIPlus[1] > lineaDIMinus[1]))
         {  
          
            Print ("C'è Incrocio Long !");
            return "long";// Cerco un incrocio long 
         }
      else if
      
      ((lineaDIMinus[2] < lineaDIPlus[2] ) && (lineaDIMinus[1] > lineaDIPlus[1]))
       
       {
          Print ("C'è Incrocio Short !");
         return "short"; // Cerco un incrocio short 
         }
    else 
      return "";  // non c'è nessun tipo di incrocio

}

 int TotaleOrdiniAperti()
 
 {
 
      int totaleOrdini = 0; // Numero degli ordini gia aperti su questo Expert
      int posizioniAperte = OrdersTotal();  // Ritorno del numoero delle posizioni aperte ( market o pending)
     // Print("Ordini Aperti su Metatrader" , posizioniAperte);
     // Print("OrderMAgicNumber = ",OrderMagicNumber());
      for(int i=posizioniAperte-1;i>=0; i--)
        {
            
          OrderSelect(i,SELECT_BY_POS,MODE_TRADES); // Funzione che va a selezionare l' ordine per successive analisi
             
              
             if(OrderMagicNumber()== numeroMagico)
               {  
                   totaleOrdini++;
                  Print("Ordini aperti expert = ",totaleOrdini);
              
               }
         
         
        }
 
   return totaleOrdini;
 }