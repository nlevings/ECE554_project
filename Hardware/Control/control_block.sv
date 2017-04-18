module control_block(A0, A1, M, LS, control, err);

	// inputs
	input [4:0] A0, A1, M, LS;	// opcodes
	output [13:0] control;		// A0_imm_sel[13] A0_op[12:9] A1_imm_sel[8] A1_op[7:4] M_imm_sel[3] M[2] L[1] S[0]
	output err;
	
	wire A0_err, A1_err, M_err;
	
	alu_ops A0_ops(.op_in(A0), .op_out(control[12:9]), .imm_sel(control[13]), .err(A0_err));
	
	alu_ops A1_ops(.op_in(A1), .op_out(control[7:4]), .imm_sel(control[8]), .err(A1_err));
	
	assign control[3] = M == 5'b01110;					// M_imm_sel
	assign control[2] = M == 5'b01101 | M == 5'b01110;	// M enable
	
	assign control[1] = LS == 5'b10001;					// Load Enable
	assign control [0] = LS == 5'b10000;				// Store Enable

	assign M_err = ~(M == 5'b01101 | M == 5'b01110 | M == 5'b01100);
	assign err = A0_err | A1_err | M_err;

endmodule