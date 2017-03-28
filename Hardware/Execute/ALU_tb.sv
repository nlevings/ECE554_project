module ALU_tb();

	reg clk;
	reg [15:0] A, B, re;
	reg [3:0] op;
	wire [15:0] result;
	string test;

	ALU A0 (A, B, op, result);

	initial begin
		clk = 0;
		
		// Basic ADD
		test = "ADD_0";
		A = 16'h1234;
		B = 16'h4321;
		re = 16'h5555;
		op = 4'b0000;
		@(posedge clk);
		
		// addition is unsigned
		test = "ADD_1";
		A = 16'h0001;
		B = 16'hFFF0;
		re = 16'hFFF1;
		op = 4'b0000;
		@(posedge clk);
		
		// Overflow Saturation
		test = "ADD_2";
		A = 16'hFFFE;
		B = 16'h000F;
		re = 16'hFFFF;
		op = 4'b0000;
		@(posedge clk);
			
		// A and B are unsigned
		test = "SUB_0";
		A = 16'h8BCD;
		B = 16'h8001;
		re = 16'h0BCC;
		op = 4'b0001;
		@(posedge clk);
		
		// underflow saturation
		test = "SUB_1";
		A = 16'h000D;
		B = 16'h000F;
		re = 16'h0000;
		op = 4'b0001;
		@(posedge clk);
		
		test = "AND_0";
		A = 16'h6F3A;
		B = 16'h299F;
		re = 16'h291A;
		op = 4'b0010;
		@(posedge clk);

		test = "OR_0";
		A = 16'h6F3A;
		B = 16'h299F;
		re = 16'h6FBF;
		op = 4'b0011;
		@(posedge clk);
				
		test = "XOR_0";
		A = 16'h6F3A;
		B = 16'h299F;
		re = 16'h46A5;
		op = 4'b0100;
		@(posedge clk);
		
		test = "NOT_0";
		A = 16'h6F3A;
		re = 16'h90C5;
		op = 4'b0101;
		@(posedge clk);
		
		test = "CLR_0";
		re = 16'h0000;
		op = 4'b0110;
		@(posedge clk);
		
		test = "CMPE_0";
		A = 16'h6F3A;
		B = 16'h299F;
		re = 16'h0000;
		op = 4'b0111;
		@(posedge clk);
		
		test = "CMPE_1";
		A = 16'h6F3A;
		B = 16'h6F3A;
		re = 16'h0001;
		op = 4'b0111;
		@(posedge clk);
		
		test = "CMPG_0";
		A = 16'h6F3A;
		B = 16'h6F3A;
		re = 16'h0000;
		op = 4'b1000;
		@(posedge clk);
		
		test = "CMPG_1";
		A = 16'h6F3A;
		B = 16'h000A;
		re = 16'h0001;
		op = 4'b1000;
		@(posedge clk);

		test = "CMPG_2";
		A = 16'h0432;
		B = 16'h7331;
		re = 16'h0000;
		op = 4'b1000;
		@(posedge clk);
		
		// Unsigned
		test = "CMPG_3";
		A = 16'h0FF0;
		B = 16'hFF00;
		re = 16'h0000;
		op = 4'b1000;
		@(posedge clk);
	
		test = "CMPL_0";
		A = 16'h0FF0;
		B = 16'h0FF0;
		re = 16'h0000;
		op = 4'b1001;
		@(posedge clk);
		
		test = "CMPL_1";
		A = 16'h0FF0;
		B = 16'h0F00;
		re = 16'h0000;
		op = 4'b1001;
		@(posedge clk);
	
		test = "CMPL_2";
		A = 16'h0F00;
		B = 16'h0FF0;
		re = 16'h0001;
		op = 4'b1001;
		@(posedge clk);
		
		// Unsigned
		test = "CMPL_3";
		A = 16'h0FF0;
		B = 16'hFF00;
		re = 16'h0001;
		op = 4'b1001;
		@(posedge clk);
		
		test = "SHRA_0";
		A = 16'hA0A0;
		B = 16'h0002;
		re = 16'hE828;
		op = 4'b1010;
		@(posedge clk);
		
		test = "SHRL_0";
		A = 16'hA0A0;
		B = 16'h0002;
		re = 16'h2828;
		op = 4'b1011;
		@(posedge clk);
		
		test = "SHL_0";
		A = 16'hA0A0;
		B = 16'h0002;
		re = 16'h8280;
		op = 4'b1100;
		@(posedge clk); 
		
		
		$stop;
	end
	
	always@(posedge clk)
		if(re == result)
			$display("%s Passed", test);
		else
			$display("***%s Failed. Expected %h, got %h.***", test, re, result);
	
	always
		#10 clk = ~clk;
	
endmodule