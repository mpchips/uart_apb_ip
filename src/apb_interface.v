module apb_interface(
    // input        pclk,
    // input        presetn,
    input        psel,
    input        penable,
    input        pwrite,
    input  [3:0] paddr,
    input  [7:0] pwdata,
    input        tx_ready,
    input        rxf_empty,
    input        rxf_full,
    input  [7:0] rxf_data,
    input        rx_ovr,
    input        rx_err,
    output [7:0] prdata,
    output       tx_start,
    output [7:0] tx_data,
    output       rxf_pop,
    output       clr_ovr,
    output       clr_err
);

    assign tx_data = pwdata;

    apb_decoder decoder(
        .psel       (psel),
        .penable    (penable),
        .pwrite     (pwrite),
        .paddr      (paddr[3:2]),
        .rxf_empty  (rxf_empty),
        // .rxf_full  (rxf_full),
        .pwdata_3   (pwdata[3]),
        .pwdata_4   (pwdata[4]),
        .tx_ready   (tx_ready),
        .tx_start   (tx_start),
        .rxf_pop    (rxf_pop),
        .clr_ovr    (clr_ovr),
        .clr_err    (clr_err)
    );

    apb_rdata_mux rdata_mux(
        .paddr      (paddr[3:2]),
        .tx_ready   (tx_ready),
        .rx_ovr     (rx_ovr),
        .rx_err     (rx_err),
        .rxf_empty  (rxf_empty),
        .rxf_full   (rxf_full),
        .rxf_data   (rxf_data),
        .prdata     (prdata)
    );

endmodule