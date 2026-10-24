module uart_apb_top
#(
    parameter CLKI_FREQ_MHZ = 25,
    parameter BAUD_RATE = 9600,
    parameter RX_FIFO_DEPTH = 16
)
(
    input        pclk,
    input        prstn,
    input  [3:0] paddr,
    input        psel,
    input        penable,
    input        pwrite,
    input        rxd,
    input  [7:0] pwdata,
    output [7:0] prdata,
    output       txd
);

    wire       tx_start;
    wire       tx_ready;
    wire [7:0] txd_in;

    wire       rxf_pop;
    wire       rxf_empty;
    wire       rxf_full;
    wire [7:0] rxf_data;

    wire       rx_done;
    wire       rxd_sync;
    wire [7:0] rxd_out;

    wire       set_ovr;
    wire       clr_ovr;
    wire       rx_ovr;

    wire       set_err;
    wire       clr_err;
    wire       rx_err;

    assign set_ovr = rx_done & rxf_full & !rxf_pop; // byte arrives while FIFO is full, no pop

    apb_interface apb_interface(
        .psel       (psel),
        .penable    (penable),
        .pwrite     (pwrite),
        .paddr      (paddr),
        .pwdata     (pwdata),
        .prdata     (prdata),
        .tx_ready   (tx_ready),
        .tx_start   (tx_start),
        .tx_data    (txd_in),
        .rxf_pop    (rxf_pop),
        .rxf_empty  (rxf_empty),
        .rxf_full   (rxf_full),
        .rxf_data   (rxf_data),
        .rx_ovr     (rx_ovr),
        .rx_err     (rx_err),
        .clr_ovr    (clr_ovr),
        .clr_err    (clr_err)
    );

    synchronizer rx_sync(
        .clk     (pclk),
        .nrst    (prstn),
        .async_i (rxd),
        .sync_o  (rxd_sync)
    );

    fifo #(
        .FIFO_DEPTH (RX_FIFO_DEPTH)
    ) rx_fifo(
        .clk    (pclk),
        .nrst   (prstn),
        .rden   (rxf_pop),
        .wren   (rx_done),
        .data_i (rxd_out),
        .empty  (rxf_empty),
        .full   (rxf_full),
        .data_o (rxf_data)
    );

    sticky_flag rx_ovr_flag(
        .clk  (pclk),
        .nrst (prstn),
        .set  (set_ovr),
        .clr  (clr_ovr),
        .flag (rx_ovr)
    );

    sticky_flag rx_err_flag(
        .clk  (pclk),
        .nrst (prstn),
        .set  (set_err),
        .clr  (clr_err),
        .flag (rx_err)
    );

    uart_rx #(
        .CLKI_FREQ_MHZ (CLKI_FREQ_MHZ),
        .BAUD_RATE     (BAUD_RATE)
    ) uart_rx(
        .clk     (pclk),
        .nrst    (prstn),
        .rx      (rxd_sync),
        .rx_done (rx_done),
        .data_o  (rxd_out),
        .rx_err  (set_err)
    );

    uart_tx #(
        .CLKI_FREQ_MHZ (CLKI_FREQ_MHZ),
        .BAUD_RATE     (BAUD_RATE)
    ) uart_tx(
        .clk      (pclk),
        .nrst     (prstn),
        .tx_start (tx_start),
        .data_i   (txd_in),
        .ready    (tx_ready),
        .tx_out   (txd)
    );

endmodule