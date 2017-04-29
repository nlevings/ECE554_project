/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Mem/Writeback
	
	Summary:
*/

module Mem_WB_reg(clk,rst_n,stall,
							memA0_Rd,memA1_Rd,memM_Rd,memLS_Rd,tmemA0_Rd,tmemA1_Rd,tmemM_Rd,tmemLS_Rd,
							//outputs
							a0_wr,a1_wr,m_wr,ls_wr,a0_tag,a1_tag,m_tag,ls_tag
							);
							
	input [15:0] memA0_Rd,memA1_Rd,memM_Rd;
	input [7:0] memLS_Rd;
	input [4:0] tmemA0_Rd,tmemA1_Rd,tmemM_Rd,tmemLS_Rd;
	input clk,rst_n,stall;
	
	output reg [15:0] a0_wr,a1_wr,m_wr;
	output reg [7:0] ls_wr;
	output reg [4:0] a0_tag,a1_tag,m_tag,ls_tag;

	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			a0_wr <= 16'd0; a1_wr <= 16'd0; m_wr <= 16'd0; ls_wr <= 8'd0;
			a0_tag <= 5'd0; a1_tag <= 5'd0; m_tag <= 5'd0; ls_tag <= 5'd0;
		end
		else begin
			//TODO need to add stall signal
			if(stall)begin
				a0_wr <= a0_wr; a1_wr <= a1_wr; m_wr <= m_wr; ls_wr <= ls_wr;
				a0_tag <= a0_tag; a1_tag <= a1_tag; m_tag <= m_tag; ls_tag <= ls_tag;
			end
			else begin
				a0_wr <= memA0_Rd; a1_wr <= memA1_Rd; m_wr <= memM_Rd; ls_wr <= memLS_Rd;
				a0_tag <= tmemA0_Rd; a1_tag <= tmemA1_Rd; m_tag <= tmemM_Rd; ls_tag <= tmemLS_Rd;
			end

		end
	end

endmodule