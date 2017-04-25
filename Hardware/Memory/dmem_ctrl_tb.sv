module dmem_ctrl_tb();

	reg rst_n;
	reg clk;

	reg granted;
	reg [24:0] sdram_addr;
	reg [15:0] row_length; // must be heald ocnstant throughout oporatiob****
	reg busy; //transaction in flight from SDRAM controller to Data Memory

	// sdram controller
	wire request;
	wire [24:0] start_addr;
	wire [24:0] length;

	//matrix memory
	wire [9:0] matrix_addr;
	wire matrix_wr_en;

	// data memory
	wire [15:0] dmc_addr;

	// cpu
	wire stall;

	wire d_sb; // choose the input for data memory (from data mem controller is 1, from SDRAM controller is 0)


	dmem_ctrl dmc(.rst_n(rst_n), .ref_clk(clk), .granted(granted), .sdram_addr(sdram_addr),
		.row_length(row_length), .busy(busy), .request(request), .start_addr(start_addr),
		.length(length), .matrix_addr(matrix_addr), .matrix_wr_en(matrix_wr_en), .dmc_addr(dmc_addr),
		.stall(stall), .d_sb(d_sb));

		
	always
		#10 clk = ~clk;
		
	always@(posedge clk)
		if(dmc.sdram_addr < dmc.curr_address)
			$display("Error. dmc_addr negative");
		
	initial begin
		clk = 0;
		rst_n = 0;
		
		///////////////////
		// MANUAL TESTS //
		/////////////////
		
		granted = 0;
		row_length = 16'd200;
		sdram_addr = 25'h0;	// start
		busy = 0;
		@(posedge clk);
		rst_n = 1;
		@(posedge clk);
		if(length != dmc.num_rows * row_length)
			$display("2: length calculated incorrectly");
		if(request != 0)
			$display("3: expected request = 0. Got request = %b", request);
		if(start_addr != 0)
			$display("4: expected start_address = 0. Got start_address = %h", start_addr);
		// Don't care about matrix_addr
		if(matrix_wr_en != 0)
			$display("5: expected matrix_wr_en = 0. Got start_address = %b", matrix_wr_en);
		if(stall != 0)
			$display("6: expected stall = 0. Got stall = %b", stall);
		if(d_sb != busy)
			$display("7: Busy signal incorrect");
		@(posedge clk);
		
		//////////////////////////////////////////////////////////
		
		sdram_addr = 25'h400;	// mid
		repeat(5) begin
		@(posedge clk);
		if(request != 1)
			$display("8: expected request = 1. Got request = %b", request);
		if(stall != 1)
			$display("9: expected stall = 1. Got stall = %b", stall);
		end
		granted = 1;
		@(posedge clk)
		if(stall != 0)
			$display("10: expected stall = 0. Got stall = %b", stall);
		if(start_addr != 25'h400 - 16'd200)
			$display("11: expected start_addr = %h. Got request = %h", 25'h400 - 16'd200, start_addr);
		if(matrix_wr_en != 0)
			$display("13: expected matrix_wr_en = 0. Got start_address = %b", matrix_wr_en);
			
			
		//////////////////////////////////////////////////////////
		
		sdram_addr = 25'h900;	// matrix mem
		@(posedge clk)
		if(matrix_wr_en != 1'b1)
			$display("14: Expected matrix_wr_en to be 1");
		if(matrix_addr != 12'h100)
			$display("15: Expected matrix_wr_en to be 0x800 less than input address");
		@(posedge clk)
		
		$stop;
		
	end
	

endmodule