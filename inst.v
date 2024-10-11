module SPI_WRAPPER (input clk, rst_n , Mosi ,ss_n ,
                      output Miso);
    //internal wires
    wire rx_valid, tx_valid;
    wire [9:0]rx_data;
    wire [7:0]tx_data;
    
    SPI_Slave spi_inst(.clk(clk),.rst_n(rst_n),.Mosi(Mosi),.ss_n(ss_n),.tx_valid(tx_valid),.tx_data(tx_data),
                       .Miso(Miso),.rx_valid(rx_valid),.rx_data(rx_data));

    RAM ram_inst(.clk(clk),.rst_n(rst_n),.din(rx_data),.rx_valid(rx_valid),.dout(tx_data),.tx_valid(tx_valid));
endmodule
