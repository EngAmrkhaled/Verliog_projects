module RAM #(
    parameter MEM_DEPTH = 256, 
    parameter ADDR_SIZE = 8
)(
    input [9:0] din,
    input clk, rst_n, rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);
  
    // Internal memory array: 256 words, each 8-bits wide
    reg [7:0] mem [MEM_DEPTH-1:0];
    
    // Internal registers to hold write and read addresses
    reg [ADDR_SIZE-1:0] wr_addr;
    reg [ADDR_SIZE-1:0] rd_addr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout     <= 8'b0;
            tx_valid <= 1'b0;
            wr_addr  <= 0;
            rd_addr  <= 0;
        end else begin
            if (rx_valid) begin
                case (din[9:8])
                    2'b00: begin
                        wr_addr  <= din[7:0]; // Hold din[7:0] internally as write address
                        tx_valid <= 1'b0;
                    end
                    
                    2'b01: begin
                        mem[wr_addr] <= din[7:0]; // Write din[7:0] into the memory array
                        tx_valid     <= 1'b0;
                    end
                    
                    2'b10: begin
                        rd_addr  <= din[7:0]; // Hold din[7:0] internally as read address
                        tx_valid <= 1'b0;
                    end
                    
                    2'b11: begin
                        dout     <= mem[rd_addr]; // Read the memory word from the stored read address
                        tx_valid <= 1'b1;         // Assert tx_valid to notify the SPI Slave
                    end
                    
                    default: tx_valid <= 1'b0;
                endcase
            end
        end
    end
endmodule
