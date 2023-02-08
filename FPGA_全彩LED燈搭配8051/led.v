module led(
	clk,
	din,
	//sfr bus
	sfr_addr,
	controller_data_in,
	sfr_wr
);

input clk,sfr_wr;
output reg din;
input [7:0] sfr_addr, controller_data_in;

parameter T0H = 20; //0.4us
parameter T0L = 42; //0.85us
parameter T1H = 40; //0.8us
parameter T1L = 22; //0.45us
parameter RESET = 3000; // 60us
parameter one_sec = 50000000;
parameter RED = 3'b000;
parameter GREEN  = 3'b001;
parameter BLUE = 3'b010;
parameter BLACK = 3'b011;
parameter RET = 3'b111;

reg[31:0] counter = 0, oneSec_ctr = 0,led_ctr = 0;
reg[4:0] bitCounter = 0;
reg[2:0] state = 0, lastState= 0,start_ctr = 0,default_state = RED;
reg[3:0] ledBit = 8;
wire initialization;
assign initialization = (start_ctr == 4) ? 0: 1;

always@(posedge clk) begin
	if(counter == T0H + T0L || state == RET) begin
		counter <= 0;
	end else if(state == RED || state == GREEN || state == BLUE || state == BLACK) begin
		counter <= counter + 1;
	end
end

always@(posedge clk) begin
	if(initialization) begin
		if(oneSec_ctr == one_sec) begin
			oneSec_ctr <= 0;
		end else begin
			oneSec_ctr <= oneSec_ctr + 1;
		end
	end
end

always@(posedge clk) begin
	if(bitCounter == 24 || state == RET) begin
		bitCounter <= 0;
	end else if(state == RED || state == GREEN || state == BLUE || state == BLACK) begin
		if(counter == T0H + T1H) begin
			bitCounter <= bitCounter + 1;
		end
	end
end

always@(posedge clk) begin
		if(state == RET || led_ctr == 8) begin
			led_ctr <= 0;
		end else if(bitCounter == 24) begin
			led_ctr <= led_ctr + 1;
		end
end

always@(posedge clk) begin
	if(initialization) begin
		if(oneSec_ctr == one_sec) begin
			state <= lastState + 1;
			lastState <= lastState + 1;
		end else if(led_ctr == ledBit - 1 && bitCounter == 24) begin
			state <= RET;			
		end
	end else if(!initialization) begin
			if(led_ctr == ledBit - 1 && bitCounter == 24) begin
				state <= RET;
			end else if(sfr_wr && sfr_addr == 8'hc2) begin //led control byte
				state <= default_state;
			end else if(sfr_wr && sfr_addr == 8'hc3 && controller_data_in == 8'h01) begin
				state <= RED ;
				default_state <= RED;
			end else if(sfr_wr && sfr_addr == 8'hc4 && controller_data_in == 8'h01) begin
				state <= GREEN ;
				default_state <= GREEN;
			end else if(sfr_wr && sfr_addr == 8'hc5 && controller_data_in == 8'h01) begin
				state <= BLUE;
				default_state <= BLUE;
			end
	end
end

always@(posedge clk) begin
	if(start_ctr == 4) begin
		start_ctr <= start_ctr;
	end else if(oneSec_ctr == one_sec) begin
		start_ctr <= start_ctr + 1;
	end
end

always@(posedge clk) begin
	if(!initialization) begin
		if(sfr_wr && sfr_addr == 8'hc2) begin
			ledBit <= controller_data_in[3:0];
		end
	end
end

always@(posedge clk) begin //din
		case (state)
			GREEN : 
				begin
					if(bitCounter < 8) begin
						if(counter <= T1H) begin
							din <= 1;
						end else if(counter > T1H)begin
							din <= 0;
						end
					end else if(bitCounter >= 8 && bitCounter < 25) begin
						if(counter <= T0H) begin
							din <= 1;
						end else if(counter > T0H)begin
							din <= 0;
						end
					end
				end
			RED : 
				begin
					if(bitCounter < 8 || (bitCounter > 15 && bitCounter < 25)) begin
						if(counter <= T0H) begin
							din <= 1;
						end else if(counter > T0H)begin
							din <= 0;
						end
					end else if(bitCounter >= 8 && bitCounter <= 15) begin
						if(counter <= T1H) begin
							din <= 1;
						end else if(counter > T1H)begin
							din <= 0;
						end
					end
				end
			BLUE : 
				begin
					if(bitCounter > 15) begin
						if(counter <= T1H) begin
							din <= 1;
						end else if(counter > T1H)begin
							din <= 0;
						end
					end else if(bitCounter <= 15) begin
						if(counter <= T0H) begin
							din <= 1;
						end else if(counter > T0H)begin
							din <= 0;
						end
					end
				end	
			RET : din <= 0; 
			BLACK  : 
				begin
					if(counter <= T0H) begin
						din <= 1;
					end else if(counter > T0H)begin
						din <= 0;
					end
				end	
			default : din <= din;
		endcase
end

endmodule
