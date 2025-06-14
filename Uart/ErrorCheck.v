`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/07/2025 04:23:16 PM
// Design Name: 
// Module Name: ErrorCheck
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ErrorCheck(
    input wire         reset_n,       //  Active low reset.
    input wire         recieved_flag, //  enable from the sipo unit for the flags.
    input wire         parity_bit,    //  The parity bit from the frame for comparison.
    input wire         start_bit,     //  The Start bit from the frame for comparison.
    input wire         stop_bit,      //  The Stop bit from the frame for comparison.
    input wire  [1:0]  parity_type,   //  Parity type agreed upon by the Tx and Rx units.
    input wire  [7:0]  raw_data,      //  The 8-bits data separated from the data frame.

    output wire [2:0]  error_flag     //  {stop_flag,start_flag,parity_flag}
);

//  Internal
reg error_parity;
reg parity_flag;
reg start_flag;
reg stop_flag;

//  Encoding for types of the parity
localparam ODD        = 2'b01,
           EVEN       = 2'b10;

//  Parity Check logic
always @(*) 
begin
  case (parity_type)
    ODD:     error_parity = (^raw_data)? 1'b0 : 1'b1;
    EVEN:    error_parity = (^raw_data)? 1'b1 : 1'b0;
    default: error_parity = 1'b1;
  endcase
end

// Error Check logic
always @(*) begin
  parity_flag  = (error_parity ^ parity_bit);
  start_flag   = (start_bit || 1'b0);
  stop_flag    = ~(stop_bit && 1'b1);
end

//  Output logic
assign error_flag = (reset_n && recieved_flag)? {stop_flag,start_flag,parity_flag} : 3'b0;

endmodule