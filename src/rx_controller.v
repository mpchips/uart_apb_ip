module rx_controller(
    input  clk,
    input  nrst,
    input  st,
    input  en_sample,
    input  curr_bit,
    output en_deb,
    output en_ctr,
    output rx_done,
    output rx_err
);

    localparam [1:0] IDLE    = 2'd0;
    localparam [1:0] CAPTURE = 2'd1;
    localparam [1:0] DONE    = 2'd2;
    localparam [1:0] ERR     = 2'd3;

    reg [1:0] state;
    reg [3:0] bit_idx;

    // state machine
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: if (st)
                    state <= CAPTURE;
                CAPTURE: 
                if ((bit_idx == 4'd9) && (curr_bit == 1'b1)) // SUCCESS
                    state <= DONE;
                else if ((bit_idx == 4'd9) && (curr_bit == 1'b0)) // ERROR AT STOP BIT
                    state <= ERR;
                DONE, ERR:
                    state <= IDLE;
            endcase
        end
    end

    // bit_idx logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            bit_idx <= 4'd0;
        end else begin
            case (state)
                default: 
                    bit_idx <= 4'd0;
                CAPTURE: if (en_sample)
                    bit_idx <= bit_idx + 4'd1;
            endcase
        end
    end

    assign en_deb  = (state == IDLE);
    assign en_ctr  = (state == CAPTURE);
    assign rx_done = (state == DONE);
    assign rx_err  = (state == ERR);

endmodule