`timescale 100 ps/100 ps
module CCU2 (
  A0,
  B0,
  C0,
  D0,
  A1,
  B1,
  C1,
  D1,
  CIN,
  COUT,
  S0,
  S1
)
;
input A0 ;
input B0 ;
input C0 ;
input D0 ;
input A1 ;
input B1 ;
input C1 ;
input D1 ;
input CIN ;
output COUT ;
output S0 ;
output S1 ;
parameter INIT0="0x0000";
parameter INIT1="0x0000";
parameter INJECT="NO";
endmodule /* CCU2 */

