`timescale 1ns/1ps

// self-checking register-access testbench for uart_apb_top
// txd is looped back to rxd. Covers:
//  - unmapped offset 0xC: read returns 0, write has no effect
//  - RXDATA read when the FIFO is empty: no pop, no underflow
//  - TXDATA write while TX is busy: ignored
module uart_reg_tb;

    localparam CLK_PERIOD = 40;   // 25 MHz
    localparam BIT_CYCLES = 2604; // 25 MHz / 9600 baud
    localparam POLL_LIMIT = 20000;

    localparam [3:0] TXDATA   = 4'h0;
    localparam [3:0] RXDATA   = 4'h4;
    localparam [3:0] STATUS   = 4'h8;
    localparam [3:0] UNMAPPED = 4'hC;

    // STATUS values: {3'b0, RX_ERR, RX_OVR, RX_FULL, RX_EMPTY, TX_READY}
    localparam [7:0] ST_IDLE_EMPTY = 8'h03;
    localparam [7:0] ST_BUSY_EMPTY = 8'h02;

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
    integer done_cnt, txd_low_cnt;
    reg [7:0] rdata;

    initial pclk = 1'b0;
    always #(CLK_PERIOD/2) pclk = ~pclk;

    // count received frames and cycles with txd low
    always @(posedge pclk) begin
        if (prstn) begin
            if (dut.uart_rx.rx_done) done_cnt = done_cnt + 1;
            if (txd == 1'b0)         txd_low_cnt = txd_low_cnt + 1;
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

    // poll STATUS until RX_EMPTY = 0
    task wait_rx_data;
        integer n;
        reg [7:0] st;
        begin
            n  = 0;
            st = 8'h02;
            while ((st[1] !== 1'b0) && (n < POLL_LIMIT)) begin
                apb_read(STATUS, st);
                n = n + 1;
            end
            if (st[1] !== 1'b0) begin
                fail_cnt = fail_cnt + 1;
                $display("FAIL @%0t: timeout waiting for RX data", $time);
            end
        end
    endtask

    initial begin
        pass_cnt    = 0;
        fail_cnt    = 0;
        done_cnt    = 0;
        txd_low_cnt = 0;

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

        // ---- unmapped offset 0xC ----
        apb_read(UNMAPPED, rdata);
        check("0xC read", rdata, 8'h00);

        // writes to 0xC, STATUS and RXDATA must have no effect:
        // no frame is sent and STATUS is unchanged
        apb_write(UNMAPPED, 8'hFF);
        apb_write(STATUS,   8'hFF);
        apb_write(RXDATA,   8'hFF);
        repeat (2*BIT_CYCLES) @(posedge pclk);
        check_count("txd low cycles", txd_low_cnt, 0);
        apb_read(STATUS, rdata);
        check("STATUS after bad writes", rdata, ST_IDLE_EMPTY);
        apb_read(UNMAPPED, rdata);
        check("0xC read after write", rdata, 8'h00);

        // ---- RXDATA read when the FIFO is empty ----
        // an empty read must not pop: the FIFO stays empty, and the next
        // received byte reads back correctly with the FIFO empty after it
        apb_read(RXDATA, rdata);   // value is undefined, not checked
        apb_read(RXDATA, rdata);
        apb_read(STATUS, rdata);
        check("STATUS after empty reads", rdata, ST_IDLE_EMPTY);

        apb_write(TXDATA, 8'h6C);
        wait_rx_data;
        apb_read(RXDATA, rdata);
        check("RXDATA after empty reads", rdata, 8'h6C);
        repeat (BIT_CYCLES) @(posedge pclk);
        apb_read(STATUS, rdata);
        check("STATUS after one byte", rdata, ST_IDLE_EMPTY);

        // ---- TXDATA write while TX is busy ----
        done_cnt = 0;
        apb_write(TXDATA, 8'h81);
        apb_read(STATUS, rdata);
        check("STATUS while busy", rdata, ST_BUSY_EMPTY);
        apb_write(TXDATA, 8'h7E);  // must be ignored
        wait_rx_data;
        apb_read(RXDATA, rdata);
        check("RXDATA after busy write", rdata, 8'h81);

        // wait longer than one more frame: no second byte may arrive
        repeat (12*BIT_CYCLES) @(posedge pclk);
        check_count("frames received", done_cnt, 1);
        apb_read(STATUS, rdata);
        check("STATUS final", rdata, ST_IDLE_EMPTY);

        $display("uart_reg_tb: %0d checks passed, %0d failed", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("uart_reg_tb: PASS");
        else
            $display("uart_reg_tb: FAIL");
        $finish;
    end

    // watchdog
    initial begin
        #(CLK_PERIOD * BIT_CYCLES * 12 * 6);
        fail_cnt = fail_cnt + 1;
        $display("uart_reg_tb: FAIL (watchdog timeout)");
        $finish;
    end

endmodule
