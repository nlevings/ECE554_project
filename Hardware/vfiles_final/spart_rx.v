//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date: January 30th 2017
// Design Name: SPART 
// Module Name:   spart_rx
// Project Name: spart
// Target Devices: Cyclone V
// Tool versions: Quartus Prime 
// Description: spart receive logic
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module spart_rx(clk, rst, iocs, iorw, rx_data, io_addr, enb, rda, rxd);
input clk, rst, iocs, iorw, enb, rxd;
input  [1:0] io_addr;

output [7:0] rx_data; //recieve buffer reg
output       rda;  //read data available wire

reg    [9:0] rx_shift_reg;  //reg for shifting in valid data from rxd
reg    [3:0] shift_count;   //reg for keeping track shift count
reg          got_start;     //reg to signal start of reception of data from rxd
							//(only high for one clock cycle during transition from
							// POLL to REC state of state machine)

parameter [3:0] load_val = 4'hA;  //used to set shift_count upper bound

always@(posedge clk or negedge rst) begin

	if(!rst) begin
		rx_shift_reg <= 10'h0;
		shift_count  <= load_val;
		got_start    <= 1'b0;
	end	
	// check if recieved start condition from Putty	
	else if(!rxd && iorw && (shift_count == load_val)) begin
		rx_shift_reg[9] <= rxd;
		shift_count     <= 4'h0;
		got_start       <= 1'b1;
	end
	// waiting for start condition, iocs held high while polling for start bit
	else if (iocs) begin
	    rx_shift_reg <= rx_shift_reg;
		shift_count <= load_val;
		got_start <= 1'b0;
	end
	// shift data in 
	else if(enb && iorw && got_start) begin
	    rx_shift_reg <= {rxd, rx_shift_reg[8:1]};				
		shift_count <= shift_count + 1'b1;
		got_start <= got_start;
	end
	// hold shift_reg value until new receive
	else if(rda) begin
	    shift_count <= shift_count;
		rx_shift_reg <= rx_shift_reg;
		got_start <= 1'b0;
	end
	// hold
	else begin
		rx_shift_reg <= rx_shift_reg;
		shift_count <= shift_count;
		got_start <= got_start;
	end
	
end
//assign statement for rx_data(enters spart as rx_data_w) 
assign rx_data = rx_shift_reg[7:0];
//assign statement to set rda(high when data in rx_data is valid)
assign rda = (shift_count == load_val) ? 1'b1 : 1'b0;

endmodule