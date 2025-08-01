//////////////////////////////////////////////////////////////////////////////////
// Engineer: Amr khaled 
// 
// Create Date: 07/04/2025 06:32:59 PM
// Module Name: write_ptr_handler
// Project Name: FIFO
//////////////////////////////////////////////////////////////////////////////////
module wptr_handler #(parameter PTR_WIDTH=3) (   // ptr width is 3 bit but we will an extra bit for knowing wrap so total is 4
  input wclk, wrst_n, w_en,
  input [PTR_WIDTH:0] g_rptr_sync,
  output reg [PTR_WIDTH:0] b_wptr, g_wptr,
  output reg full
);

  wire [PTR_WIDTH:0] b_wptr_next;
  wire [PTR_WIDTH:0] g_wptr_next;
   
  reg wrap_around;
  wire wfull;
  
  assign b_wptr_next = b_wptr + (w_en & !full);
  assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;
  
  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      b_wptr <= 0;
      g_wptr <= 0;
      wrap_around <= 0;
    end
    else begin
      b_wptr <= b_wptr_next;
      g_wptr <= g_wptr_next;
      wrap_around <= (b_wptr_next[PTR_WIDTH] != b_wptr[PTR_WIDTH]); // complete wrap (7 to 0 again)
    end
  end
  
  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) full <= 0;
    else        full <= wfull;
  end

  assign wfull = (g_wptr_next == {~g_rptr_sync[PTR_WIDTH:PTR_WIDTH-1], g_rptr_sync[PTR_WIDTH-2:0]});

endmodule