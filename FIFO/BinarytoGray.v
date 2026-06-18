module BinarytoGray #(parameter WIDTH = 4) (
    input wire [WIDTH-1:0] B,
    output wire [WIDTH-1:0] G
);
    assign G = (B >> 1) ^ B;
endmodule