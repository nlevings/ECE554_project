/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Decode
	
	Summary:
*/

module ID(A0,A1,M,LS,clk,
						a0_wr,a1_wr,m_wr,ls_wr,a0_tag,a1_tag,m_tag,ls_tag,
						teA0_Rd,teA1_Rd,teM_Rd,tmemA0_Rd,tmemA1_Rd,tmemLS_Rd,tmemM_Rd,
						eA0_Rd,eA1_Rd,eM_Rd,memA0_Rd,memA1_Rd,memLS_Rd,memM_Rd,
						predRW,
						a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,
						a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,
						a0cnd,a1cnd,lscnd,mcnd,
						CntrlSig,
						a0_en,a1_en,m_en,ls_en,
						a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag
						);


	input [21:0] A0,A1,M,LS;
	input clk;
	input [15:0] a0_wr,a1_wr,m_wr,ls_wr;
	input [4:0] a0_tag,a1_tag,m_tag,ls_tag;
	input a0_en,a1_en,m_en,ls_en;
	output a0cnd,a1cnd,lscnd,mcnd;
	output [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1;
	output [4:0] a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag;
	output predRW;
	output [12:0] CntrlSig; //{4'A0op,4'dA1op,1'LSop,4'_en}
	output [4:0] a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag;
	
	//inputs from execute and memory for forewarding
	input [4:0] teA0_Rd,teA1_Rd,teM_Rd,tmemA0_Rd,tmemA1_Rd,tmemLS_Rd,tmemM_Rd;
	input [15:0] eA0_Rd,eA1_Rd,eM_Rd,memA0_Rd,memA1_Rd,memLS_Rd,memM_Rd;
	
	wire [15:0] rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1;
	wire o_r30,o_r31,cond,oF_r30,oF_r31;
	wire chsa0,chsa1,chsls,chsm;
	
	assign a0_R0_tag = A0[9:5];
	assign a0_R1_tag = A0[14:10];
	assign a1_R0_tag = A1[9:5];
	assign a1_R1_tag = A1[14:10];
	assign m_R0_tag = M[9:5];
	assign m_R1_tag = M[14:10];
	assign ls_R0_tag = LS[9:5];
	assign ls_R1_tag = LS[14:10];
	
	assign a0_Rd_tag = A0[19:15];
	assign a1_Rd_tag = A1[19:15];
	assign m_Rd_tag = M[19:15];
	assign ls_Rd_tag = LS[19:15];
	
	
	regfile regfile0(.a0R0(A0[9:5]),.a0R1(A0[14:10]),.a1R0(A1[9:5]),.a1R1(A1[14:10]),.mR0(M[9:5]),.mR1(M[14:10]),.lsR0(LS[9:5]),.lsR1(LS[9:5]),.clk(clk), //inputs
						.rA0_R0(rA0_R0),.rA0_R1(rA0_R1),.rA1_R0(rA1_R0),.rA1_R1(rA1_R1),.rM_R0(rM_R0),.rM_R1(rM_R1),.rLS_R0(rLS_R0),.rLS_R1(rLS_R1),		//outputs
						.o_r30(o_r30),.o_r31(o_r31),	//outputs
						.a0_wr(a0_wr),.a1_wr(a1_wr),.m_wr(m_wr),.ls_wr(ls_wr),	//inputs
						.a0_tag(a0_tag),.a1_tag(a1_tag),.m_tag(m_tag),.ls_tag(ls_tag), //inputs
						.a0_en(a0_en),.a1_en(a1_en),.m_en(m_en),.ls_en(ls_en));	//inputs (from control block passed through to WB)
						
	forwardUnit forwardUnit0(.a0_R0(a0_R0),.a0_R1(a0_R1),.a1_R0(a1_R0),.a1_R1(a1_R1),.m_R0(m_R0),.m_R1(m_R1),.ls_R0(ls_R0),.ls_R1(ls_R1), .oF_r30(oF_r30),.oF_r31(oF_r31),					//outputs
								.rA0_R0(rA0_R0),.rA0_R1(rA0_R1),.rA1_R0(rA1_R0),.rA1_R1(rA1_R1),.rM_R0(rM_R0),.rM_R1(rM_R1),.rLS_R0(rLS_R0),.rLS_R1(rLS_R1), .o_r30(o_r30),.o_r31(o_r31),	//input values from this stage
								.tA0_R0(A0[9:5]),.tA0_R1(A0[14:10]),.tA1_R0(A1[9:5]),.tA1_R1(A1[14:10]),.tM_R0(M[9:5]),.tM_R1(M[14:10]),.tLS_R0(LS[9:5]),.tLS_R1(LS[9:5]),	//input tags from this stage
								.teA0_Rd(teA0_Rd),.teA1_Rd(teA1_Rd),.teM_Rd(teM_Rd),	//input tags from execute
								.eA0_Rd(eA0_Rd),.eA1_Rd(eA1_Rd),.eM_Rd(eM_Rd),	//input values from execute
								.tmemA0_Rd(tmemA0_Rd),.tmemA1_Rd(tmemA1_Rd),.tmemM_Rd(tmemM_Rd),.tmemLS_Rd(tmemLS_Rd),	//input tags from memory
								.memA0_Rd(memA0_Rd),.memA1_Rd(memA1_Rd),.memM_Rd(memM_Rd),.memLS_Rd(memLS_Rd));	//input values from memory
								
	//controlBlock controlBlock0(.A0(A0[4:0]),.A1(A1[4:0]),.LS(LS[4:0]),.M(M[4:0]),.CntrlSig(CntrlSig));
								
	//conditional assignment
	or CND(cond,oF_r30,oF_r31);
	
	or CHSA0(chsa0,A0[21],A0[20]);
	or CHSA1(chsa1,A1[21],A1[20]);
	or CHSM(chsm,M[21],M[20]);
	or CHSLS(chsls,LS[21],LS[20]);
	
	and A0CND(a0cnd,chsa0,cond);
	and A1CND(a1cnd,chsa1,cond);
	and MCND(mcnd,chsm,cond);
	and LSCND(lscnd,chsls,cond);
	
	//determine if jump instruction/ if jump prediction was right or wrong
	assign eq_jmpOP = (A0[4:0] == 5'b01001) ? 1'b1: 1'b0;
	and JMPCHS(predRW,a0cnd,eq_jmpOP);

	
endmodule