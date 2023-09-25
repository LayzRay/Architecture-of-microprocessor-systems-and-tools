module RISC_V_Processor(

    ///////Control pins///////////

    input clk_i,
    input arstn_i,
    
    ///////Instructions pins//////////////
    
    input  [31:0] instr_rdata_i,
    output [31:0] instr_addr_o,

    ///////Data pins//////////////////////
    
    input  [31:0] data_rdata_i,
    
    output data_req_o,
    output data_we_o,
    output [3:0] data_be_o,
    output [31:0] data_addr_o,
    output [31:0] data_wdata_o,
    
    //////////Interrupt pins///////////////
    
    input INT_o,
    input [31:0] mcause,
    
    output INT_RST,
    output [31:0] mie

    );
    
    ////////////////Main decoder//////////////////////////////////
    
    logic  [1:0]   ex_op_a_sel;      
    logic  [2:0]   ex_op_b_sel;      //  Выбор 2-го операнда АЛУ
    
    logic  [4:0]   alu_op;           //  Выбор операции АЛУ
    
    logic  [2:0]   CSRop;
    logic          csr;
    
    logic          mem_req;          //  Запрос к памяти данных
    logic          mem_we;           //  Запись в память данных
    logic  [2:0]   mem_size;         //  З/Ч байта, полуслова, слова
    
    logic          gpr_we_a;         //  Запись в регистровый файл
    logic          wb_src_sel;       //  Выбор источника записи в регистровый файл
    
    logic          illegal_instr;    //  Сигнал ошибки
    
    logic          branch;           //  Условный переход
    logic          jal;              //  Сигнал об инструкции безусловного перехода
    logic  [1:0]   jalr;
    
    //////////////////////////////////////////////////////////////////////////////
    
    Main_decoder MD (
    
        .fetched_instr_i( instr_rdata_i ),
        
        .INT_o( INT_o ),
        .INT_o_RST( INT_RST ),
    
        .ex_op_a_sel_o( ex_op_a_sel ),      
        .ex_op_b_sel_o( ex_op_b_sel ),      
    
        .alu_op_o( alu_op ),
        
        .CSRop( CSRop ),
        .csr( csr ),
    
        .mem_req_o( mem_req ),
        .mem_we_o( mem_we ),           
        .mem_size_o( mem_size ),       
    
        .gpr_we_a_o( gpr_we_a ),         
        .wb_src_sel_o( wb_src_sel ),       
    
        .illegal_instr_o( illegal_instr ),
    
        .branch_o( branch ),      
        .jal_o( jal ),             
        .jalr_o( jalr )
    
    );
    
    /////////////////////////////////////////////////////////////
    
    logic [31:0] PC = 32'd0;
    
    assign instr_addr_o = PC;
    
    ////////////Register file/////////////////////////////
    
    logic [31:0] RD1, RD2;
    
    logic [31:0] Source_selected_1, Source_selected_2;
    
    Register_file RF (
    
        .CLK( clk_i ),
        .WE3( gpr_we_a ),
        
        .A1( instr_rdata_i[19:15] ),
        .A2( instr_rdata_i[24:20] ),
        .A3( instr_rdata_i[11:7] ),
        
        .WD3( Source_selected_2 ),
        
        .RD1( RD1 ),
        .RD2( RD2 )
    
    );
    
    ///////////////////////////////////////////
    
    logic [31:0] A_selected, B_selected;
    
    logic [31:0] ALU_result;
    
    logic Comparison;
    
    ///////////////////////////////////////////
    
    RISCV_ALU ALU (
    
    .A_i( A_selected ),
    .B_i( B_selected ),
    
    .ALUOp_i( alu_op ),
    
    .Result_o( ALU_result ),
    .Flag_o( Comparison )
    
    );
    
    ////////////Load/Store unit/////////
    
    logic [31:0] RD;
    logic lsu_stall_req; // Stop all
    
    Load_Store_Unit LSU (
    
        .clk_i( clk_i ),
        .arstn_i( arstn_i ),
    
        .lsu_addr_i( ALU_result ),
        .lsu_we_i( mem_we ),
        .lsu_size_i( mem_size ),
        .lsu_data_i( RD2 ),
        .lsu_req_i( mem_req ),
        .lsu_stall_req_o( lsu_stall_req ),
        .lsu_data_o( RD ),
        
        .data_rdata_i( data_rdata_i ),
        .data_req_o( data_req_o ),
        .data_we_o( data_we_o ),
        .data_be_o( data_be_o ),
        .data_addr_o( data_addr_o ),
        .data_wdata_o( data_wdata_o )
    
    );
    
    /////////Control and Status Registers/////////////////////////////////////////////
    
    logic [31:0] mtvec, mepc;
    logic [31:0] CSR_RD;
    
    Control_Status_Registers CSR (
    
        .CLK( clk_i ),
        .arstn_i( arstn_i ),
    
        .PC( PC ),
        .OP( CSRop ),
        
        .A( instr_rdata_i[31:20] ),
        .WD( RD1 ),
        
        .mcause( mcause ),
        
        .mie( mie ),
        .mtvec( mtvec ),
        .mepc( mepc),
        .RD( CSR_RD )
    
    ); 
    
    /////////////////Immediate////////////////////////////////////////////////////////
    
    logic [31:0] imm_I, imm_S, imm_J, imm_B;
    
    assign imm_I = { { 20{ instr_rdata_i[31] } }, instr_rdata_i[31:20] };
    assign imm_S = { { 20{ instr_rdata_i[31] } }, instr_rdata_i[31:25], instr_rdata_i[11:7] };
    assign imm_J = { { 12{ instr_rdata_i[31] } }, instr_rdata_i[31], instr_rdata_i[19:12], instr_rdata_i[20], instr_rdata_i[30:21] };
    assign imm_B = { { 19{ instr_rdata_i[31] } }, instr_rdata_i[31], instr_rdata_i[7], instr_rdata_i[30:25], instr_rdata_i[11:8], 1'b0 };
    
    //////////Select box/////////////////////////////////////////////////////////////////
    
    always_comb begin
    
        case ( ex_op_a_sel )
        
            2'd0: A_selected <= RD1;
            2'd1: A_selected <= PC;
            2'd2: A_selected <= 32'd0;
            
            default: A_selected <= 32'd0;
        
        endcase
        
        case ( ex_op_b_sel )
        
            3'd0: B_selected <= RD2;
            3'd1: B_selected <= imm_I;
            3'd2: B_selected <= { instr_rdata_i[31:12], 12'd0 };
            3'd3: B_selected <= imm_S;
            3'd4: B_selected <= 32'd4;
            
            default: B_selected <= 32'd0;
        
        endcase
        
        if ( wb_src_sel ) Source_selected_1 <= RD;
        else              Source_selected_1 <= ALU_result;
        
        if ( csr ) Source_selected_2 <= CSR_RD;
        else       Source_selected_2 <= Source_selected_1;
    
    end
    
    /////////Control PC/////////////////////////////////////
    
    always_ff @( posedge clk_i )
    
        if ( !arstn_i ) PC <= 32'd0; 
        else 
        
            if ( !lsu_stall_req )
            
                case ( jalr )
                
                    2'd0: 
                     
                        if ( jal | Comparison & branch )
            
                            if ( branch ) PC <= PC + imm_B;
                            else          PC <= PC + imm_J;
                
                        else PC <= PC + 32'd4;
                        
                     2'd1: PC <= RD1 + imm_I;
                     
                     2'd2: PC <= mepc;
                     
                     2'd3: PC <= mtvec;
                
                endcase
             
            else PC <= PC + 32'd0; 
        
    //////////////////////////////////////////////////////////////
    
endmodule
