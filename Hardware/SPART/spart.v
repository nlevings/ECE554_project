//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date:
// Design Name: 
// Module Name:    spart
// Project Name: spart
// Target Devices: Cyclone V
// Tool versions: Quartus Prime 
// Description: spart module wrapper 
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input       	spart_ref_clk,
    input       	rst,
	input       	rxd,			// Read from GPIO[5]
    output      	txd,			// for testing use (send back to PC). Assign to GPIO[3]
	output [15:0]	spart_w_data,
	output 			spart_w_req,
	output [24:0]	spart_start_addr,
	output [24:0]	spart_end_addr
    );
	
parameter start_addr = 25'h0;
parameter end_addr = 25'h3A980;	//200x400 * 3
	
reg [7:0] tx_data;
wire [7:0] rx_data_w;
wire [7:0] databus;
wire shift;
wire iocs;
wire iorw;
wire rda;
wire tbr;
wire [1:0] ioaddr;
wire update_addr;

reg [3:0] byte_counter;

assign spart_start_addr = start_addr;
assign spart_end_addr = end_addr;

assign spart_w_data = (spart_w_req & ~update_addr) ? {8'b0, databus} : 16'bZ;

assign databus = iorw ? rx_data_w : 8'bz; //tri-state databus
     
baud_gen baud_gen (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .db_data(databus), .io_addr(ioaddr), .shift(shift)); 	

spart_tx spart_tx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .tx_data(databus), 
	.io_addr(ioaddr), .enb(shift), .tbr(tbr), .txd(txd));

spart_rx spart_rx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rx_data(rx_data_w),
	.io_addr(ioaddr), .enb(shift), .rda(rda), .rxd(rxd));

driver driver( .clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr),
	.ioaddr(ioaddr), .databus(databus),.data_valid(spart_w_req));

endmodule