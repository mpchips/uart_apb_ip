module rx_shifter(
    input        clk,
    input        nrst,
    input        en_sample,
    input        ser_in,
    output       curr_bit,
    output [7:0] data
);

    reg [8:0] shift_reg; // register that received data will be shifted into

    assign data = shift_reg[7:0];
    assign curr_bit = shift_reg[8];

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            shift_reg <= 9'd0;
        end else begin
            if (en_sample) 
                shift_reg <= {ser_in, shift_reg[8:1]};
        end
    end

endmodule