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
	input			send_start_end,	// if asserted, the first 8 bytes will be start/stop addresses	
	input       	rxd,			// Read from GPIO[5]
    output      	txd,			// for testing use (send back to PC). Assign to GPIO[3]
	output [15:0]	spart_w_data,
	output 			spart_w_req,
	output reg [24:0]	spart_start_addr,
	output reg [24:0]	spart_end_addr,
	output			spart_address_valid		// Asserts when start and end addresses are valid
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
wire data_valid;

reg [3:0] byte_counter;
reg [24:0] nxt_start, nxt_end;
reg [3:0] ascii_to_hex;	// Converts a hexadecimal character's ascii value to the hexadecimal value

assign spart_w_req = data_valid & (byte_counter >= 4'hE | ~send_start_end);
assign spart_w_data = (send_start_end & byte_counter < 4'hE) ? 16'bZ : (spart_w_req) ? {8'b0, databus} : 16'bZ;

assign spart_address_valid = (~send_start_end) ? 1'b1 : (byte_counter >= 4'hE) ? 1'b1 : 1'b0;

assign databus = iorw ? rx_data_w : 8'bz; //tri-state databus
     
baud_gen baud_gen (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .db_data(databus), .io_addr(ioaddr), .shift(shift)); 	

spart_tx spart_tx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .tx_data(databus), 
	.io_addr(ioaddr), .enb(shift), .tbr(tbr), .txd(txd));

spart_rx spart_rx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rx_data(rx_data_w),
	.io_addr(ioaddr), .enb(shift), .rda(rda), .rxd(rxd));

driver driver( .clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr),
	.ioaddr(ioaddr), .databus(databus),.data_valid(data_valid));

// Start and end address sent over SPART
always@(posedge spart_ref_clk, negedge rst) begin
	if(!rst) begin
		byte_counter <= 4'b0;
		spart_start_addr <= start_addr;
		spart_end_addr <= end_addr;
	end else if(send_start_end & data_valid & byte_counter < 4'hE) begin
		byte_counter <= byte_counter + 1;
		spart_start_addr <= nxt_start;
		spart_end_addr <= nxt_end;
	end else begin
		byte_counter <= byte_counter;
		spart_start_addr <= spart_start_addr;
		spart_end_addr <= spart_end_addr;
	end
end

always@(*) begin
	// defaults
	nxt_start = spart_start_addr;
	nxt_end = spart_end_addr;
	case(byte_counter)
	4'h0:	
		nxt_start[24] = ascii_to_hex[0];
	4'h1:
		nxt_start[23:20] = ascii_to_hex;
	4'h2:
		nxt_start[19:16] = ascii_to_hex;
	4'h3:
		nxt_start[15:12] = ascii_to_hex;
	4'h4:
		nxt_start[11:8] = ascii_to_hex;
	4'h5:
		nxt_start[7:4] = ascii_to_hex;
	4'h6:
		nxt_start[3:0] = ascii_to_hex;
	4'h7:	
		nxt_end[24] = ascii_to_hex[0];
	4'h8:
		nxt_end[23:20] = ascii_to_hex;
	4'h9:
		nxt_end[19:16] = ascii_to_hex;
	4'hA:
		nxt_end[15:12] = ascii_to_hex;
	4'hB:
		nxt_end[11:8] = ascii_to_hex;
	4'hC:
		nxt_end[7:4] = ascii_to_hex;
	4'hD:
		nxt_end[3:0] = ascii_to_hex;	
	default:
	begin
		nxt_start = spart_start_addr;
		nxt_end = spart_end_addr;
	end
	endcase

end

// ascii to hex
always@(*) begin
	casex(databus)
	8'h30:
		ascii_to_hex = 4'h0;
	8'h31:
		ascii_to_hex = 4'h1;
	8'h32:
		ascii_to_hex = 4'h2;
	8'h33:
		ascii_to_hex = 4'h3;
	8'h34:
		ascii_to_hex = 4'h4;
	8'h35:
		ascii_to_hex = 4'h5;
	8'h36:
		ascii_to_hex = 4'h6;
	8'h37:
		ascii_to_hex = 4'h7;
	8'h38:
		ascii_to_hex = 4'h8;
	8'h39:
		ascii_to_hex = 4'h9;
	8'hX1:
		ascii_to_hex = 4'hA;
	8'hX2:
		ascii_to_hex = 4'hB;
	8'hX3:
		ascii_to_hex = 4'hC;
	8'hX4:
		ascii_to_hex = 4'hD;
	8'hX5:
		ascii_to_hex = 4'hE;
	8'hX6:
		ascii_to_hex = 4'hF;
	default:
		ascii_to_hex = 4'h0;
	endcase
end

endmodule