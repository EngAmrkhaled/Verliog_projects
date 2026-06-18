module Synchronizer #(parameter WIDTH = 4) (
    input wire clk,
    input wire rst_n,
    input wire [WIDTH-1:0] data_in,
    output wire [WIDTH-1:0] data_out
);
    wire [WIDTH-1:0] data_inter;

    FF #(.WIDTH(WIDTH)) FF_Inst1 (
        .clk(clk), .rst_n(rst_n), .d(data_in), .q(data_inter)
    );

    FF #(.WIDTH(WIDTH)) FF_Inst2 (
        .clk(clk), .rst_n(rst_n), .d(data_inter), .q(data_out)
    );
    
endmodule