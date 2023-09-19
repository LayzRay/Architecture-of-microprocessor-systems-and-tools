module RISC_V_processor(

    input CLK

    );
    
   logic [31:0] PC = 0;
   
   logic [31:0] instr;
   
   logic [1:0] ex_op_a_sel;
   logic [2:0] ex_op_b_sel;
   
   logic [31:0] A_select, B_select;
   
   logic [31:0] data_1, data_2;
   logic [31:0] imm_I, imm_S, imm_J, imm_B;
   
   logic mem_req;
   logic [2:0] mem_size;
   
   logic [4:0] alu_op;
   
   logic [31:0] res_alu;
   
   logic comp, mem_we, gpr_we_a, wb_src_sel;
   
   logic [31:0] WD, data_mem;
   
   logic illegal_instr;
   logic branch;
   
   logic [31:0] provod, provod_2;
   
   logic jal, jalr;
   
   logic [31:0] DATA;
  
    
   Main_decoder MD (
   
        .fetched_instr_i(instr),
        .ex_op_a_sel_o(ex_op_a_sel),
        .ex_op_b_sel_o(ex_op_b_sel),
        .mem_req_o(mem_req),
        .mem_size_o(mem_size),
        .alu_op_o(alu_op),
        .mem_we_o(mem_we),
        .gpr_we_a_o(gpr_we_a),
        .wb_src_sel_o(wb_src_sel),
        .illegal_instr_o(illegal_instr),
        .branch_o(branch),
        .jal_o(jal),
        .jalr_o(jalr)
        
   );
   
   Instruction_memory IM (.A(PC), .RD(instr));
   
   Data_memory DM (.CLK(CLK), .WE(mem_we), .mem_req(mem_req), .mem_size(mem_size), .A(res_alu), .WD(data_2), .RD(data_mem));
   
   Register_file RF (.CLK(CLK), .WE3(), .A1(instr[19:15]), .A2(instr[24:20]), .A3(instr[11:7]), .WD3(gpr_we_a), .RD1(data_1), .RD2(data_2));
   
   RISCV_ALU ALU (.A_i(A_select), .B_i(B_select), .ALUOp_i(alu_op), .Result_o(res_alu), .Flag_o(comp));
   
   assign imm_I = { {20{instr[31]}} ,instr[31:20] };
   assign imm_S = { {19{instr[31]}} ,instr[31:25], instr[11:7] };
   assign imm_J = { {12{instr[31]}} ,instr[31], instr[19:12], instr[20], instr[30:21] };
   assign imm_B = { {20{instr[31]}} ,instr[31], instr[7], instr[30:25], instr[11:8] };
   
   always_comb begin
   
     if ( wb_src_sel ) WD <= data_mem;
     else              WD <= res_alu;
   
     case ( ex_op_a_sel )
     
        2'b00: A_select <= data_1;
        2'b01: A_select <= PC;
        2'b10: A_select <= 32'd0;
        
        default: A_select <= 32'd0;
     
     endcase
     
     case ( ex_op_b_sel )
     
        3'b000: B_select <= data_2;
        3'b001: B_select <= imm_I;
        3'b010: B_select <= { {12{instr[31]}} ,instr[31:12], 1'b0 };
        3'b011: B_select <= imm_S;
        3'b100: B_select <= 32'd4;
        
        default: B_select <= 32'd0;
     
     endcase
     
     if ( branch ) provod <= imm_B;
     else          provod <= imm_J;
     
     if ( jal | ( comp & branch ) ) provod_2 <= provod;
     else provod_2 <= 32'd4;
     
     if ( jalr ) DATA <= data_1 + imm_I;
     else DATA <= PC + provod_2;
   
   end
    
endmodule
