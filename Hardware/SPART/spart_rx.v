//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date:
// Design Name: 
// Module Name:    driver
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

output [7:0] rx_data; //recieve buffer
output       rda;

reg    [9:0] rx_shift_reg;
reg    [3:0] shift_count;
reg          got_start;

parameter [3:0] load_val = 4'hA;

always@(posedge clk or negedge rst) begin

	if(!rst) begin
		rx_shift_reg <= 10'h0;
		shift_count  <= load_val;
		got_start    <= 1'b0;
	end	
	// get start condition	
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
	// hold shifted in data until new receive
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

assign rx_data = rx_shift_reg[7:0];
assign rda = (shift_count == load_val) ? 1'b1 : 1'b0;

endmodule