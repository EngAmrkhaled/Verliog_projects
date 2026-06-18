module Fifo_Mem #(parameter DATA_WIDTH = 8,parameter ADDR_WIDTH = 4) (
    input wire wclk,
    input wire wclken,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [ADDR_WIDTH-1:0] waddr,
    input wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] rdata  
);

    //(2^ADDR_WIDTH)
    localparam DEPTH = 1 << ADDR_WIDTH; 
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge wclk) begin
        if (wclken)
            mem[waddr] <= wdata;
    end

    assign rdata = mem[raddr];

endmodule