module Main_decoder(

    input          [31:0]  fetched_instr_i,    // 32-� ������ ����������
    
    output  logic  [1:0]   ex_op_a_sel_o,      //  ����� 1-�� �������� ���
    output  logic  [2:0]   ex_op_b_sel_o,      //  ����� 2-�� �������� ���
    
    output  logic  [4:0]   alu_op_o,           //  ����� �������� ���
    
    output  logic          mem_req_o,          //  ������ � ������ ������
    output  logic          mem_we_o,           //  ������ � ������ ������
    output  logic  [2:0]   mem_size_o,         //  �/� �����, ���������, �����
    
    output  logic          gpr_we_a_o,         //  ������ � ����������� ����
    output  logic          wb_src_sel_o,       //  ����� ��������� ������ � ����������� ����
    
    output  logic          illegal_instr_o,    //  ������ ������
    
    output  logic          branch_o,           //  �������� �������
    output  logic          jal_o,              //  ������ �� ���������� ������������ ��������
    output  logic          jalr_o              //  ������� �� �������� � ����������� ������ �������

    );
    
    import RISC_V_pac::*;
    
    always_comb begin
    
        case ( fetched_instr_i[6:0] ) // Opcode
        
            7'b0110011: begin // R-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd0;
                
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 1;
                
                mem_we_o <= 0;
                mem_req_o <= 0;         
                mem_size_o <= LDST_B;            
                
                branch_o <= 0;
                jal_o <= 0; 
                jalr_o <= 0;
                
                illegal_instr_o <= 0;
            
                case ( {fetched_instr_i[31:25], fetched_instr_i[14:12]} )
                
                    12'h000: alu_op_o <= ALU_ADD;
                    12'h200: alu_op_o <= ALU_SUB;
                    12'h004: alu_op_o <= ALU_XOR;
                    12'h006: alu_op_o <= ALU_OR;
                    12'h007: alu_op_o <= ALU_AND;
                    12'h001: alu_op_o <= ALU_SLL;
                    12'h005: alu_op_o <= ALU_SRL;
                    12'h205: alu_op_o <= ALU_SRA;
                    12'h002: alu_op_o <= ALU_SLT;
                    12'h003: alu_op_o <= ALU_SLTU;
                    
                    default: begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end 
                
                endcase
            
            end
            
            7'b0010011: begin // I-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd1;
                
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 1;
                
                mem_we_o <= 0;
                mem_req_o <= 0;         
                mem_size_o <= LDST_B;            
                
                branch_o <= 0;
                jal_o <= 0; 
                jalr_o <= 0;
                
                illegal_instr_o <= 0;
            
                case ( fetched_instr_i[14:12] )
                
                    3'b000: alu_op_o <= ALU_ADD;
                    3'b100: alu_op_o <= ALU_XOR;
                    3'b110: alu_op_o <= ALU_OR;
                    3'b111: alu_op_o <= ALU_AND;
                    3'b010: alu_op_o <= ALU_SLT;
                    3'b011: alu_op_o <= ALU_SLTU;
                    
                    3'b001: if ( fetched_instr_i[31:25] == 7'd0) alu_op_o <= ALU_SLL;
                            else begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end 
                            
                    3'b101: if ( fetched_instr_i[31:25] == 7'd0) alu_op_o <= ALU_SRL;
                            else if ( fetched_instr_i[31:25] == 7'b0100000) alu_op_o <= ALU_SRA;
                            else begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end 
                    
                    default: begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end
                
                endcase     
                  
            end
            
            7'b0000011: begin // I-type (load)
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd1;
                
                alu_op_o <= ALU_ADD;
                
                mem_req_o <= 1;
            
                wb_src_sel_o <= 1;
                gpr_we_a_o <= 1;
                
                
                mem_we_o <= 0;
                
                branch_o <= 0;
                jal_o <= 0; 
                jalr_o <= 0;
                
                illegal_instr_o <= 0;
                
            
                case ( fetched_instr_i[14:12] )
                
                    4'h0: mem_size_o <= LDST_B;
                    4'h1: mem_size_o <= LDST_H;
                    4'h2: mem_size_o <= LDST_W;
                    4'h4: mem_size_o <= LDST_BU;
                    4'h5: mem_size_o <= LDST_HU;
                    
                    default: begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end
                                    
                endcase
            
            end
            
            7'b0100011: begin // S-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd3;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 0;
                
                mem_req_o <= 1;
                mem_we_o <= 1;
                
                branch_o <= 0;
                jal_o <= 0; 
                jalr_o <= 0;
                
                illegal_instr_o <= 0;
            
                case ( fetched_instr_i[14:12] )
                
                    4'h0: mem_size_o <= LDST_B;
                    4'h1: mem_size_o <= LDST_H;
                    4'h2: mem_size_o <= LDST_W;
                    
                    default: begin illegal_instr_o <= 1; mem_req_o <= 0;  gpr_we_a_o <= 0; end
                                    
                endcase
            
            end
        
            7'b1100011: begin // B-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd0;
               
                
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 0;
                
                mem_req_o <= 0;
                mem_size_o <= LDST_B;
                mem_we_o <= 0;
                
                branch_o <= 1;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 0;
                  
                case ( fetched_instr_i[14:12] )
                
                    3'b000: alu_op_o <= ALU_BEQ;
                    3'b001: alu_op_o <= ALU_BNE;
                    3'b100: alu_op_o <= ALU_BLT;
                    3'b101: alu_op_o <= ALU_BGE;
                    3'b110: alu_op_o <= ALU_BLTU;
                    3'b111: alu_op_o <= ALU_BGEU;
                    
                    default: begin
                    
                        illegal_instr_o <= 1; 
                        mem_req_o <= 0;  
                        gpr_we_a_o <= 0; 
                        branch_o <= 0;
                        
                    end
                                                        
                endcase
            
            end
            
            7'b1101111: begin // J-type
            
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd4;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 1;
                
                illegal_instr_o <= 0;
            
            end
            
            7'b1100111: begin // I-type (jarl) 
            
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd4;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 0;
                
                jal_o <= 0;
                branch_o <= 0;
                
                if ( fetched_instr_i[14:12] == 3'd0 ) begin  
                    
                    gpr_we_a_o <= 1;
                    jalr_o <= 1;
                    illegal_instr_o <= 0;
                    
                end else begin
                
                    illegal_instr_o <= 1;
                    gpr_we_a_o <= 0;
                    jalr_o <= 0;
                    
                end
                
            end
            
            7'b0110111: begin // U-type
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd2;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 0;
            
            end
            
            7'b0010111: begin // U-type (auipc)
            
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd2;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 0;
            
            end
            
            7'b1110011: begin // nop
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 0;
            
            end
            
            7'b0001111: begin // nop
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 0;
            
            end
            
            default: begin
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 0;
                gpr_we_a_o <= 0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 0;
                mem_we_o <= 0;
                
                branch_o <= 0;
                jalr_o <= 0;
                jal_o <= 0;
                
                illegal_instr_o <= 1;
            
            end
        
        endcase
    
    end
    
endmodule
