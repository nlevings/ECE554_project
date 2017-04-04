//////////////////////////////////////////////////////////////////////////////////
// Company: UW Madison - ECE 554
// Engineer: Nick Levings, Cody Schnabel
//
// Create Date: January 30th 2017
// Design Name: SPART 
// Module Name:  driver
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
    input [1:0]      br_cfg,
    output reg       iocs,
    output reg       iorw,
    input            rda,
    input            tbr,
    output reg [1:0] ioaddr,
    inout [7:0]      databus
    );

reg [7:0]   write_data; // data to write on databus (baud rate config/RX data)
reg [7:0]   read_data;  // data from an RX transaction (recieved from Putty)
reg [15:0]  div_reg_load_val;  //data used to store the baud rate value of switches 

//definition of state machine states
typedef enum reg[2:0]{IDLE, BAUD_LOW, BAUD_HIGH, TX, RX_POLL, RX_REC, TRANS} state_t;
  state_t state, nxt_state;

 //logic block to set div_reg_load_val value based on switches
always_comb begin
    if(br_cfg == 2'b00)begin
		div_reg_load_val = 15'h028A;
	end
	else if(br_cfg == 2'b01)begin
	    div_reg_load_val = 15'h0145;
	end
	else if(br_cfg == 2'b10)begin
	    div_reg_load_val = 15'h00A2;
	end
	else begin
	    div_reg_load_val = 15'h0050;
	end
end
  
//logic block to set databus value based on ioaddr. ioaddr determines 
//if databus gets data from div_reg_load_val or read_data.
always_comb begin
	if(ioaddr == 2'b10 && ~iorw)
		write_data = div_reg_load_val[7:0];
	else if(ioaddr == 2'b11 && ~iorw)
	    write_data = div_reg_load_val[15:8];
	else
		write_data = read_data;
 end

 //flip-flop to set the read_data reg when valid data is on the databus 
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

//assign statement to set databus for write condition (iorw == 0);
assign databus = iorw ? 8'bz : write_data;

//state machine: moore outputs ioaddr, iocs, iorw
always_comb begin
	ioaddr    = 2'b00;
	iorw      = 1'b0;
	iocs      = 1'b0;	
	nxt_state = IDLE;

	case(state)
	    //IDLE for one cycle after reset is asserted 
		IDLE :
        begin
		    ioaddr      = 2'b00;
	        iocs        = 1'b0;
	        iorw        = 1'b0;			
			nxt_state   = BAUD_LOW;
		end
		//state to set baud counter(LOW)
		BAUD_LOW :
		begin
		    ioaddr      = 2'b10;
		    iorw        = 1'b0;
			iocs        = 1'b0;			
            nxt_state   = BAUD_HIGH;
		end
		//state to set baud counter(HIGH) 
		BAUD_HIGH :
		begin
		    ioaddr      = 2'b11;
		    iorw        = 1'b0;
			iocs        = 1'b0;			
            nxt_state   = RX_POLL;
		end
		//Hold state while waiting for start bit
		RX_POLL : if(~rda) begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b0;			
			nxt_state	= RX_REC;
		end
		else begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b1;			
			nxt_state	= RX_POLL;
		end
		//state for recieving data from Putty
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
		//Hold state for one cycle to update databus path from recieving
		//to sending.
		TRANS:
		begin
		    ioaddr      = 2'b00;
		    iorw        = 1'b0;
			iocs        = 1'b1;			
            nxt_state   = TX;
		end
		//state for sending data to Putty
		TX : if(tbr) begin
			ioaddr		= 2'b00;
			iorw 		= 1'b1;
			iocs		= 1'b1;
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
