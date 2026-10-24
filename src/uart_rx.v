module uart_rx
#(
    parameter CLKI_FREQ_MHZ = 25,
    parameter BAUD_RATE = 9600
)
(
    input        clk,
    input        nrst,
    input        rx,
    output       rx_done,
    output       rx_err,
    output [7:0] data_o
);

    localparam BAUD_PERIOD = CLKI_FREQ_MHZ*1000000/BAUD_RATE;

    wire en_deb;
    wire en_ctr;
    wire st_rx;
    wire en_sample;
    wire curr_bit;

    rx_controller controller(
        .clk       (clk),       // inputs
        .nrst      (nrst),
        .st        (st_rx),
        .en_sample (en_sample),
        .curr_bit  (curr_bit),
        .en_deb    (en_deb),    // outputs
        .en_ctr    (en_ctr),
        .rx_done   (rx_done),
        .rx_err    (rx_err)
    );

    debouncer #(
        .DELAY(BAUD_PERIOD/2)
    ) debouncer(
        .clk      (clk),    // inputs
        .nrst     (nrst),
        .en       (en_deb),
        .sig      (rx),
        .detected (st_rx)   // output
    );

    rx_counter #(
        .BAUD_PERIOD(BAUD_PERIOD)
    )counter(
        .clk       (clk),      // inputs
        .nrst      (nrst),
        .en        (en_ctr),
        .en_sample (en_sample) // output
    );

    rx_shifter rx_shifter(
        .clk       (clk),       // inputs
        .nrst      (nrst),
        .ser_in    (rx),
        .en_sample (en_sample),
        .curr_bit  (curr_bit),  // outputs
        .data      (data_o)
    );


endmodule