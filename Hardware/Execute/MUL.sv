module MUL(A, B, result);

	input [15:0] A;
	input [15:0] B;
	output reg [15:0] result;
	reg [15:0] overflow;
	always@(*) begin
		{overflow, result} = A*B;
		if(overflow > 0)
			result = 16'hFFFF;	// saturates
	end
	
endmodule