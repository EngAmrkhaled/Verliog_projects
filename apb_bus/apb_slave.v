module APB_Slave  #(parameter MEM_WIDTH = 32 , parameter MEM_DEPTH = 1024)(
    input PSEL , PENABLE , PWRITE ,  
    input [31:0] PADDR , PWDATA ,
    input [3:0] PSTRB ,
    input PCLK , PRESETn ,
    output reg [31:0] PRDATA ,
    output PREADY ,
    output reg PSLVERR);
    reg [MEM_DEPTH-1 : 0] cache [MEM_WIDTH-1 : 0];
    
    always @ (posedge PCLK) begin
        if (~PRESETn) begin
            PSLVERR <= 0;
            PRDATA <= 0;
                       end
        else if (PSEL) begin  //here we have just one slave so the PSEL signal is one bit, PSEL only as we will go to the ACCESS state anyway
                               //writing stage
                if (PWRITE) begin     
                     case (PSTRB)
                          4'b0001: cache[PADDR] <= {{24{PWDATA[7]}}, PWDATA[7:0]}; // Store the least significant byte (sb)
                          4'b0010: cache[PADDR] <= {{24{PWDATA[15]}}, PWDATA[15:8], 8'h00}; // Store the second byte with zeroes in the least 8 bits
                          4'b0011: cache[PADDR] <= {{16{PWDATA[15]}}, PWDATA[15:0]}; // Store the least significant half-word (sh)
                          4'b0100: cache[PADDR] <= {{24{PWDATA[23]}}, PWDATA[23:16], 8'h00}; // Store the third byte with zeroes in the least 8 bits
                          4'b0101: cache[PADDR] <= {{16{PWDATA[23]}}, PWDATA[23:16], 8'h00, PWDATA[7:0]}; // Store the third and least significant bytes with zeroes
                          4'b0110: cache[PADDR] <= {{8{PWDATA[23]}}, PWDATA[23:8], 8'h00}; // Store the second and third bytes with zeroes in the least 8 bits
                          4'b0111: cache[PADDR] <= {{8{PWDATA[23]}}, PWDATA[23:0]}; // Store the least significant three bytes (sh)
                          4'b1000: cache[PADDR] <= {PWDATA[31:24], 24'h000000}; // Store the most significant byte without sign extension
                          4'b1001: cache[PADDR] <= {PWDATA[31:24], 16'h0000, PWDATA[7:0]}; // Store the most and least significant bytes without sign extension
                          4'b1010: cache[PADDR] <= {PWDATA[31:23], 8'h00, PWDATA[15:8], 8'h00}; // Store the most significant half-word with zeroes in the least significant byte if PSTRB[0] == 0
                          4'b1011: cache[PADDR] <= {PWDATA[31:23], 8'h00, PWDATA[15:0]}; // Store the most significant half-word and the least significant byte, zeroing the middle byte if necessary
                          4'b1100: cache[PADDR] <= {PWDATA[31:16], 16'h0000}; // Store the most significant and second bytes without sign extension
                          4'b1101: cache[PADDR] <= {PWDATA[31:16], 8'h00, PWDATA[7:0]}; // Store the most significant three bytes with zeroes in the least 8 bits
                          4'b1110: cache[PADDR] <= {PWDATA[31:8], 8'h00}; // Store the most significant three bytes with zeroes in the least 8 bits
                          4'b1111: cache[PADDR] <= PWDATA[31:0]; // Store the full word without sign extension
                         default: cache[PADDR] <= 32'h00000000; // Default case to handle invalid PSTRB values
                     endcase
                     PSLVERR <= 0;
                               end
                     //reading stage
                     else                  begin
                        if (PSTRB != 0)
                            PSLVERR <= 1;  //PSTRB must remain low when reading
                        else begin
                            PRDATA <= cache[PADDR];
                            PSLVERR <= 0;
                             end
                                          end
                           end
      end
     assign PREADY = (PSEL && PENABLE) ? 1 : 0; 
     endmodule    