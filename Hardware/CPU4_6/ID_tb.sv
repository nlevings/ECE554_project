/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Decode TB
	
	Summary:
*/
module ID_tb();

	reg [9:0] pc_next;
	reg [21:0] A0,A1,M,LS;
	reg clk;
	reg [15:0] a0_wr,a1_wr,m_wr,ls_wr;
	reg [4:0] a0_tag,a1_tag,m_tag,ls_tag;
	reg a0_en,a1_en,m_en,ls_en;
	wire a0_cnd,a1_cnd,m_cnd,ls_cnd;
	wire [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1;
	wire [4:0] a0_R0_tag,a0_R1_tag,a1_R0_tag,a1_R1_tag,m_R0_tag,m_R1_tag,ls_R0_tag,ls_R1_tag;
	wire [4:0] a0_Rd_tag, a1_Rd_tag, m_Rd_tag, ls_Rd_tag;
	wire predRW;
	wire [12:0] CntrlSig; //{4'A0op,4'dA1op,1'LSop,4'_en}
	
	//inputs from execute and memory for forewarding
	reg [4:0] teA0_Rd,teA1_Rd,teM_Rd,tmemA0_Rd,tmemA1_Rd,tmemLS_Rd,tmemM_Rd;
	reg [15:0] eA0_Rd,eA1_Rd,eM_Rd,memA0_Rd,memA1_Rd,memLS_Rd,memM_Rd;

	ID iDUT(.pc_next(pc_next),.A0(A0),.A1(A1),.M(M),.LS(LS),.clk(clk),
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
	
	initial #100 $stop;
	
	initial begin
		clk = 0;
		pc_next = 10'd0;
		A0 = 22'd0; A1 = 22'd0; M = 22'd0; LS = 22'd0;
		a0_wr = 16'd0; a1_wr = 16'd0; m_wr = 16'd0; ls_wr = 16'd0;
		a0_tag = 5'd0; a1_tag = 5'd0; m_tag = 5'd0; ls_tag = 5'd0;
		teA0_Rd = 5'd0; teA1_Rd = 5'd0; teM_Rd = 5'd0; tmemA0_Rd = 5'd0; tmemA1_Rd = 5'd0; tmemLS_Rd = 5'd0; tmemM_Rd = 5'd0;
		eA0_Rd = 16'd0; eA1_Rd = 16'd0; eM_Rd = 16'd0; memA0_Rd = 16'd0; memA1_Rd = 16'd0; memLS_Rd = 16'd0; memM_Rd = 16'd0;
		a0_en = 0; a1_en = 0; m_en = 0; ls_en = 0;
		
		//Test 0: Basic test no forewarding necessary, no jmp, no conditionals
		/*A0: ADDI R1 = R0 + #5; A1: ADDI R2 = R0 + #2; M: NOP; LS: R3 = mem[R0]
		writing data[n]:   a0_wr = 16'd10; a1_wr = 16'd8; m_wr = 16'd5; ls_wr = 16'd15;	
						   a0_tag = 5'd8; a1_tag = 5'd9; m_tag = 5'd10; ls_tag = 5'd11; 
		writing data[n+1]: a0_wr = 16'd12; a1_wr = 16'd13; m_wr = 16'd14; ls_wr = 16'd15;	
						   a0_tag = 5'd12; a1_tag = 5'd13; m_tag = 5'd14; ls_tag = 5'd15;
		writing data[n+2]: a0_wr = 16'd16; a1_wr = 16'd17; m_wr = 16'd18; ls_wr = 16'd19;	
						   a0_tag = 5'd16; a1_tag = 5'd17; m_tag = 5'd18; ls_tag = 5'd19;
		writing data[n+3]: a0_wr = 16'd5; a1_wr = 16'd2; m_wr = 16'dx; ls_wr = 16'd0;	//assume mem[R0] is 0
						   a0_tag = 5'd1; a1_tag = 5'd2; m_tag = 5'dx; ls_tag = 5'd3;
		*/
		@(posedge clk);
		A0 = 22'b00_00001_00101_00000_00001; A1 = 22'b00_00010_00011_00000_00001; M = 22'b00_00001_00101_00000_01100; LS = 22'b00_00011_01111_00000_10001;
		a0_wr = 16'd10; a1_wr = 16'd8; m_wr = 16'd5; ls_wr = 16'd15;	
		a0_tag = 5'd8; a1_tag = 5'd9; m_tag = 5'd10; ls_tag = 5'd11;
		a0_en = 1; a1_en = 1; m_en = 1; ls_en = 1;
		@(posedge clk);
		if(a0_R0 != 0) begin
			$display("Error with a0_R0, expected: 0 but got %h",a0_R0);
			$stop;
		end
		if(a1_R0 != 0) begin
			$display("Error with a1_R0, expected: 0 but got %h",a0_R0);
			$stop;
		end
		if(ls_R0 != 0) begin
			$display("Error with ls_R0, expected: 0 but got %h",a0_R0);
			$stop;
		end
		if(a0_Rd_tag != 1) begin
			$display("Error with a0_Rd_tag, expected: 1 but got %h",a0_R0);
			$stop;
		end
		
		//Test 1: test forwarding unit and jmp, no conditionals
		/*A0: JMPI 0x20; A1: ADDI R30 = R0 + #0; M: MUL R5 = R1 * R2; LS: ST mem[R0] = R1;
							need to forward R1 from exec and R16 from mem; for M need to forward R1 and R2 from exec
		writing data[n]: a0_wr = 16'd12; a1_wr = 16'd13; m_wr = 16'd14; ls_wr = 16'd15;	
						   a0_tag = 5'd12; a1_tag = 5'd13; m_tag = 5'd14; ls_tag = 5'd15;
		writing data[n+1]: a0_wr = 16'd16; a1_wr = 16'd17; m_wr = 16'd18; ls_wr = 16'd19;	
						   a0_tag = 5'd16; a1_tag = 5'd17; m_tag = 5'd18; ls_tag = 5'd19;
		writing data[n+2]: a0_wr = 16'd5; a1_wr = 16'd2; m_wr = 16'dx; ls_wr = 16'd0;	//assume mem[R0] is 0
						   a0_tag = 5'd1; a1_tag = 5'd2; m_tag = 5'dx; ls_tag = 5'd3;
		writing data[n+3]: a0_wr = 16'dx a1_wr = 16'd0; m_wr = 16'd10; ls_wr = 16'dx;	
						   a0_tag = 5'dx; a1_tag = 5'd30; m_tag = 5'd5; ls_tag = 5'dx;
		*/
		A0 = 22'b00_00000_00001_00000_01001; A1 = 22'b00_11110_00000_00000_00001; M = 22'b00_00101_00010_00001_01101; LS = 22'b00_11111_00001_00000_10000;
		a0_wr = 16'd12; a1_wr = 16'd13; m_wr = 16'd14; ls_wr = 16'd15;	
		a0_tag = 5'd12; a1_tag = 5'd13; m_tag = 5'd14; ls_tag = 5'd15;
		a0_en = 1; a1_en = 1; m_en = 1; ls_en = 1;
		teA0_Rd = 5'd1; teA1_Rd = 5'd2; tmemA0_Rd = 5'd16; 
		eA0_Rd = 16'd5; eA1_Rd = 16'd2; memA0_Rd = 16'd16; 
		
		@(posedge clk);
		if(m_R0 != 5)begin
			$display("Forwarding failed, expected 5 but got %d",m_R0);
			$stop;
		end
		if(m_R1 != 2)begin
			$display("Forwarding failed, expected 2 but got %d",m_R1);
			$stop;
		end
		//Test 2: test conditionals
		/*A0: [R30] JMPI 0x20; A1: NOP; M: NOP; LS: NOP;
							need to forward R1 from exec and R16 from mem; for M need to forward R1 and R2 from exec
		writing data[n]: a0_wr = 16'd16; a1_wr = 16'd17; m_wr = 16'd18; ls_wr = 16'd19;	
						   a0_tag = 5'd16; a1_tag = 5'd17; m_tag = 5'd18; ls_tag = 5'd19;
		writing data[n+1]: a0_wr = 16'd5; a1_wr = 16'd2; m_wr = 16'dx; ls_wr = 16'd0;	//assume mem[R0] is 0
						   a0_tag = 5'd1; a1_tag = 5'd2; m_tag = 5'dx; ls_tag = 5'd3;
		writing data[n+2]: a0_wr = 16'dx a1_wr = 16'd0; m_wr = 16'd10; ls_wr = 16'dx;	
						   a0_tag = 5'dx; a1_tag = 5'd30; m_tag = 5'd5; ls_tag = 5'dx;
		writing data[n+3]: a0_wr = 16'dx a1_wr = 16'dx; m_wr = 16'dx; ls_wr = 16'dx;	
						   a0_tag = 5'dx; a1_tag = 5'dx; m_tag = 5'dx; ls_tag = 5'dx;
		*/
		A0 = 22'b01_00000_00001_00000_01001; A1 = 22'b00_00100_10000_00001_01100; M = 22'b00_00101_00010_00001_01100; LS = 22'b00_11111_00001_00000_01100;
		a0_wr = 16'd16; a1_wr = 16'd17; m_wr = 16'd18; ls_wr = 16'd19;	
		a0_tag = 5'd16; a1_tag = 5'd17; m_tag = 5'd18; ls_tag = 5'd19;
		a0_en = 1; a1_en = 1; m_en = 1; ls_en = 1;
		teA0_Rd = 5'd0; teA1_Rd = 5'd30; tmemA0_Rd = 5'd16; 
		eA0_Rd = 16'dx; eA1_Rd = 16'd0; memA0_Rd = 16'd16; 
		
		@(posedge clk);
		if(iDUT.oF_r30 != 0)begin
			$display("Failed to forward r30 correctly got: %d but suppose to be 0",iDUT.oF_r30);
			$stop;
		end
		if(iDUT.a0cnd != 0)begin
			$display("Wrong conditional set for the jump instruction");
			$stop;
		end
		if(iDUT.eq_jmpOP != 1)begin
			$display("Failed to see that this was a jump instruction");
			$stop;
		end
		if(predRW != 0)begin
			$display("Prediction correction was wrong (should have said it predicted correct)");
			$stop;
		end
		
	end
	
	always #5 clk=~clk;
endmodule