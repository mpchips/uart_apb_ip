module rx_counter
#(
    parameter BAUD_PERIOD = 2604 // default is for 9600 baud with 25 MHz clk
)
(
    input clk,
    input nrst,
    input en,
    output en_sample
);

    reg [15:0] count;

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            count <= 16'd0;
        end else begin
            if (!en) begin
                count <= 16'd0;
            end else begin
                if (count >= BAUD_PERIOD-1)
                    count <= 16'd0;
                else
                    count <= count + 16'd1;
            end
        end
    end

    assign en_sample = (count == BAUD_PERIOD-1);

endmodule