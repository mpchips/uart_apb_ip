module debouncer
#(
    parameter DELAY = 1302
)
(
    input  clk,
    input  nrst,
    input  en,
    input  sig,
    output detected
);

    localparam IDLE = 2'd0;
    localparam WAIT = 2'd1;
    localparam ACTIVE = 2'd2;

    reg [1:0] state;

    reg [15:0] count;
    reg prev, curr;

    // state machine
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            state <= IDLE;
        end else begin
            if (en) begin
                case (state)
                    IDLE: if ((prev == 1'b1) && (curr == 1'b0))
                        state <= WAIT;
                    WAIT: if (count >= DELAY)
                        state <= ACTIVE;
                    ACTIVE: 
                        state <= IDLE;
                endcase
            end else begin
                state <= IDLE;
            end
        end
    end

    // output signal ('detected') logic
    assign detected = (state == ACTIVE);

    // curr and prev values for edge detection
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            prev <= 1'b0;
            curr <= 1'b0;
        end else if (en) begin
            curr <= sig;
            prev <= curr;
        end else begin
            prev <= 1'b0;
            curr <= 1'b0;
        end
    end

    // counter logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            count <= 16'd0;
        end else begin
            if (en) begin
                case (state)
                    WAIT: begin
                    if (count < DELAY)
                        count <= count + 16'd1;
                    else
                        count <= 16'd0;
                    end
                    default: 
                        count <= 16'd0;
                endcase
            end else begin
                count <= 16'd0;
            end
        end
    end

endmodule