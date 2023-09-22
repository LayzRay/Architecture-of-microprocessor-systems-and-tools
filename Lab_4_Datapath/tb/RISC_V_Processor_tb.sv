`timescale 1ns / 1ns

module RISC_V_Processor_tb();

   logic CLK;
    
   parameter PERIOD = 10;

   always begin
      CLK = 1'b0;
      #(PERIOD/2) CLK = 1'b1;
      #(PERIOD/2);
   end
   
   logic reset;
   
   RISC_V_Processor Proc ( .clk_i( CLK ), .arstn_i( reset ) );
   
   initial begin
   
       #35;
       reset = 1'b0;
       @( posedge CLK ); #1;
       reset = 1'b1;
       
   end

endmodule
