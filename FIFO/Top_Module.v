module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    // Write Domain Signals
    input wire wclk,
    input wire wrst_n,
    input wire winc,
    input wire [DATA_WIDTH-1:0] wdata,
    output wire wfull,

    // Read Domain Signals
    input wire rclk,
    input wire rrst_n,
    input wire rinc,
    output wire [DATA_WIDTH-1:0] rdata,
    output wire rempty
);

    // =======================================================
    // (Internal Wires)
    // =======================================================
    
    // memory
    wire wclken;
    wire [ADDR_WIDTH-1:0] waddr, raddr;
    
    // ptrs to B2G
    wire [ADDR_WIDTH:0] wptr_bin, rptr_bin;
    
    // after G conversion
    wire [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    
    // after Synchronizer
    wire [ADDR_WIDTH:0] sync_wptr_gray, sync_rptr_gray;
    
    // after B conversion
    wire [ADDR_WIDTH:0] sync_wptr_bin, sync_rptr_bin;


    // =======================================================
    // (Memory Instantiation)
    // =======================================================
    Fifo_Mem #(
        .DATA_WIDTH(DATA_WIDTH), 
        .ADDR_WIDTH(ADDR_WIDTH)
    ) fifo_mem_inst (
        .wclk(wclk),
        .wclken(wclken),
        .wdata(wdata),
        .waddr(waddr),
        .raddr(raddr),
        .rdata(rdata)
    );

    // =======================================================
    // (Write Domain Logic)
    // =======================================================
    write_ptr #(.ADDR_WIDTH(ADDR_WIDTH)) wptr_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .sync_rptr(sync_rptr_bin), 
        .wclken(wclken),
        .waddr(waddr),
        .wptr(wptr_bin),
        .wfull(wfull)
    );

    
    BinarytoGray #(.WIDTH(ADDR_WIDTH + 1)) wptr_b2g (
        .B(wptr_bin),
        .G(wptr_gray)
    );

    Synchronizer #(.WIDTH(ADDR_WIDTH + 1)) rptr_sync (
        .clk(wclk),
        .rst_n(wrst_n),
        .data_in(rptr_gray),
        .data_out(sync_rptr_gray)
    );

    GraytoBinary #(.WIDTH(ADDR_WIDTH + 1)) rptr_g2b (
        .G(sync_rptr_gray),
        .B(sync_rptr_bin)
    );

    // =======================================================
    // (Read Domain Logic)
    // =======================================================
    
    read_ptr #(.ADDR_WIDTH(ADDR_WIDTH)) rptr_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .sync_wptr(sync_wptr_bin), 
        .raddr(raddr),
        .rptr(rptr_bin),
        .rempty(rempty)
    );

    BinarytoGray #(.WIDTH(ADDR_WIDTH + 1)) rptr_b2g (
        .B(rptr_bin),
        .G(rptr_gray)
    );

    Synchronizer #(.WIDTH(ADDR_WIDTH + 1)) wptr_sync (
        .clk(rclk),
        .rst_n(rrst_n),
        .data_in(wptr_gray),
        .data_out(sync_wptr_gray)
    );

    GraytoBinary #(.WIDTH(ADDR_WIDTH + 1)) wptr_g2b (
        .G(sync_wptr_gray),
        .B(sync_wptr_bin)
    );

endmodule