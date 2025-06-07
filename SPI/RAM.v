module RAM(
    input clk,rst_n,rx_valid,
    input [9:0] din,
    output reg tx_valid,
    output reg [7:0] dout
);

parameter width = 8, depth = 256;
reg [width-1:0] mem[depth-1:0];  //memory

reg [7:0] addr_write;
reg [7:0] addr_read;
integer i;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    // Initialize memory 
    for ( i = 0; i < depth; i = i + 1) begin
      mem[i] <= 8'b00000000;
    end
    dout <= 0;
    tx_valid <= 0;
  end
 else begin 
   tx_valid <= 0;
   case (din[9:8])
      2'b00: if(rx_valid) begin // Write address
          addr_write <= din[7:0];   
        end
            
      2'b01: if(rx_valid) begin // Write data   
          mem[addr_write] <= din[7:0];
        end
          
      2'b10: if(rx_valid) begin // Read address   
          addr_read <= din[7:0];
            end

      2'b11: begin // Read data
          tx_valid <= 1;
          mem[addr_read]<=mem[addr_write];
        end
             endcase
end
end
endmodule

