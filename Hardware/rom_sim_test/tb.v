`timescale 1 ns / 1 ns 

module tb();

reg clk;
reg [9:0] address;
wire [21:0] q;

initial begin
clk = 0;
address = 10'b0;
repeat (5) @(posedge clk);
address = 1'b1; 
end

always #5 clk = !clk;

image_rom image_rom (
	.address(address),
	.clock(clk),
	.q(q));
	
endmodule