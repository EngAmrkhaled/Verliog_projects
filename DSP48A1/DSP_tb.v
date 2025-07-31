
module DSP48A1_tb();

// Test Parameters
parameter CLK_PERIOD = 10;

// DUT Signals
reg RSTA, RSTB, RSTC, RSTD, RSTM, RSTCARRYIN, RSTOPMODE, RSTP;
reg CEA, CEB, CEC, CED, CEM, CEP, CEOPMODE, CECARRYIN;
reg [17:0] A, B, D, BCIN;
reg [47:0] C, PCIN;
reg clk, carryin;
reg [7:0] opmode;

wire [35:0] M;
wire [47:0] P, PCOUT;
wire [17:0] BCOUT;
wire carryout, carryoutF;

// Test Control
integer test_num = 0;
integer passed_tests = 0;
integer failed_tests = 0;
reg [255:0] test_name;

// DUT Instantiation
DSP_proj dut (
    .RSTA(RSTA), .RSTB(RSTB), .RSTC(RSTC), .RSTD(RSTD),
    .RSTM(RSTM), .RSTCARRYIN(RSTCARRYIN), .RSTOPMODE(RSTOPMODE), .RSTP(RSTP),
    .CEA(CEA), .CEB(CEB), .CEC(CEC), .CED(CED),
    .CEM(CEM), .CEP(CEP), .CEOPMODE(CEOPMODE), .CECARRYIN(CECARRYIN),
    .A(A), .B(B), .D(D), .BCIN(BCIN),
    .C(C), .PCIN(PCIN),
    .clk(clk), .carryin(carryin),
    .opmode(opmode),
    .M(M), .P(P), .PCOUT(PCOUT),
    .BCOUT(BCOUT), .carryout(carryout), .carryoutF(carryoutF)
);

// Clock Generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Reset Task
task reset_all();
begin
    $display("\nInitializing system...");
    RSTA = 1; RSTB = 1; RSTC = 1; RSTD = 1;
    RSTM = 1; RSTCARRYIN = 1; RSTOPMODE = 1; RSTP = 1;
    CEA = 1; CEB = 1; CEC = 1; CED = 1;
    CEM = 1; CEP = 1; CEOPMODE = 1; CECARRYIN = 1;
    A = 0; B = 0; D = 0; BCIN = 0;
    C = 0; PCIN = 0; carryin = 0; opmode = 0;

    $display("Applying reset signals...");
    repeat(5) @(negedge clk);

    RSTA = 0; RSTB = 0; RSTC = 0; RSTD = 0;
    RSTM = 0; RSTCARRYIN = 0; RSTOPMODE = 0; RSTP = 0;

    $display("Reset released, system ready.\n");
    repeat(3) @(negedge clk);
end
endtask

// Display Results Task
task display_results(
    input [47:0] expected_P,
    input [35:0] expected_M,
    input [17:0] expected_BCOUT,
    input [255:0] operation_desc
);
reg test_passed;
begin
    test_num = test_num + 1;
    test_passed = (P == expected_P) && (M == expected_M) && (BCOUT == expected_BCOUT);

    $display("------------------------------------------------------------");
    $display("TEST %0d: %s", test_num, test_name);
    $display("Operation: %s", operation_desc);
    $display("Inputs: A=%d, B=%d, D=%d, C=%d, opmode=0x%02X, carryin=%b", A, B, D, C, opmode, carryin);
    $display("Expected: P=%d, M=%d, BCOUT=%d", expected_P, expected_M, expected_BCOUT);
    $display("Actual:   P=%d, M=%d, BCOUT=%d", P, M, BCOUT);
    $display("PCOUT: %d, carryout: %b", PCOUT, carryout);

    if (test_passed) begin
        $display("RESULT: PASS\n");
        passed_tests = passed_tests + 1;
    end else begin
        $display("RESULT: FAIL\n");
        failed_tests = failed_tests + 1;
    end
end
endtask

// Apply inputs and wait for pipeline
task run_test(
    input [17:0] in_A, in_B, in_D,
    input [47:0] in_C,
    input [7:0] in_opmode,
    input in_carryin
);
begin
    A = in_A; B = in_B; D = in_D; C = in_C;
    BCIN = 0; PCIN = 0; carryin = in_carryin; opmode = in_opmode;

    $display("Applying inputs and waiting for pipeline...");
    repeat(6) @(negedge clk);
    $display("Pipeline settled, reading results...\n");
end
endtask

// Main Test Sequence
initial begin
    $display("\n=== DSP48A1 Testbench Start ===\n");
    reset_all();

    // TEST 1
    test_name = "Basic Multiplication (A × B)";
    run_test(18'd10, 18'd5, 18'd0, 48'd0, 8'b00000001, 1'b0);
    display_results(48'd50, 36'd50, 18'd5, "P = A × B = 10 × 5 = 50");

    // TEST 2
    test_name = "Pre-Adder Test ((D + B) × A)";
    run_test(18'd3, 18'd4, 18'd6, 48'd0, 8'b00010001, 1'b0);
    display_results(48'd30, 36'd30, 18'd10, "P = (D + B) × A = (6 + 4) × 3 = 30");

    // TEST 3
    test_name = "Pre-Subtractor Test ((D - B) × A)";
    run_test(18'd5, 18'd3, 18'd8, 48'd0, 8'b01010001, 1'b0);
    display_results(48'd25, 36'd25, 18'd5, "P = (D - B) × A = (8 - 3) × 5 = 25");

    // TEST 4
    test_name = "Zero Test (All inputs zero)";
    run_test(18'd0, 18'd0, 18'd0, 48'd0, 8'b00000000, 1'b0);
    display_results(48'd0, 36'd0, 18'd0, "P = 0 (All inputs zero)");

    // Final Report
    $display("\n=== Final Report ===");
    $display("Total Tests Run:   %0d", test_num);
    $display("Tests Passed:      %0d", passed_tests);
    $display("Tests Failed:      %0d", failed_tests);
    $display("Success Rate:      %0.1f%%", (passed_tests * 100.0) / test_num);
    if (failed_tests == 0)
        $display("RESULT: ALL TESTS PASSED - DESIGN VERIFIED.");
    else
        $display("RESULT: %0d TEST(S) FAILED - DESIGN NEEDS REVIEW.", failed_tests);
    $display("Simulation Time:   %0t\n", $time);

    $finish;
end

// Waveform dump
initial begin
    $dumpfile("dsp48a1_focused_tb.vcd");
    $dumpvars(0, DSP48A1_tb);
end

// Timeout protection
initial begin
    #5000;
    $display("TIMEOUT: Simulation exceeded maximum time limit.");
    $finish;
end

endmodule
