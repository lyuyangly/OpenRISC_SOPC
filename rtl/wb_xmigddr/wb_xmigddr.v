//***************************************************************************
//   Copyright(c)2016, Lyu Yang
//   All rights reserved
//
//   File name        :   wb_xmigddr.v
//   Module name      :   
//   Author           :   Lyu Yang
//   Email            :   lyuyangly@qq.com
//   Date             :   2016-12-12
//   Version          :   v1.0
//
//   Abstract         :   DDR Chip Clock Source is 50MHz.
//
//   Modification history
//   ------------------------------------------------------------------------
// Version       Data(yyyy/mm/dd)   name
// Description
//
// $Log$
//***************************************************************************
`timescale 1ns / 100ps
module wb_xmigddr (
    input           								wb_clk_i,
    input           								wb_rst_i,

    // Wishbone Interface
    input           								wb_cyc_i,
    input           								wb_stb_i,
    input           								wb_we_i,
    input [3:0]     								wb_sel_i,
    input [31:0]    								wb_adr_i,
    input [31:0]    								wb_dat_i,
    output [31:0]   								wb_dat_o,
    output											wb_ack_o,
	
	// DDR Chip Signals
	output											mcb3_dram_ck,
	output											mcb3_dram_ck_n,
	inout  [15:0]									mcb3_dram_dq,
	output [12:0]									mcb3_dram_a,
	output [2:0]									mcb3_dram_ba,
	output											mcb3_dram_ras_n,
	output											mcb3_dram_cas_n,
	output											mcb3_dram_we_n,
	output											mcb3_dram_odt,
	output											mcb3_dram_cke,
	output											mcb3_dram_dm,
	inout											mcb3_dram_udqs,
	inout											mcb3_dram_udqs_n,
	output											mcb3_dram_udm,
	inout											mcb3_dram_dqs,
	inout											mcb3_dram_dqs_n,
	inout											mcb3_rzq,
	inout											mcb3_zio
);

// DDR DRAM Calib Done
wire				c3_calib_done;
// BIU Signals
wire				c3_px_cmd_en;
wire	[2:0]		c3_px_cmd_instr;
wire	[29:0]		c3_px_cmd_byte_addr;
wire				c3_px_cmd_full;
wire				c3_px_wr_en;
wire				c3_px_wr_empty;
wire				c3_px_rd_en;
wire				c3_px_rd_empty;


// Read, Write and Ack Signals
wire				wb_req;
reg					wb_req_r, wb_ack_write, wb_ack_read;

assign wb_req = wb_stb_i & wb_cyc_i & c3_calib_done; 

always @(posedge wb_clk_i)
	wb_req_r <= wb_req & !wb_ack_o;

assign wb_req_new  = wb_req & !wb_req_r;

// Write and Read Ack Signal
always @(posedge wb_clk_i)
	wb_ack_write <= wb_req & wb_we_i & !wb_ack_write & !c3_px_cmd_full;

always @(posedge wb_clk_i)
	wb_ack_read <= wb_req & !wb_we_i & !wb_ack_read & !c3_px_rd_empty;


assign wb_ack_o = (wb_we_i ? wb_ack_write : wb_ack_read) & wb_stb_i;
assign c3_px_cmd_instr = {2'b00, ~wb_we_i};
assign c3_px_cmd_byte_addr = {wb_adr_i[29:2], 2'b00};
assign c3_px_wr_en = (wb_stb_i & wb_cyc_i & wb_we_i) ? wb_req_new : 1'b0;
assign c3_px_rd_en = (wb_stb_i & wb_cyc_i & !wb_we_i) ? wb_ack_read : 1'b0;
assign c3_px_cmd_en = (wb_stb_i & wb_cyc_i & wb_we_i) ? wb_ack_write : wb_req_new & !wb_we_i;


// Xilinx Spartan6 MIG
mig_spartan6 memc_ddr
(
	// controller clock and reset
	.c3_sys_clk					(wb_clk_i),
	.c3_sys_rst_i				(wb_rst_i),
	
	// user insterface signals
	.c3_p0_cmd_clk				(wb_clk_i),
	.c3_p0_cmd_en				(c3_px_cmd_en),
	.c3_p0_cmd_instr			(c3_px_cmd_instr),
	.c3_p0_cmd_bl				('d0),
	.c3_p0_cmd_byte_addr		(c3_px_cmd_byte_addr),
	.c3_p0_cmd_empty			(),
	.c3_p0_cmd_full				(c3_px_cmd_full),
	.c3_p0_wr_clk				(wb_clk_i),
	.c3_p0_wr_en				(c3_px_wr_en),
	.c3_p0_wr_mask				(~wb_sel_i),
	.c3_p0_wr_data				(wb_dat_i),
	.c3_p0_wr_full				(),
	.c3_p0_wr_empty				(c3_px_wr_empty),
	.c3_p0_wr_count				(),
	.c3_p0_wr_underrun			(),
	.c3_p0_wr_error				(),
	.c3_p0_rd_clk				(wb_clk_i),
	.c3_p0_rd_en				(c3_px_rd_en),
	.c3_p0_rd_data				(wb_dat_o),
	.c3_p0_rd_full				(),
	.c3_p0_rd_empty				(c3_px_rd_empty),
	.c3_p0_rd_count				(),
	.c3_p0_rd_overflow			(),
	.c3_p0_rd_error				(),
	// port1
	.c3_p1_cmd_clk				(),
	.c3_p1_cmd_en				(1'b0),
	.c3_p1_cmd_instr			(),
	.c3_p1_cmd_bl				(),
	.c3_p1_cmd_byte_addr		(),
	.c3_p1_cmd_empty			(),
	.c3_p1_cmd_full				(),
	.c3_p1_wr_clk				(),
	.c3_p1_wr_en				(1'b0),
	.c3_p1_wr_mask				(),
	.c3_p1_wr_data				(),
	.c3_p1_wr_full				(),
	.c3_p1_wr_empty				(),
	.c3_p1_wr_count				(),
	.c3_p1_wr_underrun			(),
	.c3_p1_wr_error				(),
	.c3_p1_rd_clk				(),
	.c3_p1_rd_en				(1'b0),
	.c3_p1_rd_data				(),
	.c3_p1_rd_full				(),
	.c3_p1_rd_empty				(),
	.c3_p1_rd_count				(),
	.c3_p1_rd_overflow			(),
	.c3_p1_rd_error				(),
	// port2
	.c3_p2_cmd_clk				(),
	.c3_p2_cmd_en				(1'b0),
	.c3_p2_cmd_instr			(),
	.c3_p2_cmd_bl				(),
	.c3_p2_cmd_byte_addr		(),
	.c3_p2_cmd_empty			(),
	.c3_p2_cmd_full				(),
	.c3_p2_wr_clk				(),
	.c3_p2_wr_en				(1'b0),
	.c3_p2_wr_mask				(),
	.c3_p2_wr_data				(),
	.c3_p2_wr_full				(),
	.c3_p2_wr_empty				(),
	.c3_p2_wr_count				(),
	.c3_p2_wr_underrun			(),
	.c3_p2_wr_error				(),
	.c3_p2_rd_clk				(),
	.c3_p2_rd_en				(1'b0),
	.c3_p2_rd_data				(),
	.c3_p2_rd_full				(),
	.c3_p2_rd_empty				(),
	.c3_p2_rd_count				(),
	.c3_p2_rd_overflow			(),
	.c3_p2_rd_error				(),
	// port3
	.c3_p3_cmd_clk				(),
	.c3_p3_cmd_en				(1'b0),
	.c3_p3_cmd_instr			(),
	.c3_p3_cmd_bl				(),
	.c3_p3_cmd_byte_addr		(),
	.c3_p3_cmd_empty			(),
	.c3_p3_cmd_full				(),
	.c3_p3_wr_clk				(),
	.c3_p3_wr_en				(1'b0),
	.c3_p3_wr_mask				(),
	.c3_p3_wr_data				(),
	.c3_p3_wr_full				(),
	.c3_p3_wr_empty				(),
	.c3_p3_wr_count				(),
	.c3_p3_wr_underrun			(),
	.c3_p3_wr_error				(),
	.c3_p3_rd_clk				(),
	.c3_p3_rd_en				(1'b0),
	.c3_p3_rd_data				(),
	.c3_p3_rd_full				(),
	.c3_p3_rd_empty				(),
	.c3_p3_rd_count				(),
	.c3_p3_rd_overflow			(),
	.c3_p3_rd_error				(),
   
	// ddr2 chip signals
	.mcb3_dram_dq				(mcb3_dram_dq),
	.mcb3_dram_a				(mcb3_dram_a),
	.mcb3_dram_ba				(mcb3_dram_ba),
	.mcb3_dram_ras_n			(mcb3_dram_ras_n),
	.mcb3_dram_cas_n			(mcb3_dram_cas_n),
	.mcb3_dram_we_n				(mcb3_dram_we_n),
	.mcb3_dram_odt				(mcb3_dram_odt),
	.mcb3_dram_cke				(mcb3_dram_cke),
	.mcb3_dram_dm				(mcb3_dram_dm),
	.mcb3_dram_udqs				(mcb3_dram_udqs),
	.mcb3_dram_udqs_n			(mcb3_dram_udqs_n),
	.mcb3_dram_udm				(mcb3_dram_udm),
	.mcb3_dram_dqs				(mcb3_dram_dqs),
	.mcb3_dram_dqs_n			(mcb3_dram_dqs_n),
	.mcb3_dram_ck				(mcb3_dram_ck),
	.mcb3_dram_ck_n				(mcb3_dram_ck_n),
	.mcb3_rzq					(mcb3_rzq),
	.mcb3_zio					(mcb3_zio),
	.c3_clk0					(),
	.c3_rst0					(),
	.c3_calib_done				(c3_calib_done)
);


endmodule
