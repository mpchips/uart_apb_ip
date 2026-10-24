module apb_rdata_mux(
    // input            pclk,
    // input            presetn,
    input      [3:2] paddr,
    // input      [7:0] pwdata,
    input            tx_ready,
    input            rx_ovr,
    input            rx_err,
    input            rxf_empty,
    input            rxf_full,
    input      [7:0] rxf_data,
    output reg [7:0] prdata
    // output     [7:0] tx_data
);

                                      // paddr[3:0]
    // localparam TXDATA_OFFSET = 2'b00; // b00xx
    localparam RXDATA_OFFSET = 2'b01; // b01xx
    localparam STATUS_OFFSET = 2'b10; // b10xx

    // assign tx_data = pwdata; // moving to apb top module

    always@(*) begin
        case (paddr)
            RXDATA_OFFSET:
                prdata = rxf_data;
            STATUS_OFFSET: 
                prdata = {3'd0, rx_err, rx_ovr, rxf_full, rxf_empty, tx_ready};
            default: 
                prdata = 8'd0;
        endcase
    end

endmodule