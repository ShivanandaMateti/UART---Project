`timescale 1ms/1ps

module baud_gen_test;

reg clk;
reg reset;

wire Sample_tick;

baud_gen_R Baudgenarator(
                         .clk(clk),
                         .reset(reset),
                         .Sample_tick_R(Sample_tick)
);


    // Clock
    initial clk = 0;
    always #0.001302083 clk = ~clk;   // time period of clock = 2.604167us
    
endmodule
