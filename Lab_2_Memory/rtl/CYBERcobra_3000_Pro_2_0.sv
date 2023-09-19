module CYBERcobra_3000_Pro_2_0
(
  input             CLK,
                    Reset,
  
         [ 31 : 0 ] DATA_i,
         
  output [ 31 : 0 ] OUT_o
);
    
  ////////////////////////////////////
  
  logic [ 7 : 0 ]  PC = 8'd0;
  logic [ 31 : 0 ] Instr;
  
  Instruction_memory IM 
  ( 
    .A ( PC    ), 
    .RD( Instr ) 
  );
  
  ////////////////////////////////////
  
  logic [ 31 : 0 ] RD1, 
                   RD2,
                   WS;
  
  Register_file RF 
  ( 
      .CLK( CLK                       ),
       
      .WE3( Instr[ 29 ] | Instr[ 28 ] ),
       
      .A1 ( Instr[ 22 : 18 ]          ), 
      .A2 ( Instr[ 17 : 13 ]          ), 
      .A3 ( Instr[ 4  : 0  ]          ), 
      
      .WD3( WS                        ),
       
      .RD1( RD1                       ), 
      .RD2( RD2                       )
   );
  
  ////////////////////////////////////
  
  logic [ 31 :0 ] ALU_result;
  logic Flag;
  
  RISCV_ALU ALU 
  (
    .A_i     ( RD1              ), 
    .B_i     ( RD2              ),
     
    .ALUOp_i ( Instr[ 27 : 23 ] ), 
    
    .Result_o( ALU_result       ), 
    
    .Flag_o  ( Flag             )
      
  );
  
  /////////////////////////////////// 
  
  always_comb
    case ( Instr[ 29 : 28 ] )
    
      2'b01: WS <= DATA_i;
      2'b10: WS <= { { 9{ Instr[ 27 ] } }, Instr[ 27 : 5 ] };
      2'b11: WS <= ALU_result;
      
      default: WS <= 32'd0;   
        
    endcase
  
  always_ff @( posedge CLK )
      if ( Reset ) 
        PC <= 8'd0;
      else
        if ( Instr[ 31 ] | ( Instr[ 30 ] & Flag ) )
            PC <= PC + Instr[ 12 : 5 ];
        else
            PC <= PC + 8'd1;

  assign OUT_o = RD1;
          
endmodule
