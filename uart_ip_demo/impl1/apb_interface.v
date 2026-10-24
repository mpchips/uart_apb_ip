// Verilog netlist produced by program LSE 
// Netlist written on Sat Oct 24 22:47:19 2026
// Source file index table: 
// Object locations will have the form @<file_index>(<first_ line>[<left_column>],<last_line>[<right_column>])
// file 0 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc.v"
// file 1 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_distributed_ram.v"
// file 2 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_ecc.v"
// file 3 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_flag_and_cnts_logic.v"
// file 4 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_gray_reg.v"
// file 5 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_gray_synchronizer.v"
// file 6 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden.v"
// file 7 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden_prim.v"
// file 8 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden_rd_ctrl_logic.v"
// file 9 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden_rd_output_logic.v"
// file 10 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden_ring_counter.v"
// file 11 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_harden_wr_ctrl_logic.v"
// file 12 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_prim_gen.v"
// file 13 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_rd_ctrl_logic.v"
// file 14 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/fifo_dc/rtl/lscc_lfmxo4_fifo_dc_wr_ctrl_logic.v"
// file 15 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp.v"
// file 16 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp_behavioral.v"
// file 17 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp_functions.vh"
// file 18 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp_impl.v"
// file 19 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp/rtl/lscc_lfmxo4_ram_dp_lut_decode.v"
// file 20 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true.v"
// file 21 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true_behavioral.v"
// file 22 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true_ecc_decoder.v"
// file 23 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true_functions.vh"
// file 24 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true_impl.v"
// file 25 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dp_true/rtl/lscc_lfmxo4_ram_dp_true_lut_decode.v"
// file 26 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dq/rtl/hsiao_ecc_decoder.v"
// file 27 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dq/rtl/hsiao_ecc_encoder.v"
// file 28 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dq/rtl/lscc_lfmxo4_ram_dq.v"
// file 29 "c:/lscc/radiant/2026.1.1/ip/lfmxo4/ram_dq/rtl/lscc_lfmxo4_ram_dq_lut_decode.v"
// file 30 "c:/lscc/radiant/2026.1.1/ip/common/adder/rtl/lscc_adder.v"
// file 31 "c:/lscc/radiant/2026.1.1/ip/common/adder_subtractor/rtl/lscc_add_sub.v"
// file 32 "c:/lscc/radiant/2026.1.1/ip/common/complex_mult/rtl/lscc_complex_mult.v"
// file 33 "c:/lscc/radiant/2026.1.1/ip/common/counter/rtl/lscc_cntr.v"
// file 34 "c:/lscc/radiant/2026.1.1/ip/common/distributed_dpram/rtl/lscc_distributed_dpram.v"
// file 35 "c:/lscc/radiant/2026.1.1/ip/common/distributed_rom/rtl/lscc_distributed_rom.v"
// file 36 "c:/lscc/radiant/2026.1.1/ip/common/distributed_spram/rtl/lscc_distributed_spram.v"
// file 37 "c:/lscc/radiant/2026.1.1/ip/common/fifo/rtl/lscc_fifo.v"
// file 38 "c:/lscc/radiant/2026.1.1/ip/common/fifo_dc/rtl/lscc_fifo_dc.v"
// file 39 "c:/lscc/radiant/2026.1.1/ip/common/mult_accumulate/rtl/lscc_mult_accumulate.v"
// file 40 "c:/lscc/radiant/2026.1.1/ip/common/mult_add_sub/rtl/lscc_mult_add_sub.v"
// file 41 "c:/lscc/radiant/2026.1.1/ip/common/mult_add_sub_sum/rtl/lscc_mult_add_sub_sum.v"
// file 42 "c:/lscc/radiant/2026.1.1/ip/common/multiplier/rtl/lscc_multiplier.v"
// file 43 "c:/lscc/radiant/2026.1.1/ip/common/ram_dp/rtl/lscc_ram_dp.v"
// file 44 "c:/lscc/radiant/2026.1.1/ip/common/ram_dp_true/rtl/lscc_ram_dp_true.v"
// file 45 "c:/lscc/radiant/2026.1.1/ip/common/ram_dq/rtl/lscc_ram_dq.v"
// file 46 "c:/lscc/radiant/2026.1.1/ip/common/ram_shift_reg/rtl/lscc_shift_register.v"
// file 47 "c:/lscc/radiant/2026.1.1/ip/common/rom/rtl/lscc_rom.v"
// file 48 "c:/lscc/radiant/2026.1.1/ip/common/subtractor/rtl/lscc_subtractor.v"
// file 49 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_add.v"
// file 50 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_addsub.v"
// file 51 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_complex_mult.v"
// file 52 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_counter.v"
// file 53 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_distributed_dpram.v"
// file 54 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_distributed_rom.v"
// file 55 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_distributed_shift_reg.v"
// file 56 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_distributed_spram.v"
// file 57 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_fifo.v"
// file 58 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_fifo_dc.v"
// file 59 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_mac.v"
// file 60 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_mult.v"
// file 61 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_multaddsub.v"
// file 62 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_multaddsubsum.v"
// file 63 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_ram_dp.v"
// file 64 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_ram_dp_be.v"
// file 65 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_ram_dp_true.v"
// file 66 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_ram_dq.v"
// file 67 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_ram_dq_be.v"
// file 68 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_rom.v"
// file 69 "c:/lscc/radiant/2026.1.1/ip/pmi/pmi_sub.v"

//
// Verilog Description of module apb_interface
//

module apb_interface (psel, penable, pwrite, paddr, pwdata, tx_ready, 
            rxf_empty, rxf_full, rxf_data, rx_ovr, prdata, tx_start, 
            tx_data, rxf_pop, clear_rx_ovr) /* synthesis cpe_box=1 */ ;
    input psel;
    input penable;
    input pwrite;
    input [3:0]paddr;
    input [7:0]pwdata;
    input tx_ready;
    input rxf_empty;
    input rxf_full;
    input [7:0]rxf_data;
    input rx_ovr;
    output [7:0]prdata;
    output tx_start;
    output [7:0]tx_data;
    output rxf_pop;
    output clear_rx_ovr;
    
    
    buf_8 buf_3 (.i({pwdata}), .o({tx_data})) /* synthesis strength0=strong0, strength1=strong1 */ ;
    apb_decoder decoder (.psel(psel), .penable(penable), .pwrite(pwrite), 
            .paddr({paddr[3:2]}), .rxf_empty(rxf_empty), .pwdata_3(pwdata[3]), 
            .tx_ready(tx_ready), .tx_start(tx_start), .rxf_pop(rxf_pop), 
            .clear_rx_ovr(clear_rx_ovr));
    apb_rdata_mux rdata_mux (.paddr({paddr[3:2]}), .tx_ready(tx_ready), 
            .rx_ovr(rx_ovr), .rxf_empty(rxf_empty), .rxf_full(rxf_full), 
            .rxf_data({rxf_data}), .prdata({prdata}));
    
endmodule

//
// Verilog Description of OPERATOR buf_8
//

module buf_8 (i, o);
    input [7:0]i;
    output [7:0]o;
    
    
    buf (o[0], i[0]) ;
    buf (o[1], i[1]) ;
    buf (o[2], i[2]) ;
    buf (o[3], i[3]) ;
    buf (o[4], i[4]) ;
    buf (o[5], i[5]) ;
    buf (o[6], i[6]) ;
    buf (o[7], i[7]) ;
    
endmodule

//
// Verilog Description of module apb_decoder
// module wrapper written out since it is a black-box. 
//

//

module apb_decoder (psel, penable, pwrite, paddr, rxf_empty, pwdata_3, 
            tx_ready, tx_start, rxf_pop, clear_rx_ovr);
    input psel;
    input penable;
    input pwrite;
    input [1:0]paddr;
    input rxf_empty;
    input pwdata_3;
    input tx_ready;
    input tx_start;
    input rxf_pop;
    input clear_rx_ovr;
    
    
    
endmodule

//
// Verilog Description of module apb_rdata_mux
// module wrapper written out since it is a black-box. 
//

//

module apb_rdata_mux (paddr, tx_ready, rx_ovr, rxf_empty, rxf_full, 
            rxf_data, prdata);
    input [1:0]paddr;
    input tx_ready;
    input rx_ovr;
    input rxf_empty;
    input rxf_full;
    input [7:0]rxf_data;
    input [7:0]prdata;
    
    
    
endmodule
