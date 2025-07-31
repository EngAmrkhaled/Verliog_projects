

module dsp_mux (
    // Input signals for multiplexers
    input [35:0] M_out,         // Multiplier output
    input [47:0] P,             // Previous P output for feedback
    input [47:0] C_out,         // C pipeline output
    input [47:0] PCIN,          // P cascade input
    input [17:0] D_out,         // D pipeline output  
    input [17:0] A_out2,        // A second pipeline output
    input [17:0] B_out3,        // B final pipeline output
    input [17:0] B,             // Direct B input
    input [17:0] BCIN,          // B cascade input
    input [7:0] opmode_out,     // Operation mode control
    input carryin,              // External carry input
    
    // Output multiplexer results
    output reg [47:0] out_mux_x,    // X multiplexer output  
    output reg [47:0] out_mux_z,    // Z multiplexer output
    output reg [17:0] B2,           // B input selection output
    output reg CIN                  // Final carry input
);

// Parameters for configuration
parameter CARRYINSEL = "OPMODE[5]";  // Carry input selection mode
parameter B_INPUT = "DIRECT";        // B input selection mode

// Internal carry cascade signal
reg Carry_Cascade_out;

always @(*) begin
    // B Input Selection Multiplexer
    // Controls whether B comes from direct input or cascade
    if (B_INPUT == "DIRECT")
        B2 = B;                 // Use direct B input
    else if (B_INPUT == "CASCADE")  
        B2 = BCIN;              // Use cascade B input
    else
        B2 = 18'b0;             // Default to zero
    
    // X Multiplexer (opmode[1:0])
    // Selects first operand for post-adder
    case (opmode_out[1:0])
        2'b00: out_mux_x = 48'b0;                           // Zero
        2'b01: out_mux_x = {{12{M_out[35]}}, M_out};        // Sign-extended multiplier output
        2'b10: out_mux_x = P;                               // Previous P output (feedback)
        2'b11: out_mux_x = {D_out[11:0], A_out2, B_out3};  // Concatenated D:A:B
    endcase
    
    // Z Multiplexer (opmode[3:2]) 
    // Selects second operand for post-adder
    case (opmode_out[3:2])
        2'b00: out_mux_z = 48'b0;       // Zero
        2'b01: out_mux_z = PCIN;        // P cascade input
        2'b10: out_mux_z = P;           // Previous P output (feedback)
        2'b11: out_mux_z = C_out;       // C register output
    endcase
    
    // Carry Input Selection
    // Determines source of carry input to post-adder
    if (CARRYINSEL == "OPMODE[5]")
        Carry_Cascade_out = opmode_out[5];  // Use opmode bit 5
    else if (CARRYINSEL == "CARRYIN")
        Carry_Cascade_out = carryin;        // Use external carry input
    else
        Carry_Cascade_out = 1'b0;           // Default to zero
    
    // Final carry input (will be registered if CARRYINREG=1)
    CIN = Carry_Cascade_out;
end

endmodule

