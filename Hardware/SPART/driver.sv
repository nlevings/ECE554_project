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
// Description: driver for spart, contains state machine 
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input            clk,
    input            rst,
    output reg       iocs,
    output reg       iorw,
    input            rda,
    input            tbr,
    output reg [1:0] ioaddr,
    inout [7:0]      databus,
	output reg		 data_valid,
	output reg [7:0] read_data,  // data from an RX transaction
    input            send_start,
	output reg       sent_start_flag
	);

reg [7:0]   write_data; // data to write on databus (baud rate config/RX data)

reg [15:0]  div_reg_load_val;


typedef enum reg[2:0]{IDLE, BAUD_LOW, BAUD_HIGH, TX, RX_POLL, RX_REC, TRANS} state_t;
  state_t state, nxt_state;

//assign div_reg_load_val = 15'h028A;				// 4800 baud
//assign div_reg_load_val = 15'h0145;				// 9600 baud
//assign div_reg_load_val = 15'h00A2;				// 19200 baud
//assign div_reg_load_val = 15'h0050;				// 38400 baud
//assign div_reg_load_val = 15'h0035;				// 57600 baud
assign div_reg_load_val = 15'h001A;				// 115200 baud
  
//databus value based on switch inputs
always_comb begin
	if(ioaddr == 2'b10 && ~iorw)
		write_data = div_reg_load_val[7:0];
	else if(ioaddr == 2'b11 && ~iorw)
	    write_data = div_reg_load_val[15:8];
	else
		//write_data = read_data;
		write_data = 8'h45; // response to indicate RX of row and col
 end

 //set the databus on valid recieved data 
 always_ff @ (posedge clk) begin
	if(rda)
		read_data <= databus;
	else
		read_data <= read_data;
	end

 //state machine flip flop
always_ff@(posedge clk, negedge rst)begin
    if(!rst)
      state <= IDLE;
    else
      state <= nxt_state;
end

reg sent_start; //from state machine

always@(*)
    if (!rst)
	    sent_start_flag = 1'b0;
	else if (sent_start)	
        sent_start_flag = 1'b1;
	else
        sent_start_flag = sent_start_flag;	
		
// iorw: 1 = r; 0 = w;
assign databus = iorw ? 8'bz : write_data;

// state machine: moore outputs ioaddr, iocs, iorw
always_comb begin
	ioaddr    = 2'b00;
	iorw      = 1'b0;
	iocs      = 1'b0;	
	data_valid = 1'b0;
	sent_start = 1'b0;
	nxt_state = IDLE;

	case(state)
		IDLE :
        begin
		    ioaddr      = 2'b00;
	        iocs        = 1'b0;
	        iorw        = 1'b0;			
			nxt_state   = BAUD_LOW;
		end

		BAUD_LOW :
		begin
		    ioaddr      = 2'b10;
		    iorw        = 1'b0;
			iocs        = 1'b0;			
            nxt_state   = BAUD_HIGH;
		end

		BAUD_HIGH :
		begin
		    ioaddr      = 2'b11;
		    iorw        = 1'b0;
			iocs        = 1'b0;			
            nxt_state   = RX_POLL;
		end

		RX_POLL : 
		if (!sent_start_flag && send_start) begin
		    ioaddr      = 2'b00;
		    iorw        = 1'b0;
			iocs        = 1'b1;	
			nxt_state   = TX;			    	
		end
		else 
		if(~rda) begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b0;			
			nxt_state	= RX_REC;
		end
		else begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b1;
            nxt_state   = RX_POLL;				
		end
			
		RX_REC : if(rda) begin
			ioaddr		= 2'b00;
			iorw        = 1'b1;
			iocs        = 1'b0;			
			nxt_state	= TRANS;
		end

		else begin
		    ioaddr      = 2'b00;
		    iorw        = 1'b1;
			iocs        = 1'b0;
            nxt_state   = RX_REC;
		end
		
		TRANS:
		begin
		    ioaddr      = 2'b00;
		    iorw        = 1'b1;
			iocs        = 1'b1;			
            data_valid 	= 1'b1;
			nxt_state	= RX_POLL;
			//nxt_state	= TX;
		end

		TX : if(tbr) begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b1;
			sent_start  = 1'b1;
			nxt_state	= RX_POLL;
		end

		else begin
			ioaddr		= 2'b00;
			iorw 		= 1'b0;
			iocs		= 1'b0;
			nxt_state	= TX;
		end

		default : nxt_state = IDLE;
	endcase
end

endmodule
