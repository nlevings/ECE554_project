module control_block_tb();
	
	reg clk;

	// A0
	reg [20:0] A0_R0, A0_R1;	// [4:0] = tag bits
	reg [4:0] A0_Rd_tag_in;
	reg [4:0] A0_imm;			
	reg A0_imm_sel;			// 1 if using immediate, 0 if using R1
	reg [3:0] A0_op;
	wire [25:0] A0_res;		// [25:10] = A0's result. [9:5],[4:0] = R1, R0 tag bits
	
	string A0_test;
	reg A0_done;
	reg [25:0] A0_expected;
	
	// A1
	reg [20:0] A1_R0, A1_R1;	// [4:0] = tag bits
	reg [4:0] A1_Rd_tag_in;
	reg [4:0] A1_imm;
	reg A1_imm_sel;			// 1 if using immediate, 0 if using R1
	reg [3:0] A1_op;
	wire [25:0] A1_res;		// [25:10] = A1's result. [9:5],[4:0] = R1, R0 tag bits
	
	string A1_test;
	reg A1_done;
	reg [25:0] A1_expected;

	// M
	reg [20:0] M_R0, M_R1;	// [4:0] = tag bits
	reg [4:0] M_Rd_tag_in;
	reg [4:0] M_imm;			
	reg M_imm_sel;			// 1 if using immediate, 0 if using R1
	wire [25:0] M_res;		// [25:10] = M's result. [9:5],[4:0] = R1, R0 tag bits
	
	string M_test;
	reg M_done;
	reg [25:0] M_expected;
	
	// LS
	reg [20:0] LS_R0;
	reg [20:0] LS_R1;
	reg [4:0] LS_Rd_tag_in;
	wire [4:0] LS_tag;
	wire [7:0] LS_data;
	wire [20:0] LS_addr;
	
	string LS_test;
	reg LS_done;
	reg [7:0] LS_expected_data;
	
	// control
	reg [4:0] A0, A1, M, LS;
	wire [13:0] control;	// A0_imm_sel[13] A0_op[12:9] A1_imm_sel[8] A1_op[7:4] M_imm_sel[3] M[2] L[1] S[0]
	
	assign A0_imm_sel = control[13];
	assign A0_op = control[12:9];
	assign A1_imm_sel = control[8];
	assign A1_op
	
	
	control_block(A0, A1, M, LS, control, err);
	
	Execute DUT(
		// Inputs
		A0_R0, A0_R1, A0_Rd_tag_in, A0_imm, A0_imm_sel, A0_op, A1_R0, A1_R1, A1_Rd_tag_in, A1_imm, A1_imm_sel, A1_op,
		M_R0, M_R1, M_Rd_tag_in, M_imm, M_imm_sel, LS_R0, LS_R1, LS_Rd_tag_in,
		// Outputs
		A0_res, A0_Rd_tag_out, A1_res, A1_Rd_tag_out, M_res, M_Rd_tag_out, LS_data, LS_tag, LS_addr, LS_Rd_tag_out
	);

	// ALU tested in ALU_tb. These tests are to make sure connections work.
	// A0 Tests
	initial begin
		A0_done = 0;
		
		A0_test = "A0_ADD0";
		A0_R0 = {16'h1234, 5'b00000};
		A0_R1 = {16'h5678, 5'b00001};
		A0_imm = 5'h00;
		A0_imm_sel = 0;
		A0_op = ALU_ADD;
		A0_expected = {16'h68AC, A0_R1[4:0] & ~{5{A0_imm_sel}}, A0_R0[4:0]};
		@(posedge clk);
		
		A0_test = "A0_SUB0";
		A0_R0 = {16'h1234, 5'b00000};
		A0_R1 = {16'h5678, 5'b00001};
		A0_imm = 5'h04;
		A0_imm_sel = 1;
		A0_op = ALU_SUB;
		A0_expected = {16'h1230, A0_R1[4:0] & ~{5{A0_imm_sel}}, A0_R0[4:0]};
		@(posedge clk);

		A0_done = 1;
	end
	
	// A1 Tests
	initial begin
		A1_done = 0;
		
		
		A1_test = "A1_ADD0";
		A1_R0 = {16'h1234, 5'b00000};
		A1_R1 = {16'h5678, 5'b00001};
		A1_imm = 5'h00;
		A1_imm_sel = 0;
		A1_op = ALU_ADD;
		A1_expected = {16'h68AC, A1_R1[4:0] & ~{5{A1_imm_sel}}, A1_R0[4:0]};
		@(posedge clk);
		
		A1_test = "A1_ADD1";
		A1_R0 = {16'h1234, 5'b00000};
		A1_R1 = {16'h5678, 5'b00001};
		A1_imm = 5'h15;
		A1_imm_sel = 1;
		A1_op = ALU_ADD;
		A1_expected = {16'h1249, A1_R1[4:0] & ~{5{A1_imm_sel}}, A1_R0[4:0]};
		@(posedge clk);
		
		A1_done = 1;
	end
	
	// M Tests
	initial begin
		M_done = 0;
		
		M_test = "M_0";
		M_R0 = {16'h0004, 5'b00000};
		M_R1 = {16'h0002, 5'b00001};
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_expected = {16'h0008, M_R1[4:0] & ~{5{M_imm_sel}}, M_R0[4:0]};
		@(posedge clk);
		
		M_test = "M_1";
		M_R0 = {16'h0FFF, 5'b00000};
		M_R1 = {16'hF002, 5'b00001};
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_expected = {16'hFFFF, M_R1[4:0] & ~{5{M_imm_sel}}, M_R0[4:0]};
		@(posedge clk);
		
		M_test = "M_2";
		M_R0 = {16'h00EA, 5'b00000};
		M_R1 = {16'h000B, 5'b00001};
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_expected = {16'h0A0E, M_R1[4:0] & ~{5{M_imm_sel}}, M_R0[4:0]};
		@(posedge clk);
		
		M_test = "M_3";
		M_R0 = {16'h00EA, 5'b00000};
		M_R1 = {16'h000B, 5'b00001};
		M_imm = 5'h1F;
		M_imm_sel = 1;
		M_expected = {16'h1C56, M_R1[4:0] & ~{5{M_imm_sel}}, M_R0[4:0]};
		@(posedge clk);
		
		M_done = 1;
	end
	
	// LS Tests
	initial begin
		LS_done = 1;
		
		LS_test = "";
		LS_R0 = 0;
		LS_R1 = 0;
		LS_expected_data = 0;
		
	end
	
	always@(posedge clk) begin
		if(A0_done)
			;// Done
		else if(A0_expected == A0_res)
			$display("%s Passed", A0_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				A0_test, A0_expected[20:10], A0_expected[9:0], A0_res[20:10], A0_res[9:0]);
			
		if(A1_done)
			;// Done
		else if(A1_expected == A1_res)
			$display("%s Passed", A1_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				A1_test, A1_expected[20:10], A1_expected[9:0], A1_res[20:10], A1_res[9:0]);

		if(M_done)
			;// Done
		else if(M_expected == M_res)
			$display("%s Passed", M_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				M_test, M_expected[20:10], M_expected[9:0], M_res[20:10], M_res[9:0]);
			
		if(LS_done)
			;// Done
		else if(LS_expected_data == LS_data)
			$display("%s Passed", A0_test);
		else
			$display("***%s Failed. Expected %h, got %h.***", LS_test, LS_expected_data, LS_data);
	end
			
	always@(posedge clk)
		if(A0_done & A1_done & M_done & LS_done)
			$stop;
	
	initial
		clk = 0;
	
	always
		#10 clk = ~clk;
	

endmodule