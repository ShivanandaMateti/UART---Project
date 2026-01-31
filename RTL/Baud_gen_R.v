
// baud_rate_receiver = (9600*8) 76800 bits/sec;

module baud_gen_R (
    input clk,
    input reset,
    output  baud_tick_R
);
integer count = 1;
reg baud_tick_R_reg;

initial baud_tick_R_reg <= 1'b0;
always @(posedge clk) begin
    if(reset)
    begin
       count <= 1;
       baud_tick_R_reg  <= 1'b1;
    end
    else if(count==5) begin     // count = 5 since // time period of clock = 2.604167us  // one baud tick of receiver occurs for every 0.013020833ms
       count <= 1;
       baud_tick_R_reg  <= 1'b1;
    end
    else begin
        count <= count + 1;
        baud_tick_R_reg <= 1'b0;
    end        
end

assign baud_tick_R = baud_tick_R_reg;

endmodule
