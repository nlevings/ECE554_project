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
// Description: spart testbench
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module spart_tb (clk, key, sw,GPIO);

output reg clk;
output reg [3:0] key;
output reg [9:0] sw;

inout [35:0] GPIO;

lab1_spart lab1_spart(.CLOCK_50(clk), .KEY(key), .SW(sw), .GPIO(GPIO));

reg txd; //transmit data (to serial)
wire rxd; //receive data (to serial)

// GPIO[3] as RX output, GPIO[5] as TX input
assign GPIO[5] = txd ;
assign rxd = GPIO[3];

always
    #10 clk = ~clk;
	
initial begin

clk = 1'b0;
key = 4'b1110; // reset assert
sw = {1'b0,1'b1,8'h0}; // set switches
txd = 1'b1;

repeat (20) @ (posedge clk);
@ (negedge clk) key = 4'b1111; // reset de-assert

// image is

// sending 0x31
repeat (5) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;
repeat (5027) @ (posedge clk);
txd = 1'b1;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;
// sending 0x24
repeat (5) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b0;
repeat (5027) @ (posedge clk);
txd = 1'b1;


end
endmodule	