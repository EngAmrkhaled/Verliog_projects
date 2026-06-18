module read_ptr #(parameter ADDR_WIDTH = 4) (
    input wire rclk,
    input wire rrst_n,
    input wire rinc,   //read order         
    input wire [ADDR_WIDTH:0] sync_wptr, 
    
    output wire [ADDR_WIDTH-1:0] raddr,   
    output reg [ADDR_WIDTH:0] rptr,       
    output wire rempty                    
);

    assign rempty = (sync_wptr == rptr);
    
    assign raddr = rptr[ADDR_WIDTH-1:0];

    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr <= 0;
        end else if (rinc & ~rempty) begin 
            rptr <= rptr + 1;
        end
    end

endmodule