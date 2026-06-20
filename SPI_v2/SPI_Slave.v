
module SPI_SLAVE (
    input clk, rst_n, MOSI, SS_n,
    input [7:0] tx_data,
    input tx_valid,              // Control signal from RAM indicating data is ready
    output reg MISO,
    output reg rx_valid,         
    output reg [9:0] rx_data     
);

// State encoding using Parameters
parameter IDLE      = 3'b000,
          CHK_CMD   = 3'b001,
          WRITE     = 3'b010,
          READ_ADD  = 3'b011,
          READ_DATA = 3'b100;

reg [2:0] cs, ns;
reg [4:0] bit_cnt;          // 5-bit counter to handle up to 20 cycles during read operation
reg [9:0] rx_shift_reg;     // Shift register for serial-to-parallel conversion (MOSI)
reg [7:0] tx_shift_reg;     // Shift register for parallel-to-serial conversion (MISO)

// =======================================================
// Block 1: State Memory (Sequential)
// =======================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        cs <= IDLE;
    else
        cs <= ns;
end

// =======================================================
// Block 2: Next State Logic (Combinational)
// =======================================================
always @(*) begin
    case (cs)
        IDLE: begin
            if (!SS_n)  ns = CHK_CMD;
            else        ns = IDLE;
        end
        
        CHK_CMD: begin
            if (SS_n)   ns = IDLE;
            else begin
                case ({rx_shift_reg[0], MOSI})
                    2'b00: ns = WRITE;     // Write Address
                    2'b01: ns = WRITE;     // Write Data
                    2'b10: ns = READ_ADD;  // Read Address
                    2'b11: ns = READ_DATA; // Read Data
                    default: ns = IDLE;
                endcase
            end
        end
        
        WRITE:     ns = (SS_n) ? IDLE : WRITE;
        READ_ADD:  ns = (SS_n) ? IDLE : READ_ADD;
        READ_DATA: ns = (SS_n) ? IDLE : READ_DATA;
        default:   ns = IDLE;
    endcase
end

// =======================================================
// Block 3: Sequential Output & Data Path Logic
// =======================================================
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bit_cnt      <= 5'b0;
        rx_shift_reg <= 10'b0;
        rx_data      <= 10'b0;
        rx_valid     <= 1'b0;
        tx_shift_reg <= 8'b0;
        MISO         <= 1'b0;
    end else begin
        case (cs)
            IDLE: begin
                bit_cnt  <= 5'b0;
                rx_valid <= 1'b0;
                MISO     <= 1'b0;
                if (!SS_n) begin
                    rx_shift_reg <= {rx_shift_reg[8:0], MOSI}; // Sample 1st bit
                    bit_cnt      <= 5'b1;
                end
            end
            
            CHK_CMD: begin
                if (!SS_n) begin
                    rx_shift_reg <= {rx_shift_reg[8:0], MOSI}; // Sample 2nd bit
                    bit_cnt      <= bit_cnt + 1;
                end
            end
            
            WRITE, READ_ADD: begin
                bit_cnt <= bit_cnt + 1;
                if (bit_cnt < 9) begin
                    rx_shift_reg <= {rx_shift_reg[8:0], MOSI};
                    rx_valid     <= 1'b0;
                end else if (bit_cnt == 9) begin
                    rx_data      <= {rx_shift_reg[8:0], MOSI};
                    rx_valid     <= 1'b1; // Trigger RAM
                end else begin
                    rx_valid     <= 1'b0;
                end
            end
            
            READ_DATA: begin
                bit_cnt <= bit_cnt + 1;
                
                // Phase 1: Receive 10 bits from Master
                if (bit_cnt < 9) begin
                    rx_shift_reg <= {rx_shift_reg[8:0], MOSI};
                    rx_valid     <= 1'b0;
                end 
                else if (bit_cnt == 9) begin
                    rx_data      <= {rx_shift_reg[8:0], MOSI};
                    rx_valid     <= 1'b1; // Trigger RAM to read
                end 
                else begin
                    rx_valid <= 1'b0; // Deassert rx_valid
                    
                    // Phase 2: Capture stable data from RAM at cycle 11 (Edge 12)
                    if (bit_cnt == 11) begin
                        if (tx_valid) begin
                            MISO         <= tx_data[7];           // Drive MSB immediately
                            tx_shift_reg <= {tx_data[6:0], 1'b0}; // Store the rest
                        end
                    end 
                    // Phase 3: Shift out remaining bits from cycle 12 to 18
                    else if (bit_cnt >= 12 && bit_cnt <= 18) begin
                        MISO         <= tx_shift_reg[7];
                        tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
                    end
                end
            end
            
            default: rx_valid <= 1'b0;
        endcase
    end
end

endmodule