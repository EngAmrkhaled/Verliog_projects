module SPI_Slave #(parameter DATA_WIDTH = 8, parameter RX_DATA_WIDTH = 10) (
  input clk,Mosi,tx_valid,rst_n,ss_n,
  input [DATA_WIDTH-1:0]tx_data,
  output reg Miso,rx_valid,
  output reg [RX_DATA_WIDTH-1:0] rx_data
);
  
  // State register
  reg [2:0] cs,ns;
  localparam IDLE = 3'b000;
  localparam CHK_CMD = 3'b001;
  localparam READ_DATA = 3'b010;
  localparam READ_ADD = 3'b011;
  localparam WRITE = 3'b100;
// internal to read data or add
  reg read_add; //if high it will write address
//  to store temp
  reg [9:0]w;
  // Counter
  reg [4:0] counter; 
 

//we will need 3 always blocks

//first always for current state
always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            cs <= IDLE;
        end else
            cs <= ns;
    end
 
//second always for next state
always@(*)begin
 case(cs)
   IDLE: begin if(ss_n)
           ns<=IDLE;
         else
           ns<=CHK_CMD;
         end
   CHK_CMD: begin if((ss_n==0)&&(Mosi==0))
               ns<=WRITE;
            else if((ss_n==0)&&(Mosi==1)&&(read_add==1))
               ns<=READ_ADD;
           else if((ss_n==0)&&(Mosi==1)&&(read_add==0))
               ns<=READ_DATA;
           else if(ss_n)
               ns<=IDLE;
           else
               ns<=cs;
           end
   READ_DATA: begin if(~ss_n)
             ns<=READ_DATA;
            else
             ns<=IDLE;
            end
   READ_ADD: begin if(~ss_n)
             ns<=READ_ADD;
            else
             ns<=IDLE;
             end
   WRITE: begin if(~ss_n)
             ns<=WRITE;
          else
             ns<=IDLE; 
          end
   default: ns<=IDLE;
endcase
end

// third always for output
always @(posedge clk) begin
if(~rst_n) begin
   Miso<=0;
   rx_valid<=0;
   rx_data<=0;
   read_add<=1;
   w<=0;
   counter<=0; 
           end
else begin
if((cs==READ_ADD)||(cs==READ_DATA)||(cs==WRITE))begin

if(cs==READ_ADD)              
   read_add<=1;
else if(cs==READ_DATA)             
   read_add<=0;

if(counter<10)begin    //input mosi for 10 cycles
      w<={Mosi,w[9:1]};                
                 end
 if(counter==9)    
      rx_valid<=1;
// tx_counter=tx_counter+1;
 if(counter==10)
      rx_data<=w;
// tx_counter=tx_counter+1;
 if(counter==11)
      rx_valid<=0;
 if(tx_valid)begin
   while((counter>=11)&&(counter<=18))begin
     Miso=tx_data[counter-11];
     counter=counter+1;
                                           end 
         end  

counter<=counter+1; 
end
else 
   counter<=0;
end
end


endmodule

