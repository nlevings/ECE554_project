/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Decode/Execute
	
	Summary:
*/


module ID_EX_reg(clk,rst_n,
				a0cnd,a1cnd,lscnd,mcnd,
				a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2,
				a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,ls_R2_tag,
				predRW,CntrlSig,
				a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag,
				a0_Imm,a1_Imm,m_Imm,
				stall,
				cntrl_sig,
				a0R0,a0R1,a1R0,a1R1,mR0,mR1,lsR0,lsR1,lsR2,
				a0Rd_tag,a1Rd_tag,mRd_tag,lsRd_tag,
				a0Imm,a1Imm,mImm);

	input clk, rst_n;
	
	input a0cnd,a1cnd,lscnd,mcnd;
	input predRW;
	input stall;
	
	input [13:0] CntrlSig;  //{A0_imm_sel[13],A0_op[12:9], A1_imm_sel[8], A1_op[7:4],M_imm_sel[3],M[2],L[1],S[0]}
	
	input [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2;
	input [4:0] a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,ls_R2_tag;
	input [4:0] a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag;
	input [4:0] a0_Imm,a1_Imm,m_Imm;
	
	output reg [13:0] cntrl_sig;
	output reg [15:0] a0R0,a0R1,a1R0,a1R1,mR0,mR1,lsR0,lsR1,lsR2;
	//output reg [4:0] a0R0_tag,a0R1_tag,a1R0_tag,a1R1_tag,mR0_tag,mR1_tag,lsR0_tag,lsR1_tag,lsR2_tag;
	output reg [4:0] a0Rd_tag,a1Rd_tag,mRd_tag,lsRd_tag;
	output reg [4:0] a0Imm,a1Imm,mImm;

	reg predRWprev;

	always@(posedge clk, negedge rst_n)begin
		if(!rst_n)begin
			// if all the destination tags are set to 0 then (except for LS since it has a store instr that does not use Rd)
			//	no value will get stored back into the register file (its like these instructions didn't exist)
			a0Rd_tag <= 5'd0;
			a1Rd_tag <= 5'd0;
			mRd_tag <= 5'd0;
			lsRd_tag <= 5'd0;
			cntrl_sig <= 14'd0;
		end
		else begin
			predRWprev <= predRW;
			//keep all values in the reg if stall is high 
			if(stall)begin
				cntrl_sig <= cntrl_sig;
				a0R0 <= a0R0; a0R1 <= a0R1; a1R0 <= a1R0; a1R1 <= a1R1; mR0 <= mR0; mR1 <= mR1; lsR0 <= lsR0; lsR1 <= lsR1; lsR2 <= lsR2;
				//a0R0_tag <= a0R0_tag; a0R1_tag <= a0R1_tag; a1R0_tag <= a1R0_tag; a1R1_tag <= a1R1_tag; mR0_tag <= mR0_tag; mR1_tag <= mR1_tag; lsR0_tag <= lsR0_tag; lsR1_tag <= lsR1_tag; lsR2_tag <= lsR2_tag;
				a0Rd_tag <= a0Rd_tag; a1Rd_tag <= a1Rd_tag; mRd_tag <= mRd_tag; lsRd_tag <= lsRd_tag;
				a0Imm <= a0Imm; a1Imm <= a1Imm; mImm <= mImm;
			end
			//Right/continue (0), Wrong/Flush (1)
			else if(predRWprev) begin
				//same as rst_n if wrong
				a0Rd_tag <= 5'd0;
				a1Rd_tag <= 5'd0;
				mRd_tag <= 5'd0;
				lsRd_tag <= 5'd0;
				cntrl_sig <= 14'd0;
			end
			else begin
				//for cnd if set to 1 need to NOT execute (set Rd tag to 5'd0)
				a0R0 <= a0_R0; a0R1 <= a0_R1; a1R0 <= a1_R0; a1R1 <= a1_R1; mR0 <= m_R0; mR1 <= m_R1; lsR0 <= ls_R0; lsR1 <= ls_R1; lsR2 <= ls_R2;
				//a0R0_tag <= a0_R0_tag; a0R1_tag <= a0_R1_tag; a1R0_tag <= a1_R0_tag; a1R1_tag <= a1_R1_tag; mR0_tag <= m_R0_tag; mR1_tag <= m_R1_tag; lsR0_tag <= ls_R0_tag; lsR1_tag <= ls_R1_tag; lsR2_tag <= ls_R2_tag;
				a0Imm <= a0_Imm; a1Imm <= a1_Imm; mImm <= m_Imm;
				cntrl_sig[13:2] <= CntrlSig[13:2];
				
				if(a0cnd)begin
					a0Rd_tag <= 5'd0;


				end 
				//check for JMPI and NOP
				else if((CntrlSig[12:9] == 4'b1111)||(CntrlSig[12:9] == 4'b1101))begin
					a0Rd_tag <= 5'd0;
				end
				else begin
					a0Rd_tag <= a0_Rd_tag;
				end
				
				if(a1cnd)begin
					a1Rd_tag <= 5'd0;

				end
				//check for NOP
				else if(CntrlSig[7:4] == 4'b1111)begin
					a1Rd_tag <= 5'd0;
				end
				else begin
					a1Rd_tag <= a1_Rd_tag;
				end
				
				
				if(mcnd)begin
					mRd_tag <= 5'd0;

				end
				else if(CntrlSig[2] == 1'b0 )begin
					mRd_tag <= 5'd0;

				end
				else begin
					mRd_tag <= m_Rd_tag;
				end
				
				
				if(lscnd)begin
					lsRd_tag <= 5'd0;
					cntrl_sig[1:0] <= 2'b00;
				end
				else if(CntrlSig[1:0] == 2'b00)begin
					lsRd_tag <= 5'd0;
					cntrl_sig[1:0] <= 2'b00;
				end
				//need to check for store since it doesn't use the Rd_tag
				else if(CntrlSig[0] == 1'b1)begin
					lsRd_tag <= 5'd0;
					cntrl_sig[1:0] <= CntrlSig[1:0];
				end
				//must be a load
				else begin
					lsRd_tag <= ls_Rd_tag;
					cntrl_sig[1:0] <= CntrlSig[1:0];
				end
				
				
			end
			
		end
	end

endmodule