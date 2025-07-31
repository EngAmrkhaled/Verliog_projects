
module synch #(
    parameter F = 18,           // Data width parameter
    parameter RSTTYPE = "SYNC"  // Reset type: "SYNC" or "ASYNC"
) (
    input [F-1:0] D,    // Data input
    input clk,          // Clock signal
    input enable,       // Clock enable signal
    input reset,        // Reset signal
    output reg [F-1:0] Q // Data output
);

generate
    // Synchronous reset implementation
    if (RSTTYPE == "SYNC") begin : SYNC_RST
        always @(posedge clk) begin
            if (reset)
                Q <= 0;         // Reset to zero on reset assertion
            else if (enable)
                Q <= D;         // Load data when enabled
            // Else hold current value
        end
    end 
    // Asynchronous reset implementation
    else begin : ASYNC_RST
        always @(posedge clk or posedge reset) begin
            if (reset)
                Q <= 0;         // Immediate reset regardless of clock
            else if (enable)
                Q <= D;         // Load data when enabled
            // Else hold current value
        end
    end
endgenerate

endmodule