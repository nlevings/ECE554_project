module CPU();


	InstructionFetch IF0(.predRW(predRW),.PCnext(PCnext),.clk(clk),.rst_n(rst_n),
						.A0(fA0),.A1(fA1),.LS(fLS),.M(fM),.PCPlus(PCPlus));

	IF_ID_reg IF_ID_reg0(.dA0(dA0),.dA1(dA1),.dLS(dLS),.dM(dM),.fA0(fA0),.fA1(fA1),.fLS(fLS),.fM(fM),.PCnext(PCnext),.PCplus(PCplus),.clk(clk),.rst_n(rst_n))

	ID ID0(.A0(dA0),.A1(dA1),.M(dM),.LS(dLS),.clk(clk),
						.a0_wr(a0_wr),.a1_wr(a1_wr),.m_wr(m_wr),.ls_wr(ls_wr),.a0_tag(a0_tag),.a1_tag(a1_tag),.m_tag(m_tag),.ls_tag(ls_tag),
						.teA0_Rd(teA0_Rd),.teA1_Rd(teA1_Rd),.teM_Rd(teM_Rd),.tmemA0_Rd(tmemA0_Rd),.tmemA1_Rd(tmemA1_Rd),.tmemLS_Rd(tmemLS_Rd),.tmemM_Rd(tmemM_Rd),
						.eA0_Rd(eA0_Rd),.eA1_Rd(eA1_Rd),.eM_Rd(eM_Rd),.memA0_Rd(memA0_Rd),.memA1_Rd(memA1_Rd),.memLS_Rd(memLS_Rd),.memM_Rd(memM_Rd),
						.predRW(predRW),
						.a0_R0(a0_R0),.a0_R1(a0_R1),.a1_R0(a1_R0),.a1_R1(a1_R1),.m_R0(m_R0),.m_R1(m_R1),.ls_R0(ls_R0),.ls_R1(ls_R1),
						.a0_R0_tag(a0_R0_tag),.a0_R1_tag(a0_R1_tag),.a1_R0_tag(a1_R0_tag),.a1_R1_tag(a1_R1_tag),.m_R0_tag(m_R0_tag),.m_R1_tag(m_R1_tag),.ls_R0_tag(ls_R0_tag),.ls_R1_tag(ls_R1_tag),
						.a0cnd(a0cnd),.a1cnd(a1cnd),.lscnd(lscnd),.mcnd(mcnd),
						.CntrlSig(CntrlSig),
						.a0_en(a0_en),.a1_en(a1_en),.m_en(m_en),.ls_en(ls_en),
						.a0_Rd_tag(a0_Rd_tag), .a1_Rd_tag(a1_Rd_tag), .m_Rd_tag(m_Rd_tag), .ls_Rd_tag(ls_Rd_tag)
						);

endmodule