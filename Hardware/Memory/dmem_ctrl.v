module dmem_ctrl(

input rst_n,
input ref_clk,

input granted,
input [24:0] sdram_addr,
input [15:0] row_length, // must be heald ocnstant throughout oporatiob****
input busy, //transaction in flight from SDRAM controller to Data Memory

// sdram controller
output reg request,
output reg [24:0] start_addr,
output [24:0] length,

//matrix memory
output [9:0] matrix_addr,
output matrix_wr_en,

// data memory
output [15:0] dmc_addr,

// cpu
output reg stall,

output d_sb // choose the input for data memory (from data mem controller is 1, from SDRAM controller is 0)
);
parameter dmem_size = 16'd1024;

reg state, nxt_state;

wire [15:0] num_rows;	
assign num_rows = dmem_size / row_length;

// updating end address of current chunck
reg [24:0] curr_address;
always @ (posedge ref_clk or negedge rst_n)
    if (!rst_n) curr_address <= 25'b0;
	else if (granted) curr_address <= start_addr;
	else curr_address <= curr_address;
	
assign length = num_rows*row_length;

// calculating new sdram address based on input from CPU
//		also requests new sdram data if needed	
always @ (*) begin
    if (sdram_addr >= curr_address + num_rows*row_length && sdram_addr < 12'h800) begin 
		request = 1'b1;
		start_addr =  sdram_addr-row_length;
	end else if(sdram_addr < curr_address ) begin
		request = 1'b1;
		start_addr =  sdram_addr;
	end else begin
		request = 1'b0;
		start_addr = curr_address;
	end
end
// matrix mem calculations
assign matrix_addr = sdram_addr - 12'h800;
assign matrix_wr_en = sdram_addr >= 12'h800;
/*
always@(posedge ref_clk or negedge rst_n)begin
	if(!rst_n) matrix_wr_en <= 0;
	else if(sdram_addr >= 12'h800) matrix_wr_en <= 1;
	else matrix_wr_en <= 0;
end
*/

// translating sdram address to dmc address
assign dmc_addr = sdram_addr - curr_address;
assign d_sb = busy;



// Stall logic
always@(posedge ref_clk, negedge rst_n) begin
	if(!rst_n)
		state <= 1'b0;
	else
		state <= nxt_state;
end

always@(*) begin
	case(state)
	1'b0: begin
		if(request) begin
			nxt_state = 1'b1;
			stall = 1'b1;
		end else begin
			nxt_state = 1'b0;
			stall = 1'b0;
		end
	end
	1'b1: begin
		stall = 1;
		if(granted) begin
			nxt_state = 1'b0;
			stall = 1'b0;
		end
		else begin
			nxt_state = 1'b1;
			stall = 1'b1;
		end
	end
	endcase
end

endmodule