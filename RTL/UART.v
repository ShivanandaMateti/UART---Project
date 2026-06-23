module UART_Protocol #(
                            parameter DataWidth = 8,
                            parameter SamplingWidth = 16
                      )
                        (
                                // inputs to tx
                                input t_clk, 
                                input reset,   // common for both
                                input send,    
                                input load_in, 
                                input [DataWidth-1:0] data_in,
                                // inputs to rx
                                input rx,    
                                input r_clk,
                                // outputs to tx
                                output tx,
                                output busy,
                                // outputs to rx
                                output[DataWidth-1:0] data_out,
                                output done,
                                output load_out,

                        );


wire Tx;

UART_TRANSMITTER   #(
                        .DataWidth(DataWidth)
                    )Transmitter(
                                .t_clk(t_clk),
                                .reset(reset),
                                .send(send),
                                .load(load_in),
                                .data_in(data_in),
                                .Tx(Tx),
                                .busy(busy)
                                );

stage2_sync    (
                    .in(Tx),
                    .reset(reset),
                    .clk(r_clk),
                    .sync(tx)

                );


UART_RECEIVER    #(
                        .DataWidth(DataWidth),
                        .SamplingWidth(SamplingWidth)

                  )  Receiver(
                                .r_clk(r_clk),
                                .reset(reset),
                                .rx(rx),
                                .data_out(data_out),
                                .done(done),
                                .load(load_out)                            
                            );

endmodule


/* TRANSMITTER */

module UART_TRANSMITTER #(
                            parameter DataWidth = 8
                        )(
                            input t_clk,
                            input reset,
                            input send,
                            input load,
                            input [DataWidth-1:0] data_in,
                            output Tx,
                            output busy
                        );
wire baud_tick;
wire [DataWidth+2 : 0] packet;
baud_gen B_T(
                .t_clk(t_clk),
                .reset(reset),
                .baud_tick(baud_tick)
            );

frame_data #(.DataWidth(DataWidth))
                            P_T(
                                .data_in(data_in),
                                .packet(packet)
                                );

transmitter #(.DataWidth(DataWidth))
            T(
            .t_clk(t_clk),
            .baud_tick(baud_tick),
            .reset(reset),
            .send(send),
            .load(load),
            .packet(packet),
            .Tx(Tx),
            .busy(busy)
            );

endmodule

// baudrate of transmitter = 3906250bps i.e 260ns
// transmitter clk period  = 16ns 
// hence for 260ns we use clock divider of 16 (since 16*16 = 256 approx(260) )

module baud_gen (
    input t_clk,
    input reset,
    output baud_tick
);

reg [4:0] count = 1;
reg baud_tick_reg;
always @(posedge t_clk,posedge reset) 
begin
    if(reset)
    begin 
        count <= 1;
        baud_tick_reg <= 1'b0;
    end
    else if(count==16)     // count = 16 since // time period of clock = 16ns  // one baud tick of transmitter occurs for every 256ns i.e 260ns
    begin
        count <= 1;
        baud_tick_reg <= 1'b1;
    end
    else 
    begin
        count <= count + 1;
        baud_tick_reg <= 1'b0;
    end        
end

assign baud_tick = baud_tick_reg;

endmodule

module frame_data#(
                    parameter DataWidth = 8
                )(
            
                        input  [DataWidth-1:0] data_in,
                        output [DataWidth+2:0] packet
                );

wire p ;
assign p = ~(^data_in);
// packet making 
assign packet = {1'b1,p,data_in[7:0],1'b0};

endmodule

module transmitter  #(
                        parameter DataWidth = 8
                     )
                        (

                            input t_clk,
                            input baud_tick,
                            input send,
                            input reset,
                            input load,
                            input [DataWidth+2:0] packet,
                            output Tx,
                            output busy

                        );



reg tx;                        // shows the output of transmitter
reg [DataWidth+2:0] packet_temp;        // to shift data and transmit
reg [DataWidth+2:0] packet_load_ready ; // for storing data to resend if data sent isn't correct 
reg [3:0] b ;                  // for counting no of bits transmitted
reg transmitting;              // can be used to check if transmitting

initial 
begin 
    b =4'd0 ; 
    transmitting = 1'b0;           // initializing them to start transmission 
    tx = 1'b1;                     // initially transmitter is in idle state 
    packet_load_ready = 11'h7ff;   // if load occurs before send this treats as an idle state
end  
       
 
always @(posedge t_clk,posedge reset)
begin
    if(reset)
    begin
        tx           <= 1'b1;
        b            <= 0;
        packet_temp  <= 11'h7ff;
        transmitting <= 1'b0;
    end
    else if(load)
    begin
        packet_temp   <=  packet_load_ready;
        transmitting  <=  1'b1;
    end
    else if (send && ~transmitting)
    begin
            packet_temp       <= packet;
            packet_load_ready <= packet;
            transmitting      <= 1'b1;
    end
    else 
    begin
        if(baud_tick && transmitting )
            begin
                tx                 <=  packet_temp[0];
                packet_temp        <=  {1'b1,packet_temp[DataWidth+2:1]};
                if(b==4'd10)
                begin
                    b              <=    4'd0;
                    transmitting   <=    1'b0;
                end
                else
                b                  <=  b + 4'd1;   
            end
    end
end


assign Tx = tx;
assign busy = ((send && ~transmitting) || transmitting);


endmodule


/* RECEIVER */

module UART_RECEIVER  #(
                            parameter SamplingWidth = 16,
                            parameter DataWidth = 8
                        )      
                        (
                             input r_clk,
                             input rx,
                             input reset,
                             output [7:0]data_out,
                             output done,
                             output load
                        );


wire Sample_tick,restart;

Sample_gen  R_S( 
                .r_clk(r_clk),
                .reset(reset),
                .restart(restart),
                .Sample_tick(Sample_tick)
            );


receiver     #(
                    .SamplingWidth(SamplingWidth),
                    .DataWidth(DataWidth)

                )
                R(
               .rx(rx),
               .reset(reset),
               .r_clk(r_clk),
               .Sample_tick(Sample_tick) ,
               .data_out(data_out),
               .done(done),
               .load(load),
               .restart(restart)
);
endmodule

// baudrate = 3906250bps i.e 3.9 MHz
// rx clk period = 5ns
// Sampling rate = 62500000sps i.e 62.5 MHz == 20ns
// so we used a clock divider of 4 to reach 20ns

module Sample_gen (
                    input r_clk,
                    input reset,
                    input restart,
                    output Sample_tick
                  );

reg [2:0] count;
reg Sample_tick_reg;
always@(posedge r_clk,posedge reset)begin
    if(reset || restart)begin
        Sample_tick_reg <= 0;
        count           <= 1;
    end
    else begin
        count       <= count + 3'd1;
        if(count == 3'd4)begin
            Sample_tick_reg <= 1;
            count           <= 1;
        end
        else
            Sample_tick_reg <= 0;
    end
end
assign Sample_tick  = Sample_tick_reg; 


endmodule





module receiver #(
                   parameter SamplingWidth = 16,
                   parameter DataWidth = 8

                )
                    (
                    input rx,
                    input Sample_tick,
                    input reset,
                    input r_clk,
                    output [7:0] data_out,
                    output restart,
                    output done,
                    output load
                    );
localparam start = 0,
           data = 1,
           parity = 2,
           stop = 3,
           correct = 4,
           error = 5,
           idle = 6;
           

reg [2:0] present_state;
reg load_reg;
reg restart_reg;
reg p;                  // flag for detecting parity,start and stop bits at midpoint
reg [7:0] data_temp;
reg [7:0] data_correct;
reg [3:0] count_s = 0;  // sampling counter
reg [2:0] data_bit_count = 0;         // data bit counter
initial load_reg = 1'b0;

// state transition logic
// assigning state
always @(posedge r_clk , posedge reset) begin
    if(reset) begin
        present_state <= idle;
        data_correct  <= 8'h00;
        data_temp     <= 8'h00;
        count_s       <= 0;
        data_bit_count<= 0;
        restart_reg   <= 1'b0;
        p             <= 1'b0;
        load_reg      <= 1'b0;
    end
    else if(rx==0 && (present_state == idle)) begin
        present_state     <= start;
        restart_reg       <= 1'b1;
    end
    else begin
        restart_reg       <= 1'b0;
        if(Sample_tick) begin
            case(present_state)

            start : begin
                    load_reg <= 0;
                    if(count_s == SamplingWidth/2)
                    begin
                        count_s      <= count_s + 1;
                        if(rx==0)
                            p <= 1;
                        else
                            p <= 0;
                    end
                    else if(count_s < SamplingWidth-1)
                        count_s        <= count_s + 1;
                    else
                        begin
                            count_s        <= 0;
                            if(p)begin
                                present_state  <= data;
                                data_bit_count   <= 0;
                            end
                            else 
                                present_state  <= idle;    
                        end
                    end

            data  : if(count_s == SamplingWidth/2)
                        begin
                            count_s                    <= count_s + 1;
                            data_temp[data_bit_count]  <= rx;
                        end
                    else if(count_s < SamplingWidth-1 )
                            count_s        <= count_s +1;
                    else 
                        begin 
                            if(data_bit_count == DataWidth-1) begin
                                  present_state <= parity;
                                  count_s <= 0;
                            end
                            else begin
                                 data_bit_count <= data_bit_count + 1;
                                 count_s <= 0;
                            end
                        end
            parity  :if(count_s == SamplingWidth/2)
                        begin
                            count_s                 <= count_s + 1;
                            if(rx == ~(^data_temp))
                                p <= 1;
                            else
                                p <= 0;
                        end
                    else if(count_s<SamplingWidth-1)
                                count_s          <= count_s + 1; 
                    else
                        begin
                                count_s          <= 0;
                                if(p)
                                    present_state    <= stop;
                                else
                                    present_state    <= error;
                        end

            stop    :if(count_s == SamplingWidth/2)
                        begin
                            count_s      <= count_s + 1;
                            if(rx)begin
                                p <= 1;
                                data_correct <= data_temp;
                            end
                            else
                                p <= 0;
                        end
                    else if(count_s < SamplingWidth-1)
                                count_s          <= count_s +1; 
                    else
                        begin
                                count_s          <= 0;
                                if(p)
                                    present_state    <= correct;
                                else
                                    present_state    <= error;
                        end

            correct  : present_state <= idle;       

            error : begin
                    load_reg <= 1'b1;
                    if(count_s == SamplingWidth/2)
                    begin
                        count_s     <= count_s + 1;
                        if(rx)
                            p <= 1;
                        else
                            p <= 0;
                    end
                    else if(count_s < SamplingWidth-1)
                            count_s          <= count_s +1;
                    else
                        begin
                            count_s          <= 0;
                            if(p)
                                present_state    <= idle;
                             else
                                present_state    <= error;
                        end
                    end
                  
            endcase
        end
    end
end


// assigning output

assign done = (present_state == correct);
assign data_out =  data_correct;
assign load =  load_reg;
assign restart = restart_reg;

endmodule

module stage2_sync
                    (
                        input in,
                        input reset,
                        input clk,
                        output sync
                    );
reg q;
reg sync_reg;

d_ff     stage1  (.d(in),.clk(clk),.reset(reset),.q(q));
d_ff     stage2  (.d(q),.clk(clk),.reset(reset),.q(sync_reg));

assign sync = sync_reg;

endmodule



module d_ff(
                input d,
                input clk,
                input reset,
                output reg q
            );
always@(posedge clk,posedge reset)begin
    if(reset)
        q <= 0;
    else
        q <= d;
end
endmodule