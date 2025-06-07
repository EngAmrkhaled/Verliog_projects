module APB_Master (
    input SWRITE ,
    input [31:0] SADDR , SWDATA , 
    input [3:0] SSTRB ,  //choose bytes will be transfer
    input transfer ,   //Enable
    output reg PSEL , PENABLE , PWRITE ,
    output reg [31:0] PADDR , PWDATA ,
    output reg [3:0] PSTRB ,
    input PCLK , PRESETn ,
    input  PREADY ,   // high if we trasfered
    input PSLVERR     // high if error occured
);
reg [1:0] cs,ns;
parameter IDLE = 0,SETUP = 2'b 01,ACCESS = 2'b10;

//current state
always@(posedge PCLK or negedge PRESETn) begin
  if(~PRESETn) 
     cs <= IDLE;
  else
     cs <= ns;                           end
     
//Fsm Logic
always@(*)                              begin
 case(cs) 
   IDLE :                   begin 
            if(~transfer)
              ns <= IDLE;
            else
              ns <= SETUP;  end      

   SETUP:   ns <= ACCESS;
   ACCESS:                  begin
            if(PREADY && !transfer)
                 ns = IDLE ;
            else if(PREADY && transfer)
                 ns = SETUP ;
            else
                 ns = ACCESS ; end    
  default:  ns <= IDLE;                      
 endcase
                                        end
//Output
always@(*)                             begin
 if(~PRESETn) begin
  PSEL = 0;
  PENABLE = 0;
  PWRITE = 0;
  PADDR = 0;
  PWDATA = 0;
  PSTRB = 0;
  
             end
 case(cs)
  IDLE : begin
           PSEL = 0;
           PENABLE = 0;  
         end
  SETUP: begin 
           PSEL = 1;
           PENABLE = 0;       
           PWRITE = SWRITE;
           PADDR = SADDR;
           PWDATA = SWDATA;
           PSTRB = SSTRB;
         end
  ACCESS: begin
           PSEL = 1;
           PENABLE = 1; 
          end       
  endcase                                      end
endmodule