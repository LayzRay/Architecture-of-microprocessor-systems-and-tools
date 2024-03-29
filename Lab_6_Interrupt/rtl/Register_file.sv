module Register_file #( parameter DEPTH = 32, WIDTH = 32 )
(
  input                              CLK, 
                                     WE3,
  
         [ $clog2( DEPTH ) - 1 : 0 ] A1,
                                     A2, 
                                     A3,
  
         [ WIDTH - 1 : 0 ]           WD3,
  
  output [ WIDTH - 1 : 0 ]           RD1, 
                                     RD2

  );
  
  logic [ WIDTH - 1 : 0 ] RAM [ 0 : DEPTH - 1 ];
  
  assign RD1 = ( A1 ) ? ( RAM[ A1 ] ) : 0;
  assign RD2 = ( A2 ) ? ( RAM[ A2 ] ) : 0;
  
  always_ff @( posedge CLK ) 
  
    RAM[ A3 ] = ( WE3 && ( A3 != 0 ) ) ? ( WD3 ) : ( RAM[ A3 ] );
  
endmodule
