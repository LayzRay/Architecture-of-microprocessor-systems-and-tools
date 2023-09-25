`timescale 1ns / 1ps

module TestBench();

  parameter     HF_CYCLE = 2.5;       // 200 MHz clock
  parameter     RST_WAIT = 100;         // 10 ns reset
  parameter     RAM_SIZE = 512;       // in 32-bit words

  // clock, reset
  logic clk;
  logic rst_n;
  
  logic [15:0] SW;
  logic start;
  

  miriscv_top #(
  
    .RAM_SIZE       ( RAM_SIZE           ),
    .RAM_INIT_FILE  ( "program_sort.dat" )
    
  ) DUT (
  
    .clk_i    ( clk   ),
    .rst_n_i  ( rst_n ),
    
    .start  ( !start ),
  
    .SW  ( SW )
    
  );

  initial begin
  
    SW = {14'd0, 2'b11};
  
    start = 1'b1;
    clk   = 1'b0;
    rst_n = 1'b0;
    #RST_WAIT;
    rst_n = 1'b1;
    
    #10;
    
    start = 1'b1;
    
    #100;
    
    start = 1'b0;
    
    #60; 
    
    start = 1'b1;
    
  end

  always begin
  
    #HF_CYCLE;
    clk = ~clk;
    
  end
    
endmodule
