module Memory(ref_clk, rst_n, A0_in, A0_Rd_tag_in, A1_in, A1_Rd_tag_in, M_in, M_Rd_tag_in, LS_Rd_tag_in,
	LS_data, LS_addr, R_nW, A0_out, A0_Rd_tag_out, A1_out, A1_Rd_tag_out, M_out, M_Rd_tag_out, LS_Rd_tag_out,
	wb_data, stall);

	// Inputs
	input ref_clk;
	input rst_n;
	
	// Pass through
	input [15:0] A0_in;			// Result from ALU0
	input [4:0] A0_Rd_tag_in;
	input [15:0] A1_in;			// Result from ALU1
	input [4:0] A1_Rd_tag_in;
	input [15:0] M_in;			// Result from Multiply
	input [4:0] M_Rd_tag_in;
	input [4:0] LS_Rd_tag_in;
	
	// LS
	input [7:0] LS_data;		// Data to store
	input [24:0] LS_addr;		// Address
	input R_nW;

	// Outputs
	// Pass through
	output [15:0] A0_out;			
	output [4:0] A0_Rd_tag_out;
	output [15:0] A1_out;			
	output [4:0] A1_Rd_tag_out;
	output [15:0] M_out;				
	output [4:0] M_Rd_tag_out;
	output [4:0] LS_Rd_tag_out;
	
	output [7:0] wb_data;	
	output stall;

	
	// Pass through signals
	assign A0_out = A0_in;
	assign A0_Rd_tag_out = A0_Rd_tag_in;
	assign A1_out = A1_in;
	assign A1_Rd_tag_out = A1_Rd_tag_in;
	assign M_out = M_in;
	assign M_Rd_tag_out = M_Rd_tag_in;
	assign LS_Rd_tag_out = LS_Rd_tag_in;
	
	
	// wires
	wire sd_busy;				// SDRAM_ctrl -> dmem_ctrl
	wire granted;				// SDRAM_ctrl -> dmem_ctrl
	wire [15:0] row_length;		// SDRAM_ctrl -> dmem_ctrl
	wire request;				// dmem_ctrl -> SDRAM_ctrl
	wire [24:0] start_addr;		// dmem_ctrl -> SDRAM_ctrl
	wire [24:0] length;			// dmem_ctrl -> SDRAM_ctrl
	wire [15:0] dmc_addr;		// dmem_ctrl -> mux -> dm_addr -> DM
	wire d_sb;					// Mux control, data mem controller is 1, SDRAM controller is 0
	
	wire [7:0] dm_data;			// Mux -> DM
	wire [15:0] dm_addr;		// Mux -> DM
	wire dm_R_nW;				// Mux -> DM
	wire [7:0] wb_data;			// DM -> MEM/WB Reg
	
	wire [7:0] sd_data;			// SDRAM_ctrl -> mux -> DM
	wire [15:0] sd_addr;		// SDRAM_ctrl -> mux -> DM
	wire sd_R_nW;				// SDRAM_ctrl -> mux -> DM
	
	wire [9:0] matrix_addr;		// SDRAM_ctrl -> matrix memory
	wire matrix_wr_en;
	
	dmem_ctrl(.rst_n(rst_n), .ref_clk(ref_clk), .granted(granted), .busy(sd_busy), .sdram_addr(LS_addr), row_length(row_length), 
			.request(request), .start_addr(start_addr), .length(length), .matrix_addr(matrix_addr), .matrix_wr_en(matrix_wr_en),
			.dmc_addr(dmc_addr), .stall(stall), .d_sb(d_sb));
			
	dmem(.data(dm_data), .addr(dm_addr), .R_nW(dm_R_nW), .wb_data(wb_data));
	
	// TODO: instantiate SDRAM Controller
	
	// Mux dmem inputs
	assign dm_data = (d_sb) ? LS_data : sd_data;
	assign dm_addr = (d_sb) ? dmc_addr : sd_addr;
	assign dm_R_nW = (d_sb) ? R_nW : sd_R_nW;

	
endmodule