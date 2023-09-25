module Control_Status_Registers (

    input CLK,
    input arstn_i,
    
    input [ 31 : 0 ] PC,
    input [2:0]  OP,
    
    input [11:0] A,
    input [31:0] WD,
    
    input [31:0] mcause,
    
    output [31:0] mie,
    output [31:0] mtvec,
    output [31:0] mepc,
    
    output logic [31:0] RD

    );
    
    logic [31:0] CSRop;
    
    logic mie_en;
    logic mtvec_en;
    logic mepc_en;
    logic mscratch_en;
    logic mcause_en;
    
    logic [31:0] mie_reg;
    logic [31:0] mtvec_reg;
    logic [31:0] mepc_reg;
    logic [31:0] mscratch_reg;
    logic [31:0] mcause_reg;
    
    assign mie = mie_reg;
    assign mtvec = mtvec_reg;
    assign mepc = mepc_reg;
    
    /*
    initial begin
    
        mie_en <= 1'b0;
        mtvec_en <= 1'b0;
        mscratch_en <= 1'b0;
        mepc_en <= 1'b0;
        mcause_en <= 1'b0;
        
        mie_reg <= 32'd0;
        mtvec_reg <= 32'd0;
        mepc_reg <= 32'd0;
        mscratch_reg <= 32'd0;
        mcause_reg <= 32'd0;
    
    end */
    
    always_comb begin
    
        case ( A )
        
            12'h304: RD <= mie_reg;
            12'h305: RD <= mtvec_reg;
            12'h340: RD <= mscratch_reg;
            12'h341: RD <= mepc_reg;
            12'h342: RD <= mcause_reg;
            
            default: RD <= 32'd0;
        
        endcase
        
        case ( OP[1:0] )
        
            2'd0: CSRop <= 32'd0;
            2'd1: CSRop <= WD;
            2'd2: CSRop <= WD | RD;
            2'd3: CSRop <= ~WD & RD;
        
        endcase
        
        mie_en <= 1'b0;
        mtvec_en <= 1'b0;
        mscratch_en <= 1'b0;
        mepc_en <= 1'b0;
        mcause_en <= 1'b0;
        
        case ( A )
            
                12'h304: mie_en <= OP[1] | OP[0];
                12'h305: mtvec_en <= OP[1] | OP[0];
                12'h340: mscratch_en <= OP[1] | OP[0];
                12'h341: mepc_en <= OP[1] | OP[0];
                12'h342: mcause_en <= OP[1] | OP[0];
            endcase
       
       if (OP[2]) begin
            mepc_en <= 1;
            mcause_en <= 1;
       end

    end
    
    always_ff @( posedge CLK ) begin
    
        if ( !arstn_i ) begin
        
            mie_reg <= 32'd0;
            mtvec_reg <= 32'd0;
            mepc_reg <= 32'd0;
            mscratch_reg <= 32'd0;
            mcause_reg <= 32'd0;
        
        end else begin

            if ( mie_en ) begin
            
                mie_reg <= CSRop;
                
            end
            
            if ( mtvec_en ) begin
                
                mtvec_reg <= CSRop;
                
            end
            
            if ( mscratch_en ) begin
                
                mscratch_reg <= CSRop;
            
            end
            
            if ( mepc_en ) begin
            
                if ( OP[2] )
                    mepc_reg <= PC;
                else
                    mepc_reg <= CSRop;
                    
            end
                    
            if ( mcause_en ) begin
            
                if ( OP[2] )
                    mcause_reg <= mcause;
                else
                    mcause_reg <= CSRop;
             
            end
        end                    
    end   
 
endmodule
