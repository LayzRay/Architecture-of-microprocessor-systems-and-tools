module Main_decoder(

    input          [31:0]  fetched_instr_i,    // 32-х битная инструкция
    
    input                  INT_o,
    output  logic          INT_o_RST,
    
    output  logic  [1:0]   ex_op_a_sel_o,      //  Выбор 1-го операнда АЛУ
    output  logic  [2:0]   ex_op_b_sel_o,      //  Выбор 2-го операнда АЛУ
    
    output  logic  [4:0]   alu_op_o,           //  Выбор операции АЛУ
    
    output  logic  [2:0]   CSRop,
    output  logic          csr,
    
    output  logic          mem_req_o,          //  Запрос к памяти данных
    output  logic          mem_we_o,           //  Запись в память данных
    output  logic  [2:0]   mem_size_o,         //  З/Ч байта, полуслова, слова
    
    output  logic          gpr_we_a_o,         //  Запись в регистровый файл
    output  logic          wb_src_sel_o,       //  Выбор источника записи в регистровый файл
    
    output  logic          illegal_instr_o,    //  Сигнал ошибки
    
    output  logic          branch_o,           //  Условный переход
    output  logic          jal_o,              //  Сигнал об инструкции безусловного перехода
    output  logic  [1:0]   jalr_o              //  Переход по регистру с сохранением адреса возрата

    );
    
    import RISC_V_pac::*;
    
    always_comb begin
    
        alu_op_o <= ALU_ADD;
    
        case ( fetched_instr_i[6:0] ) // Opcode
        
            7'b0110011: begin // R-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd0;
                
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b1;
                
                mem_we_o <= 1'b0;
                mem_req_o <= 1'b0;         
                mem_size_o <= LDST_B;            
                
                branch_o <= 1'b0;
                jal_o <= 1'b0; 
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;

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
                    
                    default: begin
                        
                        illegal_instr_o <= 1'b1;
                        mem_req_o <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                        alu_op_o <= ALU_ADD;
                        
                    end 
                
                endcase
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b0010011: begin // I-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd1;
                
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b1;
                
                mem_we_o <= 1'b0;
                mem_req_o <= 1'b0;         
                mem_size_o <= LDST_B;            
                
                branch_o <= 1'b0;
                jal_o <= 1'b0; 
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
            
                case ( fetched_instr_i[14:12] )
                
                    3'b000: alu_op_o <= ALU_ADD;
                    3'b100: alu_op_o <= ALU_XOR;
                    3'b110: alu_op_o <= ALU_OR;
                    3'b111: alu_op_o <= ALU_AND;
                    3'b010: alu_op_o <= ALU_SLT;
                    3'b011: alu_op_o <= ALU_SLTU;
                    
                    3'b001: 
                    
                        if ( fetched_instr_i[31:25] == 7'd0)
                            
                            alu_op_o <= ALU_SLL;
                            
                        else begin 
                            
                            illegal_instr_o <= 1'b1;
                            mem_req_o <= 1'b0;
                            gpr_we_a_o <= 1'b0;
                        
                        end 
                            
                    3'b101:
                    
                        if ( fetched_instr_i[31:25] == 7'd0)
                            
                            alu_op_o <= ALU_SRL;
                            
                        else if ( fetched_instr_i[31:25] == 7'b0100000)
                            
                            alu_op_o <= ALU_SRA;
                            
                        else begin
                            
                            illegal_instr_o <= 1'b1;
                            mem_req_o <= 1'b0;
                            gpr_we_a_o <= 1'b0;
                            
                        end 
                    
                    default: begin
                        
                        illegal_instr_o <= 1'b1;
                        mem_req_o <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                    
                    end
                
                endcase     
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
                  
            end
            
            7'b0000011: begin // I-type (load)
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd1;
                
                alu_op_o <= ALU_ADD;
                
                mem_req_o <= 1'b1;
            
                wb_src_sel_o <= 1'b1;
                gpr_we_a_o <= 1'b1;
                
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0; 
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;  
            
                case ( fetched_instr_i[14:12] )
                
                    4'h0: mem_size_o <= LDST_B;
                    4'h1: mem_size_o <= LDST_H;
                    4'h2: mem_size_o <= LDST_W;
                    4'h4: mem_size_o <= LDST_BU;
                    4'h5: mem_size_o <= LDST_HU;
                    
                    default: begin
                    
                        illegal_instr_o <= 1'b1;
                        mem_req_o <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                        mem_size_o <= 0;
                        
                    end
                                    
                endcase
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b0100011: begin // S-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd3;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b0;
                
                mem_req_o <= 1'b1;
                mem_we_o <= 1'b1;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0; 
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
            
                case ( fetched_instr_i[14:12] )
                
                    4'h0: mem_size_o <= LDST_B;
                    4'h1: mem_size_o <= LDST_H;
                    4'h2: mem_size_o <= LDST_W;
                    
                    default: begin
                    
                        illegal_instr_o <= 1'b1;
                        mem_req_o <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                        mem_size_o <= 0;
                        
                    end
                                    
                endcase
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
        
            7'b1100011: begin // B-type
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd0;
               
                
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b0;
                
                mem_req_o <= 1'b0;
                mem_size_o <= LDST_B;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b1;
                jal_o <= 1'b0;
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                  
                case ( fetched_instr_i[14:12] )
                
                    3'b000: alu_op_o <= ALU_BEQ;
                    3'b001: alu_op_o <= ALU_BNE;
                    3'b100: alu_op_o <= ALU_BLT;
                    3'b101: alu_op_o <= ALU_BGE;
                    3'b110: alu_op_o <= ALU_BLTU;
                    3'b111: alu_op_o <= ALU_BGEU;
                    
                    default: begin
                    
                        illegal_instr_o <= 1'b1; 
                        mem_req_o <= 1'b0;  
                        gpr_we_a_o <= 1'b0; 
                        branch_o <= 1'b0;
                        
                    end
                                                        
                endcase
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b1101111: begin // J-type
            
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd4;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b1;             
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b1100111: begin // I-type (jarl) 
            
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd4;
                
                alu_op_o <= ALU_ADD;
                
                wb_src_sel_o <= 1'b0;
                
                jal_o <= 1'b0;
                branch_o <= 1'b0;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                if ( fetched_instr_i[14:12] == 3'd0 ) begin  
                    
                    gpr_we_a_o <= 1'b1;
                    jalr_o <= 2'b01;
                    illegal_instr_o <= 1'b0;
                    
                end else begin
                
                    illegal_instr_o <= 1'b1;
                    gpr_we_a_o <= 1'b0;
                    jalr_o <= 2'b00;
                    
                end
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
                
            end
            
            7'b0110111: begin // U-type
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd2;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0;
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b0010111: begin // U-type (auipc)
            
                ex_op_a_sel_o <= 2'd1;
                ex_op_b_sel_o <= 3'd2;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b1;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0;
                jalr_o <= 1'b0;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            7'b1110011: begin // INT_oerrupt
            
                ex_op_a_sel_o <= 2'd0;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0; 
                jalr_o <= 2'b00;
                
                CSRop <= fetched_instr_i[14:12];
                csr <= 1'b1;
                gpr_we_a_o <= 1'b1;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                
                if ( fetched_instr_i[14:12] == 3'b000) begin
                        
                        jalr_o <= 2'b10;
                        csr <= 1'b0;
                        gpr_we_a_o <= 1'b0;
                        
                        INT_o_RST <= 1'b1;
                    
                end else if ( fetched_instr_i[14:12] > 3'b011 ) begin
                    
                    gpr_we_a_o <= 1'b0;
                    illegal_instr_o <= 1'b1;
                    
                end
            
            end
            
            7'b0001111: begin // nop
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0;
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b0;
                
                if ( INT_o ) begin
                
                    jalr_o <= 2'b11;
                    CSRop <= 3'b100;
                    
                end
            
            end
            
            default: begin
            
                ex_op_a_sel_o <= 2'd2;
                ex_op_b_sel_o <= 3'd4;
                    
                alu_op_o <= ALU_ADD;
                    
                wb_src_sel_o <= 1'b0;
                gpr_we_a_o <= 1'b0;
                
                mem_size_o <= LDST_B;
                mem_req_o <= 1'b0;
                mem_we_o <= 1'b0;
                
                branch_o <= 1'b0;
                jal_o <= 1'b0;
                jalr_o <= 2'b00;
                
                CSRop <= 3'b000;
                csr <= 1'b0;
                
                INT_o_RST <= 1'b0;
                
                illegal_instr_o <= 1'b1;  
            
            end
        
        endcase
    
    end
    
endmodule
