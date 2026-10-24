module apb_decoder (
    // input            pclk,
    // input            presetn,
    input            psel,
    input            penable,
    input            pwrite,
    input      [3:2] paddr,
    input            rxf_empty,
    // input             rxf_full,
    input            tx_ready,
    input            pwdata_3,
    input            pwdata_4,
    output reg       tx_start,
    output reg       rxf_pop,
    output reg       clr_ovr,
    output reg       clr_err
);

                                      // paddr[3:0]
    localparam TXDATA_OFFSET = 2'b00; // b00xx
    localparam RXDATA_OFFSET = 2'b01; // b01xx
    localparam STATUS_OFFSET = 2'b10; // b10xx

    // strobe generator (tx_start, rxf_pop, clr_ovr, clr_err)
    always@(*) begin
        if (psel & penable) begin // if in ENABLE state
            if (pwrite) begin // write operation

                rxf_pop = 1'b0; // not asserted for write

                case (paddr)
                    TXDATA_OFFSET: begin
                        tx_start = (tx_ready == 1'b1);
                        clr_ovr = 1'b0;
                        clr_err = 1'b0;
                    end
                    STATUS_OFFSET: begin
                        tx_start = 1'b0;
                        clr_ovr = (pwdata_3 == 1'b1);
                        clr_err = (pwdata_4 == 1'b1);
                    end
                    default: begin
                        tx_start = 1'b0;
                        clr_ovr = 1'b0;
                        clr_err = 1'b0;
                    end
                endcase

            end else begin // read operation

                tx_start = 1'b0; // not asserted for read
                clr_ovr = 1'b0; // not asserted for read
                clr_err = 1'b0; // not asserted for read

                case (paddr)
                    RXDATA_OFFSET:
                        rxf_pop = (rxf_empty == 1'b0);
                    default:
                        rxf_pop = 1'b0;
                endcase

            end
        end else begin
            tx_start = 1'b0;
            rxf_pop = 1'b0;
            clr_ovr = 1'b0;
            clr_err = 1'b0;
        end
    end

endmodule