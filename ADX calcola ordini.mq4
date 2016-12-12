//+------------------------------------------------------------------+
//|                                          ADX  calcola ordini.mq4 |
//|                                                             Max. |
//|                                                    semper_ca_mia |
//+------------------------------------------------------------------+
//#property library
//#property copyright "Max."
//#property link      "semper_ca_mia"
//#property version   "1.00"
//#property strict
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
// int MyCalculator(int value,int value2) export
//   {
//    return(value+value2);
//   }
//+------------------------------------------------------------------+
// array of open positions as it was on the previous tick
////int pre_OrdArray[][2]; // [amount of positions][ticket #, positions type]


void ADX_calcola_ordini(int magic1=0)
  {
///////////////////////////////////////////faccio un primo conteggio degli ordini in essere da usarsi nel secondo luoop/////////////////////////////
   int _GetLastError=0;
   int _OrdTot= OrdersTotal();
   int ord_buy=0;
   int ord_sell=0;
   for( int z2 = _OrdTot - 1; z2 >= 0; z2 -- )
     {
      if(!OrderSelect(z2,SELECT_BY_POS))
        {
         _GetLastError=GetLastError();
         Print("OrderSelect( ",z2,", SELECT_BY_POS ) - Error #",_GetLastError);
         continue;
        }
      // Count the amount of orders on the current symbol with the specified MagicNumber
      if(OrderMagicNumber()==magic1 && OrderSymbol()==Symbol())
        {
         if(OrderType()==0)
           {
            ord_buy=ord_buy+1;
           }
         if(OrderType()==1)
           {
            ord_sell=ord_sell+1;
           }
        }
     }

///////////////////////////////////////////fine primo conteggio degli ordini in essere da usarsi nel secondo luoop/////////////////////////////

   int adx_OrdTot=0;
   int adx_OrdArray[][2]; // [# in the list][ticket #, position type]
                          // change the open positions array size for the current amount
   ArrayResize(adx_OrdArray,MathMax(_OrdTot,1));
// zeroize the array
   ArrayInitialize(adx_OrdArray,0.0);

// zeroize arrays of closed positions and triggered orders
////    ArrayInitialize( now_ClosedOrdArray, 0.0 );
////    ArrayInitialize( now_OpenedPendOrders, 0.0 );

//+------------------------------------------------------------------+
//| Acquisisco i dati
//| 
//+------------------------------------------------------------------+
   for(int z1=_OrdTot-1; z1>=0; z1 --)
     {
      if(!OrderSelect(z1,SELECT_BY_POS))
        {
         _GetLastError=GetLastError();
         Print("OrderSelect( ",z1,", SELECT_BY_POS ) - Error #",_GetLastError);
         continue;
        }
      // Count the amount of orders on the current symbol with the specified MagicNumber
      if(OrderMagicNumber()==magic1 && OrderSymbol()==Symbol())
        {
         adx_OrdArray[adx_OrdTot][1] = OrderType();
         adx_OrdArray[adx_OrdTot][0] = OrderTicket();
         //+------------------------------------------------------------------+
         //| Faccio le cancellazioni mirate
         //| 
         //+------------------------------------------------------------------+           

         if((adx_OrdArray[adx_OrdTot][1]==0 && pos_ap_long==2 && ord_buy==1))//se ordine buy aperto e risulta che eravamo in condizione di due ordini allora faccio modifica
           {
            Print("sono entrato nella routine di correzione secondo ordine LONG");
            OrderSelect(ticket2,SELECT_BY_TICKET);
            bool res7=OrderModify(ticket2,OrderOpenPrice(),OrderOpenPrice()+Poin,(((OrderOpenPrice()-OrderStopLoss())*2)+OrderOpenPrice()),0,clrAquamarine);
            //                                       bool res7=OrderModify(ticket2,OrderOpenPrice(),TP_long+set_clr_l,TP_long-max_setup+TP_long,0,clrAquamarine);                                    
            if(!res7)
              {
               Print("Error in TP OrderModify long profit. Error code=",GetLastError()," ticket2 = "+ticket2+" set= "+OrderOpenPrice()+" SL="+(TP_long+set_clr_l)+" TP="+(TP_long-max_setup+TP_long)+"  Ask= "+Ask+"  Bid= "+Bid);
              }
            else
              {
               Print("Ordine TP long modified successfully.ticket2 "+ticket2);
              }
            pos_ap_long=0;
           }
         else if(( adx_OrdArray[adx_OrdTot][1]==1 && pos_ap_short==2 && ord_sell==1))//se ordine short aperto e risulta che eravamo in condizione di due ordini allora faccio modifica

           {
            Print("sono entrato nella routine di correzione secondo ordine SHORT");
            OrderSelect(ticket5,SELECT_BY_TICKET);
//            bool res8=OrderModify(ticket5,OrderOpenPrice(),TP_short-set_clr_l,TP_short-(TP_short-val_upper),0,clrChocolate);
              bool res8=OrderModify(ticket5,OrderOpenPrice(),OrderOpenPrice()-Poin,(((OrderOpenPrice()-OrderStopLoss())*2)-OrderOpenPrice()),0,clrChocolate);          
            
            //                                        bool res8=OrderModify(ticket5,OrderOpenPrice(),TP_short-set_clr_l,TP_short-(TP_short-val_upper),0,clrChocolate);                                               
            if(!res8)
              {
               Print("Error in TP OrderModify short profit. Error code=",GetLastError()," ticket5 = "+ticket5+" set= "+OrderOpenPrice()+" SL="+(TP_short-set_clr_l)+" TP="+(TP_short-(TP_short-val_upper))+"  Ask= "+Ask+"  Bid= "+Bid);
              }
            else
              {
               Print("Ordine TP short modified successfully.ticket5 "+ticket5);
               //           Print("stop_main_short= "+stop_main_short+"       ordine_attivo_s= "+ordine_attivo_s );

              }
            pos_ap_short=0;
           }

         adx_OrdTot++;
        }
     }
  }
//+------------------------------------------------------------------+
