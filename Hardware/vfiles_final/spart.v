//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date: January 30th 2017
// Design Name: SPART 
// Module Name:  spart
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
    input       clk,
    input       rst,
    input       iocs,
    input       iorw,
    output      rda,
    output      tbr,
    input [1:0] ioaddr,
    inout [7:0] databus,
    output      txd,
    input       rxd
    );
	
reg [7:0] tx_data;     //reg to send tx_data from databus to spart_tx
wire [7:0] rx_data_w;  //wire to send data to spart_rx
wire shift;  //wire from baud_gen to spart_rx and spart_tx to control data shifts

//assign statement to set databus for read condition (iorw == 1);
assign databus = iorw ? rx_data_w : 8'bz; //tri-state databus
  

//Instantiate baud_gen
baud_gen baud_gen (.clk(clk), .rst(rst), .iocs(iocs), .db_data(databus), .io_addr(ioaddr), .shift(shift)); 	

//Instantiate spart_tx
spart_tx spart_tx (.clk(clk), .rst(rst), .iocs(iocs), .iorw(iorw), .tx_data(databus), 
	.io_addr(ioaddr), .enb(shift), .tbr(tbr), .txd(txd));

//Instantiate spart_rx
spart_rx spart_rx (.clk(clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rx_data(rx_data_w),
	.io_addr(ioaddr), .enb(shift), .rda(rda), .rxd(rxd));	

endmodule