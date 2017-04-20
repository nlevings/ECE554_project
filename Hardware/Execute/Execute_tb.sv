module Execute_tb();
	
	reg clk;

	// A0
	reg [15:0] A0_R0, A0_R1;
	reg [4:0] A0_Rd_tag_in;
	reg [4:0] A0_imm;			
	reg A0_imm_sel;			// 1 if using immediate, 0 if using R1
	reg [3:0] A0_op;
	wire [15:0] A0_res;
	wire [4:0] A0_Rd_tag_out;
	
	string A0_test;
	reg A0_done;
	reg [15:0] A0_expected;
	
	// A1
	reg [15:0] A1_R0, A1_R1;
	reg [4:0] A1_Rd_tag_in;
	reg [4:0] A1_imm;
	reg A1_imm_sel;			// 1 if using immediate, 0 if using R1
	reg [3:0] A1_op;
	wire [15:0] A1_res;	
	wire [4:0] A1_Rd_tag_out;
	
	string A1_test;
	reg A1_done;
	reg [15:0] A1_expected;

	// M
	reg [15:0] M_R0, M_R1;
	reg [4:0] M_Rd_tag_in;
	reg [4:0] M_imm;			
	reg M_imm_sel;			// 1 if using immediate, 0 if using R1
	wire [15:0] M_res;
	wire [4:0] M_Rd_tag_out;
	
	string M_test;
	reg M_done;
	reg [15:0] M_expected;
	
	// LS
	reg [15:0] LS_R0;
	reg [15:0] LS_R1;
	reg [15:0] LS_R2;
	reg [4:0] LS_Rd_tag_in;	
	reg write;				
	wire [7:0] LS_data;
	wire [24:0] LS_addr;		
	wire 		 LS_R_nW;		// Read_/write siganl. Defaults to read.
	wire [4:0] LS_Rd_tag_out;
	
	string LS_test;
	reg LS_done;
	reg [7:0] LS_expected_data;
	reg [24:0] LS_expected_addr;
	reg LS_expected_R_nW;
	
	// ALU OPs
	localparam ALU_ADD = 4'b0000;
	localparam ALU_SUB = 4'b0001;
	localparam ALU_AND = 4'b0010;
	localparam ALU_OR = 4'b0011;
	localparam ALU_XOR = 4'b0100;
	localparam ALU_NOT = 4'b0101;
	localparam ALU_CLR = 4'b0110;
	localparam ALU_CMPE = 4'b0111;
	localparam ALU_CMPG = 4'b1000;
	localparam ALU_CMPL = 4'b1001;
	localparam ALU_SHRA = 4'b1010;
	localparam ALU_SHRL = 4'b1011;
	localparam ALU_SHL = 4'b1100;
	

	Execute DUT(A0_R0, A0_R1, A0_Rd_tag_in, A0_imm, A0_imm_sel, A0_op, A1_R0, A1_R1, A1_Rd_tag_in, A1_imm, A1_imm_sel, A1_op,
		M_R0, M_R1, M_Rd_tag_in, M_imm, M_imm_sel, LS_R0, LS_R1, LS_R2, LS_Rd_tag_in, write,
		A0_res, A0_Rd_tag_out, A1_res, A1_Rd_tag_out, M_res, M_Rd_tag_out, LS_data, LS_addr, LS_R_nW, LS_Rd_tag_out);

	// ALU tested in ALU_tb. These tests are to make sure connections work.
	// A0 Tests
	initial begin
		A0_done = 0;
		
		A0_test = "A0_ADD0";
		A0_R0 = 16'h1234;
		A0_R1 = 16'h5678;
		A0_imm = 5'h00;
		A0_imm_sel = 0;
		A0_Rd_tag_in = 5'b01001;
		A0_op = ALU_ADD;
		A0_expected = 16'h68AC;
		@(posedge clk);
		
		A0_test = "A0_SUB0";
		A0_R0 = 16'h1234;
		A0_R1 = 16'h5678;
		A0_imm = 5'h04;
		A0_imm_sel = 1;
		A0_Rd_tag_in = 5'b11011;
		A0_op = ALU_SUB;
		A0_expected = 16'h1230;
		@(posedge clk);

		A0_done = 1;
	end
	
	// A1 Tests
	initial begin
		A1_done = 0;
		
		A1_test = "A1_ADD0";
		A1_R0 = 16'h1234;
		A1_R1 = 16'h5678;
		A1_imm = 5'h00;
		A1_imm_sel = 0;
		A1_Rd_tag_in = 5'b01001;
		A1_op = ALU_ADD;
		A1_expected = 16'h68AC;
		@(posedge clk);
		
		A1_test = "A1_ADD1";
		A1_R0 = 16'h1234;
		A1_R1 = 16'h5678;
		A1_imm = 5'h15;
		A1_imm_sel = 1;
		A1_Rd_tag_in = 5'b01101;
		A1_op = ALU_ADD;
		A1_expected = 16'h1249;
		@(posedge clk);
		
		A1_done = 1;
	end
	
	// M Tests
	initial begin
		M_done = 0;
		
		M_test = "M_0";
		M_R0 = 16'h0004;
		M_R1 = 16'h0002;
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_Rd_tag_in = 5'b11110;
		M_expected = 16'h0008;
		@(posedge clk);
		
		M_test = "M_1";
		M_R0 = 16'h0FFF;
		M_R1 = 16'hF002;
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_Rd_tag_in = 5'b00001;
		M_expected = 16'hFFFF;
		@(posedge clk);
		
		M_test = "M_2";
		M_R0 = 16'h00EA;
		M_R1 = 16'h000B;
		M_imm = 5'h00;
		M_imm_sel = 0;
		M_Rd_tag_in = 5'b00101;
		M_expected = 16'h0A0E;
		@(posedge clk);
		
		M_test = "M_3";
		M_R0 = 16'h00EA;
		M_R1 = 16'h000B;
		M_imm = 5'h1F;
		M_imm_sel = 1;
		M_Rd_tag_in = 5'b00111;
		M_expected = 16'h1C56;
		@(posedge clk);
		
		M_done = 1;
	end
	
	// LS Tests
	initial begin
		LS_done = 0;
		
		LS_test = "L_0";
		LS_R0 = 16'hABCD;
		LS_R1 = 16'hEF01;
		LS_R2 = 16'h2008;
		LS_Rd_tag_in = 5'b10101;	
		write = 1;	
		LS_expected_data = LS_R2[7:0];
		LS_expected_addr = {LS_R1[8:0], LS_R0};
		LS_expected_R_nW = ~write;
		@(posedge clk);
		
		LS_test = "L_1";
		LS_R0 = 16'hAFFF;
		LS_R1 = 16'h0020;
		LS_R2 = 16'h1113;
		LS_Rd_tag_in = 5'b11111;	
		write = 1;	
		LS_expected_data = LS_R2[7:0];
		LS_expected_addr = {LS_R1[8:0], LS_R0};
		LS_expected_R_nW = ~write;
		@(posedge clk);
		
		LS_test = "R_0";
		LS_R0 = 16'hABCD;
		LS_R1 = 16'hEF01;
		LS_R2 = 16'h2008;
		LS_Rd_tag_in = 5'b10101;	
		write = 0;	
		LS_expected_data = LS_R2[7:0];
		LS_expected_addr = {LS_R1[8:0], LS_R0};
		LS_expected_R_nW = ~write;
		@(posedge clk);
		
		LS_test = "L_1";
		LS_R0 = 16'hAFFF;
		LS_R1 = 16'h0020;
		LS_R2 = 16'h1113;
		LS_Rd_tag_in = 5'b11111;	
		write = 0;	
		LS_expected_data = LS_R2[7:0];
		LS_expected_addr = {LS_R1[8:0], LS_R0};
		LS_expected_R_nW = ~write;
		@(posedge clk);
		
		LS_done = 1;
	end
	
	always@(posedge clk) begin
		if(A0_done)
			;// Done
		else if(A0_expected == A0_res && A0_Rd_tag_out == A0_Rd_tag_in)
			$display("%s Passed", A0_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				A0_test, A0_expected, A0_Rd_tag_in, A0_res, A0_Rd_tag_out);
			
		if(A1_done)
			;// Done
		else if(A1_expected == A1_res && A1_Rd_tag_out == A1_Rd_tag_in)
			$display("%s Passed", A1_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				A1_test, A1_expected, A1_Rd_tag_in, A1_res, A1_Rd_tag_out);

		if(M_done)
			;// Done
		else if(M_expected == M_res && M_Rd_tag_out == M_Rd_tag_in)
			$display("%s Passed", M_test);
		else
			$display("***%s Failed. Expected %h with %h tag, got %h with %h tag.***",
				M_test, M_expected, M_Rd_tag_in, M_res, M_Rd_tag_out);
			
		if(LS_done)
			;// Done
		else if(write) begin
			if(LS_expected_data == LS_data && LS_expected_addr == LS_addr && LS_Rd_tag_out == LS_Rd_tag_in && write != LS_R_nW)
				$display("%s Passed", A0_test);
			else
				$display("***%s Failed. Expected %h written to %h with %h tag, got %h written to %h with %h tag.***", 
					LS_test, LS_expected_data, LS_expected_addr, LS_Rd_tag_in, LS_data, LS_addr, LS_Rd_tag_out);
		end else begin
			if(LS_expected_addr == LS_addr && LS_Rd_tag_out == LS_Rd_tag_in && write != LS_R_nW)
				$display("%s Passed", A0_test);
			else
				$display("***%s Failed. Expected read from %h with %h tag, got read from %h with %h tag.***", 
					LS_test, LS_expected_addr, LS_Rd_tag_in, LS_addr, LS_Rd_tag_out);
		end
	end
			
	always@(posedge clk)
		if(A0_done & A1_done & M_done & LS_done)
			$stop;
	
	initial
		clk = 0;
	
	always
		#10 clk = ~clk;
	

endmodule