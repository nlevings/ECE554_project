module Execute(
	// Inputs
	A0_R0, A0_R1, A0_Rd_tag_in, A0_imm, A0_imm_sel, A0_op, A1_R0, A1_R1, A1_Rd_tag_in, A1_imm, A1_imm_sel, A1_op,
	M_R0, M_R1, M_Rd_tag_in, M_imm, M_imm_sel, LS_R0, LS_R1, LS_Rd_tag_in,
	// Outputs
	A0_res, A0_Rd_tag_out, A1_res, A1_Rd_tag_out, M_res, M_Rd_tag_out, LS_data, LS_tag, LS_addr, LS_Rd_tag_out
	);
	
	// Inputs
	// A0
	input [20:0] A0_R0, A0_R1;	// [4:0] = tag bits
	input [4:0] A0_Rd_tag_in;
	input [4:0] A0_imm;			
	input A0_imm_sel;			// 1 if using immediate, 0 if using R1
	input [3:0] A0_op;
	
	// A1
	input [20:0] A1_R0, A1_R1;	// [4:0] = tag bits
	input [4:0] A1_Rd_tag_in;
	input [4:0] A1_imm;
	input A1_imm_sel;			// 1 if using immediate, 0 if using R1
	input [3:0] A1_op;

	// M
	input [20:0] M_R0, M_R1;	// [4:0] = tag bits
	input [4:0] M_Rd_tag_in;
	input [4:0] M_imm;			
	input M_imm_sel;			// 1 if using immediate, 0 if using R1
	
	// LS
	input [20:0] LS_R0;
	input [20:0] LS_R1;
	input LS_Rd_tag_in;
	
	// Outputs
	// A0
	output [25:0] A0_res;		// [25:10] = A0's result. [9:5],[4:0] = R1, R0 tag bits
	output [4:0] A0_Rd_tag_out;
	
	// A1
	output [25:0] A1_res;		// [25:10] = A1's result. [9:5],[4:0] = R1, R0 tag bits
	output [4:0] A1_Rd_tag_out;	
	
	// M
	output [25:0] M_res;		// [25:10] = M's result. [9:5],[4:0] = R1, R0 tag bits
	output [4:0] M_Rd_tag_out;	
	
	// LS
	output [7:0] LS_data;
	output [4:0] LS_tag;
	output [24:0] LS_addr;		// extended to 25 bits
	output [4:0] LS_Rd_tag_out;
	
	// Wires
	wire [15:0] A0_B;			// Second input (B) into A0
	wire [15:0] A1_B;			// Second input (B) into A1
	wire [15:0] M_B;			// Second input (B) into mul
	
	// A0
	// Mux zero extended immediate or R1
	assign A0_B = (A0_imm_sel) ? {11'b0, A0_imm[4:0]} : A0_R1[20:5];
	// concatenate tag bits (R1, then R0). If using immediate, tag bits are 0.
	assign A0_res[9:0] = (A0_imm_sel) ? {5'b0, A0_R0[4:0]} : {A0_R1[4:0], A0_R0[4:0]};
	
	assign A0_Rd_tag_out = A0_Rd_tag_in;
	
	ALU A0(.A(A0_R0[20:5]), .B(A0_B), .op(A0_op), .result(A0_res[25:10]));
	
	// A1
	// Mux zero extended immediate or R1
	assign A1_B = (A1_imm_sel) ? {11'b0, A1_imm[4:0]} : A1_R1[20:5];
	// concatenate tag bits (R1, then R0). If using immediate, tag bits are 0.
	assign A1_res[9:0] = (A1_imm_sel) ? {5'b0, A1_R0[4:0]} : {A1_R1[4:0], A1_R0[4:0]};
	
	assign A1_Rd_tag_out = A1_Rd_tag_in;
	
	ALU A1(.A(A1_R0[20:5]), .B(A1_B), .op(A1_op), .result(A1_res[25:10]));
	
	// M
	// Mux zero extended immediate or R1
	assign M_B = (M_imm_sel) ? {11'b0, M_imm[4:0]} : M_R1[20:5];
	// concatenate tag bits (R1, then R0). If using immediate, tag bits are 0.
	assign M_res[9:0] = (M_imm_sel) ? {5'b0, M_R0[4:0]} : {M_R1[4:0], M_R0[4:0]};
	
	assign M_Rd_tag_out = M_Rd_tag_in;
	
	MUL M(.A(M_R0[20:5]), .B(M_B), .result(M_res[25:10]));
	
	// LS
	// TODO
	
	assign LS_Rd_tag_out = LS_Rd_tag_in;
	
endmodule