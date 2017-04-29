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
						a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2,
						a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,ls_R2_tag,
						a0cnd,a1cnd,lscnd,mcnd,
						CntrlSig,
						a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag,
						a0_Imm,a1_Imm,m_Imm
						);


	input [21:0] A0,A1,M,LS;
	input clk;
	input [15:0] a0_wr,a1_wr,m_wr,ls_wr;
	input [4:0] a0_tag,a1_tag,m_tag,ls_tag;
	output a0cnd,a1cnd,lscnd,mcnd;
	output [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2;
	output [4:0] a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,ls_R2_tag;
	output predRW;
	output [13:0] CntrlSig;  //{A0_imm_sel[13],A0_op[12:9], A1_imm_sel[8], A1_op[7:4],M_imm_sel[3],M[2],L[1],S[0]}
	output [4:0] a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag;
	output [4:0] a0_Imm,a1_Imm,m_Imm;
	
	//inputs from execute and memory for forewarding
	input [4:0] teA0_Rd,teA1_Rd,teM_Rd,tmemA0_Rd,tmemA1_Rd,tmemLS_Rd,tmemM_Rd;
	input [15:0] eA0_Rd,eA1_Rd,eM_Rd,memA0_Rd,memA1_Rd,memLS_Rd,memM_Rd;
	
	wire [15:0] rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1,rLS_R2;
	wire o_r30,o_r31,oF_r30,oF_r31;
	wire chsa00,chsa01,chsa10,chsa11,chsls0,chsls1,chsm0,chsm1;
	wire err;
	wire eq_jmpOP;
	assign a0_R0_tag = A0[9:5];
	assign a0_R1_tag = A0[14:10];
	assign a1_R0_tag = A1[9:5];
	assign a1_R1_tag = A1[14:10];
	assign m_R0_tag = M[9:5];
	assign m_R1_tag = M[14:10];
	assign ls_R0_tag = LS[9:5];
	assign ls_R1_tag = LS[14:10];
	assign ls_R2_tag = LS[19:15];
	
	assign a0_Rd_tag = A0[19:15];
	assign a1_Rd_tag = A1[19:15];
	assign m_Rd_tag = M[19:15];
	assign ls_Rd_tag = LS[19:15];
	
	assign a0_Imm = A0[14:10];
	assign a1_Imm = A1[14:10];
	assign m_Imm = M[14:10];
	
	regfile regfile0(.a0R0(A0[9:5]),.a0R1(A0[14:10]),.a1R0(A1[9:5]),.a1R1(A1[14:10]),.mR0(M[9:5]),.mR1(M[14:10]),.lsR0(LS[9:5]),.lsR1(LS[14:10]),.lsR2(LS[19:15]),.clk(clk), //inputs
						.rA0_R0(rA0_R0),.rA0_R1(rA0_R1),.rA1_R0(rA1_R0),.rA1_R1(rA1_R1),.rM_R0(rM_R0),.rM_R1(rM_R1),.rLS_R0(rLS_R0),.rLS_R1(rLS_R1),.rLS_R2(rLS_R2),		//outputs
						.o_r30(o_r30),.o_r31(o_r31),	//outputs
						.a0_wr(a0_wr),.a1_wr(a1_wr),.m_wr(m_wr),.ls_wr(ls_wr),	//inputs
						.a0_tag(a0_tag),.a1_tag(a1_tag),.m_tag(m_tag),.ls_tag(ls_tag) //inputs
						);	//inputs (from control block passed through to WB)
						
	forwardUnit forwardUnit0(.a0_R0(a0_R0),.a0_R1(a0_R1),.a1_R0(a1_R0),.a1_R1(a1_R1),.m_R0(m_R0),.m_R1(m_R1),.ls_R0(ls_R0),.ls_R1(ls_R1),.ls_R2(ls_R2),.oF_r30(oF_r30),.oF_r31(oF_r31),					//outputs
								.rA0_R0(rA0_R0),.rA0_R1(rA0_R1),.rA1_R0(rA1_R0),.rA1_R1(rA1_R1),.rM_R0(rM_R0),.rM_R1(rM_R1),.rLS_R0(rLS_R0),.rLS_R1(rLS_R1),.rLS_R2(rLS_R2), .o_r30(o_r30),.o_r31(o_r31),	//input values from this stage
								.tA0_R0(A0[9:5]),.tA0_R1(A0[14:10]),.tA1_R0(A1[9:5]),.tA1_R1(A1[14:10]),.tM_R0(M[9:5]),.tM_R1(M[14:10]),.tLS_R0(LS[9:5]),.tLS_R1(LS[14:10]),.tLS_R2(LS[19:15]),	//input tags from this stage
								.teA0_Rd(teA0_Rd),.teA1_Rd(teA1_Rd),.teM_Rd(teM_Rd),	//input tags from execute
								.eA0_Rd(eA0_Rd),.eA1_Rd(eA1_Rd),.eM_Rd(eM_Rd),	//input values from execute
								.tmemA0_Rd(tmemA0_Rd),.tmemA1_Rd(tmemA1_Rd),.tmemM_Rd(tmemM_Rd),.tmemLS_Rd(tmemLS_Rd),	//input tags from memory
								.memA0_Rd(memA0_Rd),.memA1_Rd(memA1_Rd),.memM_Rd(memM_Rd),.memLS_Rd(memLS_Rd),			//input values from memory
								.twbA0_Rd(a0_tag),.twbA1_Rd(a1_tag),.twbM_Rd(m_tag),.twbLS_Rd(ls_tag),			//input tags from wb
								.wbA0_Rd(a0_wr),.wbA1_Rd(a1_wr),.wbM_Rd(m_wr),.wbLS_Rd(ls_wr));					//input values from wb
								
	control_block control_block0(.A0(A0[4:0]),.A1(A1[4:0]),.LS(LS[4:0]),.M(M[4:0]),.control(CntrlSig), .err(err));

								
	//conditional assignment
	and CHSA00(chsa00,A0[20],oF_r30);
	and CHSA01(chsa01,A0[21],oF_r31);
	or A0CND(a0cnd,chsa00,chsa01);
	and CHSA10(chsa10,A1[20],oF_r30);
	and CHSA11(chsa11,A1[21],oF_r31);
	or A1CND(a1cnd,chsa10,chsa11);
	and CHSM0(chsm0,M[20],oF_r30);
	and CHSM1(chsm1,M[21],oF_r31);
	or MCND(mcnd,chsm1,chsm0);
	and CHSLS0(chsls0,LS[20],oF_r30);
	and CHSLS1(chsls1,LS[21],oF_r31);
	or LSCND(lscnd,chsls1,chsls0);

	
	//determine if jump instruction/ if jump prediction was right or wrong
	assign eq_jmpOP = (A0[4:0] == 5'b01001) ? 1'b1: 1'b0;
	and JMPCHS(predRW,a0cnd,eq_jmpOP);

	
endmodule