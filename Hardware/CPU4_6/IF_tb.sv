module IF_tb();

	reg predRW,clk,rst_n;
	reg [9:0] PCnext;
	
	wire [21:0] A0,A1,LS,M;


	InstructionFetch iDUT(.predRW(predRW),.PCnext(PCnext),.clk(clk),.rst_n(rst_n),
						.A0(A0),.A1(A1),.LS(LS),.M(M),.PCPlus(PCPlus));
						
	initial begin
		clk = 0; rst_n = 0;
		predRW = 0; 
		PCnext = 0;
		@(negedge clk);
		rst_n = 1;
		@(posedge clk);
		//Test0: test PC increment performs correct
		predRW = 0; PCnext = 10'd24;
		@(posedge clk);
		if(iDUT.PC != 1)begin
			$display("Failed to increment the PC got: %d but should have been 1",iDUT.PC);
			$stop;
		end
		//Test1: test prediction wrong
		predRW = 1; PCnext = 10'd24;
		@(posedge clk);
		if(iDUT.PC != 24)begin
			$display("Failed to correct jump misprediction, PC got: %d but should have been 24",iDUT.PC);
			$stop;
		end
	end

	always #5 clk = ~clk;
	
endmodule