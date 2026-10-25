`timescale 1ns/1ps

// self-checking RX_OVR (STATUS bit 3) testbench for uart_apb_top
// txd is looped back to rxd. Covers:
//  - filling the FIFO exactly does not set RX_OVR
//  - a byte arriving while the FIFO is full sets RX_OVR and is dropped
//  - RX_OVR is sticky across STATUS reads and RXDATA pops
//  - writing 0 to bit 3, or 1 to bit 3 at another offset, does not clear it
//  - writing 1 to STATUS bit 3 clears it
//  - set and W1C in the same cycle: set wins
//  - FIFO full, pop and write in the same cycle: byte is stored, no overrun
// The two same-cycle cases time the APB access phase to the rx_done cycle
// using the receiver's bit_idx (white-box)
module uart_ovr_tb;

    localparam CLK_PERIOD = 40;   // 25 MHz
    localparam BIT_CYCLES = 2604; // 25 MHz / 9600 baud
    localparam FIFO_DEPTH = 16;   // must match the DUT
    localparam POLL_LIMIT = 20000;

    localparam [3:0] TXDATA   = 4'h0;
    localparam [3:0] RXDATA   = 4'h4;
    localparam [3:0] STATUS   = 4'h8;
    localparam [3:0] UNMAPPED = 4'hC;

    // STATUS values: {3'b0, RX_ERR, RX_OVR, RX_FULL, RX_EMPTY, TX_READY}
    localparam [7:0] ST_IDLE_EMPTY = 8'h03;
    localparam [7:0] ST_IDLE_FULL  = 8'h05;
    localparam [7:0] ST_OVR_FULL   = 8'h0D;
    localparam [7:0] ST_OVR_PART   = 8'h09;

    reg        pclk;
    reg        prstn;
    reg  [3:0] paddr;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg  [7:0] pwdata;
    wire [7:0] prdata;
    wire       txd;

    uart_apb_top dut(
        .pclk    (pclk),
        .prstn   (prstn),
        .paddr   (paddr),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .rxd     (txd),     // loopback
        .pwdata  (pwdata),
        .prdata  (prdata),
        .txd     (txd)
    );

    integer pass_cnt, fail_cnt;
    integer i;
    integer pop_coinc_cnt, clr_coinc_cnt;
    reg [7:0] rdata;

    // reference model of the FIFO contents
    reg [7:0] model [0:255];
    integer   model_wr, model_rd;

    initial pclk = 1'b0;
    always #(CLK_PERIOD/2) pclk = ~pclk;

    // count the same-cycle events the two timed tests must hit, so a
    // missed timing shows up as a failure instead of a false pass
    always @(posedge pclk) begin
        if (prstn) begin
            if (dut.rx_done & dut.rxf_full & dut.rxf_pop)
                pop_coinc_cnt = pop_coinc_cnt + 1;
            if (dut.rx_done & dut.rxf_full & dut.clr_ovr)
                clr_coinc_cnt = clr_coinc_cnt + 1;
        end
    end

    // APB2 write: setup phase, then one access phase
    task apb_write;
        input [3:0] addr;
        input [7:0] data;
        begin
            @(posedge pclk);
            psel    <= 1'b1;
            penable <= 1'b0;
            pwrite  <= 1'b1;
            paddr   <= addr;
            pwdata  <= data;
            @(posedge pclk);
            penable <= 1'b1;
            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
        end
    endtask

    // APB2 read: prdata is sampled in the middle of the access phase
    task apb_read;
        input  [3:0] addr;
        output [7:0] data;
        begin
            @(posedge pclk);
            psel    <= 1'b1;
            penable <= 1'b0;
            pwrite  <= 1'b0;
            paddr   <= addr;
            @(posedge pclk);
            penable <= 1'b1;
            @(negedge pclk);
            data = prdata;
            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
        end
    endtask

    // APB2 access whose access phase lines up with the rx_done cycle.
    // bit_idx reaches 9 on the stop-bit sample; the controller enters DONE
    // one clock later and rx_done is high for the clock after that
    task apb_access_at_rx_done;
        input        wr;
        input  [3:0] addr;
        input  [7:0] wdata;
        output [7:0] data;
        begin
            wait (dut.uart_rx.controller.bit_idx == 4'd9);
            psel    <= 1'b1;
            penable <= 1'b0;
            pwrite  <= wr;
            paddr   <= addr;
            pwdata  <= wdata;
            @(posedge pclk);
            penable <= 1'b1;
            @(negedge pclk);
            data = prdata;
            @(posedge pclk);
            psel    <= 1'b0;
            penable <= 1'b0;
        end
    endtask

    task check;
        input [8*28-1:0] name;
        input [7:0]      actual;
        input [7:0]      expected;
        begin
            if (actual === expected) begin
                pass_cnt = pass_cnt + 1;
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: %0s = %h, expected %h", $time, name, actual, expected);
            end
        end
    endtask

    task check_count;
        input [8*28-1:0] name;
        input integer    actual;
        input integer    expected;
        begin
            if (actual == expected) begin
                pass_cnt = pass_cnt + 1;
            end else begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: %0s = %0d, expected %0d", $time, name, actual, expected);
            end
        end
    endtask

    // poll STATUS until TX_READY = 1
    task wait_tx_ready;
        integer n;
        reg [7:0] st;
        begin
            n  = 0;
            st = 8'h00;
            while ((st[0] !== 1'b1) && (n < POLL_LIMIT)) begin
                apb_read(STATUS, st);
                n = n + 1;
            end
            if (st[0] !== 1'b1) begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: timeout waiting for TX_READY", $time);
            end
        end
    endtask

    // write one byte, wait until the transmitter is idle again, then
    // wait one more bit period so the receiver has finished the frame
    task send_byte;
        input [7:0] data;
        begin
            wait_tx_ready;
            apb_write(TXDATA, data);
            wait_tx_ready;
            repeat (BIT_CYCLES) @(posedge pclk);
        end
    endtask

    // send_byte, but also store the byte in the reference model
    task send_stored;
        input [7:0] data;
        begin
            model[model_wr] = data;
            model_wr = model_wr + 1;
            send_byte(data);
        end
    endtask

    // pop one byte over RXDATA and compare it with the reference model
    task read_expect;
        begin
            apb_read(RXDATA, rdata);
            check("RXDATA", rdata, model[model_rd]);
            model_rd = model_rd + 1;
        end
    endtask

    initial begin
        pass_cnt      = 0;
        fail_cnt      = 0;
        pop_coinc_cnt = 0;
        clr_coinc_cnt = 0;
        model_wr      = 0;
        model_rd      = 0;

        prstn   = 1'b0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        paddr   = 4'h0;
        pwdata  = 8'h00;
        repeat (5) @(posedge pclk);
        prstn = 1'b1;
        repeat (5) @(posedge pclk);

        apb_read(STATUS, rdata);
        check("STATUS after reset", rdata, ST_IDLE_EMPTY);

        // ---- full is not an overrun ----
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            send_stored(8'hA0 ^ (i * 8'h11));
        apb_read(STATUS, rdata);
        check("STATUS when full", rdata, ST_IDLE_FULL);

        // ---- overrun sets the flag, byte is dropped ----
        send_byte(8'h5A);
        apb_read(STATUS, rdata);
        check("STATUS after overrun", rdata, ST_OVR_FULL);

        // ---- sticky across STATUS reads ----
        apb_read(STATUS, rdata);
        apb_read(STATUS, rdata);
        check("STATUS after re-reads", rdata, ST_OVR_FULL);

        // ---- sticky across an RXDATA pop ----
        read_expect;
        apb_read(STATUS, rdata);
        check("STATUS after one pop", rdata, ST_OVR_PART);
        send_stored(8'h3C);  // refill, not an overrun
        apb_read(STATUS, rdata);
        check("STATUS after refill", rdata, ST_OVR_FULL);

        // ---- writes that must not clear ----
        apb_write(STATUS, 8'hF7);    // bit 3 = 0
        apb_read(STATUS, rdata);
        check("STATUS after write 0", rdata, ST_OVR_FULL);
        apb_write(UNMAPPED, 8'h08);  // bit 3 = 1, wrong offset
        apb_write(RXDATA,   8'h08);  // bit 3 = 1, wrong offset
        apb_read(STATUS, rdata);
        check("STATUS after W1C elsewhere", rdata, ST_OVR_FULL);

        // ---- W1C clears ----
        apb_write(STATUS, 8'h08);
        apb_read(STATUS, rdata);
        check("STATUS after W1C", rdata, ST_IDLE_FULL);

        // ---- set and clear in the same cycle: set wins ----
        wait_tx_ready;
        apb_write(TXDATA, 8'h96);    // dropped: FIFO is full
        apb_access_at_rx_done(1'b1, STATUS, 8'h08, rdata);
        wait_tx_ready;
        repeat (BIT_CYCLES) @(posedge pclk);
        check_count("set+clear same cycle", clr_coinc_cnt, 1);
        apb_read(STATUS, rdata);
        check("STATUS after set+clear", rdata, ST_OVR_FULL);
        apb_write(STATUS, 8'h08);
        apb_read(STATUS, rdata);
        check("STATUS after second W1C", rdata, ST_IDLE_FULL);

        // ---- full, pop and write in the same cycle: no overrun ----
        wait_tx_ready;
        model[model_wr] = 8'hC3;
        model_wr = model_wr + 1;
        apb_write(TXDATA, 8'hC3);    // stored: a pop frees the slot
        apb_access_at_rx_done(1'b0, RXDATA, 8'h00, rdata);
        check("RXDATA at pop+write", rdata, model[model_rd]);
        model_rd = model_rd + 1;
        wait_tx_ready;
        repeat (BIT_CYCLES) @(posedge pclk);
        check_count("pop+write same cycle", pop_coinc_cnt, 1);
        apb_read(STATUS, rdata);
        check("STATUS after pop+write", rdata, ST_IDLE_FULL);

        // ---- drain: contents match the model, flag stays clear ----
        for (i = 0; i < FIFO_DEPTH; i = i + 1)
            read_expect;
        check_count("bytes left in model", model_wr - model_rd, 0);
        apb_read(STATUS, rdata);
        check("STATUS after drain", rdata, ST_IDLE_EMPTY);

        $display("uart_ovr_tb: %0d checks passed, %0d failed", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("uart_ovr_tb: PASS");
        else
            $display("uart_ovr_tb: FAIL");
        $finish;
    end

    // watchdog
    initial begin
        #(CLK_PERIOD * BIT_CYCLES * 12 * (FIFO_DEPTH + 10));
        fail_cnt = fail_cnt + 1;
        $display("uart_ovr_tb: FAIL (watchdog timeout)");
        $finish;
    end

endmodule
