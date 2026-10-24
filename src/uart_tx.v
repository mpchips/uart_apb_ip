module uart_tx
#(
    parameter CLKI_FREQ_MHZ = 25,
    parameter BAUD_RATE = 9600
)
(
    input            clk,
    input            nrst,
    input            tx_start,
    input      [7:0] data_i,
    output reg       tx_out,
    output           ready
);

    localparam BAUD_PERIOD = CLKI_FREQ_MHZ*1000000/BAUD_RATE;

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [15:0] count;
    reg [7:0]  data_reg;
    reg [3:0]  bit_idx;

    reg tx;

    // state machine
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: if (tx_start)
                    state <= START;
                START: if (count >= BAUD_PERIOD-1)
                    state <= DATA;
                DATA: if ((count >= BAUD_PERIOD-1) && (bit_idx == 4'd7))
                    state <= STOP;
                STOP: if (count >= BAUD_PERIOD-1)
                    state <= IDLE;
            endcase
        end
    end

    // tx_out logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            tx_out <= 1'b1;
        end else begin
            tx_out <= tx;
        end
    end

    // tx logic
    always @(*) begin
        case (state)
            IDLE:  tx = 1'b1;
            START: tx = 1'b0;
            DATA:  tx = data_reg[bit_idx];
            STOP:  tx = 1'b1;
        endcase
    end

    // busy logic
    // always@(*) begin
    //     case (state)
    //         START, DATA: busy = 1'b1;
    //         default:     busy = 1'b0;
    //     endcase
    // end

    assign ready = (state == IDLE);

    // data_i reg logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            data_reg <= 8'd0;
        end else begin
            case (state)
                IDLE: if (tx_start)
                    data_reg <= data_i;
                default:
                    data_reg <= data_reg;
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
                DATA: if (count >= BAUD_PERIOD-1)
                    bit_idx <= bit_idx + 4'd1;
            endcase
        end
    end

    // counter logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            count <= 16'd0;
        end else begin
            case (state)
                IDLE:
                    count <= 16'd0;
                default: begin
                    if (count >= BAUD_PERIOD-1)
                        count <= 16'd0;
                    else
                        count <= count + 16'd1;
                end
            endcase
        end
    end

endmodule