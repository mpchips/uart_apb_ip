module fifo
#(
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)
(
    input      clk,
    input      nrst,
    input      wren,
    input      rden,
    input      [DATA_WIDTH-1:0] data_i,
    output     [DATA_WIDTH-1:0] data_o,
    output     full,
    output     empty
);

    localparam PTR_WIDTH = $clog2(FIFO_DEPTH);

    reg [DATA_WIDTH-1:0] buffer [FIFO_DEPTH-1:0];
    reg [PTR_WIDTH-1:0]  wr_ptr, rd_ptr;
    reg [PTR_WIDTH:0]    data_count;

    integer i;

    assign data_o = buffer[rd_ptr];
    assign empty  = (data_count == 0);
    assign full   = (data_count == FIFO_DEPTH);

    // data count logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            data_count <= 'd0;
        end else begin
            if (wren & !rden & !full)
                data_count <= data_count + 1;
            else if (rden & !wren & !empty)
                data_count <= data_count - 1;
            else if (wren & rden & empty) // only the write is accepted
                data_count <= data_count + 1;
        end
    end

    // write logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            for (i=0; i<FIFO_DEPTH; i=i+1) begin
                buffer[i] <= 'd0;
            end
            wr_ptr <= 'd0;
        end else begin
            if ((wren & !full) | (wren & full & rden)) begin

                buffer[wr_ptr] <= data_i;

                if (wr_ptr < (FIFO_DEPTH-1)) begin
                    wr_ptr <= wr_ptr + 1;
                end else begin
                    wr_ptr <= 'd0;
                end
            end
        end
    end

    // read logic
    always @(posedge clk or negedge nrst) begin
        if (!nrst) begin
            rd_ptr  <= 'd0;
        end else begin
            if (rden & !empty) begin
                if (rd_ptr < (FIFO_DEPTH-1)) begin
                    rd_ptr <= rd_ptr + 1;
                end else begin
                    rd_ptr <= 'd0;
                end
            end
        end
    end

endmodule