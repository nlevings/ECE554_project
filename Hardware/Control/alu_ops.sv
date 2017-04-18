module alu_ops(op_in, op_out, imm_sel, err);
	input [4:0] op_in;
	output reg [3:0] op_out;
	output reg imm_sel;
	output reg err;
	
	
	always_comb begin
		case(op_in)
		5'b00000: begin
			// ADD
			op_out = 4'b0000;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b00001: begin
			// ADDI
			op_out = 4'b0000;
			imm_sel = 1'b1;
			err = 1'b0;
		end
		5'b00011: begin
			// SUB
			op_out = 4'b0001;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b00100: begin
			// SUBI
			op_out = 4'b0001;
			imm_sel = 1'b1;
			err = 1'b0;
		end
		5'b00101: begin
			// AND
			op_out = 4'b0010;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b00110: begin
			// OR
			op_out = 4'b0011;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b00111: begin
			// XOR
			op_out = 4'b0100;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b01000: begin
			// NOT
			op_out = 4'b0101;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b01001: begin
			// JMPI
			op_out = 4'b1101;	
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b01011: begin
			// CLR
			op_out = 4'b0110;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b01100: begin
			// NOP
			op_out = 4'b1111;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b10010: begin
			// CMPE
			op_out = 4'b0111;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b10011: begin
			// CMPG
			op_out = 4'b1000;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b10100: begin
			// CMPL
			op_out = 4'b1001;
			imm_sel = 1'b0;
			err = 1'b0;
		end		
		5'b10101: begin
			// SHRA
			op_out = 4'b1010;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b10110: begin
			// SHRL
			op_out = 4'b1011;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		5'b10111: begin
			// SHL
			op_out = 4'b1100;
			imm_sel = 1'b0;
			err = 1'b0;
		end
		default: begin
			// NON-ALU OP 
			op_out = 4'b1111;
			imm_sel = 1'b0;
			err = 1'b1;
		end
		
		endcase
	end

endmodule