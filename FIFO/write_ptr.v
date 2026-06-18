module write_ptr #(
    parameter ADDR_WIDTH = 4
) (
    input wire wclk,
    input wire wrst_n,
    input wire winc,            
    input wire [ADDR_WIDTH:0] sync_rptr, 

    output wire wclken,                  
    output wire [ADDR_WIDTH-1:0] waddr,  
    output reg  [ADDR_WIDTH:0] wptr,      
    output wire wfull                    
);

 //write in memory
    assign wclken = winc & ~wfull;

    assign waddr = wptr[ADDR_WIDTH-1:0];

    assign wfull = (wptr[ADDR_WIDTH]     != sync_rptr[ADDR_WIDTH]) && 
                   (wptr[ADDR_WIDTH-1:0] == sync_rptr[ADDR_WIDTH-1:0]);

    // (Sequential Logic)
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr <= 0;
        end else if (wclken) begin
            wptr <= wptr + 1;
        end
    end

endmodule