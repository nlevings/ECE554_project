//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date: January 30th 2017
// Design Name: SPART 
// Module Name:   spart_tx
// Project Name: spart
// Target Devices: Cyclone V
// Tool versions: Quartus Prime 
// Description: spart transmit logic
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module spart_tx (clk, rst, iocs, iorw, tx_data, io_addr, enb, tbr, txd);
input clk, rst, iocs, iorw, enb;
input [1:0] io_addr;
input [7:0] tx_data;

output tbr;  //transmit buffer ready wire
output txd;  //data out wire

// transmit section
reg [9:0] tx_shift_reg;  //reg for shifting out next data bit to txd
reg [3:0] shift_count;  //reg for keeping track of shift count

parameter [3:0] load_val = 4'h9;  //used to set shift_count upper bound

always@(posedge clk, negedge rst) begin

	if(~rst) begin	
		tx_shift_reg <= 10'h3FF;
		shift_count <= load_val;		
	end
	// load shift reg if start of transmit
	else if(iocs && !iorw) begin
		tx_shift_reg <= {1'b1, tx_data, 1'b0};		
		shift_count <= 1'b0;
	end	
	// shift data on enb
	else if(enb && !iorw) begin
		tx_shift_reg <= tx_shift_reg>>1;		
		shift_count <= shift_count + 1'b1;
	end	
	// hold
	else begin		
		tx_shift_reg <= tx_shift_reg;
		shift_count <= shift_count;
	end
end
//assign to set txd to current valid data
assign txd = tx_shift_reg[0];
//assign to set tbr based on current shift_count
assign tbr = (shift_count == load_val) ? 1'b1 : 1'b0;
	
endmodule