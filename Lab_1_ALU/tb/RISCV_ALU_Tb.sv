`timescale 1ns / 1ps

module RISC_V_ALU_Tb();

  import RISC_V_pac :: *;
  logic [ WORD_LENGTH - 1 : 0 ] A_tb, 
                                B_tb;
  logic [ 4 : 0 ] ALUOp_tb;
  logic [ WORD_LENGTH - 1 : 0 ] Result_tb;
  logic Flag_tb; 

  RISCV_ALU #( .N( WORD_LENGTH ) ) 
  ALU 
  (
  
    .A_i     ( A_tb      ),
    .B_i     ( B_tb      ),
  
    .ALUOp_i ( ALUOp_tb  ),
  
    .Result_o( Result_tb ),
    .Flag_o  ( Flag_tb   )
  
  );
  
  task RISCV_ALUOp_Test;
  
    input integer ALUOp_task;
    input integer A_task, B_task;
    
    begin
    
      A_tb     = A_task;
      B_tb     = B_task;
      ALUOp_tb = ALUOp_task;
      
      #10; 
      $display( "A = %0d\n", A_tb, "B = %0d\n", B_tb, "Result = %0d\n", $signed( Result_tb ), "Flag = %0d\n", Flag_tb );
      $display( "Time = %0t ns\n", $realtime/1000 );
    
    end
  
  endtask
  
  initial begin
      
    $display( " " );
    $display( "/////////////////Testbench results//////////////////////////" );
    $display( " " );
  
    $display( "ALU_ADD:" );
    RISCV_ALUOp_Test( ALU_ADD, 32'd37, 32'd563 );
    
    $display( "ALU_SUB:" );
    RISCV_ALUOp_Test( ALU_SUB, 32'd37, 32'd563 );
    
    $display( "ALU_SLL:" );
    RISCV_ALUOp_Test( ALU_SLL, 32'd6, 32'd1 );
    
    $display( "ALU_SLT:" );
    RISCV_ALUOp_Test( ALU_SLT, 32'd37, 32'd563 );
    
    $display( "ALU_SLTU:" );
    RISCV_ALUOp_Test( ALU_SLTU, 32'd37, 32'd3 );
    
    $display( "ALU_XOR:" );
    RISCV_ALUOp_Test( ALU_XOR, 3'b101, 3'b010 );
    
    $display( "ALU_SRL:" );
    RISCV_ALUOp_Test( ALU_SRL, 32'd6, 32'd1 );
    
    $display( "ALU_SRA:" );
    RISCV_ALUOp_Test( ALU_SRA, 5'b10110, 32'd1 );
    
    $display( "ALU_OR:" );
    RISCV_ALUOp_Test( ALU_OR, 3'b101,  3'b100 );
    
    $display( "ALU_AND:" );
    RISCV_ALUOp_Test( ALU_AND, 3'b101, 3'b011 );
    
    $display( "ALU_BEQ:" );
    RISCV_ALUOp_Test( ALU_BEQ, 32'd37, 32'd37 );
    
    $display( "ALU_BNE:" );
    RISCV_ALUOp_Test( ALU_BNE, 32'd37, 32'd37 );
    
    $display( "ALU_BLT:" );
    RISCV_ALUOp_Test( ALU_BLT, 32'd37, 32'd39 );
    
    $display( "ALU_BGE:" );
    RISCV_ALUOp_Test( ALU_BGE, 32'd37, 32'd37 );
    
    $display( "ALU_BLTU:" );
    RISCV_ALUOp_Test( ALU_BLTU, 32'd37, 32'd37 );
    
    $display( "ALU_BGEU:" );
    RISCV_ALUOp_Test( ALU_BGEU, 32'd37, 32'd37 );
    
    $display( "////////////////////////////////////////////////////////////\n" );
    
    $finish;
  
  end

endmodule
