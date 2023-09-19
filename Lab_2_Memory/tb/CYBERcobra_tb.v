`timescale 1ns / 1ps

module CYBERcobra_tb();

    reg CLK;
    reg Reset_tb;
    
    reg [31:0] DATA_tb;
    wire [31:0] OUT_tb;
    
    parameter PERIOD = 10;

    always begin
       CLK = 1'b0;
       #(PERIOD/2) CLK = 1'b1;
       #(PERIOD/2);
    end

    CYBERcobra_3000_Pro_2_0 DUT (

        .CLK(CLK),
        .Reset(Reset_tb),
    
        .DATA_i(DATA_tb),
        .OUT_o(OUT_tb)

     );
     
     initial begin
     
        Reset_tb = 1'b1;
        @( CLK ); #1;
        
        Reset_tb = 1'b0;
        DATA_tb = 32'd9;
     
     end    
     
endmodule
