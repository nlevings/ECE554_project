module CPU(clk,rst_n);
	
	input clk,rst_n;
	
	//wires IF
	wire predRW;
	wire [9:0] PCnext;
	wire [9:0] PCplus;
	wire [21:0] fA0,fA1,fLS,fM;
	
	//wires ID
	wire [21:0] dA0,dA1,dM,dLS;
	wire [15:0] a0_wr,a1_wr,m_wr; //data coming back to ID in WB stage
	wire [7:0] ls_wr;
	wire [4:0] a0_tag,a1_tag,m_tag,ls_tag; //tags coming back to ID in WB stage
	wire a0cnd,a1cnd,lscnd,mcnd;
	wire [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2;
	wire [4:0] a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag,ls_R2_tag;	
	wire [13:0] CntrlSig;
	wire [4:0] a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag;
	wire [4:0] a0_Imm,a1_Imm,m_Imm;
	wire [4:0] tmemA0_Rd,tmemA1_Rd,tmemLS_Rd,tmemM_Rd;
	wire [15:0] memA0_Rd,memA1_Rd,memM_Rd;
	wire [7:0] memLS_Rd;
	//cntrl sig
	wire A0_imm_sel,A1_imm_sel,M_imm_sel;
	wire [3:0] A0_op, A1_op;
	
	//wires EX
	wire [13:0] cntrl_sig;
	wire [4:0] a0Rd_tag,a1Rd_tag,mRd_tag,lsRd_tag;
	wire [4:0] A0_imm,A1_imm,M_imm;
	wire [15:0] A0_R0,A0_R1,A1_R0,A1_R1,M_R0,M_R1,LS_R0,LS_R1,LS_R2;
	wire [4:0] M_Rd_tag_in,A0_Rd_tag_in,A1_Rd_tag_in,LS_Rd_tag_in;
	wire [4:0] M_Rd_tag_out,A0_Rd_tag_out,A1_Rd_tag_out,LS_Rd_tag_out;
	wire [15:0] A0_res, A1_res, M_res;
	wire [7:0] LS_data;
	wire [4:0] LS_tag;
	wire [24:0] LS_addr;
	
	//wires for Mem
	wire [24:0] sdram_addr;
	wire LS_R_nW;
	wire r_nW,stall;
	wire [15:0] A0_mem_out,A1_mem_out,M_mem_out;
	wire [7:0] LS_mem_out;
	wire [4:0] A0_mem_tag_out,A1_mem_tag_out,M_mem_tag_out,LS_mem_tag_out;
	
	//IF
	InstructionFetch IF0(.predRW(predRW),.PCnext(PCnext),.clk(clk),.rst_n(rst_n),
						.A0(fA0),.A1(fA1),.LS(fLS),.M(fM),.PCplus(PCplus));
	//IF/ID
	IF_ID_reg IF_ID_reg0(.dA0(dA0),.dA1(dA1),.dLS(dLS),.dM(dM),.fA0(fA0),.fA1(fA1),.fLS(fLS),.fM(fM),.PCnext(PCnext),.PCplus(PCplus),.clk(clk),.rst_n(rst_n),.stall(stall));

	//ID
	ID ID0(.A0(dA0),.A1(dA1),.M(dM),.LS(dLS),.clk(clk),
						.a0_wr(a0_wr),.a1_wr(a1_wr),.m_wr(m_wr),.ls_wr({8'd0,ls_wr}),.a0_tag(a0_tag),.a1_tag(a1_tag),.m_tag(m_tag),.ls_tag(ls_tag),
						.teA0_Rd(A0_Rd_tag_out),.teA1_Rd(A1_Rd_tag_out),.teM_Rd(M_Rd_tag_out),.tmemA0_Rd(tmemA0_Rd),.tmemA1_Rd(tmemA1_Rd),.tmemLS_Rd(tmemLS_Rd),.tmemM_Rd(tmemM_Rd),
						.eA0_Rd(A0_res),.eA1_Rd(A1_res),.eM_Rd(M_res),.memA0_Rd(memA0_Rd),.memA1_Rd(memA1_Rd),.memLS_Rd({8'd0,memLS_Rd}),.memM_Rd(memM_Rd),
						.predRW(predRW),
						.a0_R0(a0_R0),.a0_R1(a0_R1),.a1_R0(a1_R0),.a1_R1(a1_R1),.m_R0(m_R0),.m_R1(m_R1),.ls_R0(ls_R0),.ls_R1(ls_R1),.ls_R2(ls_R2),
						.a0_R0_tag(a0_R0_tag),.a0_R1_tag(a0_R1_tag),.a1_R0_tag(a1_R0_tag),.a1_R1_tag(a1_R1_tag),.m_R0_tag(m_R0_tag),.m_R1_tag(m_R1_tag),.ls_R0_tag(ls_R0_tag),.ls_R1_tag(ls_R1_tag),.ls_R2_tag(ls_R2_tag),
						.a0cnd(a0cnd),.a1cnd(a1cnd),.lscnd(lscnd),.mcnd(mcnd),
						.CntrlSig(CntrlSig),
						.a0_Rd_tag(a0_Rd_tag), .a1_Rd_tag(a1_Rd_tag), .m_Rd_tag(m_Rd_tag), .ls_Rd_tag(ls_Rd_tag),
						.a0_Imm(a0_Imm),.a1_Imm(a1_Imm),.m_Imm(m_Imm)
						);
				
	//ID/EX
	ID_EX_reg ID_EX_reg0(.clk(clk),.rst_n(rst_n),
				.a0cnd(a0cnd),.a1cnd(a1cnd),.lscnd(lscnd),.mcnd(mcnd),
				.a0_R0(a0_R0),.a0_R1(a0_R1),.a1_R0(a1_R0),.a1_R1(a1_R1),.m_R0(m_R0),.m_R1(m_R1),.ls_R0(ls_R0),.ls_R1(ls_R1),.ls_R2(ls_R2),
				.a0_R0_tag(a0_R0_tag),.a0_R1_tag(a0_R1_tag),.a1_R0_tag(a1_R0_tag),.a1_R1_tag(a1_R1_tag),.m_R0_tag(m_R0_tag),.m_R1_tag(m_R1_tag),.ls_R0_tag(ls_R0_tag),.ls_R1_tag(ls_R1_tag),.ls_R2_tag(ls_R2_tag),
				.predRW(predRW),.CntrlSig(CntrlSig),
				.a0_Rd_tag(a0_Rd_tag), .a1_Rd_tag(a1_Rd_tag), .m_Rd_tag(m_Rd_tag), .ls_Rd_tag(ls_Rd_tag),
				.a0_Imm(a0_Imm),.a1_Imm(a1_Imm),.m_Imm(m_Imm),
				.stall(stall),
				.cntrl_sig(cntrl_sig),	//outputs begin here
				.a0R0(A0_R0),.a0R1(A0_R1),.a1R0(A1_R0),.a1R1(A1_R1),.mR0(M_R0),.mR1(M_R1),.lsR0(LS_R0),.lsR1(LS_R1),.lsR2(LS_R2),
				.a0Rd_tag(A0_Rd_tag_in),.a1Rd_tag(A1_Rd_tag_in),.mRd_tag(M_Rd_tag_in),.lsRd_tag(LS_Rd_tag_in),
				.a0Imm(A0_imm),.a1Imm(A1_imm),.mImm(M_imm));

	//Ex
	assign A0_imm_sel = cntrl_sig[13];
	assign A1_imm_sel = cntrl_sig[8];
	assign M_imm_sel = cntrl_sig[3];
	assign A0_op = cntrl_sig[12:9];
	assign A1_op = cntrl_sig[7:4];

	//TODO add LS_R2 into Execute
	Execute Execute0(
	// Inputs
	.A0_R0(A0_R0), .A0_R1(A0_R1), .A0_Rd_tag_in(A0_Rd_tag_in), .A0_imm(A0_imm), .A0_imm_sel(A0_imm_sel), .A0_op(A0_op), .A1_R0(A1_R0), .A1_R1(A1_R1), .A1_Rd_tag_in(A1_Rd_tag_in), .A1_imm(A1_imm), .A1_imm_sel(A1_imm_sel), .A1_op(A1_op),
	.M_R0(M_R0), .M_R1(M_R1), .M_Rd_tag_in(M_Rd_tag_in), .M_imm(M_imm), .M_imm_sel(M_imm_sel), .LS_R0(LS_R0), .LS_R1(LS_R1), .LS_R2(LS_R2), .LS_Rd_tag_in(LS_Rd_tag_in),.write(cntrl_sig[0]),
	// Outputs
	.A0_res(A0_res), .A0_Rd_tag_out(A0_Rd_tag_out), .A1_res(A1_res), .A1_Rd_tag_out(A1_Rd_tag_out), .M_res(M_res), .M_Rd_tag_out(M_Rd_tag_out), .LS_data(LS_data),.LS_addr(LS_addr), .LS_R_nW(LS_R_nW), .LS_Rd_tag_out(LS_Rd_tag_out)
	);

	
	//Ex/Mem
	Ex_Mem_reg Ex_Mem_reg0(.clk(clk),.rst_n(rst_n),
							.a0resE(A0_res),.a1resE(A1_res),.mresE(M_res),.a0tagE(A0_Rd_tag_out),.a1tagE(A1_Rd_tag_out),.mtagE(M_Rd_tag_out),
							.lsData(LS_data),.lstagE(LS_Rd_tag_out),.lsaddr(LS_addr),
							.LS_R_nW(LS_R_nW),
							//outputs
							.memA0_Rd(memA0_Rd),.memA1_Rd(memA1_Rd),.memM_Rd(memM_Rd),.tmemA0_Rd(tmemA0_Rd),.tmemA1_Rd(tmemA1_Rd),.tmemM_Rd(tmemM_Rd),
							.memLS_Rd(memLS_Rd),.tmemLS_Rd(tmemLS_Rd),.sdram_addr(sdram_addr),
							.r_nW(r_nW),
							.stall(stall)
							);
	//Mem
	/*Memory Memory0(.ref_clk(clk), .rst_n(rst_n), .A0_in(memA0_Rd), .A0_Rd_tag_in(tmemA0_Rd), .A1_in(memA1_Rd), .A1_Rd_tag_in(tmemA1_Rd), .M_in(memM_Rd), .M_Rd_tag_in(tmemM_Rd), .LS_Rd_tag_in(tmemLS_Rd),
	.LS_data(memLS_Rd), .LS_addr(sdram_addr), .R_nW(r_nW), .A0_out(A0_mem_out), .A0_Rd_tag_out(A0_mem_tag_out), .A1_out(A1_mem_out), .A1_Rd_tag_out(A1_mem_tag_out), .M_out(M_mem_out), .M_Rd_tag_out(M_mem_tag_out), .LS_Rd_tag_out(LS_mem_tag_out),
	.wb_data(LS_mem_out), .stall(stall));*/
	Memory Memory0(.ref_clk(clk), .rst_n(rst_n), .A0_in(memA0_Rd), .A0_Rd_tag_in(tmemA0_Rd), .A1_in(memA1_Rd), .A1_Rd_tag_in(tmemA1_Rd), .M_in(memM_Rd), .M_Rd_tag_in(tmemM_Rd), .LS_Rd_tag_in(tmemLS_Rd),
	.LS_data(memLS_Rd), .LS_addr(sdram_addr), .R_nW(r_nW), .A0_out(A0_mem_out), .A0_Rd_tag_out(A0_mem_tag_out), .A1_out(A1_mem_out), .A1_Rd_tag_out(A1_mem_tag_out), .M_out(M_mem_out), .M_Rd_tag_out(M_mem_tag_out), .LS_Rd_tag_out(LS_mem_tag_out)
	);
	assign LS_mem_out = 8'd0;
	
	
	//Mem/WB
	Mem_WB_reg Mem_WB_reg0(.clk(clk),.rst_n(rst_n),.stall(stall),
							.memA0_Rd(A0_mem_out),.memA1_Rd(A1_mem_out),.memM_Rd(M_mem_out),.memLS_Rd(LS_mem_out),.tmemA0_Rd(A0_mem_tag_out),.tmemA1_Rd(A1_mem_tag_out),.tmemM_Rd(M_mem_tag_out),.tmemLS_Rd(LS_mem_tag_out),
							//outputs
							.a0_wr(a0_wr),.a1_wr(a1_wr),.m_wr(m_wr),.ls_wr(ls_wr),.a0_tag(a0_tag),.a1_tag(a1_tag),.m_tag(m_tag),.ls_tag(ls_tag)
							);

endmodule