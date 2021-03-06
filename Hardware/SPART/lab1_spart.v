//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date:
// Design Name: 
// Module Name:    lab1_spart
// Project Name: spart
// Target Devices: Cyclone V
// Tool versions: Quartus Prime 
// Description: top level spart wrapper for spart and driver 
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module lab1_spart(

 //////////// CLOCK //////////
    input               CLOCK_50,
    //input               CLOCK2_50,
    //input               CLOCK3_50,
    //input               CLOCK4_50,

 //////////// SEG7 //////////
    output reg   [6:0]  HEX0,
    output reg   [6:0]  HEX1,
    output reg   [6:0]  HEX2,
    output reg   [6:0]  HEX3,
    output reg   [6:0]  HEX4,
    output reg   [6:0]  HEX5,

//////////// KEY //////////
    input        [3:0]  KEY,

 //////////// LED //////////
    output reg	   [9:0]		LEDR,

 //////////// SW //////////
    input        [9:0]  SW,

 //////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
    inout       [35:0]  GPIO
);



wire txd; //transmit data (to serial)
wire rxd; //receive data (to serial)

wire [15:0]	spart_w_data;
wire 		spart_w_req;
wire [24:0]	spart_start_addr;
wire [24:0]	spart_end_addr;
wire spart_address_valid;

// press button[0] to generate a low active reset signal
wire rst = KEY[0];

// GPIO[3] as TX output, GPIO[5] as RX input
assign GPIO[3] = txd;
assign rxd = GPIO[5];

// Instantiate your spart here
spart spart0(   .spart_ref_clk(CLOCK_50),
                .rst(rst),
                .txd(txd),
                .rxd(rxd),
				.spart_wr_data(spart_w_data),
				.spart_wr_req(spart_w_req),
				.spart_start_addr(spart_start_addr),
				.spart_end_addr(spart_end_addr),
				.spart_address_valid(spart_address_valid),
				.spart_trxn_grant(1'b1)
            );
	


// To test if spart_w_req is valid when spart_w_req is asserted
always@(*) begin
	if(spart_w_req) begin
		LEDR [7:0] = spart_w_data[7:0];
	end else begin
		LEDR [7:0] = LEDR [7:0];
	end
	
end

// To test if start_addr and end_addr work
always@(*) begin
	if(spart_start_addr == 25'h0123456)
		LEDR[9] = 1;
	else
		LEDR[9] = 0;
	if(spart_end_addr == 25'h1ABCDEF)
		LEDR[8] = 1;
	else
		LEDR[8] = 0;
end
		
endmodule