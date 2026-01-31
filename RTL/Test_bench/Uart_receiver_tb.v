`timescale 1ms/1ps
module UART_RECEIVER_TB;
         reg clk,in,reset;
         wire [7:0] data_out;
         wire done,load;

    UART_RECEIVER  Receiver_DUT(
        .clk(clk),
        .in(in),
        .reset(reset),
        .data_out(data_out),
        .load(load),
        .done(done)
    );

    initial         clk = 1'b0;
    always   #0.001302083 clk = ~ clk;
    initial 
    begin   
        $dumpfile("Uart_receiver.vcd");
        $dumpvars(0,UART_RECEIVER_TB);
      //  $monitor("%t %b %b %b %b %b",$time,in,reset,baud_tick_R,data,done);
               in=1;reset=1;
        #0.3437511 reset=0;
        #0.1041667 in=1;
        #0.1041667 in=0;       // start bit data = 12
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;        // parity bit = 1 even parity
        #0.1041667 in=1;        // stop bit// correct data with even parity ikkada done = 1
        #0.1041667 in=1;
        #0.1041667 in=1;reset=1;
        #0.1041667 in=0;        //start bit data = 96
        #0.1041667 in=0;      
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;        // parity bit = 1
        #0.1041667 in=1;        //stop bit // here reset = 1 so data should not be taken;
        #0.1041667 in=1;        // even if the data is correct.
        #0.1041667 reset=0;    
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;   // start bit data = 07
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;        
        #0.1041667 in=0;
        #0.1041667 in=0;   // here correct data with odd parity bit;
        #0.1041667 in=0;   // parity bit = 0 odd parity
        #0.1041667 in=1;   // stop bit
        #0.1041667 in=0;   // start bit data = 69
        #0.1041667 in=1;   // soon after stop bit again start bit is sent
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;    // here correct data with odd parity
        #0.1041667 in=1;    // stop bit 
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;    // long idle state
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;    // startbit data = 1F with wrong odd parity no data taken
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0; 
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;    // parity bit should be 0 but its 1
        #0.1041667 in=1;    // stop bit
        #0.1041667 in=1;
        #0.1041667 in=0;    // start bit data = 45
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;     
        #0.1041667 in=1;    // parity bit = 1 wrong odd parity so data not taken
        #0.1041667 in=1;    // stop bit
        #0.1041667 in=0;    // start bit data = EF
        #0.1041667 in=1;  
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;    //  parity = 0 correct odd parity
        #0.1041667 in=0;    // stop bit isn't given so no data taken
        #0.1041667 in=1;
        #0.1041667 in=0;    // start bit data = FF
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;     // parity bit = 1 (even parity) 
        #0.1041667 in=1;     // stop bit detected so data taken
        #0.1041667 in=0;     // start bit data = 00
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;  // parity bit =1 even
        #0.1041667 in=1;  // stop bit data detected 
        #0.1041667 in=0;  // start bit data = 55
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;  // parity bit
        #0.1041667 in=1;  // stop bit data detected
        #0.1041667 in=0;  // start bit data = 01
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;  // parity bit = 0  odd parity
        #0.1041667 in=1;  // stop bit data detected
        #0.1041667 in=0;  // start bit data = 80
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;  // parity bit = 0 odd parity
        #0.1041667 in=1;  // stop bit
        #0.1041667 in=0;  // start bit data = AA
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;  // parity bit = 1 even parity
        #0.1041667 in=1;  // stop bit 
        #0.1041667 in=0;  // start bit data = 99 
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 reset=1;in=1; // parity bit = 1 but reset = 1 so data not read enters idle state
        #0.1041667 reset=0;in=0; // start bit data = 0F
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1; // parity bit = 1 even
        #0.1041667 in=1; // stop bit
        #0.1041667 reset=0;in=0; // start bit data = 21
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1; // parity bit = 1 even parity
        #0.1041667 reset=1;in=1; // stop bit but not taken since reset = 1
        #0.1041667 in=0;reset=0; // start bit data = FO
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=0;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1;
        #0.1041667 in=1; // parity bit = 1 even
        #0.1041667 in=1; // stop bit = 1
        #0.1041667 in=1;


        #1.145837 $finish;
    end
endmodule








