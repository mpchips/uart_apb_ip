`timescale 1ns/1ps

// self-checking testbench for fifo.v
// a reference model follows the RX FIFO Behavior table in specs.md;
// run with -GFIFO_DEPTH=2 and with the default 16
module fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter SEED       = 1;

    localparam CLK_PERIOD = 40; // 25 MHz

    reg                   clk;
    reg                   nrst;
    reg                   wren;
    reg                   rden;
    reg  [DATA_WIDTH-1:0] data_i;
    wire [DATA_WIDTH-1:0] data_o;
    wire                  full;
    wire                  empty;

    fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .FIFO_DEPTH (FIFO_DEPTH)
    ) dut(
        .clk    (clk),
        .nrst   (nrst),
        .wren   (wren),
        .rden   (rden),
        .data_i (data_i),
        .data_o (data_o),
        .full   (full),
        .empty  (empty)
    );

    // reference model
    reg [DATA_WIDTH-1:0] model [0:FIFO_DEPTH-1];
    integer head, tail, count;

    integer pass_cnt, fail_cnt;
    integer i, seed;
    reg [DATA_WIDTH-1:0] next_val;

    initial clk = 1'b0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // compare DUT outputs against the model
    task check;
        begin
            if (empty !== (count == 0)) begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: empty=%b, model count=%0d", $time, empty, count);
            end else if (full !== (count == FIFO_DEPTH)) begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: full=%b, model count=%0d", $time, full, count);
            end else if ((count != 0) && (data_o !== model[head])) begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: data_o=%h, expected %h", $time, data_o, model[head]);
            end else begin
                pass_cnt = pass_cnt + 1;
            end
        end
    endtask

    // update the model with what the FIFO accepts on this clock edge
    task model_update;
        input                  wr;
        input                  rd;
        input [DATA_WIDTH-1:0] din;
        reg do_wr, do_rd;
        begin
            do_rd = rd & (count != 0);
            do_wr = wr & ((count != FIFO_DEPTH) | do_rd);
            if (do_rd) begin
                head  = (head + 1) % FIFO_DEPTH;
                count = count - 1;
            end
            if (do_wr) begin
                model[tail] = din;
                tail  = (tail + 1) % FIFO_DEPTH;
                count = count + 1;
            end
        end
    endtask

    // one clock cycle: drive inputs at the falling edge, check, then let the rising edge act
    task step;
        input                  wr;
        input                  rd;
        input [DATA_WIDTH-1:0] din;
        begin
            @(negedge clk);
            wren   = wr;
            rden   = rd;
            data_i = din;
            check;
            @(posedge clk);
            model_update(wr, rd, din);
        end
    endtask

    task push;
        begin
            step(1'b1, 1'b0, next_val);
            next_val = next_val + 1;
        end
    endtask

    task pop;
        begin
            step(1'b0, 1'b1, {DATA_WIDTH{1'b0}});
        end
    endtask

    task push_pop;
        begin
            step(1'b1, 1'b1, next_val);
            next_val = next_val + 1;
        end
    endtask

    task idle;
        begin
            step(1'b0, 1'b0, {DATA_WIDTH{1'b0}});
        end
    endtask

    initial begin
        pass_cnt = 0;
        fail_cnt = 0;
        head     = 0;
        tail     = 0;
        count    = 0;
        next_val = 1;
        seed     = SEED;

        nrst   = 1'b0;
        wren   = 1'b0;
        rden   = 1'b0;
        data_i = {DATA_WIDTH{1'b0}};
        repeat (3) @(posedge clk);
        @(negedge clk);
        nrst = 1'b1;

        $display("fifo_tb: FIFO_DEPTH=%0d", FIFO_DEPTH);

        // reset state
        idle;

        // read when empty: no pop, no underflow
        pop;
        pop;
        idle;

        // fill to full
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            push;
        idle;

        // write when full: dropped
        push;
        push;
        idle;

        // write and read in the same cycle while full: both accepted, stays full
        push_pop;
        push_pop;
        idle;

        // drain, checking order
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            pop;
        idle;

        // write and read in the same cycle while empty: only the write is accepted
        push_pop;
        idle;
        pop;
        idle;

        // write and read in the same cycle at a middle level
        push;
        push;
        push_pop;
        push_pop;
        pop;
        pop;
        idle;

        // pointer wrap: several passes around the buffer at different levels
        for (i = 0; i < 3*FIFO_DEPTH; i = i + 1) begin
            push;
            pop;
        end
        for (i = 0; i < 3*FIFO_DEPTH; i = i + 1)
            push_pop;
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            pop;
        idle;

        // random traffic
        for (i = 0; i < 4000; i = i + 1)
            step($random(seed), $random(seed), $random(seed));
        idle;

        $display("fifo_tb: %0d checks passed, %0d failed", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("fifo_tb: PASS");
        else
            $display("fifo_tb: FAIL");
        $finish;
    end

endmodule
