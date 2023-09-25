module Interrupt_Controller(

    input CLK,
    input arstn_i,
    
    input [31:0] mie,
    input [31:0] int_req,
    
    input INT_RST,
    
    output [31:0] mcause,
    output logic [31:0] int_fin,
    
    output logic INT_o
    
    );
    
    logic [4:0] count;
    logic buffer;
    
    logic interrupt;
    /*
    initial begin
        
        count <= 5'd0;
        buffer <= 1'd0;
        int_fin <= 32'd0;
        
        interrupt <= 1'd0;
        
    end */
    
    assign mcause = { 27'h4000000, count };
    assign interrupt = mie[count] & int_req[count];
    
    
    always_ff @( posedge CLK ) begin
    
        if ( !arstn_i ) begin
        
            count <= 5'd0;
            buffer <= 1'd0;
            int_fin <= 32'd0;  
            
            INT_o <= 1'b0;
        
        end else
    
        if ( INT_RST ) begin
        
            int_fin[count] <= interrupt & INT_RST;
        
            count <= 5'd0;
            buffer <= 1'd0;
   

        end else begin  
           
            if ( !interrupt ) 
            
                count <= count + 1'b1;
                
            else begin     
            
                INT_o <= buffer ^ interrupt;
                
                buffer <= interrupt;

            end
        
        end
  
    end
   
endmodule
