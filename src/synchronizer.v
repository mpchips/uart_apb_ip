module synchronizer 
#(
    parameter [0:0] RESET_VAL = 1'b1
)
(
    input  clk,
    input  nrst,
    input  async_i,
    output sync_o
);

    reg [1:0] sync_ffs; // synchronizer flip-flops

    assign sync_o = sync_ffs[1];

    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            sync_ffs <= {2{RESET_VAL}};
        end else begin
            sync_ffs <= {sync_ffs[0], async_i};
        end
    end

endmodule