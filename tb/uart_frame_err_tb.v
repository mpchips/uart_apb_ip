`timescale 1ns/1ps

// self-checking framing-error testbench for uart_apb_top
// the testbench drives rxd directly. Covers:
//  - a frame with a bad stop bit is not written to the RX FIFO, and the
//    receiver still accepts the next good frame
//  - a bad frame sets RX_ERR (STATUS bit 4)
//  - RX_ERR is sticky across STATUS reads and RXDATA pops
//  - writing 0 to bit 4, 1 to bit 3 only, or 1 to bit 4 at another offset,
//    does not clear it
//  - writing 1 to STATUS bit 4 clears it
//  - set and W1C in the same cycle: set wins
// The same-cycle case times the APB access phase to the rx_err cycle
// using the receiver's bit_idx (white-box)
module uart_frame_err_tb;

    localparam CLK_PERIOD = 40;   // 25 MHz
    localparam BIT_CYCLES = 2604; // 25 MHz / 9600 baud

    localparam [3:0] RXDATA   = 4'h4;
    localparam [3:0] STATUS   = 4'h8;
    localparam [3:0] UNMAPPED = 4'hC;

    // STATUS values: {3'b0, RX_ERR, RX_OVR, RX_FULL, RX_EMPTY, TX_READY}
    localparam [7:0] ST_IDLE_EMPTY = 8'h03;
    localparam [7:0] ST_IDLE_DATA  = 8'h01;
    localparam [7:0] ST_ERR_EMPTY  = 8'h13;
    localparam [7:0] ST_ERR_DATA   = 8'h11;

    reg        pclk;
    reg        prstn;
    reg  [3:0] paddr;
    reg        psel;
    reg        penable;
    reg        pwrite;
    reg  [7:0] pwdata;
    reg        rxd;
    wire [7:0] prdata;
    wire       txd;

    uart_apb_top dut(
        .pclk    (pclk),
        .prstn   (prstn),
        .paddr   (paddr),
        .psel    (psel),
        .penable (penable),
        .pwrite  (pwrite),
        .rxd     (rxd),
        .pwdata  (pwdata),
        .prdata  (prdata),
        .txd     (txd)
    );

    integer pass_cnt, fail_cnt;
    integer done_cnt, err_cnt;
    integer clr_coinc_cnt;
    reg [7:0] rdata;

    initial pclk = 1'b0;
    always #(CLK_PERIOD/2) pclk = ~pclk;

    // count receiver pulses through hierarchy, to tell "dropped after a
    // detected framing error" apart from "frame never received", and count
    // the same-cycle set/clear event so a missed timing shows up as a
    // failure instead of a false pass
    always @(posedge pclk) begin
        if (prstn) begin
            if (dut.uart_rx.rx_done) done_cnt = done_cnt + 1;
            if (dut.uart_rx.rx_err)  err_cnt  = err_cnt + 1;
            if (dut.set_err & dut.clr_err)
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

    // APB2 write whose access phase lines up with the rx_err cycle.
    // bit_idx reaches 9 on the stop-bit sample; the controller enters ERR
    // one clock later and rx_err is high for the clock after that
    task apb_write_at_rx_err;
        input [3:0] addr;
        input [7:0] data;
        begin
            wait (dut.uart_rx.controller.bit_idx == 4'd9);
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

    task check_count;
        input [8*24-1:0] name;
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

    task hold_bit;
        input b;
        begin
            rxd = b;
            repeat (BIT_CYCLES) @(posedge pclk);
        end
    endtask

    // drive one 8N1 frame on rxd, LSB first, then two idle bit periods
    task send_frame;
        input [7:0] data;
        input       stop;
        integer k;
        begin
            hold_bit(1'b0);
            for (k = 0; k < 8; k = k + 1)
                hold_bit(data[k]);
            hold_bit(stop);
            hold_bit(1'b1);
            hold_bit(1'b1);
        end
    endtask

    initial begin
        pass_cnt      = 0;
        fail_cnt      = 0;
        done_cnt      = 0;
        err_cnt       = 0;
        clr_coinc_cnt = 0;

        rxd     = 1'b1;
        prstn   = 1'b0;
        psel    = 1'b0;
        penable = 1'b0;
        pwrite  = 1'b0;
        paddr   = 4'h0;
        pwdata  = 8'h00;
        repeat (5) @(posedge pclk);
        prstn = 1'b1;
        repeat (BIT_CYCLES) @(posedge pclk);

        apb_read(STATUS, rdata);
        check("STATUS after reset", rdata, ST_IDLE_EMPTY);

        // ---- bad frame on an empty FIFO: nothing written, RX_ERR set ----
        send_frame(8'hA5, 1'b0);
        check_count("rx_err pulses", err_cnt, 1);
        check_count("rx_done pulses", done_cnt, 0);
        apb_read(STATUS, rdata);
        check("STATUS after bad frame", rdata, ST_ERR_EMPTY);

        // ---- RX_ERR is sticky ----
        apb_read(STATUS, rdata);
        check("STATUS read again", rdata, ST_ERR_EMPTY);
        apb_write(STATUS,   8'hEF);  // bit 4 = 0
        apb_write(STATUS,   8'h08);  // bit 3 only (RX_OVR W1C)
        apb_write(UNMAPPED, 8'h10);  // bit 4 = 1, wrong offset
        apb_write(RXDATA,   8'h10);  // bit 4 = 1, wrong offset
        apb_read(STATUS, rdata);
        check("STATUS after bad writes", rdata, ST_ERR_EMPTY);

        // ---- W1C clears ----
        apb_write(STATUS, 8'h10);
        apb_read(STATUS, rdata);
        check("STATUS after W1C", rdata, ST_IDLE_EMPTY);

        // ---- good, bad, good: only the good bytes are stored ----
        send_frame(8'h11, 1'b1);
        send_frame(8'h22, 1'b0);
        send_frame(8'h33, 1'b1);
        check_count("rx_err pulses", err_cnt, 2);
        check_count("rx_done pulses", done_cnt, 2);
        apb_read(STATUS, rdata);
        check("STATUS with data", rdata, ST_ERR_DATA);

        // RX_ERR stays set while the FIFO is drained
        apb_read(RXDATA, rdata);
        check("RXDATA 1st", rdata, 8'h11);
        apb_read(STATUS, rdata);
        check("STATUS after 1st pop", rdata, ST_ERR_DATA);
        apb_read(RXDATA, rdata);
        check("RXDATA 2nd", rdata, 8'h33);
        apb_read(STATUS, rdata);
        check("STATUS after drain", rdata, ST_ERR_EMPTY);
        apb_write(STATUS, 8'h10);
        apb_read(STATUS, rdata);
        check("STATUS after 2nd W1C", rdata, ST_IDLE_EMPTY);

        // ---- bad frame with all-zero data (line held low, like a break) ----
        send_frame(8'h00, 1'b0);
        send_frame(8'hC3, 1'b1);
        check_count("rx_err pulses", err_cnt, 3);
        check_count("rx_done pulses", done_cnt, 3);
        apb_read(RXDATA, rdata);
        check("RXDATA after break", rdata, 8'hC3);
        apb_read(STATUS, rdata);
        check("STATUS after break", rdata, ST_ERR_EMPTY);
        apb_write(STATUS, 8'h10);

        // ---- set and W1C in the same cycle: set wins ----
        fork
            send_frame(8'h5A, 1'b0);
            apb_write_at_rx_err(STATUS, 8'h10);
        join
        check_count("set/W1C same cycle", clr_coinc_cnt, 1);
        check_count("rx_err pulses", err_cnt, 4);
        apb_read(STATUS, rdata);
        check("STATUS set over W1C", rdata, ST_ERR_EMPTY);
        apb_write(STATUS, 8'h10);
        apb_read(STATUS, rdata);
        check("STATUS final", rdata, ST_IDLE_EMPTY);

        // a good frame after clearing does not set RX_ERR
        send_frame(8'h7E, 1'b1);
        apb_read(STATUS, rdata);
        check("STATUS after good frame", rdata, ST_IDLE_DATA);
        apb_read(RXDATA, rdata);
        check("RXDATA last", rdata, 8'h7E);

        $display("uart_frame_err_tb: %0d checks passed, %0d failed", pass_cnt, fail_cnt);
        if (fail_cnt == 0)
            $display("uart_frame_err_tb: PASS");
        else
            $display("uart_frame_err_tb: FAIL");
        $finish;
    end

    // watchdog
    initial begin
        #(CLK_PERIOD * BIT_CYCLES * 12 * 15);
        fail_cnt = fail_cnt + 1;
        $display("uart_frame_err_tb: FAIL (watchdog timeout)");
        $finish;
    end

endmodule
