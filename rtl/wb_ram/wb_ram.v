//******************************************************************************
//  File    : wb_ram.v
//  Author  : Lyu Yang
//  Date    : 2019-07-12
//  Details :
//******************************************************************************
// synthesis translate_off
`timescale 1ns / 10ps
// synthesis translate_on
module wb_ram (
	input	wire				wb_clk_i,
	input	wire				wb_rst_i,
	input	wire				wb_cyc_i,
	input	wire				wb_stb_i,
	input	wire				wb_we_i,
	input	wire	[3:0]		wb_sel_i,
	input   wire	[31:0]		wb_adr_i,
	input	wire	[31:0]		wb_dat_i,   
	output	reg		[31:0]      wb_dat_o,
	output	reg     	        wb_ack_o
);

parameter mem_words = 4096;

wire [31:0]		wr_data;

// mux for data to ram
assign wr_data[31:24] = wb_sel_i[3] ? wb_dat_i[31:24] : wb_dat_o[31:24];
assign wr_data[23:16] = wb_sel_i[2] ? wb_dat_i[23:16] : wb_dat_o[23:16];
assign wr_data[15: 8] = wb_sel_i[1] ? wb_dat_i[15: 8] : wb_dat_o[15: 8];
assign wr_data[ 7: 0] = wb_sel_i[0] ? wb_dat_i[ 7: 0] : wb_dat_o[ 7: 0];

// genarate ack signal
always @ (posedge wb_clk_i)
begin
	if(wb_ack_o)
		wb_ack_o <= 1'b0;
	else if(wb_cyc_i & wb_stb_i & !wb_ack_o)
		wb_ack_o <= 1'b1;
	else wb_ack_o <= 1'b0;
end

// memory
reg [31: 0] ram [0 : mem_words - 1];

initial $readmemh("../sw/data.txt", ram);

always @ (posedge wb_clk_i)
begin 
	wb_dat_o <= ram[wb_adr_i[31:2]];
    if(wb_cyc_i & wb_stb_i & wb_we_i & wb_ack_o)
		ram[wb_adr_i[31:2]] <= wr_data;
end 

endmodule
