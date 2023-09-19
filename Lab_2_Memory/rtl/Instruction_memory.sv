module Instruction_memory #( parameter DEPTH = 256, WIDTH = 32 )
(
  input [ $clog2( DEPTH ) - 1 : 0 ] A,
  
  output [ WIDTH - 1 : 0 ]          RD
  
);
    
  logic [ WIDTH - 1 : 0 ] RAM [ 0 : DEPTH - 1 ];

  initial $readmemb( "Instructions_Lab_2.mem", RAM );
  
  assign RD = RAM[ A ];
    
endmodule
