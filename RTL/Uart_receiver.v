/* RECEIVER */

module UART_RECEIVER(
    input clk,
    input in,
    input reset,
    output [7:0]data_out,
    output done,
    output load
);

wire baud_tick_R;
baud_gen_R     B_R(
                   .clk(clk),
                   .reset(reset),
                   .baud_tick_R(baud_tick_R)
);
receiver     R(
               .in(in),
               .reset(reset),
               .clk(clk),
               .baud_tick_R(baud_tick_R),
               .data_out(data_out),
               .done(done),
               .load(load)
);
endmodule

// baud_rate_receiver = (9600*8) 76800 bits/sec;

module baud_gen_R (
    input   clk,
    input   reset,
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


module receiver(
    input in,
    input baud_tick_R,
    input reset,
    input clk,
    output [7:0] data_out,
    output done,
    output load
);
localparam idle = 0,
           start = 1,
           d0 = 2,
           d1 = 3,
           d2 = 4,
           d3 = 5,
           d4 = 6,
           d5 = 7,
           d6 = 8,
           d7 = 9,
           parity = 10,
           error = 11,
           stop = 12;

reg [3:0] present_state;
reg p=1'b1;
reg load_reg;
reg [7:0] data_temp;
reg [7:0] data_correct;
parameter N = 8;
integer count_s = 1;
initial load_reg = 1'b0;
// state transition logic
// assigning state
always @(posedge clk , posedge reset) begin
    if(reset) begin
        present_state <= idle;
        data_correct  <= 8'h00;
        data_temp     <= 8'h00;
        p             <= 1'b1 ;
        count_s       <= 1    ;
    end     
    else 
    begin
        if(baud_tick_R) begin
            case(present_state)
            idle : begin
                    load_reg         <= 1'b0;
                    if(in==0)begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else
                    begin
                     count_s       <= 1;  
                     present_state <= start; 
                    end 
                    end
                  end
            start : begin
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[0]   <= in;    
                    end
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                    end
                    else
                    begin
                     count_s        <= 1;
                     present_state  <= d0;
                    end
                    end
            d0    : begin
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[1]   <= in;   
                    end
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                    end
                    else
                    begin
                     count_s        <= 1;
                     present_state  <= d1;
                    end 
                    end
            d1    : begin
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[2]   <= in;    
                    end 
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                    end
                    else
                    begin
                     count_s        <=  1;
                     present_state  <= d2;
                    end
                    end
            d2    : begin
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[3]   <= in;   
                    end 
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                    end
                    else
                    begin
                     count_s        <= 1;
                     present_state  <= d3;
                    end
                    end
            d3    : begin 
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[4]   <= in;    
                    end
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                    end
                    else
                    begin
                     count_s        <= 1;
                     present_state  <= d4;
                    end
                    end
            d4    : begin
                    if(count_s==N/2)
                    begin
                        present_state  <= present_state;
                        count_s        <= count_s +1;
                        data_temp[5]   <= in;     
                    end
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state <= present_state;
                        count_s       <= count_s +1;
                    end
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= d5;
                    end
                    end
            d5    : begin
                    if(count_s==N/2)
                    begin
                        present_state <= present_state;
                        count_s       <= count_s +1;
                        data_temp[6]  <= in;     
                    end 
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state <= present_state;
                        count_s       <= count_s +1;
                    end
                    else
                    begin
                     count_s          <=  1;
                     present_state    <= d6;
                    end 
                    end
            d6    : begin
                    if(count_s==N/2 )
                    begin
                        present_state <= present_state;
                        count_s       <= count_s +1;
                        data_temp[7]  <= in;     
                    end 
                    else if(count_s >=1 && count_s <N )
                    begin
                        present_state <= present_state;
                        count_s       <= count_s +1;
                    end
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= d7;
                     p                <= ~(^data_temp);
                    end
                    end
            d7    : begin
                    if(in==p)
                    begin
                    if(count_s<N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else 
                    begin
                     count_s          <= 1;
                     present_state    <= parity;
                    end 
                    end
                    else
                    begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else 
                    begin
                     count_s          <= 1;
                     present_state    <= error;
                     load_reg            <= 1'b1;
                    end 
                  end
            end
            parity: begin
                    if(in)
                    begin
                    if(count_s==N/2)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                     data_correct     <= data_temp;
                    end
                    else if(count_s<N)
                    begin
                     count_s          <= count_s +1; 
                     present_state    <= present_state;
                    end 
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= stop;
                     p                <= 1'b1;
                    end
                    end
                    else
                    begin
                    if(count_s<N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else 
                    begin
                     count_s          <= 1;
                     present_state    <= error;
                    end 
                    end
            end
            stop  : begin
                  if(in)
                  begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= idle;
                    end 
                  end
                  else
                  begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else 
                    begin
                     count_s          <= 1;
                     present_state    <= start;
                    end 
                  end
            end
            error : begin
                  if(in)
                  begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= idle;
                    end 
                  end
                  else
                  begin
                    if(count_s < N)
                    begin
                     present_state    <= present_state;
                     count_s          <= count_s +1;
                    end
                    else
                    begin
                     count_s          <= 1;
                     present_state    <= present_state;
                    end 
                  end
                  end
                endcase
    end
    end
    end

// assigning output

assign done = (present_state == stop);
assign data_out =  data_correct;
assign load =  load_reg;

endmodule



