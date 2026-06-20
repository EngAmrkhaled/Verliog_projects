module SPI_Wrapper #(
    parameter MEM_DEPTH = 256, parameter ADDR_SIZE = 8)(
    input clk,
    input rst_n,
    input MOSI,
    input SS_n,
    output MISO
);

    // Internal wires to connect SPI Slave and RAM modules
    wire [9:0] rx_data_wire;
    wire rx_valid_wire;
    wire [7:0] tx_data_wire;
    wire tx_valid_wire;

    // Instantiation of the SPI Slave Module
    SPI_SLAVE SPI (
        .clk(clk),
        .rst_n(rst_n),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .tx_data(tx_data_wire),
        .tx_valid(tx_valid_wire),
        .MISO(MISO),
        .rx_valid(rx_valid_wire),
        .rx_data(rx_data_wire)
    );

    // Instantiation of the Single-port Async RAM Module
    RAM #(
        .MEM_DEPTH(MEM_DEPTH),
        .ADDR_SIZE(ADDR_SIZE)
    ) Ram (
        .din(rx_data_wire),
        .clk(clk),
        .rst_n(rst_n),
        .rx_valid(rx_valid_wire),
        .dout(tx_data_wire),
        .tx_valid(tx_valid_wire)
    );

endmodule