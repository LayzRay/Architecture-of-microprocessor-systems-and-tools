module RISC_V_Processor
(
  ///////Control pins///////////

  input clk_i,
  input arstn_i

);
    
  ////////////////Main decoder//////////////////////////////////
  
  logic  [ 1 : 0 ] ex_op_a_sel;      
  logic  [ 2 : 0 ] ex_op_b_sel;   //  Выбор 2-го операнда АЛУ
      
  logic  [ 4 : 0 ] alu_op;        //  Выбор операции АЛУ
      
  logic            mem_req;       //  Запрос к памяти данных
  logic            mem_we;        //  Запись в память данных
  logic  [ 2 : 0 ] mem_size;      //  З/Ч байта, полуслова, слова
  
  logic            gpr_we_a;      //  Запись в регистровый файл
  logic            wb_src_sel;    //  Выбор источника записи в регистровый файл
      
  logic            illegal_instr; //  Сигнал ошибки
      
  logic            branch;        //  Условный переход
  logic            jal;           //  Сигнал об инструкции безусловного перехода
  logic            jalr;
  
  //////////////////////////////////////////////////////////////////////////////
  
  logic [ 31 : 0 ] instr;
  
  Main_decoder MD 
  (
  
    .fetched_instr_i( instr         ),
  
    .ex_op_a_sel_o  ( ex_op_a_sel   ),      
    .ex_op_b_sel_o  ( ex_op_b_sel   ),      
  
    .alu_op_o       ( alu_op        ),
  
    .mem_req_o      ( mem_req       ),
    .mem_we_o       ( mem_we        ),           
    .mem_size_o     ( mem_size      ),       
  
    .gpr_we_a_o     ( gpr_we_a      ),         
    .wb_src_sel_o   ( wb_src_sel    ),       
  
    .illegal_instr_o( illegal_instr ),
  
    .branch_o       ( branch        ),      
    .jal_o          ( jal           ),             
    .jalr_o         ( jalr          )
  
  );
  
  /////////////////////////////////////////////////////////////
  
  logic [ 31 : 0 ] PC;

  ////////////Instruction memory////////////////////////

  Instruction_memory IM
  (
    
    .A ( PC     ),
    .RD( instr  )

  );

  ////////////Register file/////////////////////////////
  
  logic [ 31 : 0 ] RD1,
                   RD2;
  
  logic [ 31 : 0 ] source_selected;
  
  Register_file RF 
  (

    .CLK( clk_i           ),
    .WE3( gpr_we_a        ),
    
    .A1( instr[ 19 : 15 ] ),
    .A2( instr[ 24 : 20 ] ),
    .A3( instr[ 11 : 7  ] ),
    
    .WD3( source_selected ),
    
    .RD1( RD1             ), 
    .RD2( RD2             )
  
  );
  
  ///////////////////////////////////////////
  
  logic [ 31 : 0 ] A_selected, B_selected;
  
  logic [ 31 : 0 ] ALU_result;
  
  logic Comparison;
  
  ///////////////////////////////////////////
  
  RISCV_ALU ALU 
  (
  
    .A_i     ( A_selected ),
    .B_i     ( B_selected ),

    .ALUOp_i ( alu_op     ),

    .Result_o( ALU_result ),
    .Flag_o  ( Comparison )
  
  );
  
  ////////////Data memory///////////////////////////////

  logic [ 31 : 0 ] RD;

  Data_memory DM 
  (

    .CLK( clk_i      ),
    .A  ( ALU_result ),
    .WD ( RD2        ),
    .WE ( mem_we     ),
    .RD ( RD         )

  );
  
  /////////////////Immediate////////////////////////////////////////////////////////
  
  logic [ 31 : 0 ] imm_I, imm_S, imm_J, imm_B;
  
  assign imm_I = { { 20{ instr[ 31 ] } }, instr[ 31 : 20 ] };
  assign imm_S = { { 20{ instr[ 31 ] } }, instr[ 31 : 25 ], instr[ 11 : 7 ] };
  assign imm_J = { { 12{ instr[ 31 ] } }, instr[ 31 ], instr[ 19 : 12 ], instr[ 20 ], instr[ 30 : 21 ] };
  assign imm_B = { { 19{ instr[ 31 ] } }, instr[ 31 ], instr[ 7 ], instr[ 30 : 25 ], instr[ 11 : 8 ], 1'b0 };
  
  //////////Select box/////////////////////////////////////////////////////////////////
  
  always_comb
    begin
  
      case ( ex_op_a_sel )
      
          2'd0: A_selected <= RD1;
          2'd1: A_selected <= PC;
          2'd2: A_selected <= 32'd0;
          
          default: A_selected <= 32'd0;
      
      endcase
      
      case ( ex_op_b_sel )
      
          3'd0: B_selected <= RD2;
          3'd1: B_selected <= imm_I;
          3'd2: B_selected <= { instr[ 31 : 12 ], 12'd0 };
          3'd3: B_selected <= imm_S;
          3'd4: B_selected <= 32'd4;
          
          default: B_selected <= 32'd0;
      
      endcase

      source_selected <= ( wb_src_sel ) ? ( RD ) : ( ALU_result );
  
    end
  
  /////////Control PC/////////////////////////////////////
  
  always_ff @( posedge clk_i )
  
    PC <= ( ~arstn_i ) ? ( 32'd0 ) :
        ( ( jalr ) ? ( RD1 + imm_I ) : 
        ( ( jal || Comparison && branch ) ? ( ( branch ) ? ( PC + imm_B ) : ( PC + imm_J ) ) : ( PC + 32'd4 ) ) );
  

  // Ниже описание тоже будет работать, вверху синтаксический сахар
  /*
    if ( ~arstn_i ) 
      PC <= 32'd0; 
    else
      if ( jalr ) 
        PC <= RD1 + imm_I;
      else 
        if ( jal || Comparison && branch )
          if ( branch ) PC <= PC + imm_B;
          else          PC <= PC + imm_J;

        else PC <= PC + 32'd4; */
           
      
  //////////////////////////////////////////////////////////////
    
endmodule
