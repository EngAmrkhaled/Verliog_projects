//`timescale 1ns / 1ps


//module DSP_proj(
//    // Reset signals for different pipeline stages
//    input RSTA, RSTB, RSTC, RSTD, RSTM, RSTCARRYIN, RSTOPMODE, RSTP,
//    // Clock enable signals for different pipeline stages  
//    input CEA, CEB, CEC, CED, CEM, CEP, CEOPMODE, CECARRYIN,
//    // Data inputs
//    input [17:0] A, B, D, BCIN,     // 18-bit inputs
//    input [47:0] C, PCIN,           // 48-bit inputs
//    input clk, carryin,             // Clock and carry input
//    input [7:0] opmode,             // Operation mode control
//    // Data outputs
//    output reg [35:0] M,            // Multiplier output
//    output reg [47:0] P, PCOUT,     // Post-adder output and cascade
//    output reg [17:0] BCOUT,        // B cascade output
//    output reg carryout, carryoutF  // Carry outputs
//);

//// Configuration Parameters
//parameter A0REG = 0;                // A0 register enable (0=bypass, 1=register)
//parameter A1REG = 1;                // A1 register enable
//parameter B0REG = 0;                // B0 register enable  
//parameter B1REG = 1;                // B1 register enable
//parameter CREG = 1;                 // C register enable
//parameter DREG = 1;                 // D register enable
//parameter MREG = 1;                 // M register enable
//parameter PREG = 1;                 // P register enable
//parameter CARRYINREG = 1;           // Carry input register enable
//parameter CARRYOUTREG = 1;          // Carry output register enable
//parameter OPMODEREG = 1;            // Opmode register enable
//parameter CARRYINSEL = "OPMODE[5]"; // Carry input selection
//parameter B_INPUT = "DIRECT";       // B input selection
//parameter RSTTYPE = "SYNC";         // Reset type

//// Internal combinational signals
//reg [47:0] C_out, out_mux_x, out_mux_z, post_adder_out;
//reg [35:0] M_out, M_out_mult;
//reg [17:0] A_out, A_out2, D_out, B_out, B_out2, B_out3, B2;
//reg CIN, COUT;
//reg [7:0] opmode_out;
//reg Carry_Cascade_out;

//// Pipeline register outputs (wires from register instances)
//wire [17:0] A1_out, A1_out2, D1_out, B1_out, B1_out3;
//wire [35:0] M1_out;
//wire [47:0] P1, C1_out;
//wire CIN1, carryout1;
//wire [7:0] opmode1;

//// Multiplexer unit outputs
//wire [47:0] mux_x_out, mux_z_out;
//wire [17:0] mux_b2_out;
//wire mux_cin_out;

//// Pipeline Register Instances
//// Each register can be enabled/disabled via parameters

//// Operation mode register
//synch #(.F(8), .RSTTYPE(RSTTYPE)) opmode_reg (
//    .reset(RSTOPMODE), .clk(clk), .enable(CEOPMODE), 
//    .Q(opmode1), .D(opmode)
//);

//// A pipeline registers (2 stages possible)
//synch #(.F(18), .RSTTYPE(RSTTYPE)) a0_reg (
//    .reset(RSTA), .clk(clk), .enable(CEA), 
//    .Q(A1_out), .D(A)
//);

//synch #(.F(18), .RSTTYPE(RSTTYPE)) a1_reg (
//    .reset(RSTA), .clk(clk), .enable(CEA), 
//    .Q(A1_out2), .D(A_out)
//);

//// D pipeline register
//synch #(.F(18), .RSTTYPE(RSTTYPE)) d_reg (
//    .reset(RSTD), .clk(clk), .enable(CED), 
//    .Q(D1_out), .D(D)
//);

//// B pipeline registers (2 stages possible)
//synch #(.F(18), .RSTTYPE(RSTTYPE)) b0_reg (
//    .reset(RSTB), .clk(clk), .enable(CEB), 
//    .Q(B1_out), .D(B2)
//);

//synch #(.F(18), .RSTTYPE(RSTTYPE)) b1_reg (
//    .reset(RSTB), .clk(clk), .enable(CEB), 
//    .Q(B1_out3), .D(B_out2)
//);

//// Multiplier output register
//synch #(.F(36), .RSTTYPE(RSTTYPE)) m_reg (
//    .reset(RSTM), .clk(clk), .enable(CEM), 
//    .Q(M1_out), .D(M_out_mult)
//);

//// C input register  
//synch #(.F(48), .RSTTYPE(RSTTYPE)) c_reg (
//    .reset(RSTC), .clk(clk), .enable(CEC), 
//    .Q(C1_out), .D(C)
//);

//// Carry input register
//synch #(.F(1), .RSTTYPE(RSTTYPE)) carryin_reg (
//    .reset(RSTCARRYIN), .clk(clk), .enable(CECARRYIN), 
//    .Q(CIN1), .D(Carry_Cascade_out)
//);

//// Carry output register
//synch #(.F(1), .RSTTYPE(RSTTYPE)) carryout_reg (
//    .reset(RSTCARRYIN), .clk(clk), .enable(CECARRYIN), 
//    .Q(carryout1), .D(COUT)
//);

//// Post-adder output register
//synch #(.F(48), .RSTTYPE(RSTTYPE)) p_reg (
//    .reset(RSTP), .clk(clk), .enable(CEP), 
//    .Q(P1), .D(post_adder_out)
//);

//// Multiplexer Unit Instance
//dsp_mux #(
//    .CARRYINSEL(CARRYINSEL),
//    .B_INPUT(B_INPUT)
//) mux_unit (
//    .M_out(M_out),
//    .P(P),
//    .C_out(C_out),
//    .PCIN(PCIN),
//    .D_out(D_out),
//    .A_out2(A_out2),
//    .B_out3(B_out3),
//    .B(B),
//    .BCIN(BCIN),
//    .opmode_out(opmode_out),
//    .carryin(carryin),
//    .out_mux_x(mux_x_out),
//    .out_mux_z(mux_z_out),
//    .B2(mux_b2_out),
//    .CIN(mux_cin_out)
//);

//// Main Combinational Logic
//always @(*) begin
//    // Operation Mode Pipeline Control
//    // Select between registered and direct opmode
//    if (OPMODEREG)
//        opmode_out = opmode1;       // Use registered opmode
//    else
//        opmode_out = opmode;        // Use direct opmode
    
//    // A Pipeline Control
//    // First stage: A0REG controls A input registration
//    if (A0REG)
//        A_out = A1_out;             // Use registered A
//    else
//        A_out = A;                  // Use direct A input
        
//    // Second stage: A1REG controls second A pipeline stage
//    if (A1REG)
//        A_out2 = A1_out2;           // Use second register stage
//    else
//        A_out2 = A_out;             // Bypass second stage
    
//    // D Pipeline Control
//    if (DREG)
//        D_out = D1_out;             // Use registered D
//    else
//        D_out = D;                  // Use direct D input
    
//    // B Input Selection (from multiplexer unit)
//    B2 = mux_b2_out;
    
//    // B Pipeline Control
//    // First stage: B0REG controls B input registration  
//    if (B0REG)
//        B_out = B1_out;             // Use registered B
//    else
//        B_out = B2;                 // Use selected B input
    
//    // Pre-adder/Subtractor Logic
//    // Controlled by opmode[4] (enable) and opmode[6] (add/sub)
//    case (opmode_out[4])
//        1'b0: B_out2 = B_out;       // Bypass pre-adder
//        1'b1: begin                 // Enable pre-adder
//            case (opmode_out[6])
//                1'b0: B_out2 = D_out + B_out;  // D + B
//                1'b1: B_out2 = D_out - B_out;  // D - B
//            endcase
//        end
//    endcase
    
//    // Second stage: B1REG controls second B pipeline stage
//    if (B1REG)
//        B_out3 = B1_out3;           // Use second register stage
//    else
//        B_out3 = B_out2;            // Bypass second stage
    
//    // B Cascade Output
//    BCOUT = B_out3;
    
//    // 18x18 Multiplier
//    // Multiply final A and B pipeline outputs
//    M_out_mult = B_out3 * A_out2;
    
//    // Multiplier Output Pipeline Control
//    if (MREG)
//        M_out = M1_out;             // Use registered multiplier output
//    else
//        M_out = M_out_mult;         // Use direct multiplier output
    
//    // Multiplier Output Assignment
//    M = M_out;
    
//    // Get multiplexer outputs
//    out_mux_x = mux_x_out;
//    out_mux_z = mux_z_out;
    
//    // C Pipeline Control  
//    if (CREG)
//        C_out = C1_out;             // Use registered C
//    else
//        C_out = C;                  // Use direct C input
    
//    // Carry Input Pipeline Control
//    Carry_Cascade_out = mux_cin_out;
    
//    if (CARRYINREG)
//        CIN = CIN1;                 // Use registered carry input
//    else
//        CIN = Carry_Cascade_out;    // Use direct carry input
    
//    // Post-Adder/Subtractor
//    // Controlled by opmode[7] (0=add, 1=subtract)
//    if (opmode_out[7])
//        {COUT, post_adder_out} = out_mux_z - (out_mux_x + CIN);  // Z - (X + CIN)
//    else
//        {COUT, post_adder_out} = out_mux_z + out_mux_x + CIN;    // Z + X + CIN
    
//    // Carry Output Pipeline Control
//    if (CARRYOUTREG)
//        carryout = carryout1;       // Use registered carry output
//    else
//        carryout = COUT;            // Use direct carry output
    
//    // Carry Output Assignment
//    carryoutF = carryout;
    
//    // P Output Pipeline Control
//    if (PREG)
//        P = P1;                     // Use registered post-adder output
//    else
//        P = post_adder_out;         // Use direct post-adder output
    
//    // P Cascade Output
//    PCOUT = P;
//end

//endmodule

`timescale 1ns / 1ps


module DSP_proj(
    // Reset signals for different pipeline stages
    input RSTA, RSTB, RSTC, RSTD, RSTM, RSTCARRYIN, RSTOPMODE, RSTP,
    // Clock enable signals for different pipeline stages  
    input CEA, CEB, CEC, CED, CEM, CEP, CEOPMODE, CECARRYIN,
    // Data inputs
    input [17:0] A, B, D, BCIN,     // 18-bit inputs
    input [47:0] C, PCIN,           // 48-bit inputs
    input clk, carryin,             // Clock and carry input
    input [7:0] opmode,             // Operation mode control
    // Data outputs
    output reg [35:0] M,            // Multiplier output
    output reg [47:0] P, PCOUT,     // Post-adder output and cascade
    output reg [17:0] BCOUT,        // B cascade output
    output reg carryout, carryoutF  // Carry outputs
);

// Configuration Parameters
parameter A0REG = 1;                // A0 register enable (0=bypass, 1=register)
parameter A1REG = 1;                // A1 register enable
parameter B0REG = 0;                // B0 register enable  
parameter B1REG = 1;                // B1 register enable
parameter CREG = 1;                 // C register enable
parameter DREG = 1;                 // D register enable
parameter MREG = 1;                 // M register enable
parameter PREG = 1;                 // P register enable
parameter CARRYINREG = 1;           // Carry input register enable
parameter CARRYOUTREG = 1;          // Carry output register enable
parameter OPMODEREG = 1;            // Opmode register enable
parameter CARRYINSEL = "OPMODE[5]"; // Carry input selection
parameter B_INPUT = "DIRECT";       // B input selection
parameter RSTTYPE = "SYNC";         // Reset type

// Internal combinational signals
reg [47:0] C_out, out_mux_x, out_mux_z, post_adder_out;
reg [35:0] M_out, M_out_mult;
reg [17:0] A_out, A_out2, D_out, B_out, B_out2, B_out3, B2;
reg CIN, COUT;
reg [7:0] opmode_out;
reg Carry_Cascade_out;

// Pipeline register outputs (wires from register instances)
wire [17:0] A1_out, A1_out2, D1_out, B1_out, B1_out3;
wire [35:0] M1_out;
wire [47:0] P1, C1_out;
wire CIN1, carryout1;
wire [7:0] opmode1;

// Multiplexer unit outputs
wire [47:0] mux_x_out, mux_z_out;
wire [17:0] mux_b2_out;

wire mux_cin_out;

// Pipeline Register Instances
// Each register can be enabled/disabled via parameters

// Operation mode register
synch #(.F(8), .RSTTYPE(RSTTYPE)) opmode_reg (
    .reset(RSTOPMODE), .clk(clk), .enable(CEOPMODE), 
    .Q(opmode1), .D(opmode)
);

// A pipeline registers (2 stages possible)
synch #(.F(18), .RSTTYPE(RSTTYPE)) a0_reg (
    .reset(RSTA), .clk(clk), .enable(CEA), 
    .Q(A1_out), .D(A)
);

synch #(.F(18), .RSTTYPE(RSTTYPE)) a1_reg (
    .reset(RSTA), .clk(clk), .enable(CEA), 
    .Q(A1_out2), .D(A_out)
);

// D pipeline register
synch #(.F(18), .RSTTYPE(RSTTYPE)) d_reg (
    .reset(RSTD), .clk(clk), .enable(CED), 
    .Q(D1_out), .D(D)
);

// B pipeline registers (2 stages possible)
synch #(.F(18), .RSTTYPE(RSTTYPE)) b0_reg (
    .reset(RSTB), .clk(clk), .enable(CEB), 
    .Q(B1_out), .D(B2)
);

synch #(.F(18), .RSTTYPE(RSTTYPE)) b1_reg (
    .reset(RSTB), .clk(clk), .enable(CEB), 
    .Q(B1_out3), .D(B_out2)
);

// Multiplier output register
synch #(.F(36), .RSTTYPE(RSTTYPE)) m_reg (
    .reset(RSTM), .clk(clk), .enable(CEM), 
    .Q(M1_out), .D(M_out_mult)
);

// C input register  
synch #(.F(48), .RSTTYPE(RSTTYPE)) c_reg (
    .reset(RSTC), .clk(clk), .enable(CEC), 
    .Q(C1_out), .D(C)
);

// Carry input register
synch #(.F(1), .RSTTYPE(RSTTYPE)) carryin_reg (
    .reset(RSTCARRYIN), .clk(clk), .enable(CECARRYIN), 
    .Q(CIN1), .D(Carry_Cascade_out)
);

// Carry output register
synch #(.F(1), .RSTTYPE(RSTTYPE)) carryout_reg (
    .reset(RSTCARRYIN), .clk(clk), .enable(CECARRYIN), 
    .Q(carryout1), .D(COUT)
);

// Post-adder output register
synch #(.F(48), .RSTTYPE(RSTTYPE)) p_reg (
    .reset(RSTP), .clk(clk), .enable(CEP), 
    .Q(P1), .D(post_adder_out)
);

// Multiplexer Unit Instance
dsp_mux #(
    .CARRYINSEL(CARRYINSEL),
    .B_INPUT(B_INPUT)
) mux_unit (
    .M_out(M_out),   // out mux for mreg
    .P(P),
    .C_out(C_out),
    .PCIN(PCIN),
    .D_out(D_out),
    .A_out2(A_out2),
    .B_out3(B_out3),
    .B(B),
    .BCIN(BCIN),
    .opmode_out(opmode_out),
    .carryin(carryin),
    .out_mux_x(mux_x_out),
    .out_mux_z(mux_z_out),
    .B2(mux_b2_out),             //??? ??? ???? ?? b
    .CIN(mux_cin_out)
);

// Main Combinational Logic
always @(*) begin
    // Operation Mode Pipeline Control
    // Select between registered and direct opmode
    // OPMODE selection
    case (OPMODEREG)
        1'b1: opmode_out = opmode1;    // Use registered opmode
        1'b0: opmode_out = opmode;     // Use direct opmode
    endcase
    
    // A Pipeline Control - First stage
    case (A0REG)
        1'b1: A_out = A1_out;          // Use registered A
        1'b0: A_out = A;               // Use direct A input
    endcase
    
    // A Pipeline Control - Second stage
    case (A1REG)
        1'b1: A_out2 = A1_out2;        // Use second register stage
        1'b0: A_out2 = A_out;          // Bypass second stage
    endcase
    
    // D Pipeline Control
    case (DREG)
        1'b1: D_out = D1_out;          // Use registered D
        1'b0: D_out = D;               // Use direct D input
    endcase
    
    // B Input Selection
    B2 = mux_b2_out;
    
    // B Pipeline Control - First stage
    case (B0REG)
        1'b1: B_out = B1_out;          // Use registered B
        1'b0: B_out = B2;              // Use selected B input
    endcase

   
    // Pre-adder/Subtractor Logic
    // Controlled by opmode[4] (enable) and opmode[6] (add/sub)
    case (opmode_out[4])
        1'b0: B_out2 = B_out;       // Bypass pre-adder
        1'b1: begin                 // Enable pre-adder
            case (opmode_out[6])
                1'b0: B_out2 = D_out + B_out;  // D + B
                1'b1: B_out2 = D_out - B_out;  // D - B
            endcase
        end
    endcase
    
    // Second stage: B1REG controls second B pipeline stage
     case (B1REG)
     1'b0 : B_out3 = B_out2;
     1'b1 : B_out3 = B1_out3;
     endcase
      
    // B Cascade Output
    BCOUT = B_out3;
    
    // 18x18 Multiplier
    // Multiply final A and B pipeline outputs
    M_out_mult = B_out3 * A_out2;
    
    // Multiplier Output Pipeline Control
    case (MREG)
             1'b0 : B_out3 = M_out_mult;
             1'b1 : M_out = M1_out;
    endcase
    // Multiplier Output Assignment
    M = M_out;
    
    // Get multiplexer outputs
    out_mux_x = mux_x_out;
    out_mux_z = mux_z_out;
    
    //C port
    case (CREG)
                     1'b0 : C_out = C;
                     1'b1 : C_out = C1_out;
    endcase
    
    // Carry Input Pipeline Control
    Carry_Cascade_out = mux_cin_out;
    
    case (CARRYINREG)
                             1'b0 : CIN = Carry_Cascade_out;
                             1'b1 : CIN = CIN1;
    endcase
    // Post-Adder/Subtractor
    // Controlled by opmode[7] (0=add, 1=subtract)
    case (opmode_out[7])
                              1'b0 : {COUT, post_adder_out} = out_mux_z + out_mux_x + CIN;    // Z + X + CIN
                              1'b1 : {COUT, post_adder_out} = out_mux_z - (out_mux_x + CIN);  // Z - (X + CIN)
            endcase
    // Carry Output Pipeline Control
    case (CARRYOUTREG)
                            1'b0 : carryout = COUT; 
                            1'b1 : carryout = carryout1;       // Use registered carry output
            endcase
    // Carry Output Assignment
    carryoutF = carryout;
    
    // P Output Pipeline Control
    case (PREG)
                             1'b0 : P = post_adder_out;         // Use direct post-adder output
                             1'b1 : P = P1;                     // Use registered post-adder output
                    endcase
    // P Cascade Output
    PCOUT = P;
end

endmodule

