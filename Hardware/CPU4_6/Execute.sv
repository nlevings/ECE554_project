module Execute(
	// Inputs
	A0_R0, A0_R1, A0_Rd_tag_in, A0_imm, A0_imm_sel, A0_op, A1_R0, A1_R1, A1_Rd_tag_in, A1_imm, A1_imm_sel, A1_op,
	M_R0, M_R1, M_Rd_tag_in, M_imm, M_imm_sel, LS_R0, LS_R1, LS_R2, LS_Rd_tag_in, write,
	// Outputs
	A0_res, A0_Rd_tag_out, A1_res, A1_Rd_tag_out, M_res, M_Rd_tag_out, LS_data, LS_addr, LS_R_nW, LS_Rd_tag_out
	);
	
	// NOTE: In the project architecture document, we use src1 and src2 instead of R0 and R1.
	// src1 = R0, src2 = R1.
	
	
	// Inputs
	// A0
	input [15:0] A0_R0, A0_R1;
	input [4:0] A0_Rd_tag_in;
	input [4:0] A0_imm;			
	input A0_imm_sel;			// 1 if using immediate, 0 if using R1
	input [3:0] A0_op;
	
	// A1
	input [15:0] A1_R0, A1_R1;
	input [4:0] A1_Rd_tag_in;
	input [4:0] A1_imm;
	input A1_imm_sel;			// 1 if using immediate, 0 if using R1
	input [3:0] A1_op;

	// M
	input [15:0] M_R0, M_R1;
	input [4:0] M_Rd_tag_in;
	input [4:0] M_imm;			
	input M_imm_sel;			// 1 if using immediate, 0 if using R1
	
	// LS
	input [15:0] LS_R0;			// lower 16 of addr
	input [15:0] LS_R1;			// [15:9] = ignored, [8:0] = upper 9 bits of addr
	input [15:0] LS_R2;			// [15:8] = ignored, [7:0] = data
	input [4:0] LS_Rd_tag_in;	
	input write;				// Should hook up to control[0]
	
	// Outputs
	// A0
	output [15:0] A0_res;
	output [4:0] A0_Rd_tag_out;
	
	// A1
	output [15:0] A1_res;
	output [4:0] A1_Rd_tag_out;	
	
	// M
	output [15:0] M_res;
	output [4:0] M_Rd_tag_out;	
	
	// LS
	output [7:0] LS_data;
	output [24:0] LS_addr;		
	output 		 LS_R_nW;		// Read_/write siganl. Defaults to read.
	output [4:0] LS_Rd_tag_out;
	
	// Wires
	wire [15:0] A0_B;			// Second input (B) into A0
	wire [15:0] A1_B;			// Second input (B) into A1
	wire [15:0] M_B;			// Second input (B) into mul
	
	// A0
	// Mux zero extended immediate or R1
	assign A0_B = (A0_imm_sel) ? {11'b0, A0_imm[4:0]} : A0_R1;
	
	assign A0_Rd_tag_out = A0_Rd_tag_in;
	
	ALU A0(.A(A0_R0), .B(A0_B), .op(A0_op), .result(A0_res));
	
	// A1
	// Mux zero extended immediate or R1
	assign A1_B = (A1_imm_sel) ? {11'b0, A1_imm[4:0]} : A1_R1;
	
	assign A1_Rd_tag_out = A1_Rd_tag_in;
	
	ALU A1(.A(A1_R0), .B(A1_B), .op(A1_op), .result(A1_res));
	
	// M
	// Mux zero extended immediate or R1
	assign M_B = (M_imm_sel) ? {11'b0, M_imm[4:0]} : M_R1;
	
	assign M_Rd_tag_out = M_Rd_tag_in;
	
	MUL M(.A(M_R0), .B(M_B), .result(M_res));
	
	// LS
	assign LS_data = LS_R2[7:0];
	assign LS_addr = {LS_R1[8:0], LS_R0};
	assign LS_R_nW = ~write;
	assign LS_Rd_tag_out = LS_Rd_tag_in;
	
endmodule