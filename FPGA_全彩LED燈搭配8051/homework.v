`define FPGA
`define FPGA_DEBUG
`include "define.h"
`include "DW8051_package.inc"
`include "DW8051_parameter.v"
`include "DW01_addsub.v"
`include "DW01_add.v"
`include "DW01_cmp2.v"
`include "DW01_sub.v"
`include "DW02_mult.v"
`include "DW8051_alu.v"
`include "DW8051_biu.v"
`include "DW8051_control.v"
`include "DW8051_intr_0.v"
`include "DW8051_intr_1.v"
`include "DW8051_main_regs.v"
`include "DW8051_op_decoder.v"
`include "DW8051_serial.v"
`include "DW8051_shftreg.v"
`include "DW8051_timer2.v"
`include "DW8051_timer_ctr.v"
`include "DW8051_timer.v"
`include "DW8051_u_ctr_clr.v"
`include "DW8051_updn_ctr.v"
`include "DW8051_cpu.v"
`include "DW8051_core.v"
`include "mcu.v"
`include "port.v"
`include "port_all.v"
`include "mcu_mux.v"
`include "rst_syn.v"
`include "jtag_inst0.v"

/*
//mcu rom
`define ROM_DATA_WIDTH 8
`define ROM_DATA_DEPTH 8192
`define ROM_ADDR_WIDTH 15

//delay
`define D  #1


//port
`define PRT_A_WID 8  //port a width
`define PRT_B_WID 3  //port b width*/

module homework(
	input wire rstn_ex,
	input wire clk  ,
	input [1:0] KEY,
	output din
);

	wire por_n; 
   wire rst_in_n; 
   wire rst_out_n; 
   wire test_mode_n; 
   wire stop_mode_n; 
   wire idle_mode_n; 
   wire [7:0] sfr_addr; 
   wire [7:0] sfr_data_out; 
   wire [7:0] sfr_data_in; 
   wire sfr_wr; 
   wire sfr_rd; 
   wire [15:0] mem_addr; 
   wire [7:0] mem_data_out; 
   wire [7:0] mem_data_in; 
   wire mem_wr_n; 
   wire mem_rd_n; 
   wire mem_pswr_n;    
   
   wire mem_psrd_n; 
   wire mem_ale; 
   reg mem_ea_n; 
   wire int0_n; 
   wire int1_n; 
   wire int2; 
   wire int3_n; 
   wire int4; 
   wire int5_n; 
   wire pfi; 
   wire wdti; 
   wire rxd0_in; 
   wire rxd0_out, txd0; 
   wire rxd1_in; 
   wire rxd1_out, txd1; 
   wire t0; 
   wire t1; 
   wire t2; 
   wire t2ex; 
   wire t0_out, t1_out, t2_out; 
   wire port_pin_reg_n, p0_mem_reg_n, p0_addr_data_n, p2_mem_reg_n; 
   wire [7:0] iram_addr, iram_data_out, iram_data_in; 
   wire iram_rd_n, iram_we1_n, iram_we2_n; 
   wire [15:0] irom_addr; 
   wire [7:0] irom_data_out; 
   wire irom_rd_n, irom_cs_n; 

DW8051_core u0 ( 
               .clk (clk), 
               .por_n (rstn_ex), 
               .rst_in_n (rstn_ex), 
               .rst_out_n (rst_out_n), 
               .test_mode_n (1'b1), 
               .stop_mode_n (stop_mode_n), 
               .idle_mode_n (idle_mode_n), 
               .sfr_addr (sfr_addr), 
               .sfr_data_out (sfr_data_out), 
               .sfr_data_in (sfr_data_in), 
               .sfr_wr (sfr_wr), 
               .sfr_rd (sfr_rd), 
               .mem_addr (mem_addr), 
               .mem_data_out (mem_data_out), 
               .mem_data_in (mem_data_in), 
               .mem_wr_n (mem_wr_n), 
               .mem_rd_n (mem_rd_n), 
               .mem_pswr_n (mem_pswr_n), 
               .mem_psrd_n (mem_psrd_n), 
               .mem_ale (mem_ale), 
               .mem_ea_n (1'b1),
               .int0_n (int0_n), 
               .int1_n (int1_n), 
               .int2 (int2), 
               .int3_n (int3_n), 
               .int4 (int4), 
               .int5_n (int5_n), 
               .pfi (pfi), 
               .wdti (wdti), 
               .rxd0_in (rxd0_in), 
               .rxd0_out (rxd0_out), 
               .txd0 (txd0), 
               .rxd1_in (rxd1_in), 
               .rxd1_out (rxd1_out), 
               .txd1 (txd1), 
               .t0 (t0), 
               .t1 (t1), 
               .t2 (t2), 
               .t2ex (t2ex), 
               .t0_out (t0_out), 
               .t1_out (t1_out), 
               .t2_out (t2_out), 
               .port_pin_reg_n (port_pin_reg_n), 
               .p0_mem_reg_n (p0_mem_reg_n), 
               .p0_addr_data_n (p0_addr_data_n), 
               .p2_mem_reg_n (p2_mem_reg_n), 
					
               .iram_addr (iram_addr), 
               .iram_data_out (iram_data_out), 
               .iram_data_in (iram_data_in), 
               .iram_rd_n (), 
               .iram_we1_n (iram_we1_n), 
               .iram_we2_n (iram_we2_n), 
					
               .irom_addr (irom_addr), 
               .irom_data_out (irom_data_out), 
               .irom_rd_n (irom_rd_n), 
               .irom_cs_n (irom_cs_n) 
);


rom u_rom(.clock (clk         ),
	.address(irom_addr    ),
	//.cen (rom_rd_n    ),
	.q   (irom_data_out    )
);

int_mem_revised int_mem2(
	.clk(clk), 
	.addr(iram_addr),     
	.data_in(iram_data_in),
	.data_out(iram_data_out),
	.we1_n(iram_we1_n),    
	.we2_n(iram_we2_n),   
	.rd_n(iram_rd_n)
);
/*
int_mem int_mem1(
	.clk(clk), 
	.addr(iram_addr),     
	.data_in(iram_data_in),
	.data_out(iram_data_out),
	.we1_n(iram_we1_n),    
	.we2_n(iram_we2_n),   
	.rd_n(iram_rd_n)
);


ram u_ram(.clock (~clk        ),
	.address(iram_addr    ),
	//.cen (1'b0       ),
	.wren (iram_we2_n),//ram_wen     ),
	.data   (iram_data_in),
	.q   (iram_data_out)
);*/

hw4 h(
	.clk(clk),
	.din(din),
	.KEY(KEY),
	//sfr bus
	.sfr_addr(sfr_addr),
	.controller_data_in(sfr_data_out),
	.controller_data_out(sfr_data_in),
	.sfr_wr(sfr_wr),
	.sfr_rd(sfr_rd)
);

endmodule
