//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date: January 30th 2017
// Design Name: SPART 
// Module Name:    spart_tb
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

module spart_tb (clk, key, sw, GPIO);

output reg clk;
output reg [3:0] key;
output reg [9:0] sw;

inout [35:0] GPIO;

//Instantiate the lab1_spart
lab1_spart lab1_spart(.CLOCK_50(clk), .KEY(key), .SW(sw), .GPIO(GPIO));

reg txd; //transmit data (to serial from Putty)
wire rxd; //receive data (to Putty from device)

//GPIO[5] as TX input from Putty
assign GPIO[5] = txd ;
//GPIO[3] as RX output to Putty 
assign rxd = GPIO[3];

//generate the clk
always
    #10 clk = ~clk;
	
initial begin

clk = 1'b0;  //set clk start value
key = 4'b1110; // reset assert
sw = {1'b0,1'b1,8'h0}; // set switches
txd = 1'b1;  //set hold condition 

//check that reset works as expected
repeat (20) @ (posedge clk);
@ (negedge clk) key = 4'b1111; // reset de-assert

//sending 0x31 with baud rate 9600
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

end
endmodule	