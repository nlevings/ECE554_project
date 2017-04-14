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
	output reg [15:0]	spart_w_data,
	output reg		spart_w_req,
	output [24:0]	spart_start_addr,
	output [24:0]	spart_end_addr,
	output			spart_address_valid		// Asserts when start and end addresses are valid
    );
	
parameter start_addr = 25'h0;
	
reg [7:0] tx_data;
wire [7:0] rx_data_w;
wire [7:0] databus;
wire shift;
wire iocs;
wire iorw;
wire rda;
wire tbr;
wire [1:0] ioaddr;
wire data_valid;

reg [2:0] byte_counter;
reg [15:0] row, col;


// SPART
assign databus = iorw ? rx_data_w : 8'bz; //tri-state databus
     
baud_gen baud_gen (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .db_data(databus), .io_addr(ioaddr), .shift(shift)); 	

spart_tx spart_tx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .tx_data(databus), 
	.io_addr(ioaddr), .enb(shift), .tbr(tbr), .txd(txd));

spart_rx spart_rx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rx_data(rx_data_w),
	.io_addr(ioaddr), .enb(shift), .rda(rda), .rxd(rxd));

driver driver( .clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr),
	.ioaddr(ioaddr), .databus(databus),.data_valid(data_valid));

	
assign spart_start_addr = start_addr;
assign spart_end_addr = start_addr + 2 + (3*row*col);
assign spart_address_valid = (byte_counter >= 3'h4);
	
// First two transmitions (row and col) use both bytes of output, rest use only one byte
always@(posedge spart_ref_clk, negedge rst) begin
	if(!rst) begin
		byte_counter <= 4'b0;
		spart_w_data <= 16'h0;
		spart_w_req <= 1'b0;
		row <= 16'b0;
		col <= 16'b0;
	end else if(data_valid & byte_counter == 3'h0) begin
		byte_counter <= byte_counter + 1;
		spart_w_data[15:8] <= databus;
		spart_w_data[7:0] <= spart_w_data[7:0];
		spart_w_req <= 1'b0;
		row[15:8] <= databus;
		row[7:0] <= row[7:0];
		col <= col;
	end else if(data_valid & byte_counter == 3'h1) begin
		byte_counter <= byte_counter + 1;
		spart_w_data[15:8] <= spart_w_data[15:8];
		spart_w_data[7:0] <= databus;
		spart_w_req <= 1'b1;
		row[15:8] <= row[15:8];
		row[7:0] <= databus;
		col <= col;
	end else if(data_valid & byte_counter == 3'h2) begin
		byte_counter <= byte_counter + 1;
		spart_w_data[15:8] <= databus;
		spart_w_data[7:0] <= spart_w_data[7:0];
		spart_w_req <= 1'b0;
		row <= row;
		col[15:8] <= databus;
		col[7:0] <= col[7:0];
	end else if(data_valid & byte_counter == 3'h3) begin
		byte_counter <= byte_counter + 1;
		spart_w_data[15:8] <= spart_w_data[15:8];
		spart_w_data[7:0] <= databus;
		spart_w_req <= 1'b1;
		row <= row;
		col[15:8] <= col[15:8];
		col[7:0] <= databus;
	end else if(data_valid & byte_counter == 3'h4) begin
		// saturate counter at 4
		byte_counter <= byte_counter;
		spart_w_data <= {8'b0, databus};
		spart_w_req <= 1'b1;
		row <= row;
		col <= col;
	end else begin
		byte_counter <= byte_counter;
		spart_w_data <= spart_w_data;
		spart_w_req <= 1'b0;
		row <= row;
		col <= col;
	end
end
	
endmodule