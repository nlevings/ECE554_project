/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Fetch
	
	Summary:
*/

module InstructionFetch(predRW,PCnext,clk,rst_n,
						A0,A1,LS,M,PCplus);
	
	input predRW,clk,rst_n;
	input [9:0] PCnext;
	output reg [9:0] PCplus;
	output reg [21:0] A0,A1,LS,M;
	
	reg [9:0] PC, PCnew;
	reg tbontb;	//jump is a micro-inst in this current bundle (to be or not to be)
	reg [9:0] PCjump;
	
	//ROM reads out on negedge of clock	
	rom romA0(.address(PC), .clock(~clk), .q(A0));
	rom romA1(.address(PC), .clock(~clk), .q(A1));
	rom romM(.address(PC), .clock(~clk), .q(M));
	rom romLS(.address(PC), .clock(~clk), .q(LS));
	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			PC <= 10'd0;
		end
		else begin
			PC <= PCnew;
		end
	end
	
	always@(predRW,tbontb)begin
		case({predRW,tbontb})
			2'b00:begin
				PCnew = PCplus;
			end
			2'b01:begin
				PCnew = PCjump;
			end
			2'b10:begin
				PCnew = PCnext;
			end
			2'b11:begin
				PCnew = PCnext;
			end
			default:begin
				PCnew = 10'd0;
			end
		endcase
	end
	
	//Jump predictor
	always@(A0)begin
		//check for jump opcode
		if(A0[4:0] == 5'b01001)begin
			PCjump = A0[19:5] + PC;
			tbontb = 1'b1;
		end
		else begin
			tbontb = 1'b0;
		end
	end
	
	//Increment PC
	always@(PC)begin
		PCplus = PC + 1'd1;
	end
endmodule