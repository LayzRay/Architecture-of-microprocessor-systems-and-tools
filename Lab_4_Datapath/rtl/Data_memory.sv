module Data_memory #( parameter DEPTH = 256, WIDTH = 32 )
(
  input                     CLK,
                            WE,
    
         [ WIDTH - 1 : 0 ]  A,
                            WD,

  output [ WIDTH - 1 : 0 ]  RD
    
);
    
    logic [ WIDTH - 1 : 0 ] RAM [ 0 : DEPTH - 1 ];
    
    assign RD = ( ( A[ 9 : 2 ] >= 32'h81000000 ) && ( A[ 9 : 2 ] <= 32'h810003FC ) ) ? ( RAM[ A[ 9 : 2 ] ] ) : ( 0 );
    
    always_ff @( posedge CLK ) 
      begin
    
        if ( ( A[ 9 : 2 ] >= 32'h81000000 ) && ( A[ 9 : 2 ] <= 32'h810003FC ) )
            RAM[ A[ 9 : 2 ] ] <= ( WE ) ? ( WD ) : ( RAM[ A[ 9 : 2 ] ]);
    
      end
    
endmodule
