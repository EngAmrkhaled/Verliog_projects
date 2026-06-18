`timescale 1ns/1ps

module async_fifo_tb;

    // =======================================================
    // Parameters Definition
    // =======================================================
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;
    parameter DEPTH = 16;

    // =======================================================
    // Testbench Signals
    // =======================================================
    // Write Domain
    reg wclk;
    reg wrst_n;
    reg winc;
    reg [DATA_WIDTH-1:0] wdata;
    wire wfull;

    // Read Domain
    reg rclk;
    reg rrst_n;
    reg rinc;
    wire [DATA_WIDTH-1:0] rdata;
    wire rempty;

    // Loop iterator
    integer i;

    // =======================================================
    // Device Under Test (DUT) Instantiation
    // =======================================================
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wdata(wdata),
        .wfull(wfull),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rdata(rdata),
        .rempty(rempty)
    );

    // =======================================================
    // Clock Generation 
    // Using completely different frequencies to test CDC
    // =======================================================
    
    // Write Clock: 100 MHz (Period = 10ns)
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // Read Clock: ~41.6 MHz (Period = 24ns)
    initial begin
        rclk = 0;
        forever #12 rclk = ~rclk;
    end

    // =======================================================
    // Helper Tasks for Stimulus
    // =======================================================
    
    // Task to write data safely
    task write_data(input [DATA_WIDTH-1:0] data_in);
        begin
            @(negedge wclk);
            if (!wfull) begin
                winc = 1;
                wdata = data_in;
            end else begin
                // Overflow condition check
                $display("Time: %0t | WARNING: Attempted to write to FULL FIFO. Data = %h dropped.", $time, data_in);
                winc = 0;
            end
            @(negedge wclk);
            winc = 0;
        end
    endtask

    // Task to read data safely
    task read_data();
        begin
            @(negedge rclk);
            if (!rempty) begin
                rinc = 1;
            end else begin
                // Underflow condition check
                $display("Time: %0t | WARNING: Attempted to read from EMPTY FIFO.", $time);
                rinc = 0;
            end
            @(negedge rclk);
            rinc = 0;
            
            // Allow a tiny delay for output to settle before displaying
            #1; 
            $display("Time: %0t | READ DATA OUT: %h", $time, rdata);
        end
    endtask

    // =======================================================
    // Main Test Sequence
    // =======================================================
    initial begin
        // Initialize all inputs to 0
        winc = 0;
        wdata = 0;
        rinc = 0;
        wrst_n = 0;
        rrst_n = 0;

        // ---------------------------------------------------
        // TEST 1: System Reset
        // ---------------------------------------------------
        $display("\n--- TEST 1: System Reset ---");
        // Hold reset for a few cycles
        #30; 
        wrst_n = 1; // Release write reset
        rrst_n = 1; // Release read reset
        #30;

        // ---------------------------------------------------
        // TEST 2: Write till FULL
        // ---------------------------------------------------
        $display("\n--- TEST 2: Write till FULL ---");
        // Write 16 values (DEPTH limit)
        for (i = 0; i < DEPTH; i = i + 1) begin
            write_data(i + 8'hA0); // Write dummy sequence: A0, A1, A2...
        end
        
        // Wait to allow signals to cross clock domains
        #50; 
        if (wfull) $display("PASS: FIFO is successfully FULL.");
        else $display("FAIL: wfull flag not asserted.");

        // ---------------------------------------------------
        // TEST 3: Write Overflow Check
        // ---------------------------------------------------
        $display("\n--- TEST 3: Write Overflow Check ---");
        // Attempting to write one more item; Should be blocked
        write_data(8'hFF); 

        // ---------------------------------------------------
        // TEST 4: Read till EMPTY
        // ---------------------------------------------------
        $display("\n--- TEST 4: Read till EMPTY ---");
        // Read out all 16 values
        for (i = 0; i < DEPTH; i = i + 1) begin
            read_data();
        end

        // Wait to allow signals to cross clock domains
        #50;
        if (rempty) $display("PASS: FIFO is successfully EMPTY.");
        else $display("FAIL: rempty flag not asserted.");

        // ---------------------------------------------------
        // TEST 5: Read Underflow Check
        // ---------------------------------------------------
        $display("\n--- TEST 5: Read Underflow Check ---");
        // Attempting to read when empty; Should be blocked
        read_data(); 

        // ---------------------------------------------------
        // TEST 6: Concurrent Read and Write
        // Using 'fork...join' to run two processes in parallel
        // ---------------------------------------------------
        $display("\n--- TEST 6: Concurrent Read and Write ---");
        fork
            // Process 1: Write continuously
            begin
                for (i = 0; i < 8; i = i + 1) begin
                    write_data(i + 8'hC0); // Write C0, C1, C2...
                    #10; // small delay between writes
                end
            end
            
            // Process 2: Read simultaneously (slightly delayed start)
            begin
                #25; 
                for (i = 0; i < 8; i = i + 1) begin
                    read_data();
                    #15; // small delay between reads
                end
            end
        join

        // ---------------------------------------------------
        // End of Simulation
        // ---------------------------------------------------
        $display("\n--- All Tests Completed Successfully ---");
        #100;
        $finish;
    end

    // =======================================================
    // Waveform Generation (Optional - for GTKWave/ModelSim)
    // =======================================================
    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, async_fifo_tb);
    end

endmodule