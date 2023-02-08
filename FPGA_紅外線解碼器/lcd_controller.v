module lcd_controller(
	clk,
	LCD_EN,
	LCD_RW,
	LCD_RS,
	LCD_DATA,
	data0,
	data1,
	data2,
	data3,
	data4,
	data5,
	data6,
	data7,
	state,
);

parameter one_Micro_Sec = 50;
parameter ninety_micro_sec = 4500;
parameter twenty_mini_sec = 1000000;
parameter one_hundred_mini_sec = 5000000;

input clk;
input [1:0] state;
input [3:0]data0,data1,data2,data3,data4,data5,data6,data7;
output reg LCD_EN ,LCD_RW ,LCD_RS ;
output reg [7:0] LCD_DATA ;

reg[3:0] initial_state = 0;
reg[4:0] data_state = 0;
reg[31:0] counter = 0, counter2 = 0;
reg[31:0] display_counter = 0;
reg stop = 0,start = 0;
reg [3:0] data[7:0];
wire [3:0] number;

assign finish = (data_state == 5'h13 && counter2 == ninety_micro_sec) ? 1 : 0;
assign number = (data_state == 5'h00) ? data[0] :
									  (data_state == 5'h01) ? data[1] :
									  (data_state == 5'h03) ? data[2] :
									  (data_state == 5'h04) ? data[3] :
									  (data_state == 5'h06) ? data[4] :
									  (data_state == 5'h07) ? data[5] :
									  (data_state == 5'h09) ? data[6] :
									  (data_state == 5'h0a) ? data[7] : 0;

always@(posedge clk) begin //start
		if(state == 3) begin
				data[0] <= data0; // key_inverse2
				data[1] <= data1; // key_inverse1
				data[2] <= data2; // key2
				data[3] <= data3; // key1
				data[4] <= data4; // customer4
				data[5] <= data5; // customer3
				data[6] <= data6; // customer2
				data[7] <= data7; // customer1
		end else if(!stop) begin
				data[0] <= 0;
				data[1] <= 0;
				data[2] <= 0;
				data[3] <= 0;
				data[4] <= 0;
				data[5] <= 0;
				data[6] <= 0;
				data[7] <= 0;
		end
end

always@(posedge clk) begin //start
		if(display_counter == one_hundred_mini_sec) begin
				start <= 1;
		end else if(data_state == 5'h13 && counter2 == ninety_micro_sec) begin
				start <= 0;
		end
end

always@(posedge clk) begin //stop
		if(initial_state >= 7) begin
				stop <= 1;
		end else begin
				stop <= 0;
		end
end

always@(posedge clk) begin // initial state
		if(initial_state >= 7) begin
				initial_state <= initial_state;
		end else if(counter == twenty_mini_sec) begin
				initial_state <= initial_state + 1;
		end
end

always@(posedge clk) begin //data_state
		if(start) begin
				if(data_state == 5'h13 
				&& counter2 == ninety_micro_sec) begin
						data_state <= 0;
				end else if(counter2 == ninety_micro_sec) begin
						data_state <= data_state + 1;
				end
		end else if(!start) begin
				data_state <= 0;
		end
end

always@(posedge clk) begin //20ms counter : initial
	if(!stop) begin
		if(counter == twenty_mini_sec) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;
		end
	end
end

always@(posedge clk) begin //90us counter2 : state 
	if(start) begin
		if(counter2 == ninety_micro_sec) begin
			counter2 <= 0;
		end else begin
			counter2 <= counter2 + 1;
		end
	end else if(start == 0) begin
		counter2 <= 0;
	end
end

always@(posedge clk) begin //display_counter
	if(stop) begin
		if(display_counter == one_hundred_mini_sec) begin
			display_counter <= 0;
		end else begin
			display_counter <= display_counter + 1;
		end
	end
end

always@(posedge clk) begin //LCD_RW
	if(!stop) begin //initial
		LCD_RW  <= 0;
	end 

	if(start) begin                   //0-1us
		if((counter2 >= 0 && counter2 <= 50) ||
		((counter2 >= 2250 && counter2 <= 2300))) begin //45-46us
			LCD_RW <= 0;
		end else begin
			LCD_RW <= 1;
		end
	end
end

always@(posedge clk) begin //LCD_RS
	if(!stop) begin //initial
		LCD_RS <= 0;
	end 

	if(start) begin                   //0-1us set
		if(counter2 >= 0 && counter2 <= 50) begin
			LCD_RS <= 0;
		end else if(counter2 >= 2250 && counter2 <= 2300) begin //45-46us write
			LCD_RS <= 1;
		end 
	end
end

always@(posedge clk) begin //LCD_EN
	if(!stop) begin  //40 - 270ns
		if(counter >= 2 && counter <= 14) begin
			LCD_EN  <= 1;
		end else begin
			LCD_EN  <= 0;
		end
	end

	if(start) begin  //40-270 ns
		if((counter2 >= 2 && counter2 <= 14) || 
		(counter2 >= 2252 && counter2 <= 2264)) begin //45us + 2ns - 45us + 230ns
			LCD_EN <= 1;
		end else begin
			LCD_EN <= 0;
		end
		end
	end

always@(posedge clk) begin //LCD_DATA
		if(!stop) begin
				if(counter >= 10 && counter <= 50) begin 
						case (initial_state)
							4'h1 : LCD_DATA <= 8'h30; 
							4'h2: LCD_DATA <= 8'h38; 
							4'h3: LCD_DATA <= 8'h08; 
							4'h4: LCD_DATA <= 8'h01; 
							4'h5: LCD_DATA <= 8'h06; 
							4'h6: LCD_DATA <= 8'h0c; 
							default : LCD_DATA  <= 8'h30; 
						endcase
				end
		end

		if(start) begin 
				if(counter2 >= 10 && counter2 <= 50) begin //address
						case (data_state)
							5'h00 : LCD_DATA  <= 8'hcf;
							5'h01 : LCD_DATA  <= 8'hce;
							5'h02 : LCD_DATA  <= 8'hcd; // -
							5'h03 : LCD_DATA  <= 8'hcc;
							5'h04 : LCD_DATA  <= 8'hcb;
							5'h05 : LCD_DATA  <= 8'hca; // -
							5'h06 : LCD_DATA  <= 8'hc9;
							5'h07 : LCD_DATA  <= 8'hc8;
							5'h08 : LCD_DATA  <= 8'hc7;// -
							5'h09 : LCD_DATA  <= 8'hc6;
							5'h0a : LCD_DATA  <= 8'hc5; 
							
							5'h0b : LCD_DATA  <= 8'h8f;// words adddress
							5'h0c : LCD_DATA  <= 8'h8e; 
							5'h0d : LCD_DATA  <= 8'h8d;
							5'h0e : LCD_DATA  <= 8'h8c;
							5'h0f : LCD_DATA  <= 8'h8b;
							5'h10 : LCD_DATA  <= 8'h8a;
							5'h11 : LCD_DATA  <= 8'h89;
							5'h12 : LCD_DATA  <= 8'h87;
							5'h13 : LCD_DATA  <= 8'h86;
							default : LCD_DATA  <= LCD_DATA ;
						endcase
				end else if(counter2 >= 2260 && counter2 <= 2300) begin
						if (data_state < 5'h0b && data_state != 5'h02 && data_state != 5'h05 && data_state != 5'h08) begin
								case (number)
									4'h0 : LCD_DATA  <= 8'h30; 
									4'h1 : LCD_DATA  <= 8'h31; 
									4'h2 : LCD_DATA  <= 8'h32;
									4'h3 : LCD_DATA  <= 8'h33;
									4'h4 : LCD_DATA  <= 8'h34;
									4'h5 : LCD_DATA  <= 8'h35;
									4'h6 : LCD_DATA  <= 8'h36;
									4'h7 : LCD_DATA  <= 8'h37;
									4'h8 : LCD_DATA  <= 8'h38;
									4'h9 : LCD_DATA  <= 8'h39;
									4'ha : LCD_DATA  <= 8'h41;
									4'hb : LCD_DATA  <= 8'h42;
									4'hc : LCD_DATA  <= 8'h43;
									4'hd : LCD_DATA  <= 8'h44;
									4'he : LCD_DATA  <= 8'h45;
									4'hf : LCD_DATA  <= 8'h46;
								endcase
						end else if(data_state == 5'h02 || data_state == 5'h05 || data_state == 5'h08) begin
								LCD_DATA  <= 8'h2d;
						end else if(data_state > 5'h0a) begin
								case (data_state)
										5'h0b : LCD_DATA  <= 8'h52;// R
										5'h0c : LCD_DATA  <= 8'h45; //E
										5'h0d : LCD_DATA  <= 8'h44;//D
										5'h0e : LCD_DATA  <= 8'h4f;//O
										5'h0f : LCD_DATA  <= 8'h43;//C
										5'h10 : LCD_DATA  <= 8'h45;//E
										5'h11 : LCD_DATA  <= 8'h44;//D
										5'h12 : LCD_DATA  <= 8'h52;//R
										5'h13 : LCD_DATA  <= 8'h49;//I
								endcase
						end
				end
		end		
end

endmodule
