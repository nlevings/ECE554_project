module ALU(A, B, op, result);

input [15:0] A;				// R0
input [15:0] B;				// R1 or immediate (which would be B[4:0])
input [3:0] op;				// opcode
output reg [15:0] result;	// Result[15:0] = value to store in dst,

reg overflow;		 


always@(*) begin
	case (op)
	
	// ADD (A+B): Adds A and B together. Saturates.
	4'b0000: begin
	
		{overflow, result} = A + B;
		if(overflow)
			result = 16'hFFFF;

	end

	// SUB (A-B): Subracts B from A. Saturates.
	4'b0001: begin
	
		{overflow, result} = A - B;
		if(overflow)
			result = 16'h0;
	
	end
	

	// AND (A&B): Bitwise AND of A and B.
	4'b0010: begin
	
		result = A & B;
		
	end
	
	// OR (A|B): Bitwise OR of A and B.
	4'b0011: begin
	
		result = A | B;
	
	end
	
	// XOR (A^B): Bitwise XOR of A and B.
	4'b0100: begin
	
		result = A ^ B;
		
	end
	
	// NOT (~A): Inverts A
	4'b0101: begin
		
		result = ~A;
		
	end
	
	// CLR: outputs 0
	4'b0110: begin
	
		result = 16'h0000;
	
	end
	
	// CMPE
	4'b0111: begin
	
		result = A == B;
	
	end
	
	// CMPG
	4'b1000: begin
	
		result = A > B;
	
	end
	
	// CMPL
	4'b1001: begin
	
		result = A < B;
	
	end
	
	// SHRA: Shift right arithmatic
	4'b1010: begin
	
		result = $signed(A) >>> B;
	
	end
	
	// SHRL: Shift right logical
	4'b1011: begin
		
		result = A >> B;
	
	end
	
	// SHL: Shift left
	4'b1100: begin
	
		result = A << B;
	
	end
	
	// NOP
	default: begin
	
		result = 16'hXXXX;
	
	end

	endcase
	
end



endmodule