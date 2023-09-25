package RISC_V_pac; 

  enum logic [ 4 : 0 ]
  { 

    ALU_ADD  = 5'b0_0_000,
    ALU_SUB  = 5'b0_1_000,
    ALU_SLL  = 5'b0_0_001,
    ALU_SLT  = 5'b0_0_010, 
    ALU_SLTU = 5'b0_0_011, 
    ALU_XOR  = 5'b0_0_100, 
    ALU_SRL  = 5'b0_0_101,
    ALU_SRA  = 5'b0_1_101, 
    ALU_OR   = 5'b0_0_110, 
    ALU_AND  = 5'b0_0_111, 
    ALU_BEQ  = 5'b1_1_000,
    ALU_BNE  = 5'b1_1_001, 
    ALU_BLT  = 5'b1_1_100, 
    ALU_BGE  = 5'b1_1_101, 
    ALU_BLTU = 5'b1_1_110,
    ALU_BGEU = 5'b1_1_111

  } ALUOp; // ALUOp = {flag, add/sub, aluop}
  
  enum logic [ 2 : 0 ] 
  { 

    LDST_B  = 3'd0, 
    LDST_H  = 3'd1, 
    LDST_W  = 3'd2,
    LDST_BU = 3'd4,
    LDST_HU = 3'd5
  
  } LDST;

endpackage
