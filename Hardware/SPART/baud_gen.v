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
// Description: baud rate generator
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module baud_gen (clk ,rst, iocs, db_data, io_addr, shift);
	input clk, rst, iocs;
	input [7:0] db_data;
	input [1:0] io_addr;

	output shift;
	wire   enable;	

	// baud rate gen	
	reg [15:0] baud_cnt; 
	reg [15:0] load_val;
	reg [4:0]  enb_cnt;
	
	// sync. load db_high/low data
	always @ (posedge clk or negedge rst)
		if (~rst) begin
		   load_val <= 16'h028A;
		end
		
		else if (io_addr == 2'b10) begin
			load_val[15:8] <= load_val[15:8];
			load_val[7:0] <= db_data;
		end
		
		else if (io_addr == 2'b11) begin
			load_val[15:8] <= db_data;
			load_val[7:0] <= load_val[7:0];
		end
		
		else begin
			load_val <= load_val;		
		end		

	//baud counter
	always@(posedge clk or negedge rst)begin
		if (!rst) begin
			baud_cnt <= 16'hF;
		end
		
		else if(iocs || baud_cnt == 16'h0) begin
			baud_cnt <= load_val;			
		end
				
		else begin
			baud_cnt <= baud_cnt - 1'b1;			
		end
	end
	assign enable = ~(|baud_cnt); // zero decoder
	
	// counts enables from baud counter
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			enb_cnt <= 4'h0;
		end	
				
		else if (iocs || (enb_cnt == 4'hF && baud_cnt == 16'h0)) begin
			enb_cnt <= 4'h0;			
		end
		
		else if (enable) begin
			enb_cnt <= enb_cnt + 1'b1;			
		end
		
		else begin
			enb_cnt <= enb_cnt;
		end
	end		
	assign shift = (enb_cnt == 8 && enable) ? 1'b1 : 1'b0; // samples data in the middle (8th enable)	
		
endmodule