`timescale 1ns/1ps

module SPI_Wrapper_tb;

    reg clk;
    reg rst_n;
    reg MOSI;
    reg SS_n;
    wire MISO;

    SPI_Wrapper DUT(
        .clk(clk),
        .rst_n(rst_n),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .MISO(MISO)
    );

    //--------------------------------------------------
    // Clock
    //--------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------
    // Send 10-bit SPI frame
    //--------------------------------------------------
    task send_frame;
        input [9:0] frame;
        integer i;
        begin

            SS_n = 0;

            for(i=9;i>=0;i=i-1) begin
                MOSI = frame[i];
                @(posedge clk);
            end

            SS_n = 1;
            @(posedge clk);

            $display("[%0t] Frame Sent = %b",
                     $time, frame);

        end
    endtask

    //--------------------------------------------------
    // Read transaction
    //--------------------------------------------------
    task read_data;
        input [7:0] addr;
        integer i;
        reg [7:0] miso_data;
        reg [9:0] cmd;
        integer j;
        begin

            //------------------------------------------
            // Read Address Command : 10 + address
            //------------------------------------------
            send_frame({2'b10,addr});

            //------------------------------------------
            // Read Data Command : 11 + dummy
            //------------------------------------------
            SS_n = 0;

          

cmd = {2'b11, 8'h00};

for(j=9; j>=0; j=j-1) begin
    MOSI = cmd[j];
    @(posedge clk);
end

            miso_data = 0;

            // extra clocks for slave output
            repeat(2)
                @(posedge clk);

            for(i=7;i>=0;i=i-1) begin
                @(posedge clk);
                miso_data[i] = MISO;
            end

            SS_n = 1;
            @(posedge clk);

            $display("[%0t] READ ADDR=%h DATA=%h",
                      $time, addr, miso_data);

        end
    endtask

    //--------------------------------------------------
    // Monitor
    //--------------------------------------------------
    initial begin
        $monitor("[%0t] SS=%b MOSI=%b MISO=%b",
                 $time,SS_n,MOSI,MISO);
    end

    //--------------------------------------------------
    // Test Sequence
    //--------------------------------------------------
    initial begin

        rst_n = 0;
        SS_n  = 1;
        MOSI  = 0;

        repeat(3) @(posedge clk);

        rst_n = 1;

        $display("\n========== RESET DONE ==========\n");

        //------------------------------------------------
        // TEST 1
        //------------------------------------------------
        $display("\nTEST1 : Write 0xAA @ Address 0x12\n");

        send_frame({2'b00,8'h12}); // write addr
        send_frame({2'b01,8'hAA}); // write data

        read_data(8'h12);

        //------------------------------------------------
        // TEST 2
        //------------------------------------------------
        $display("\nTEST2 : Write 0x55 @ Address 0x34\n");

        send_frame({2'b00,8'h34});
        send_frame({2'b01,8'h55});

        read_data(8'h34);

        //------------------------------------------------
        // TEST 3
        //------------------------------------------------
        $display("\nTEST3 : Overwrite same address\n");

        send_frame({2'b00,8'h12});
        send_frame({2'b01,8'hF0});

        read_data(8'h12);

        //------------------------------------------------
        // TEST 4
        //------------------------------------------------
        $display("\nTEST4 : Boundary Address 00\n");

        send_frame({2'b00,8'h00});
        send_frame({2'b01,8'h11});

        read_data(8'h00);

        //------------------------------------------------
        // TEST 5
        //------------------------------------------------
        $display("\nTEST5 : Boundary Address FF\n");

        send_frame({2'b00,8'hFF});
        send_frame({2'b01,8'h22});

        read_data(8'hFF);

        //------------------------------------------------
        // TEST 6
        //------------------------------------------------
        $display("\nTEST6 : Read Unwritten Address\n");

        read_data(8'h80);

        $display("\n========== END OF TEST ==========\n");

        #100;
        $finish;
    end

endmodule