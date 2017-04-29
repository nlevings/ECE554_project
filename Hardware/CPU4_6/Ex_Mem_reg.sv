/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Execute/Memory
	
	Summary:
*/


module Ex_Mem_reg(clk,rst_n,
							a0resE,a1resE,mresE,a0tagE,a1tagE,mtagE,
							lsData,lstagE,lsaddr,
							LS_R_nW,
							//outputs
							memA0_Rd,memA1_Rd,memM_Rd,tmemA0_Rd,tmemA1_Rd,tmemM_Rd,
							memLS_Rd,tmemLS_Rd,sdram_addr,
							r_nW,
							stall
							);

	
	input [15:0] a0resE,a1resE,mresE;
	input [4:0] a0tagE,a1tagE,mtagE,lstagE;
	input [7:0] lsData;
	input [24:0] lsaddr;
	input clk, rst_n, LS_R_nW, stall;
	
	output reg [15:0] memA0_Rd,memA1_Rd,memM_Rd;
	output reg [7:0] memLS_Rd;
	output reg [4:0] tmemA0_Rd,tmemA1_Rd,tmemM_Rd,tmemLS_Rd;
	output reg [24:0] sdram_addr;
	output reg r_nW;
	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			memA0_Rd <= 16'd0; memA1_Rd <= 16'd0; memM_Rd <= 16'd0; memLS_Rd <= 8'd0;
			tmemA0_Rd <= 5'd0; tmemA1_Rd <= 5'd0; tmemM_Rd <= 5'd0; tmemLS_Rd <= 5'd0;
			sdram_addr <= 25'd0; r_nW <= 1'd0;
			
		end
		else begin
			if(stall)begin
				memA0_Rd <= memA0_Rd; memA1_Rd <= memA1_Rd; memM_Rd <= memM_Rd; memLS_Rd <= memLS_Rd;
				tmemA0_Rd <= tmemA0_Rd; tmemA1_Rd <= tmemA1_Rd; tmemM_Rd <= tmemM_Rd; tmemLS_Rd <= tmemLS_Rd;
				sdram_addr <= sdram_addr; r_nW <= r_nW;
			end
			else begin
				memA0_Rd <= a0resE; memA1_Rd <= a1resE; memM_Rd <= mresE; memLS_Rd <= lsData;
				tmemA0_Rd <= a0tagE; tmemA1_Rd <= a1tagE; tmemM_Rd <= mtagE; tmemLS_Rd <= lstagE;
				sdram_addr <= lsaddr; r_nW <= LS_R_nW;
			end
		end
	end

endmodule