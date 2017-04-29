/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Fetch/Instruction Decode
	
	Summary:
*/


module IF_ID_reg(dA0,dA1,dLS,dM,fA0,fA1,fLS,fM,PCnext,PCplus,clk,rst_n,stall);

	input [21:0] fA0,fA1,fLS,fM;
	input [9:0] PCplus;
	input clk, rst_n, stall;
	output reg [21:0] dA0,dA1,dLS,dM;
	output reg [9:0] PCnext;
	
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			dA0 <= 22'b00_00000_00000_00000_01100;	//NOPs
			dA1 <= 22'b00_00000_00000_00000_01100;
			dLS <= 22'b00_00000_00000_00000_01100;
			dM <= 22'b00_00000_00000_00000_01100;
			PCnext <= 10'd0;
		end
		else begin
			//TODO need to add stall signal
			if(stall)begin
				dA0 <= dA0;
				dA1 <= dA1;
				dLS <= dLS;
				dM <= dM;
				PCnext <= PCnext;
			end
			else begin
				dA0 <= fA0;
				dA1 <= fA1;
				dLS <= fLS;
				dM <= fM;
				PCnext <= PCplus;
			end

		end
	end

endmodule