//+------------------------------------------------------------------+
//|                                              cancella ordini.mq4 |
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
 

void cancella_ordini( int magic1 = 0,int type_cancel = 0 )
{
//Print ("magic1"+magic1+"type_cancel"+type_cancel);
    // flag of the first launch
////    static bool first1 = true;
    // the last error code
    int _GetLastError = 0;
    // total amount of positions
    int _OrdTot = OrdersTotal();
    // the amount of positions met the criteria (the current symbol and the specified MagicNumber),
    // as it is on the current tick
    int now_OrdTot = 0;
    // the amount of positions met the criteria as on the previous tick
////    static int pre_OrdTot = 0;
    // array of open positions as of the current tick
    int now_OrdArray[][2]; // [# in the list][ticket #, position type]
    // the current number of the position in array now_OrdArray (for searching)
////    int now_CurOrder = 0;
    // the current number of the position in array pre_OrdArray (for searching)
////    int pre_CurOrder = 0;
 
    // array for storing the amount of closed positions of each type
////    int now_ClosedOrdArray[6][3]; // [order type][closing type]
    // array for storing the amount of triggered pending orders
////    int now_OpenedPendOrders[4]; // [order type]
 
    // temporary flags
////    bool OrdClosed = true, PendOrdOpened = false;
    // temporary variables
////    int ticket_c = 0, type_c = -1, close_type_c = -1;
 
 
    // change the open positions array size for the current amount
    ArrayResize( now_OrdArray, MathMax( _OrdTot, 1 ) );
    // zeroize the array
    ArrayInitialize( now_OrdArray, 0.0 );
 
    // zeroize arrays of closed positions and triggered orders
////    ArrayInitialize( now_ClosedOrdArray, 0.0 );
////    ArrayInitialize( now_OpenedPendOrders, 0.0 );
 
    //+------------------------------------------------------------------+
    //| Acquisisco i dati
    //| 
    //+------------------------------------------------------------------+
    for ( int z1 = _OrdTot - 1; z1 >= 0; z1 -- )
    {
        if ( !OrderSelect( z1, SELECT_BY_POS ) )       
        {
            _GetLastError = GetLastError();
            Print( "OrderSelect( ", z1, ", SELECT_BY_POS ) - Error #", _GetLastError );
            continue;
        }
        // Count the amount of orders on the current symbol with the specified MagicNumber
        if ( OrderMagicNumber() == magic1 && OrderSymbol() == Symbol() )
        {
            now_OrdArray[now_OrdTot][1] = OrderType();
            now_OrdArray[now_OrdTot][0] = OrderTicket();
     //+------------------------------------------------------------------+
    //| Faccio le cancellazioni mirate
    //| 
    //+------------------------------------------------------------------+           
            
              if ( (now_OrdArray[now_OrdTot][1] == 4 || now_OrdArray[now_OrdTot][1] == 5) && type_cancel == 3)//se buystop e sellstop con cancellatutto
                                 {
                             bool res17=OrderDelete(now_OrdArray[now_OrdTot][0]);
                                 if(!res17)
                                    {
                                    Print("Error Cancellazione ordine code=",GetLastError()," ticket = "+now_OrdArray[now_OrdTot][0]);
                                    }           
                                 else
                                    {
                                    ;
                                    }                                   
                                 }                                  
             else if ( now_OrdArray[now_OrdTot][1] == 4 && type_cancel == 1) //con buy stop e cancella buy                 
                                 {
                             bool res18=OrderDelete(now_OrdArray[now_OrdTot][0]);
                                 if(!res18)
                                    {
                                    Print("Error Cancellazione ordine code=",GetLastError()," ticket = "+now_OrdArray[now_OrdTot][0]);
                                    }           
                                 else
                                    {
                                    ;
                                    }                                                                                                                                                                                                           
                                 }
             else if ( now_OrdArray[now_OrdTot][1] == 5 && type_cancel == 2) //con sell stop e cancella sell                 
                                 {
                             bool res19=OrderDelete(now_OrdArray[now_OrdTot][0]);
                                 if(!res19)
                                    {
                                    Print("Error Cancellazione ordine code=",GetLastError()," ticket = "+now_OrdArray[now_OrdTot][0]);
                                    }           
                                 else
                                    {
                                    ;
                                    }                                                                                                      
                                 } 
             else if ( now_OrdArray[now_OrdTot][1] == 0 && (type_cancel == 3 || type_cancel == 1)) //con buy  e cancellatutto o buy                
                                 {                                
                             bool res20=OrderClose (now_OrdArray[now_OrdTot][0],lotsize,Bid,2,clrBlueViolet);                                                                                                   
                                 if(!res20)
                                    {
                                    Print("Error Chiusura ordine code=",GetLastError()," ticket = "+now_OrdArray[now_OrdTot][0]);
                                    }           
                                 else
                                    {
                                    ;
                                    }                                                                                                                                                                                                                                                                                                                                                                                          
                                 } 
             else if ( now_OrdArray[now_OrdTot][1] == 1 && (type_cancel == 3 || type_cancel == 2)) //con Sell  e cancellatutto o sell                   
                                 {                                                                                          
                             bool res21=OrderClose (now_OrdArray[now_OrdTot][0],lotsize,Ask,2,clrBlueViolet); 
                                                                                                     
                                 if(!res21)
                                    {
                                    Print("Error Chiusura ordine code=",GetLastError()," ticket = "+now_OrdArray[now_OrdTot][0]);
                                    }           
                                 else
                                    {
                                    ;                                                                     
                                    }                                                                                                                                                                                                                                                                                                                                            
                                 }                                                                                                    
            now_OrdTot ++;
        }
    }   
 }   
