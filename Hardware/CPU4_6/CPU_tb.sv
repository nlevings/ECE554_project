`timescale 1 ns / 1 ps
module CPU_tb();

	reg clk, rst_n;

	CPU iDUT(clk,rst_n);
	
	initial #5000 $stop;
	
	initial begin
		clk = 0;
		rst_n = 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(negedge clk);
		rst_n = 1; 
	end
	
	
	always #10 clk = ~clk;

endmodule