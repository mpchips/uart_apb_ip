`timescale 1ns/1ps

// self-checking burst testbench for uart_apb_top
// txd is looped back to rxd. FIFO_DEPTH bytes are sent without reading,
// one more byte is sent while the RX FIFO is full (it must be dropped and
// set RX_OVR), then every stored byte is read back and compared in order.
// RX_OVR clearing is covered by uart_ovr_tb
module uart_burst_tb;

    localparam CLK_PERIOD  = 40;   // 25 MHz
    localparam BIT_CYCLES  = 2604; // 25 MHz / 9600 baud
    localparam FIFO_DEPTH  = 16;   // must match the DUT
    localparam POLL_LIMIT  = 20000;

    localparam [3:0] TXDATA = 4'h0;
    localparam [3:0] RXDATA = 4'h4;
    localparam [3:0] STATUS = 4'h8;

    // STATUS values: {3'b0, RX_ERR, RX_OVR, RX_FULL, RX_EMPTY, TX_READY}
    localparam [7:0] ST_IDLE_EMPTY = 8'h03;
    localparam [7:0] ST_IDLE_FULL  = 8'h05;
    localparam [7:0] ST_OVR_FULL   = 8'h0D;
    localparam [7:0] ST_OVR_EMPTY  = 8'h0B;

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
    reg [7:0] rdata;
    reg [7:0] sent [0:FIFO_DEPTH];

    initial pclk = 1'b0;
    always #(CLK_PERIOD/2) pclk = ~pclk;

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
        input [8*24-1:0] name;
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

    initial begin
        pass_cnt = 0;
        fail_cnt = 0;

        prstn   = 1'b0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        paddr   = 4'h0;
        pwdata  = 8'h00;
        repeat (5) @(posedge pclk);
        prstn = 1'b1;
        repeat (5) @(posedge pclk);

        // STATUS reset value
        apb_read(STATUS, rdata);
        check("STATUS after reset", rdata, ST_IDLE_EMPTY);

        // fill the RX FIFO
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            sent[i] = 8'hA0 ^ (i * 8'h11);
            send_byte(sent[i]);
        end
        apb_read(STATUS, rdata);
        check("STATUS when full", rdata, ST_IDLE_FULL);

        // one more byte while full: dropped, RX_OVR set
        sent[FIFO_DEPTH] = 8'h5A;
        send_byte(sent[FIFO_DEPTH]);
        apb_read(STATUS, rdata);
        check("STATUS after overflow", rdata, ST_OVR_FULL);

        // read back in order
        for (i = 0; i < FIFO_DEPTH; i = i + 1) begin
            apb_read(RXDATA, rdata);
            check("RXDATA", rdata, sent[i]);
        end
        // RX_OVR is sticky: draining does not clear it
        apb_read(STATUS, rdata);
        check("STATUS after drain", rdata, ST_OVR_EMPTY);

        $display("uart_burst_tb: %0d checks passed, %0d failed", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("uart_burst_tb: PASS");
        else
            $display("uart_burst_tb: FAIL");
        $finish;
    end

    // watchdog
    initial begin
        #(CLK_PERIOD * BIT_CYCLES * 12 * (FIFO_DEPTH + 4));
        fail_cnt = fail_cnt + 1;
        $display("uart_burst_tb: FAIL (watchdog timeout)");
        $finish;
    end

endmodule
