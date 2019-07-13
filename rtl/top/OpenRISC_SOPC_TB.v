//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:54:27 07/06/2019 
// Design Name: 
// Module Name:    OpenRISC_SOPC_TB 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ns
module OpenRISC_SOPC_TB;

reg             clk;
reg             rst;
wire    [3:0]   led;

OpenRISC_SOPC  U_DUT (
    .clk                (clk            ),
    .rst                (rst            ),
    .mcb3_dram_ck       (),
    .mcb3_dram_ck_n     (),
    .mcb3_dram_dq       (),
    .mcb3_dram_a        (),
    .mcb3_dram_ba       (),
    .mcb3_dram_ras_n    (),
    .mcb3_dram_cas_n    (),
    .mcb3_dram_we_n     (),
    .mcb3_dram_odt      (),
    .mcb3_dram_cke      (),
    .mcb3_dram_dm       (),
    .mcb3_dram_udqs     (),
    .mcb3_dram_udqs_n   (),
    .mcb3_dram_udm      (),
    .mcb3_dram_dqs      (),
    .mcb3_dram_dqs_n    (),
    .mcb3_rzq           (),
    .mcb3_zio           (),
    .uart_txd           (),
    .uart_rxd           (1'b1           ),
    .key                (4'ha           ),
    .led                (led            )
);

initial forever #5 clk = ~clk;

initial begin
    clk  = 1'b0;
    rst  = 1'b1;
    #100;
    rst = 1'b0;
    #500000;
    $finish;
end

endmodule
