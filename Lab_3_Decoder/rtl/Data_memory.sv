module Data_memory #( parameter DEPTH = 256, WIDTH = 32 )(

    input [WIDTH - 1:0] A,
    
    input WE,
    input CLK,
    
    input mem_req,
    input [2:0] mem_size,
    
    input [WIDTH - 1:0] WD,
    output logic [WIDTH - 1:0] RD
    
    );
    
    import RISC_V_pac::*;
    
    logic [WIDTH - 1:0] RAM [0:DEPTH - 1];
    
    always_comb begin
    
        if ( mem_req ) begin // Чтение
        
            case ( mem_size )
            
                LDST_B: RD <= { { 24{RAM[A][7]} } ,RAM[A][7:0] };
                LDST_H: RD <= { { 16{RAM[A][15]} } ,RAM[A][15:0] };
                LDST_W: RD <= RAM[A][31:0];
                LDST_BU: RD <= { 24'd0 , RAM[A][7:0] };
                LDST_HU: RD <= { 16'd0 , RAM[A][15:0] };
            
            endcase
        
        end
    
    end
    
    always_ff @( posedge CLK ) begin
        
        if ( mem_req )
        
            if ( WE ) 
            
                case ( mem_size )
            // Byte enable
                    LDST_B: RAM[A] <= WD;
                    LDST_H: RAM[A] <= WD;
                    LDST_W: RAM[A] <= WD;
            
                endcase
    
    end
    
endmodule
