module dmem(data, addr, R_nW, wb_data);
	// Inputs
	input [7:0] data;
	input [15:0] addr;
	input R_nW;
	
	// Output
	output [8:0] wb_data;

endmodule