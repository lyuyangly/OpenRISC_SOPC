//******************************************************************************
//  File    : OpenRISC_SOPC.v
//  Author  : Lyu Yang
//  Date    : 2019-07-12
//  Details :
//******************************************************************************
// synopsys translate_off
`timescale 1 ns / 100 ps
// synopsys translate_on
module OpenRISC_SOPC (
    input               clk             ,
    input               rst             ,
    output              mcb3_dram_ck    ,
    output              mcb3_dram_ck_n  ,
    inout   [15:0]      mcb3_dram_dq    ,
    output  [12:0]      mcb3_dram_a     ,
    output  [2:0]       mcb3_dram_ba    ,
    output              mcb3_dram_ras_n ,
    output              mcb3_dram_cas_n ,
    output              mcb3_dram_we_n  ,
    output              mcb3_dram_odt   ,
    output              mcb3_dram_cke   ,
    output              mcb3_dram_dm    ,
    inout               mcb3_dram_udqs  ,
    inout               mcb3_dram_udqs_n,
    output              mcb3_dram_udm   ,
    inout               mcb3_dram_dqs   ,
    inout               mcb3_dram_dqs_n ,
    inout               mcb3_rzq        ,
    inout               mcb3_zio        ,
    output              uart_txd        ,
    input               uart_rxd        ,
    input   [3:0]       key             ,
    output  [3:0]       led
);

// CRG
wire                rst_sync;

// CPU Instruction
wire                iwb_ack_i;
wire                iwb_cyc_o;
wire                iwb_stb_o;
wire    [31:0]      iwb_dat_i;
wire    [31:0]      iwb_dat_o;
wire    [31:0]      iwb_adr_o;
wire    [3:0]       iwb_sel_o;
wire                iwb_we_o;
wire                iwb_err_i;
wire                iwb_rty_i;

// CPU Data
wire                dwb_ack_i;
wire                dwb_cyc_o;
wire                dwb_stb_o;
wire    [31:0]      dwb_dat_i;
wire    [31:0]      dwb_dat_o;
wire    [31:0]      dwb_adr_o;
wire                dwb_we_o;
wire    [3:0]       dwb_sel_o;
wire                dwb_err_i;
wire                dwb_rty_i;

// SOC RAM
wire                ram_ack_o;
wire                ram_cyc_i;
wire                ram_stb_i;
wire    [31:0]      ram_dat_i;
wire    [31:0]      ram_dat_o;
wire    [31:0]      ram_adr_i;
wire                ram_we_i;
wire    [3:0]       ram_sel_i;

// DDR2 SDRAM
wire                ddr_ack_o;
wire                ddr_cyc_i;
wire                ddr_stb_i;
wire    [31:0]      ddr_dat_i;
wire    [31:0]      ddr_dat_o;
wire    [31:0]      ddr_adr_i;
wire                ddr_we_i;
wire    [3:0]       ddr_sel_i;

// WB GPIO
wire                gpio_ack_o;
wire                gpio_cyc_i;
wire                gpio_stb_i;
wire    [31:0]      gpio_dat_i;
wire    [31:0]      gpio_dat_o;
wire    [31:0]      gpio_adr_i;
wire    [3:0]       gpio_sel_i;
wire                gpio_we_i;
wire                gpio_err_o;
wire                gpio_irq;

// WB UART
wire                uart_ack_o;
wire                uart_cyc_i;
wire                uart_we_i;
wire    [3:0]       uart_sel_i;
wire                uart_stb_i;
wire    [31:0]      uart_data_i;
wire    [31:0]      uart_data_o;
wire    [31:0]      uart_addr_i;
wire                uart_irq;

// RST SYNC
rst_sync U_RST_SYNC (
    .clk                (clk                ),
    .arst_i             (rst                ),
    .srst_o             (rst_sync           )
);

// OpenRISC CPU
or1200_top U_CPU (
    .clk_i              (clk                ),
    .rst_i              (rst_sync           ),
    .pic_ints_i         ('d0                ),
    .clmode_i           (2'b00              ),
    // Instruction WISHBONE INTERFACE
    .iwb_clk_i          (clk                ),
    .iwb_rst_i          (rst_sync           ),
    .iwb_ack_i          (iwb_ack_i          ),
    .iwb_err_i          (iwb_err_i          ),
    .iwb_rty_i          (iwb_rty_i          ),
    .iwb_dat_i          (iwb_dat_i          ),
    .iwb_cyc_o          (iwb_cyc_o          ),
    .iwb_adr_o          (iwb_adr_o          ),
    .iwb_stb_o          (iwb_stb_o          ),
    .iwb_we_o           (iwb_we_o           ),
    .iwb_sel_o          (iwb_sel_o          ),
    .iwb_dat_o          (iwb_dat_o          ),
`ifdef OR1200_WB_CAB
    .iwb_cab_o          (                   ),
`endif

`ifdef OR1200_WB_B3
    .iwb_cti_o          (                   ),
    .iwb_bte_o          (                   ),
`endif
    // Data WISHBONE INTERFACE
    .dwb_clk_i          (clk                ),
    .dwb_rst_i          (rst_sync           ),
    .dwb_ack_i          (dwb_ack_i          ),
    .dwb_err_i          (dwb_err_i          ),
    .dwb_rty_i          (dwb_rty_i          ),
    .dwb_dat_i          (dwb_dat_i          ),
    .dwb_cyc_o          (dwb_cyc_o          ),
    .dwb_adr_o          (dwb_adr_o          ),
    .dwb_stb_o          (dwb_stb_o          ),
    .dwb_we_o           (dwb_we_o           ),
    .dwb_sel_o          (dwb_sel_o          ),
    .dwb_dat_o          (dwb_dat_o          ),
`ifdef OR1200_WB_CAB
    .dwb_cab_o          (                   ),
`endif
`ifdef OR1200_WB_B3
    .dwb_cti_o          (                   ),
    .dwb_bte_o          (                   ),
`endif
    // External Debug Interface
    .dbg_stall_i        (1'b0               ),
    .dbg_ewt_i          (1'b0               ),
    .dbg_lss_o          (                   ),
    .dbg_is_o           (                   ),
    .dbg_wp_o           (                   ),
    .dbg_bp_o           (                   ),
    .dbg_stb_i          (1'b0               ),
    .dbg_we_i           (1'b0               ),
    .dbg_adr_i          (32'd0              ),
    .dbg_dat_i          (32'd0              ),
    .dbg_dat_o          (                   ),
    .dbg_ack_o          (                   ),
`ifdef OR1200_BIST
    .mbist_si_i         (                   ),
    .mbist_so_o         (                   ),
    .mbist_ctrl_i       (                   ),
`endif
    // Power Management
    .pm_cpustall_i      (1'b0               ),
    .pm_clksd_o         (                   ),
    .pm_dc_gate_o       (                   ),
    .pm_ic_gate_o       (                   ),
    .pm_dmmu_gate_o     (                   ),
    .pm_immu_gate_o     (                   ),
    .pm_tt_gate_o       (                   ),
    .pm_cpu_gate_o      (                   ),
    .pm_wakeup_o        (                   ),
    .pm_lvolt_o         (                   )
);

// Wishbone Conmax
wb_conmax_top U_WB_CONMAX (
    .clk_i              (clk                ),
    .rst_i              (rst_sync           ),

    // Master 0 Interface
    .m0_data_i          (iwb_dat_o          ),
    .m0_data_o          (iwb_dat_i          ),
    .m0_addr_i          (iwb_adr_o          ),
    .m0_sel_i           (iwb_sel_o          ),
    .m0_we_i            (iwb_we_o           ),
    .m0_cyc_i           (iwb_cyc_o          ),
    .m0_stb_i           (iwb_stb_o          ),
    .m0_ack_o           (iwb_ack_i          ),
    .m0_err_o           (iwb_err_i          ),
    .m0_rty_o           (iwb_rty_i          ),

    // Master 1 Interface
    .m1_data_i          (dwb_dat_o          ),
    .m1_data_o          (dwb_dat_i          ),
    .m1_addr_i          (dwb_adr_o          ),
    .m1_sel_i           (dwb_sel_o          ),
    .m1_we_i            (dwb_we_o           ),
    .m1_cyc_i           (dwb_cyc_o          ),
    .m1_stb_i           (dwb_stb_o          ),
    .m1_ack_o           (dwb_ack_i          ),
    .m1_err_o           (dwb_err_i          ),
    .m1_rty_o           (dwb_rty_i          ),

    // Slave 0 Interface
    .s0_data_i          (ram_dat_o          ),
    .s0_data_o          (ram_dat_i          ),
    .s0_addr_o          (ram_adr_i          ),
    .s0_sel_o           (ram_sel_i          ),
    .s0_we_o            (ram_we_i           ),
    .s0_cyc_o           (ram_cyc_i          ),
    .s0_stb_o           (ram_stb_i          ),
    .s0_ack_i           (ram_ack_o          ),
    .s0_err_i           (1'b0               ),
    .s0_rty_i           (1'b0               ),

    // Slave 1 Interface
    .s1_data_i          (ddr_dat_o          ),
    .s1_data_o          (ddr_dat_i          ),
    .s1_addr_o          (ddr_adr_i          ),
    .s1_sel_o           (ddr_sel_i          ),
    .s1_we_o            (ddr_we_i           ),
    .s1_cyc_o           (ddr_cyc_i          ),
    .s1_stb_o           (ddr_stb_i          ),
    .s1_ack_i           (ddr_ack_o          ),
    .s1_err_i           (1'b0               ),
    .s1_rty_i           (1'b0               ),

    // Slave 2 Interface
    .s2_data_i          (gpio_dat_o         ),
    .s2_data_o          (gpio_dat_i         ),
    .s2_addr_o          (gpio_adr_i         ),
    .s2_sel_o           (gpio_sel_i         ),
    .s2_we_o            (gpio_we_i          ),
    .s2_cyc_o           (gpio_cyc_i         ),
    .s2_stb_o           (gpio_stb_i         ),
    .s2_ack_i           (gpio_ack_o         ),
    .s2_err_i           (gpio_err_o         ),
    .s2_rty_i           (1'b0               ),

    // Slave 3 Interface
    .s3_data_i          (uart_data_o        ),
    .s3_data_o          (uart_data_i        ),
    .s3_addr_o          (uart_addr_i        ),
    .s3_sel_o           (uart_sel_i         ),
    .s3_we_o            (uart_we_i          ),
    .s3_cyc_o           (uart_cyc_i         ),
    .s3_stb_o           (uart_stb_i         ),
    .s3_ack_i           (uart_ack_o         ),
    .s3_err_i           (1'b0               ),
    .s3_rty_i           (1'b0               )
);

// RAM For RISC-V CPU
wb_ram U_WB_RAM (
    .wb_clk_i           (clk                ),
    .wb_rst_i           (rst_sync           ),
    .wb_cyc_i           (ram_cyc_i          ),
    .wb_stb_i           (ram_stb_i          ),
    .wb_we_i            (ram_we_i           ),
    .wb_sel_i           (ram_sel_i          ),
    .wb_adr_i           (ram_adr_i          ),
    .wb_dat_i           (ram_dat_i          ),
    .wb_dat_o           (ram_dat_o          ),
    .wb_ack_o           (ram_ack_o          )
);

// DDR2 SDRAM
wb_xmigddr U_SPMIG_DDR (
    .wb_clk_i           (clk                    ),
    .wb_rst_i           (rst_sync               ),

    // Wishbone Interface
    .wb_cyc_i           (ddr_cyc_i              ),
    .wb_stb_i           (ddr_stb_i              ),
    .wb_we_i            (ddr_we_i               ),
    .wb_sel_i           (ddr_sel_i              ),
    .wb_adr_i           (ddr_adr_i              ),
    .wb_dat_i           (ddr_dat_i              ),
    .wb_dat_o           (ddr_dat_o              ),
    .wb_ack_o           (ddr_ack_o              ),

   // ddr2 chip signals
    .mcb3_dram_dq       (mcb3_dram_dq           ),
    .mcb3_dram_a        (mcb3_dram_a            ),
    .mcb3_dram_ba       (mcb3_dram_ba           ),
    .mcb3_dram_ras_n    (mcb3_dram_ras_n        ),
    .mcb3_dram_cas_n    (mcb3_dram_cas_n        ),
    .mcb3_dram_we_n     (mcb3_dram_we_n         ),
    .mcb3_dram_odt      (mcb3_dram_odt          ),
    .mcb3_dram_cke      (mcb3_dram_cke          ),
    .mcb3_dram_dm       (mcb3_dram_dm           ),
    .mcb3_dram_udqs     (mcb3_dram_udqs         ),
    .mcb3_dram_udqs_n   (mcb3_dram_udqs_n       ),
    .mcb3_dram_udm      (mcb3_dram_udm          ),
    .mcb3_dram_dqs      (mcb3_dram_dqs          ),
    .mcb3_dram_dqs_n    (mcb3_dram_dqs_n        ),
    .mcb3_dram_ck       (mcb3_dram_ck           ),
    .mcb3_dram_ck_n     (mcb3_dram_ck_n         ),
    .mcb3_rzq           (mcb3_rzq               ),
    .mcb3_zio           (mcb3_zio               )
);

// WB GPIO
gpio_top U_WB_GPIO (
    .wb_clk_i           (clk                    ),
    .wb_rst_i           (rst_sync               ),
    .wb_cyc_i           (gpio_cyc_i             ),
    .wb_adr_i           (gpio_adr_i             ),
    .wb_dat_i           (gpio_dat_i             ),
    .wb_sel_i           (gpio_sel_i             ),
    .wb_we_i            (gpio_we_i              ),
    .wb_stb_i           (gpio_stb_i             ),
    .wb_dat_o           (gpio_dat_o             ),
    .wb_ack_o           (gpio_ack_o             ),
    .wb_err_o           (gpio_err_o             ),
    .wb_inta_o          (gpio_irq               ),
    .ext_pad_i          (key                    ),
    .ext_pad_o          (led                    ),
    .ext_padoe_o        (                       )
);

// UART 16550 8BIT Mode
uart_top U_UART (
    .wb_clk_i           (clk                    ),
    .wb_rst_i           (rst_sync               ),
    .wb_stb_i           (uart_stb_i             ),
    .wb_cyc_i           (uart_cyc_i             ),
    .wb_ack_o           (uart_ack_o             ),
    .wb_adr_i           (uart_addr_i            ),
    .wb_we_i            (uart_we_i              ),
    .wb_sel_i           (uart_sel_i             ),
    .wb_dat_i           (uart_data_i            ),
    .wb_dat_o           (uart_data_o            ),
    .int_o              (uart_irq               ),
    .stx_pad_o          (uart_txd               ),
    .srx_pad_i          (uart_rxd               ),
    .rts_pad_o          (                       ),
    .cts_pad_i          (1'b0                   ),
    .dtr_pad_o          (                       ),
    .dsr_pad_i          (1'b0                   ),
    .ri_pad_i           (1'b0                   ),
    .dcd_pad_i          (1'b0                   )
);

endmodule

