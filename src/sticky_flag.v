module sticky_flag(
    input      clk,
    input      nrst,
    input      set,
    input      clr,
    output reg flag
);

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            flag <= 1'b0;
        end else begin
            if (set) // set over clear priority
                flag <= 1'b1;
            else if (clr)
                flag <= 1'b0;
        end
    end

endmodule