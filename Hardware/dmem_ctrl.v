module dmem_ctrl(
input rst_n,
input ref_clk,
input busy
input [24:0] sdram_addr,

output request,
output [24:0] start_addr,
output [24:0] length,
output [15:0] dmc_addr,
output stall

output d_sb // choose the input for data memory (from data mem controller is 1, from SDRAM controller is 0)
);


endmodule
