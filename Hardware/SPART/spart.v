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
module spart (
    // connected in top level
    input             rst, // actually an active low reset
    input             rxd, // from PC
    output            txd, // to PC
	// to sdram controller
	output reg        spart_trxn_req,
    input             spart_trxn_grant,
	input             spart_trxn_busy,
	
	input             spart_ref_clk,
    output reg [15:0] spart_wr_data,
    output reg        spart_wr_req,
    output     [24:0] spart_start_addr,
    output     [24:0] spart_trxn_length     	   
);

wire [7:0] rx_data;
wire [7:0] databus;
wire shift;
wire iocs;
wire iorw;
wire rda;
wire tbr;
wire [1:0] ioaddr;
wire data_valid;
wire [7:0] read_data;
wire sent_start;
wire send_start;
reg [2:0] byte_counter;
reg [15:0] row, col;


// latch grant since input will not stay high
reg spart_trxn_grant_internal;
always@(*)
    if(!rst)
        spart_trxn_grant_internal = 1'b0;
    else if (spart_trxn_grant)
        spart_trxn_grant_internal = 1'b1;
    else
        spart_trxn_grant_internal = spart_trxn_grant_internal;

assign send_start = byte_counter == 3'h7 && spart_trxn_grant_internal;		
//always@(posedge spart_ref_clk or negedge rst)
//begin
//    if(!rst)
//        spart_trxn_req <= 1'b0;
//    else if (byte_counter == 3'h7 && !spart_trxn_grant_internal)
//        spart_trxn_req <= 1'b1;
//    else if (spart_trxn_grant_internal)
//        spart_trxn_req <= 1'b0;
//    else 
//        spart_trxn_req <= spart_trxn_req;
//end

// SPART
assign databus = iorw ? rx_data : 8'bz; //tri-state databus

baud_gen baud_gen (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .db_data(databus), .io_addr(ioaddr), .shift(shift));

spart_tx spart_tx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .tx_data(databus),
    .io_addr(ioaddr), .enb(shift), .tbr(tbr), .txd(txd));

spart_rx spart_rx (.clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rx_data(rx_data),
    .io_addr(ioaddr), .enb(shift), .rda(rda), .rxd(rxd));

driver driver( .clk(spart_ref_clk), .rst(rst), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr),
    .ioaddr(ioaddr), .databus(databus),.data_valid(data_valid), .read_data(read_data), .send_start(send_start), .sent_start_flag(sent_start));

parameter start_addr = 25'h0;
assign spart_start_addr = start_addr;
assign spart_trxn_length = 2'h2 + row*col-1'b1;

// more or less a state machine to capture row and col to calc end address
// then sits in state waiting to transmit picture data
// First two transmissions (row and col) use both bytes of output, rest use only one byte
// fist get row and col in 4 rx's, calc space needed, request all data after
// (including row and col as first two)
always@(posedge spart_ref_clk, negedge rst) begin
    if(!rst) begin
        byte_counter <= 3'b0;        
		spart_trxn_req <= 1'b0;
		
        spart_wr_data <= 16'h0;
        spart_wr_req <= 1'b0;

        row <= 16'b0;
        col <= 16'b0;
	// row upper
    end else if(data_valid & byte_counter == 3'h0) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row[15:8] <= read_data;
        row[7:0] <= row[7:0];

        col <= col;
	// row lower
    end else if(data_valid & byte_counter == 3'h1) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row[15:8] <= row[15:8];
        row[7:0] <= read_data;

        col <= col;
	// col upper
    end else if(data_valid & byte_counter == 3'h2) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row <= row;

        col[15:8] <= read_data;
        col[7:0] <= col[7:0];
	// col lower
    end else if(data_valid & byte_counter == 3'h3) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row <= row;

        col[15:8] <= col[15:8];
        col[7:0] <= read_data;
	// have demnsions, send wrie request to sdram controller
    end else if(byte_counter == 3'h4) begin
		if (!spart_trxn_grant)
            byte_counter <= byte_counter;		
		else
		    byte_counter <= byte_counter + 1'b1;
        		
		spart_trxn_req <= 1'b1;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row <= row;
        col <= col;
        // write row dimensions 
    end else if(byte_counter == 3'h5) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= row;
        spart_wr_req <= 1'b1;

        row <= row;
        col <= col;
        // write col dimensions
    end else if(byte_counter == 3'h6) begin
        byte_counter <= byte_counter + 1'b1;        
		spart_trxn_req <= 1'b0;

        spart_wr_data <= col;
        spart_wr_req <= 1'b1;

        row <= row;
        col <= col;
	// write everything in MIF file to SDRAM
    end else if(data_valid && byte_counter == 3'h7 && sent_start) begin
        // saturate counter at 7
        byte_counter <= byte_counter;       
		spart_trxn_req <= 1'b0;

        spart_wr_data <= {8'b0, read_data};
        spart_wr_req <= 1'b1;

        row <= row;
        col <= col;
    end else begin
        byte_counter <= byte_counter;       
		spart_trxn_req <= 1'b0;

        spart_wr_data <= spart_wr_data;
        spart_wr_req <= 1'b0;

        row <= row;
        col <= col;
    end
end

endmodule
