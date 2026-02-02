// Sampling_rate_receiver = ( baud_rate_T * 8 ) = (9600*8) 76800 samples/sec;

module Sample_gen_R (
    input   clk,
    input   reset,
    output  Sample_tick_R
);
integer count = 1;
reg Sample_tick_R_reg;

initial Sample_tick_R_reg <= 1'b0;
always @(posedge clk) begin
    if(reset)
    begin
       count <= 1;
       Sample_tick_R_reg  <= 1'b1;
    end
    else if(count==5) begin     // count = 5 since // time period of clock = 2.604167us  // one sample tick of receiver occurs for every 0.013020833ms
       count <= 1;
       Sample_tick_R_reg  <= 1'b1;
    end
    else begin
        count <= count + 1;
        Sample_tick_R_reg <= 1'b0;
    end        
end

assign Sample_tick_R = Sample_tick_R_reg;

endmodule
