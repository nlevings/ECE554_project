`define DMEM_A_LEN 14
module sdram_controller(
    input            rst_n,
    input            ref_clk,
    output [2:0]     curr_state,
    output [15:0]    smth,

    //// spart section
    input            spart_trxn_req,
    output           spart_trxn_grant,
    output           spart_trxn_busy,

    output           spart_ref_clk,
    input [15:0]     spart_wr_data,
    input            spart_wr_req,
    input [24:0]     spart_start_addr,
    input [24:0]     spart_end_addr,
    input            spart_load_addr,

    //// VGA section
    input            vga_request,
    output           vga_grant,
    output           vga_busy,

    input            vga_ref_clk,
    input [15:0]     vga_w_data,
    input            vga_w_req,
    input [24:0]     vga_start_addr,
    input [24:0]     vga_end_addr,
    input            vga_load_addr,

    // DATA MEM secti
    input            dmem_request,
    output           dmem_grant,
    output           dmem_busy,

    output           dmem_ref_clk,
    output [`DMEM_A_LEN-1:0] dmem_addr_out,
    output     [7:0] dmem_wr_data,
    input      [7:0] dmem_rd_data,
    output           dmem_rden_out,
    output           dmem_wren_out,

    // SDRAM section
    output [15:0]     sdram_rd_data, // from sub-controller
    output reg [15:0] sdram_wr_data,

    output [12:0]     sa,         //SDRAM address output
    output [1:0]      ba,         //SDRAM bank address
    output            cs_n,       //SDRAM Chip Selects
    output            cke,        //SDRAM clock enable
    output            ras_n,      //SDRAM Row address Strobe
    output            cas_n,      //SDRAM Column address Strobe
    output            we_n,       //SDRAM write enable
    inout  [15:0]     dq,         //SDRAM data bus
    output [1:0]      dqm,        //SDRAM data mask lines
    output	      sdr_clk	  //SDRAM clock
);

// pll for on-chip RAM
wire clk_050_pll;
wire clk_100_pll;
//wire locked;
//extern_rw_clk extern_rw_pll(
//        .refclk   (ref_clk),   //  refclk.clk
//		.rst      (!rst_n),      //   reset.reset
//		.outclk_0 (clk_100_pll), // outclk0.clk
//		.outclk_1 (clk_050_pll), // outclk1.clk
//		.locked   (locked)    //  locked.export
//);

//////// CLOCKS /////////////
// ** need to take care of read empty if i want to use this clk
//assign dmem_ref_clk = clk_100_pll;

reg [26:0] beat;
always @ (posedge clk_100_pll)
begin
	beat <= beat + 1'b1;
end
//assign dmem_ref_clk = beat[25];
assign dmem_ref_clk = clk_050_pll;

assign spart_ref_clk = clk_050_pll;

//parameter [7:0]
//   IDLE_ARB
assign spart_trxn_grant = 1'b1;


// read write sdram dmem state machine
parameter [2:0]
    IDLE        = 3'b000,
    WRITE_DMEM  = 3'b001,
    READ_DMEM   = 3'b010,

    WRITE_SDRAM = 3'b011,
    READ_SDRAM  = 3'b100,

    WAIT1       = 3'b101,
    WAIT2       = 3'b110,

    FAIL        = 3'b111;

reg [2:0] state, next_state;
// next state assignment
always@(posedge dmem_ref_clk or negedge rst_n)
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
assign curr_state = state; // to output on LED's

// count register to write address as data
parameter length = 6;
parameter [24:0] start_addr = 25'b0;
parameter [24:0] range =  { {(25-length){1'b0}}, {length {1'b1}}  };// 25'h3FF;

reg [24:0] count;
reg count_en;
reg count_rst;
reg mem_txn_done;
always@(posedge dmem_ref_clk or negedge rst_n)
    if (!rst_n)            count <= 0;
    else if (mem_txn_done || count_rst) count <= 0;
    else                   count <= (count_en && !read_empty) ? count + 1'b1 : count;

reg [24:0] count_spart;
always@(posedge spart_ref_clk or negedge rst_n)
    if (!rst_n)            count_spart <= 0;
    else if (mem_txn_done) count_spart <= 0;
    else                   count_spart <= spart_wr_req ? count_spart + 1'b1 : count_spart;

wire [`DMEM_A_LEN-1:0] dmem_addr;
//assign dmem_addr =  {{(10-length) {1'b0}},count};
assign dmem_addr =  count[`DMEM_A_LEN-1:0];

wire [15:0] wr_data;
//assign wr_data = {{(16-length) {1'b0}},count};
assign wr_data = count[15:0];

wire dmem_to_sdram;
assign dmem_to_sdram = 1'b0;

reg sdram_rden;
reg sdram_wren;
reg dmem_rden;
reg dmem_wren;
always@(*) begin
    next_state = IDLE;

    dmem_wren = 1'b0;
    dmem_rden = 1'b0;

    sdram_rden = 1'b0;
    sdram_wren = 1'b0;

    count_en = 1'b0;
    count_rst = 1'b1;
    mem_txn_done = 1'b1;
    case (state)
        IDLE: begin
                next_state = dmem_to_sdram ? WRITE_DMEM : WRITE_SDRAM;
        end

        WRITE_DMEM: begin
            if (~&count) begin
                next_state = WRITE_DMEM;

                dmem_wren =  1'b1;
                dmem_rden =  1'b0;

                sdram_wren = 1'b0;
                sdram_rden = 1'b0;

                count_en =   1'b1;
                count_rst  = 1'b0;
                mem_txn_done = 1'b0;

            end else begin
                next_state = READ_DMEM;

                dmem_wren =  1'b1;
                dmem_rden =  1'b0;

                sdram_wren = 1'b0;
                sdram_rden = 1'b0;

                count_en =   1'b1;
                count_rst  = 1'b1;
                mem_txn_done = 1'b0;
            end
        end
        READ_DMEM: begin // also write sdram with dmem read data
            //if (~&count) begin
            //if (count != 25'd19) begin
            if (count != (sdram_end_addr_reg - sdram_start_addr_reg )) begin
            //if (count != 25'd4097) begin
                next_state = READ_DMEM;

                dmem_wren =  1'b0;
                dmem_rden =  1'b1;

                if (dmem_to_sdram)
                    sdram_wren = 1'b1;
                else
                    sdram_wren = 1'b0;

                sdram_rden = 1'b0;
                count_en =   1'b1;
                count_rst  = 1'b0;
                mem_txn_done = 1'b0;

            end else begin
               if (dmem_to_sdram)
                   next_state = WAIT1;
               else
                   next_state = WAIT2;

                dmem_wren =  1'b0;
                dmem_rden =  1'b1;

                if (dmem_to_sdram)
                    sdram_wren = 1'b1;
                else
                    sdram_wren = 1'b0;

                sdram_rden = 1'b0;
                count_en =   1'b0;
                count_rst  = 1'b1;
                mem_txn_done = 1'b0;
            end
        end
        WAIT1: begin //wait for last read from DMEM or SDRAM
           if (dmem_to_sdram)
                next_state = READ_SDRAM;
           else
                next_state = READ_DMEM;

                dmem_wren =  1'b0;
                dmem_rden =  1'b0;
                sdram_wren = 1'b0;
                sdram_rden = 1'b0;
                count_en =   1'b0;
                count_rst  = 1'b1;
                mem_txn_done = 1'b0;
        end
        WRITE_SDRAM: begin
            //if (~&count) begin
            //if (~count_spart[length]) begin
	    if (count_spart != (sdram_end_addr_reg - sdram_start_addr_reg + 2'h1)) begin
            //if (count_spart != 25'd4098) begin
                next_state = WRITE_SDRAM;

                dmem_wren =  1'b0;
                dmem_rden =  1'b0;

                sdram_wren = 1'b1;
                sdram_rden = 1'b0;

                //count_en = 1'b1;
                count_rst  = 1'b0;
                mem_txn_done = 1'b0;

            end else begin
                next_state = READ_SDRAM;

                dmem_wren =  1'b0;
                dmem_rden =  1'b0;

                sdram_wren = 1'b1;
                sdram_rden = 1'b0;

                //count_en = 1'b1;
                count_rst  = 1'b1;
                mem_txn_done = 1'b0;
            end
        end
        READ_SDRAM: begin //also writes dmem
            //if (~&count) begin
            //if (count != 25'd20) begin
            if (count != (sdram_end_addr_reg - sdram_start_addr_reg )) begin
            //if (count != 25'd4097) begin
		if(count > 2'h3) begin
		    if ((count_del[15:0] - 2'h3)%9'h100 != sdram_rd_data_reg)
	                next_state = FAIL;
	            else
                        next_state = READ_SDRAM;
        	end else begin
                        next_state = READ_SDRAM;
		end

                if (dmem_to_sdram)
                    dmem_wren =  1'b0;
                else
                    dmem_wren =  1'b1;

                dmem_rden =  1'b0;

                sdram_wren = 1'b0;
                sdram_rden = 1'b1;

                count_en =   1'b1;
                count_rst  = 1'b0;
                mem_txn_done = 1'b0;

            end else begin
                if (dmem_to_sdram)
                    next_state = WAIT2;
                else
                    next_state = WAIT1;

                if (dmem_to_sdram)
                    dmem_wren =  1'b0;
                else
                    dmem_wren =  1'b1;

                dmem_rden =  1'b0;

                sdram_wren = 1'b0;
                sdram_rden = 1'b1;

                count_en =   1'b1;
                count_rst  = 1'b0;
                mem_txn_done = 1'b0;
            end
        end
        WAIT2: begin //wait for last read from DMEM or SDRAM
                next_state = IDLE;
                dmem_wren =  1'b0;
                dmem_rden =  1'b0;
                sdram_wren = 1'b0;
                sdram_rden = 1'b0;
                count_en =   1'b0;
                count_rst  = 1'b1;
                mem_txn_done = 1'b0;
        end
	FAIL: begin
	    next_state = FAIL;
	end
    endcase
end
reg [15:0]sdram_rd_data_reg;
always@(posedge dmem_ref_clk or negedge rst_n)
    if (!rst_n) sdram_rd_data_reg <= 16'h0;
    else sdram_rd_data_reg <= sdram_rd_data;

wire [15:0]trial;
assign trial = count_del[15:0] - 2'h3;
assign smth = {trial[4:0],sdram_rd_data_reg[4:0]}; 
/////START DELAY READ WRITE DATA AND ENABLES TO FROM SDRAM DMEM////////////

// FIFO reads occur one clock after rden goes high, use delayed rden signal
// with normal rd_data to sync rd data w/ rd_en from read side of fifo
reg dmem_wren_del;
reg dmem_rden_del;
reg [`DMEM_A_LEN-1:0] dmem_addr_del;
always@(posedge dmem_ref_clk or negedge rst_n)
    if (~rst_n) begin
        dmem_wren_del <= 1'b0;
        dmem_rden_del <= 1'b0;
        dmem_addr_del <= {`DMEM_A_LEN-1 {1'b0}};
    end else begin
        dmem_wren_del <= dmem_wren;
        dmem_rden_del <= dmem_rden;
        dmem_addr_del <= dmem_addr;
    end

// choice between dmem read data or original write data
assign dmem_wr_data  = dmem_to_sdram ? wr_data[7:0]   : sdram_rd_data[7:0];
assign dmem_addr_out = dmem_to_sdram ? dmem_addr : dmem_addr_del;
assign dmem_wren_out = dmem_to_sdram ? dmem_wren : dmem_wren_del;
assign dmem_rden_out = dmem_to_sdram ? dmem_rden : dmem_rden_del;
//////////////////////////////////////////////////////////////////////
// RAM reads occur one clock after rden goes high, use delayed rden signal with
// normal rd_data to sync rd data w/ rd_en on write side of fifo
reg sdram_wren_del;
always@(posedge dmem_ref_clk or negedge rst_n)
    if (~rst_n) sdram_wren_del <= 1'b0;
    else        sdram_wren_del <= sdram_wren;

//// choice between dmem read data or original write data
wire [15:0] sdram_wr_data_ctrl;
assign sdram_wr_data_ctrl = dmem_to_sdram ? {8'b0,dmem_rd_data} : wr_data;
wire sdram_wren_ctrl;
assign sdram_wren_ctrl = dmem_to_sdram ? sdram_wren_del : sdram_wren;

/////END DELAY READ WRITE DATA AND ENABLES TO FROM SDRAM DMEM////////////
reg [24:0] count_del;
always@(posedge dmem_ref_clk or negedge rst_n)
	if (!rst_n) begin 
		count_del   <= 25'b0;
	end else begin
		count_del   <= count; 
	end	

always@(posedge spart_ref_clk or negedge rst_n)
    if (~rst_n) sdram_wr_data <= 1'b0;
    else if (spart_wr_req)   sdram_wr_data <= spart_wr_data;
    else        sdram_wr_data <= sdram_wr_data;

//assign smth = {sdram_rden,dmem_ref_clk,wr_data[3:0],sdram_rd_data[3:0]};
/////////// START SDRAM START END ADDRESS AND LOAD ENABLE ////////////
wire sdram_do_load_addr;
assign sdram_do_load_addr = 1'b1;

wire [24:0] sdram_start_addr_wire; //to controller
wire [24:0] sdram_end_addr_wire; //to controller  
assign sdram_start_addr_wire = spart_start_addr;
assign sdram_end_addr_wire = spart_end_addr;

reg [24:0] sdram_start_addr_reg; // for count reg
reg [24:0] sdram_end_addr_reg; //for count reg
always @ (posedge spart_ref_clk or negedge rst_n)
    if (!rst_n) begin
        sdram_start_addr_reg <= 25'b0;
        sdram_end_addr_reg <= 25'b0;
    end else if (sdram_do_load_addr) begin
        sdram_start_addr_reg <= sdram_start_addr_wire;
        sdram_end_addr_reg <= sdram_end_addr_wire;
    end else begin
        sdram_start_addr_reg <= sdram_start_addr_reg;
        sdram_end_addr_reg <= sdram_end_addr_reg;
    end
/////////// END SDRAM START END ADDRESS AND LOAD ENABLE ////////////
//assign smth = {sdram_do_load_addr,sdram_end_addr_reg[8:0]}; 
//assign smth = sdram_end_addr_reg[9:0]; 
wire read_empty;
wire write_full;
wire [8:0] rd_use;
wire [8:0] wr_use;
//assign smth = {write_full,read_empty,count[7:0]}; 
//assign smth = rd_use; 
Sdram_Control sub_controller (
	//	HOST Side
	.REF_CLK     (ref_clk),
	.RESET_N     (rst_n),
	.CLK_50      (clk_050_pll),
	.CLK_100     (clk_100_pll),
    //	FIFO Write Side
	.WR_DATA     (spart_wr_data), //(sdram_wr_data_ctrl),
	.WR          (spart_wr_req), //(sdram_wren_ctrl),
	.WR_ADDR     (sdram_start_addr_wire), //(start_addr),
	.WR_MAX_ADDR (25'h1ffffff), //(sdram_end_addr_wire+2'd2), //(start_addr + range),
	.WR_LENGTH   (9'd02),
	.WR_LOAD     (!rst_n), //(sdram_do_load_addr),
	.WR_CLK      (spart_ref_clk), //(dmem_ref_clk),
        .WR_FULL     (write_full),
        .WR_USE      (wr_use),
		//	FIFO Read Side
        .RD_DATA     (sdram_rd_data),
   	.RD          (sdram_rden),
	.RD_ADDR     (sdram_start_addr_wire), //(start_addr),
	.RD_MAX_ADDR (25'h1ffffff), //(sdram_end_addr_wire+2'd2), //(start_addr + range), // 33554431
	.RD_LENGTH   (9'd02),
	.RD_LOAD     (!rst_n), //(sdram_do_load_addr),
	.RD_CLK      (dmem_ref_clk),
        .RD_EMPTY    (read_empty),
        .RD_USE      (rd_use),
        //	SDRAM Side
        .SA          (sa),
        .BA          (ba),
        .CS_N        (cs_n),
        .CKE         (cke),
        .RAS_N       (ras_n),
        .CAS_N       (cas_n),
        .WE_N        (we_n),
        .DQ          (dq),
        .DQM         (dqm),
        .SDR_CLK     (sdr_clk)
);

endmodule
