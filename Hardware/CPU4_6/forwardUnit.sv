/*
	Team: DSP (Discretely Superior Processing)
	Members: Brian Guttag, Cheng Xiang, Nick Levings, Cody Schnabel, James Papa
	
	Block: CPU
	Stage: Instruction Decode
	
	Summary:
*/
module forwardUnit(a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2,oF_r30,oF_r31,					//outputs
								rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1,rLS_R2,o_r30,o_r31,	//input values from this stage
								tA0_R0,tA0_R1,tA1_R0,tA1_R1,tM_R0,tM_R1,tLS_R0,tLS_R1,tLS_R2,	//input tags from this stage
								teA0_Rd,teA1_Rd,teM_Rd,	//input tags from execute
								eA0_Rd,eA1_Rd,eM_Rd,	//input values from execute
								tmemA0_Rd,tmemA1_Rd,tmemM_Rd,tmemLS_Rd,	//input tags from memory
								memA0_Rd,memA1_Rd,memM_Rd,memLS_Rd,     //input values from memory
								twbA0_Rd,twbA1_Rd,twbM_Rd,twbLS_Rd,
								wbA0_Rd,wbA1_Rd,wbM_Rd,wbLS_Rd
								);	
								
	input [4:0] tA0_R0,tA0_R1,tA1_R0,tA1_R1,tM_R0,tM_R1,tLS_R0,tLS_R1,tLS_R2;
	input [15:0] rA0_R0,rA0_R1,rA1_R0,rA1_R1,rM_R0,rM_R1,rLS_R0,rLS_R1,rLS_R2;
	input o_r30, o_r31;
	input [4:0] teA0_Rd,teA1_Rd,teM_Rd;
	input [15:0] eA0_Rd,eA1_Rd,eM_Rd;
	input [4:0] tmemA0_Rd,tmemA1_Rd,tmemM_Rd,tmemLS_Rd;
	input [15:0] memA0_Rd,memA1_Rd,memM_Rd,memLS_Rd;
	input [4:0] twbA0_Rd,twbA1_Rd,twbM_Rd,twbLS_Rd;
	input [15:0] wbA0_Rd,wbA1_Rd,wbM_Rd,wbLS_Rd;
	output [15:0] a0_R0,a0_R1,a1_R0,a1_R1,m_R0,m_R1,ls_R0,ls_R1,ls_R2;
	output oF_r30, oF_r31; 
	//TODO add a WB-ID forwarding
	assign a0_R0 = 	(tA0_R0 == 5'd0) ? rA0_R0:
					(tA0_R0 == teA0_Rd) ? eA0_Rd:
					(tA0_R0 == teA1_Rd) ? eA1_Rd:
					(tA0_R0 == teM_Rd) ? eM_Rd:
					(tA0_R0 == tmemA0_Rd) ? memA0_Rd:
					(tA0_R0 == tmemA1_Rd) ? memA1_Rd:
					(tA0_R0 == tmemM_Rd) ? memM_Rd:
					(tA0_R0 == tmemLS_Rd) ? memLS_Rd:
					(tA0_R0 == twbA0_Rd) ? wbA0_Rd:
					(tA0_R0 == twbA1_Rd) ? wbA1_Rd:
					(tA0_R0 == twbM_Rd) ? wbM_Rd:
					(tA0_R0 == twbLS_Rd) ? wbLS_Rd:
					rA0_R0;
	assign a0_R1 = (tA0_R1 == 5'd0) ? rA0_R1:
					(tA0_R1 == teA0_Rd) ? eA0_Rd:
					(tA0_R1 == teA1_Rd) ? eA1_Rd:
					(tA0_R1 == teM_Rd) ? eM_Rd:
					(tA0_R1 == tmemA0_Rd) ? memA0_Rd:
					(tA0_R1 == tmemA1_Rd) ? memA1_Rd:
					(tA0_R1 == tmemM_Rd) ? memM_Rd:
					(tA0_R1 == tmemLS_Rd) ? memLS_Rd:
					(tA0_R1 == twbA0_Rd) ? wbA0_Rd:
					(tA0_R1 == twbA1_Rd) ? wbA1_Rd:
					(tA0_R1 == twbM_Rd) ? wbM_Rd:
					(tA0_R1 == twbLS_Rd) ? wbLS_Rd:
					rA0_R1;
	assign a1_R0 = (tA1_R0 == 5'd0) ? rA1_R0:
					(tA1_R0 == teA0_Rd) ? eA0_Rd:
					(tA1_R0 == teA1_Rd) ? eA1_Rd:
					(tA1_R0 == teM_Rd) ? eM_Rd:
					(tA1_R0 == tmemA0_Rd) ? memA0_Rd:
					(tA1_R0 == tmemA1_Rd) ? memA1_Rd:
					(tA1_R0 == tmemM_Rd) ? memM_Rd:
					(tA1_R0 == tmemLS_Rd) ? memLS_Rd:
					(tA1_R0 == twbA0_Rd) ? wbA0_Rd:
					(tA1_R0 == twbA1_Rd) ? wbA1_Rd:
					(tA1_R0 == twbM_Rd) ? wbM_Rd:
					(tA1_R0 == twbLS_Rd) ? wbLS_Rd:
					rA1_R0;
	assign a1_R1 = (tA1_R1 == 5'd0) ? rA1_R1:
					(tA1_R1 == teA0_Rd) ? eA0_Rd:
					(tA1_R1 == teA1_Rd) ? eA1_Rd:
					(tA1_R1 == teM_Rd) ? eM_Rd:
					(tA1_R1 == tmemA0_Rd) ? memA0_Rd:
					(tA1_R1 == tmemA1_Rd) ? memA1_Rd:
					(tA1_R1 == tmemM_Rd) ? memM_Rd:
					(tA1_R1 == tmemLS_Rd) ? memLS_Rd:
					(tA1_R1 == twbA0_Rd) ? wbA0_Rd:
					(tA1_R1 == twbA1_Rd) ? wbA1_Rd:
					(tA1_R1 == twbM_Rd) ? wbM_Rd:
					(tA1_R1 == twbLS_Rd) ? wbLS_Rd:
					rA1_R1;
	assign m_R0 = (tM_R0 == 5'd0) ? rM_R0:
					(tM_R0 == teA0_Rd) ? eA0_Rd:
					(tM_R0 == teA1_Rd) ? eA1_Rd:
					(tM_R0 == teM_Rd) ? eM_Rd:
					(tM_R0 == tmemA0_Rd) ? memA0_Rd:
					(tM_R0 == tmemA1_Rd) ? memA1_Rd:
					(tM_R0 == tmemM_Rd) ? memM_Rd:
					(tM_R0 == tmemLS_Rd) ? memLS_Rd:
					(tM_R0 == twbA0_Rd) ? wbA0_Rd:
					(tM_R0 == twbA1_Rd) ? wbA1_Rd:
					(tM_R0 == twbM_Rd) ? wbM_Rd:
					(tM_R0 == twbLS_Rd) ? wbLS_Rd:
					rM_R0;
	assign m_R1 = (tM_R1 == 5'd0) ? rM_R1:
					(tM_R1 == teA0_Rd) ? eA0_Rd:
					(tM_R1 == teA1_Rd) ? eA1_Rd:
					(tM_R1 == teM_Rd) ? eM_Rd:
					(tM_R1 == tmemA0_Rd) ? memA0_Rd:
					(tM_R1 == tmemA1_Rd) ? memA1_Rd:
					(tM_R1 == tmemM_Rd) ? memM_Rd:
					(tM_R1 == tmemLS_Rd) ? memLS_Rd:
					(tM_R1 == twbA0_Rd) ? wbA0_Rd:
					(tM_R1 == twbA1_Rd) ? wbA1_Rd:
					(tM_R1 == twbM_Rd) ? wbM_Rd:
					(tM_R1 == twbLS_Rd) ? wbLS_Rd:
					rM_R1;
	assign ls_R0 =  (tLS_R0 == 5'd0) ? rLS_R0:
					(tLS_R0 == teA0_Rd) ? eA0_Rd:
					(tLS_R0 == teA1_Rd) ? eA1_Rd:
					(tLS_R0 == teM_Rd) ? eM_Rd:
					(tLS_R0 == tmemA0_Rd) ? memA0_Rd:
					(tLS_R0 == tmemA1_Rd) ? memA1_Rd:
					(tLS_R0 == tmemM_Rd) ? memM_Rd:
					(tLS_R0 == tmemLS_Rd) ? memLS_Rd:
					(tLS_R0 == twbA0_Rd) ? wbA0_Rd:
					(tLS_R0 == twbA1_Rd) ? wbA1_Rd:
					(tLS_R0 == twbM_Rd) ? wbM_Rd:
					(tLS_R0 == twbLS_Rd) ? wbLS_Rd:
					rLS_R0;
	assign ls_R1 =  (tLS_R1 == 5'd0) ? rLS_R1:
					(tLS_R1 == teA0_Rd) ? eA0_Rd:
					(tLS_R1 == teA1_Rd) ? eA1_Rd:
					(tLS_R1 == teM_Rd) ? eM_Rd:
					(tLS_R1 == tmemA0_Rd) ? memA0_Rd:
					(tLS_R1 == tmemA1_Rd) ? memA1_Rd:
					(tLS_R1 == tmemM_Rd) ? memM_Rd:
					(tLS_R1 == tmemLS_Rd) ? memLS_Rd:
					(tLS_R1 == twbA0_Rd) ? wbA0_Rd:
					(tLS_R1 == twbA1_Rd) ? wbA1_Rd:
					(tLS_R1 == twbM_Rd) ? wbM_Rd:
					(tLS_R1 == twbLS_Rd) ? wbLS_Rd:
					rLS_R1;
	assign ls_R2 =  (tLS_R2 == 5'd0) ? rLS_R2:
					(tLS_R2 == teA0_Rd) ? eA0_Rd:
					(tLS_R2 == teA1_Rd) ? eA1_Rd:
					(tLS_R2 == teM_Rd) ? eM_Rd:
					(tLS_R2 == tmemA0_Rd) ? memA0_Rd:
					(tLS_R2 == tmemA1_Rd) ? memA1_Rd:
					(tLS_R2 == tmemM_Rd) ? memM_Rd:
					(tLS_R2 == tmemLS_Rd) ? memLS_Rd:
					(tLS_R2 == twbA0_Rd) ? wbA0_Rd:
					(tLS_R2 == twbA1_Rd) ? wbA1_Rd:
					(tLS_R2 == twbM_Rd) ? wbM_Rd:
					(tLS_R2 == twbLS_Rd) ? wbLS_Rd:
					rLS_R2;
	
	assign oF_r30 = (teA0_Rd == 5'd30) ? |eA0_Rd:
					(teA1_Rd == 5'd30) ? |eA1_Rd:
					(tmemA0_Rd == 5'd30)  ? |memA0_Rd:
					(tmemA1_Rd == 5'd30)  ? |memA1_Rd:
					(twbA0_Rd == 5'd30) ? |wbA0_Rd:
					(twbA1_Rd == 5'd30) ? |wbA1_Rd:
					o_r30;
	assign oF_r31 = (teA0_Rd == 5'd31) ? |eA0_Rd:
					(teA1_Rd == 5'd31) ? |eA1_Rd:
					(tmemA0_Rd == 5'd31)  ? |memA0_Rd:
					(tmemA1_Rd == 5'd31)  ? |memA1_Rd:
					(twbA0_Rd == 5'd31) ? |wbA0_Rd:
					(twbA1_Rd == 5'd31) ? |wbA1_Rd:
					o_r31;				
	
endmodule