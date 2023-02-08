module hw3(
	CLOCK_50,
	IRDA_RXD,
	KEY,
	LCD_EN,
	LCD_RW,
	LCD_RS,
	LCD_ON,
	LCD_BLON,
	LCD_DATA
);

//675000 = 13.5ms
//  56000 = 1.12ms 
//112500 = 2.25ms
parameter leader_high_range = 800000; 
parameter leader_low_range = 540000; 
parameter logic0_high_range = 67200; 
parameter logic0_low_range = 44800; 
parameter logic1_high_range = 135000; 
parameter logic1_low_range = 90000; 

input CLOCK_50, IRDA_RXD ; 
input [1:0] KEY;
output LCD_EN, LCD_RW, LCD_RS, LCD_ON, LCD_BLON ;
output [7:0] LCD_DATA ;

// display data
reg[3:0] customer1 = 0,customer2 = 0,customer3 = 0,customer4 = 0;
reg[3:0] key1 = 0,key2 = 0,key_inverse1 = 0,key_inverse2 = 0;

//given data
reg[3:0] data = 0;

//counter
reg[31:0] counter = 0;

reg[2:0] temp = 0;
reg[1:0] state = 0;
reg[5:0] bitCounter = 0;

wire POS_IRDA_RXD  ;
wire NEG_IRDA_RXD  ;
assign LCD_ON  = 1;
assign LCD_BLON  = 1;

lcd_controller display(
		.clk(CLOCK_50),
		.LCD_EN (LCD_EN ),
		.LCD_RW (LCD_RW ),
		.LCD_RS (LCD_RS ),
		.LCD_DATA (LCD_DATA ),
		.data0(key_inverse2),
		.data1(key_inverse1),
		.data2(key2),
		.data3(key1),
		.data4(customer4),
		.data5(customer3),
		.data6(customer2),
		.data7(customer1),
		.state(state),
);

always@(posedge CLOCK_50 or negedge KEY[0]) begin
		if(!KEY[0]) begin
				temp <= 0;
		end else begin
				temp[0] <= IRDA_RXD ;
				temp[1] <= temp[0];
				temp[2] <= temp[1];
		end
end
assign NEG_IRDA_RXD  = ~temp[0] && temp[1] && temp[2];

always@(posedge CLOCK_50 or negedge KEY[0]) begin //state
		if(!KEY[0]) begin
				state <= 0;
		end else if(state == 0 && NEG_IRDA_RXD  ) begin //idle
				state <= state + 1;
		end else if(state == 1 && NEG_IRDA_RXD  ) begin //leader check
				if(counter <= leader_high_range &&
				   counter >= leader_low_range) begin
						state <= state + 1;
				end else begin
						state <= state;
				end
		end else if(state == 2 && bitCounter == 32) begin
				state <= state + 1;
		end else if(state == 2 && NEG_IRDA_RXD  ) begin //receive data bit
				if((counter <= logic0_high_range &&
				counter >= logic0_low_range) || 
				(counter <= logic1_high_range &&
				counter >= logic1_low_range)) begin
							state <= state;
				end else begin
						state <= 0;
				end
		end else if(state == 3) begin
				state <= 0;
		end
end

always@(posedge CLOCK_50  or negedge KEY[0]) begin //counter
		if(!KEY[0]) begin 
				counter <= 0;
		end else if(state != 1 && state != 2) begin
				counter <= 0;
		end else if(NEG_IRDA_RXD) begin
				counter <= 0;
		end else begin
				counter <= counter + 1;
		end 
end 

always@(posedge CLOCK_50 or negedge KEY[0]) begin //bitCounter
		if(!KEY[0]) begin 
				bitCounter <= 0;
		end else if(bitCounter == 32 || state != 2) begin
				bitCounter <= 0;
		end else if(state == 2 && NEG_IRDA_RXD  ) begin
				bitCounter <= bitCounter + 1;
		end
end

always@(posedge CLOCK_50 or negedge KEY[0]) begin //data
		if(!KEY[0]) begin
				data <= 0;
		end else if(!state) begin
				data <= 0;
		end else if(state == 2 && NEG_IRDA_RXD) begin
				if(counter <= logic0_high_range &&
				counter >= logic0_low_range) begin
						data <= {1'b0,data[3:1]};
				end else if(counter<= logic1_high_range &&
				counter >= logic1_low_range) begin
						data <= {1'b1,data[3:1]};
				end
		end
end

always@(posedge CLOCK_50  or negedge KEY[0]) begin //give data
		if(!KEY[0]) begin
				customer1 = 0; customer2 = 0; customer3 = 0; customer4 = 0;
				key1 = 0; key2 = 0; 
				key_inverse1 = 0; key_inverse2 = 0;
		end else begin
				case (bitCounter)
						6'h04 : customer2 <= data;
						6'h08 : customer1 <= data;
						6'h0c : customer4 <= data;
						6'h10 : customer3 <= data;
						6'h14 : key2  <= data;
						6'h18 : key1 <= data;
						6'h1c : key_inverse2 <= data;
						6'h20 : key_inverse1 <= data;
						default : 
								begin
									customer1 <= customer1; customer2 <= customer2; 
									customer3 <= customer3; customer4 <= customer4;
									key1 <= key1; key2 <= key2;
									key_inverse1 <= key_inverse1;
									key_inverse2 <= key_inverse2;
								end
				endcase
		end
end

endmodule
