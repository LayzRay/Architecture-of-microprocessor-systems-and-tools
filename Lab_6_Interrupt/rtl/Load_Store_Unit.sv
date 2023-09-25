module Load_Store_Unit(

    input clk_i,  // Синхронизация
    input arstn_i, // Сброс внутренних регистров
    
    // Core protocol
    input [31:0] lsu_addr_i, // Адрес, по которому хотим обратиться
    input lsu_we_i,         // 1 - если нужно записать в память
    input [2:0] lsu_size_i, // Размер обрабатываемых данных
    input [31:0] lsu_data_i, // Данные для записи в память
    input lsu_req_i,         // 1 - обратиться к памяти
    output logic lsu_stall_req_o,  // Используется как !enable pc
    output logic [31:0] lsu_data_o, // Данные, считанные из памяти
    
    // Memory protocol
    input [31:0] data_rdata_i,       // Запрошенные данные
    
    output logic data_req_o,         // 1 - Обратиться к памяти
    output logic data_we_o,          // 1 - Запрос на память
    output logic [3:0] data_be_o,    // К каким байтам слова идёт обращение
    output logic [31:0] data_addr_o, // Адрес, по которому идёт обращение
    output logic [31:0] data_wdata_o // Данные, которые требуется записать
    
    );
    
    import RISC_V_pac::*;
    
    parameter IDLE = 2'b00;
    parameter WRITE = 2'b01;
    parameter READ = 2'b10;
    
    logic [1:0] state = IDLE;
    
    assign lsu_stall_req_o = (state == IDLE) && lsu_req_i;
    
    always_comb begin
    
        lsu_data_o <= 0;
    
        case ( lsu_size_i )
                            
                                LDST_B: case ( lsu_addr_i[1:0] )
                                 
                                    2'd0: lsu_data_o <= { {24{data_rdata_i[7]}}, data_rdata_i[7:0] };
                                    2'd1: lsu_data_o <= { {24{data_rdata_i[15]}}, data_rdata_i[15:8] };
                                    2'd2: lsu_data_o <= { {24{data_rdata_i[23]}}, data_rdata_i[23:16] };
                                    2'd3: lsu_data_o <= { {24{data_rdata_i[31]}}, data_rdata_i[31:24] };
                                    
                                endcase
                                
                                LDST_H: case ( lsu_addr_i[1:0] ) 
                                
                                    2'd0: lsu_data_o <= { {16{data_rdata_i[15]}}, data_rdata_i[15:0] };
                                    2'd2: lsu_data_o <= { {16{data_rdata_i[31]}}, data_rdata_i[31:16] };
                                    
                                endcase
                                
                                LDST_W: lsu_data_o <= data_rdata_i;
                                
                                LDST_BU: case ( lsu_addr_i[1:0] )
                                 
                                    2'd0: lsu_data_o <= { 24'd0, data_rdata_i[7:0] };
                                    2'd1: lsu_data_o <= { 24'd0, data_rdata_i[15:8] };
                                    2'd2: lsu_data_o <= { 24'd0, data_rdata_i[23:16] };
                                    2'd3: lsu_data_o <= { 24'd0, data_rdata_i[31:24] };
                                    
                                endcase
                                
                                LDST_HU: case ( lsu_addr_i[1:0] ) 
                                
                                    2'd0: lsu_data_o <= { 16'd0, data_rdata_i[15:0] };
                                    2'd2: lsu_data_o <= { 16'd0, data_rdata_i[31:16] };
                                    
                                endcase
                            
                            endcase
    end
    
    always_ff @( posedge clk_i ) begin
        
        if ( !arstn_i ) begin 
        
           state <= IDLE; 
           
//           lsu_stall_req_o <= 1'b0;
           data_req_o <= 1'b0;
           data_we_o <= 1'b0;
        
        end else
        
            case ( state )
            
                IDLE: begin
                
                    if ( lsu_req_i ) begin
                    
                        data_req_o <= lsu_req_i;
                        data_addr_o <= lsu_addr_i;
                    
                        if ( lsu_we_i ) begin
                        
                            data_we_o <= lsu_we_i;
                                   
                            case ( lsu_size_i )
                
                                LDST_B: begin
                                
                                    data_wdata_o <= {4{lsu_data_i[7:0]}};
                                    
                                    case ( lsu_addr_i[1:0] )
                                    
                                        2'd0: data_be_o <= 4'b0001;
                                        2'd1: data_be_o <= 4'b0010;
                                        2'd2: data_be_o <= 4'b0100;
                                        2'd3: data_be_o <= 4'b1000;
                                    
                                    endcase
                                     
                                end
                                
                                LDST_H: begin
                                
                                    data_wdata_o <= { 2{lsu_data_i[15:0]} };
                                    
                                    case ( lsu_addr_i[1:0] )
                                    
                                        2'd0: data_be_o <= 4'b0011;
                                        2'd2: data_be_o <= 4'b1100;
                                        
                                        default: data_be_o <= 4'b0011;
                                    
                                    endcase
                                    
                                end
                                
                                LDST_W: begin
                                
                                    data_wdata_o <= lsu_data_i;
                                    data_be_o <= 4'b1111;
                                
                                end
                            
                            endcase
                            
//                            lsu_stall_req_o <= 1'b1;
                            
                            state <= WRITE;
                            
                         end else begin
                
//                            lsu_stall_req_o <= 1'b1;     
                            
                            state <= READ;
                         
                         end
                         
                    end else begin
                      
                      state <= IDLE;
                       
//                      lsu_stall_req_o = 1'b0;
                      data_req_o <= 1'b0;
                      data_we_o <= 1'b0;
                     
                     end
                     
                end
                
                WRITE: begin
                    
                    data_we_o <= lsu_we_i; 
                    data_req_o <= lsu_req_i;  
//                    lsu_stall_req_o <= 1'b0;
                    state <= IDLE;
                     
                end 
              
                READ: begin
                
                    

                    data_req_o <= lsu_req_i;
//                    lsu_stall_req_o <= 1'b0;
                    state <= IDLE;
               
                end
            
            endcase 
    end

endmodule
