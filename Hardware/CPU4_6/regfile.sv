/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Decode
	
	Summary:
*/
module regfile(a0R0,a0R1,a1R0,a1R1,mR0,mR1,lsR0,lsR1,lsR2,clk, //inputs
						rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1,rLS_R2,		//outputs
						o_r30,o_r31,	//outputs
						a0_wr,a1_wr,m_wr,ls_wr,	//inputs
						a0_tag,a1_tag,m_tag,ls_tag //inputs
						);
 
	//outputs
	output [15:0] rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1,rLS_R2;
	output o_r30,o_r31;

	//inputs
	input clk;
	input [4:0] a0R0,a0R1,a1R0,a1R1,mR0,mR1,lsR0,lsR1,lsR2;
	input [15:0] a0_wr,a1_wr,m_wr,ls_wr;
	input [4:0] a0_tag,a1_tag,m_tag,ls_tag;


	reg [15:0] registers[31:0];
	
	assign rA0_R0 = (a0R0 == 0) ? 16'd0 : registers[a0R0]; // reads data from reg addr as long as the register is not the 0th register in which case it gives 0
	assign rA0_R1 = (a0R1 == 0) ? 16'd0 : registers[a0R1]; 

	assign rA1_R0 = (a1R0 == 0) ? 16'd0 : registers[a1R0]; // reads data from reg addr as long as the register is not the 0th register in which case it gives 0
	assign rA1_R1 = (a1R1 == 0) ? 16'd0 : registers[a1R1]; 

	assign rM_R0 = (mR0 == 0) ? 16'd0 : registers[mR0]; // reads data from reg addr as long as the register is not the 0th register in which case it gives 0
	assign rM_R1 = (mR1 == 0) ? 16'd0 : registers[mR1]; 

	assign rLS_R0 = (lsR0 == 0) ? 16'd0 : registers[lsR0]; // reads data from reg addr as long as the register is not the 0th register in which case it gives 0
	assign rLS_R1 = (lsR1 == 0) ? 16'd0 : registers[lsR1]; 
	assign rLS_R2 = (lsR2 == 0) ? 16'd0 : registers[lsR2];

	assign o_r30 = |registers[30];
	assign o_r31 = |registers[31];
	
	
	
	always @(posedge clk) begin
		registers[0] <= 16'd0;
		if((a0_tag != 5'b0))
				registers[a0_tag] <= a0_wr;
			
		if((a1_tag != 5'b0))
				registers[a1_tag] <= a1_wr;

		if((m_tag != 5'b0))
				registers[m_tag] <= m_wr;
	
		if((ls_tag != 5'b0))
				registers[ls_tag] <= ls_wr;
	end
	
endmodule