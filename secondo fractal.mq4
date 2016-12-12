//+------------------------------------------------------------------+
//|                                              secondo fractal.mq4 |
//|                                                             Max. |
//|                                                    semper_ca_mia |
//+------------------------------------------------------------------+
 
void secondo_fractal( int magic1 = 0)
{

    int _GetLastError_fl = 0;
    // total amount of positions
    int _OrdTot_fl = OrdersTotal();
    int now_OrdTot_fl = 0;
    int now_OrdArray_fl[][2]; // [# in the list][ticket #, position type]

    // change the open positions array size for the current amount
    ArrayResize( now_OrdArray_fl, MathMax( _OrdTot_fl, 1 ) );
    // zeroize the array
    ArrayInitialize( now_OrdArray_fl, 0.0 );
 
    // zeroize arrays of closed positions and triggered orders
////    ArrayInitialize( now_ClosedOrdArray, 0.0 );
////    ArrayInitialize( now_OpenedPendOrders, 0.0 );
 
    //+------------------------------------------------------------------+
    //| Acquisisco i dati fractal
    //| 
    //+------------------------------------------------------------------+
        ord_symbol_fl=0;
   for ( int z1fl = _OrdTot_fl - 1; z1fl >= 0; z1fl -- )
    {
        if ( !OrderSelect( z1fl, SELECT_BY_POS ) )       
        {
 //           _GetLastError_sl = GetLastError();
 //           Print( "OrderSelect( ", z1fl, ", SELECT_BY_POS ) - Error #", _GetLastError_sl );
            continue;
        }
        // Count the amount of orders on the current symbol with the specified MagicNumber
        if ( OrderMagicNumber() == magic1 && OrderSymbol() == Symbol() )
        {
        ord_symbol_fl=ord_symbol_fl +1;
        }
    }
    
        if ( ord_symbol_fl == 0  && ord_long_ins ==1)       
        {       
              for(n_fl=0; n_fl<(Bars-1);n_fl++)
                {
                if(iFractals(NULL,PERIOD_CURRENT,MODE_LOWER,n_fl)!=NULL)
                break;
                LowerFractal_fl=n_fl+1;
                }
                val_lower_fl=Low[LowerFractal_fl];
                  //     TP_long=(max_setup-val_lower)+max_setup;
                if (val_lower != val_lower_fl)   
                {                          
                   ticket7=OrderSend(Symbol(),OP_BUYSTOP,lotsize,Ask+Poin,2,Ask-Poin,0,"ticket7",MagicNumber,0,clrGreen);
                   //           Print("reali L_ticket7**Set="+(max_setup)+" SL="+(val_lower)+" TP="+TP_long+" Ask="+Ask+" Bid="+Bid+" set_clr_l"+set_clr_l);

                     if(ticket7>0)
                     {
                        Alert("buystop order successful ticket7= "+ticket7);
//                        break;
                     }
                     else
                     {
                        Alert("error opening buy order, error code = ",ErrorDescription(GetLastError()),"  ticket7="+ticket7);
                     }
                     Sleep(300);
                     RefreshRates();
                }                                                
         }         
         else if ( ord_symbol_fl == 0  && ord_short_ins ==1)         
         {                          
               for(n_fl=0; n_fl<(Bars-1);n_fl++)
                 {
                 if(iFractals(NULL,PERIOD_CURRENT,MODE_UPPER,n_fl)!=NULL)
                 break;
                 UpperFractal_1=n_fl+1;
                 }
                 val_upper_fl=High[UpperFractal_fl];
                  //     TP_short=min_setup-(val_upper-min_setup);
                 if (val_upper != val_upper_fl)   
                {                         
            ticket8=OrderSend(Symbol(),OP_SELLSTOP,lotsize,Bid-Poin,2,Bid+Poin,0,"ticket8",MagicNumber,0,clrRed);
//            _ticket6=OrderTicket();
//            Print("reali S_ticket8**Set="+min_setup+" SL="+val_upper+" TP="+TP_short+" Ask="+Ask+" Bid="+Bid+" set_clr_s="+set_clr_s);
            //                                                                              Print ("_ticket6 porca vacca"+_ticket6); //max                          
                      if(ticket8>0)
                      {
                        Alert("sellstop order successful ticket8= "+ticket8);
//                      break;
                      }
                      else
                      {
                        Alert("error opening sell order, error code = ",ErrorDescription(GetLastError()),"  ticket8="+ticket8);
                      }
                        Sleep(300);
                        RefreshRates();
                  }                                                  
         }             
 }   

