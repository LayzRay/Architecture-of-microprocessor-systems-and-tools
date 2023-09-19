`timescale 1ns / 1ps

module CYBERcobra_tb();

  logic CLK_tb,
        Reset_tb;
  
  logic [ 31 : 0 ] DATA_tb,
                   OUT_tb;
  
  parameter PERIOD = 10;
  always
    begin

      CLK_tb = 1'b0;
      #( PERIOD / 2 ) CLK_tb = 1'b1;
      #( PERIOD / 2 );

    end

  CYBERcobra_3000_Pro_2_0 DUT
  (
      .CLK   ( CLK_tb   ),
      .Reset ( Reset_tb ),
  
      .DATA_i( DATA_tb  ),
      .OUT_o ( OUT_tb   )
  );
   
  initial 
    begin
  
      Reset_tb = 1'd1;
      @( CLK_tb ); #1;

      Reset_tb = 1'd0;
      DATA_tb  = 32'd9;
  
    end    
     
endmodule
