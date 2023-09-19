module RISCV_ALU #( parameter N = 32 )
(
    input [ N - 1 : 0 ]        A_i,
                               B_i,
          
          [ 4 : 0 ]            ALUOp_i,
    
    output logic [ N - 1 : 0 ] Result_o,
           logic               Flag_o
    
    );
    
    import RISC_V_pac::*;
    
    always_comb
      case ( ALUOp_i )

        ALU_ADD : begin Result_o <= A_i + B_i;                Flag_o   <= 0; end
        ALU_SUB : begin Result_o <= A_i - B_i;                Flag_o   <= 0; end
    
        ALU_SLL : begin Result_o <= A_i << B_i;               Flag_o   <= 0; end
        ALU_SLT : begin Result_o <= $signed( A_i < B_i );     Flag_o   <= 0; end
        ALU_SLTU: begin Result_o <= A_i < B_i;                Flag_o   <= 0; end
    
        ALU_XOR : begin Result_o <= A_i ^ B_i;                Flag_o   <= 0; end
    
        ALU_SRL : begin Result_o <= A_i >> B_i;               Flag_o   <= 0; end
        ALU_SRA : begin Result_o <= $signed( A_i ) >>> B_i;   Flag_o   <= 0; end
    
        ALU_OR  : begin Result_o <= A_i | B_i;                Flag_o   <= 0; end
        ALU_AND : begin Result_o <= A_i & B_i;                Flag_o   <= 0; end

        ALU_BEQ : begin Flag_o   <= A_i == B_i;               Result_o <= 0; end
        ALU_BNE : begin Flag_o   <= A_i != B_i;               Result_o <= 0; end

        ALU_BLT : begin Flag_o   <= $signed( A_i < B_i );     Result_o <= 0; end
        ALU_BGE : begin Flag_o   <= $signed( A_i >= B_i );    Result_o <= 0; end

        ALU_BLTU: begin Flag_o   <= ( A_i < B_i );            Result_o <= 0; end
        ALU_BGEU: begin Flag_o   <= ( A_i >= B_i );           Result_o <= 0; end

        default : begin Result_o <= 0;                        Flag_o   <= 0; end

  endcase
    
endmodule
