module GraytoBinary #(parameter WIDTH = 4) (
    input wire [WIDTH-1:0] G,
    output wire [WIDTH-1:0] B
);
    genvar i;
    generate
        assign B[WIDTH-1] = G[WIDTH-1];
        for (i = WIDTH-2; i >= 0; i = i - 1) begin : gen_bin
            assign B[i] = B[i+1] ^ G[i];
        end
    endgenerate
endmodule