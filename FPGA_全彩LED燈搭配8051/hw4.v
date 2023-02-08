module hw4(
	clk,
	din,
	KEY,
	//sfr bus
	sfr_addr,
	controller_data_in,
	controller_data_out,
	sfr_wr,
	sfr_rd
);

parameter delayTime = 1000;
input clk, sfr_wr, sfr_rd;
input [1:0] KEY;
input [7:0] sfr_addr, controller_data_in;
output reg [7:0] controller_data_out;
output din;
wire key_finish0,key_finish1;
reg [31:0] ctr = 0;
reg [4:0] state = 0;
wire read_trig;
assign read_trig = (sfr_rd && sfr_addr == 8'hc6 
	&& (controller_data_out == 8'h01 || controller_data_out == 8'h10)) ? 1 : 0;

debounce de1(
	.clk(clk),
	.buttom(KEY[0]),
	.finish(key_finish0)
);

debounce de2(
	.clk(clk),
	.buttom(KEY[1]),
	.finish(key_finish1)
);

led control(
	.clk(clk),
	.din(din),
	//sfr bus
	.sfr_addr(sfr_addr),
	.controller_data_in(controller_data_in),
	.sfr_wr(sfr_wr)
);

always @(posedge clk) begin
	if(ctr == delayTime || state == 5'h00) begin
		ctr <= 0;
	end else if(state == 5'h01 || state == 5'h02) begin
		ctr <= ctr + 1;
	end
end

always@(posedge clk) begin
	if(read_trig) begin
		state <= 5'h00;
	end else if(key_finish0) begin
		state <= 5'h01;
	end else if(key_finish1) begin
		state <= 5'h02;
	end/* else if(ctr == delayTime) begin
		state <= 5'h00;
	end*/
end

always@(posedge clk) begin
	case (state)
		5'h00 : controller_data_out <= 8'h00;
		5'h01 : controller_data_out <= 8'h01;
		5'h02 : controller_data_out <= 8'h10;
		default : controller_data_out <= 8'h00;
	endcase
end

endmodule
