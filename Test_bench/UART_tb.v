`timescale 1ms/1ps

module uart_protocol_tb;

    reg clk_T;
    reg clk_R;
    reg reset;
    reg send;
    reg load;
    reg [7:0] data_in;

    
    wire busy;
    wire done;
    wire [7:0] data_out;

    // Transmitter Clock
    initial clk_T = 0;
    always #0.001302083 clk_T = ~clk_T;   // time period of clock = 2.604167us  // one baud tick of transmitter occurs for every 0.1041667ms
    // Receiver clock
    initial clk_R = 0;
    always #0.001302083 clk_R = ~clk_R;   // time period of clock = 2.604167us  // one baud tick of receiver occurs for every 0.1041667ms
    
    UART_Protocol   UART_DUT(
                            .clk_T(clk_T),
                            .clk_R(clk_R),
                            .reset(reset),
                            .load(load),
                            .send(send),
                            .data_in(data_in),
                            .done(done),
                            .data_out(data_out),
                            .busy(busy)
                            
    );

    // Stimulus
    initial begin
        $dumpfile("Uart_protocol.vcd");
        $dumpvars(0, uart_protocol_tb);

                 reset = 1 ; send = 1'b0 ; data_in = 8'h00 ;load=1'b0;
        #0.1145837  reset = 0; send = 1'b1; data_in = 8'h18; #0.1145837 send = 1'b0;  // simple data transmission check
        #1.2500004 data_in = 8'h45;                                                  // data is send but send=0 so not taken
        #0.1145837 send = 1'b1 ; data_in = 8'h00 ; #0.1145837 send = 1'b0;          // after making send 1 data is transmitted again
        #1.145837 reset = 1;send = 1'b1;data_in = 8'h21;#0.1145837 send = 1'b0;   // here reset is asserted so data not taken
        #1.145837 reset = 0;send = 1'b1;data_in = 8'h07;#0.1145837 send = 1'b0;   // here reset made 0 and send 1 so data read again
        #1.145837 send = 1'b1 ; data_in = 8'h55 ; #0.1145837 send = 1'b0;         // here after transmitting one byte immediatedly 
                                                                                  // the next byte send still read
        #1.145837 send = 1'b1 ; data_in = 8'haa ; #0.1145837 send = 1'b0;         // same case
        #1.5625005 send = 1'b1 ; data_in = 8'hff ; #0.1145837 send = 1'b0;         // here after long gap again data sent
        #1.145837 send = 1'b1 ; data_in = 8'h0f ; #0.1145837 send = 1'b0; 
        #1.145837 send = 1'b1 ; data_in = 8'hf0 ; #0.1145837 send = 1'b0;
        #1.145837 send = 1'b1 ; data_in = 8'h01 ; #0.1145837 send = 1'b0;         // data sent immediately
        #1.145837 send = 1'b1 ; data_in = 8'h80 ; #0.1145837 send = 1'b0;
        #1.041667 send = 1'b1 ; data_in = 8'h25 ; #0.1145837 send = 1'b0;         // new data sent at the stop bit of previous data so not taken
        #1.145837 send = 1'b1 ; data_in = 8'h51 ; #0.1145837 send = 1'b0;         // here before complete transmission of 51 another
        #0.1145837 send = 1'b1 ; data_in = 8'h96 ; #0.1145837 send = 1'b0;            // data 96,48 is sent so not taken beacuse we are busy 
        #0.1145837 send = 1'b1 ; data_in = 8'h48 ; #0.1145837 send = 1'b0;
        #1.145837 send = 1'b1 ; data_in = 8'h88 ; #0.1145837 send = 1'b0;         // data is sent but reset is 1 in between so it goes to idle state
        #0.3491674 reset = 1 ; #0.3491674 reset = 0;
        

        #1.2500004 $finish;
    end

endmodule
