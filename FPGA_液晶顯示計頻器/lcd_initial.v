module lcd_controller(
	clk,
	LCD_EN,
	LCD_RW,
	LCD_RS,
	LCD_DATA,
	oneSecCount,
	data0,
	data1,
	data2,
	data3,
	data4,
	data5,
	data6,
	data7
);

parameter one_sec = 50000000; //100mini sec
parameter one_Micro_Sec = 50;
parameter ninety_micro_sec = 4500;
parameter twenty_mini_sec = 1000000;

input clk;
input [31:0] oneSecCount;
input [3:0]data0,data1,data2,data3,data4,data5,data6,data7;
output reg LCD_EN ,LCD_RW ,LCD_RS ;
output reg [7:0] LCD_DATA ;

reg[3:0] initial_state = 0,data_state = 0;
reg[31:0] counter = 0, counter2 = 0;
reg stop = 0,start = 0;
reg [3:0] data[7:0];
wire [3:0] number;

assign number = (data_state == 4'h2) ? data[0] :
				  (data_state == 4'h3) ? data[1] :
				  (data_state == 4'h4) ? data[2] :
				  (data_state == 4'h5) ? data[3] :
				  (data_state == 4'h6) ? data[4] :
				  (data_state == 4'h7) ? data[5] :
				  (data_state == 4'h8) ? data[6] :
				  (data_state == 4'h9) ? data[7] : 0;
					  
always@(posedge clk) begin //start
	if(oneSecCount == one_sec) begin
		data[0] <= data0;
		data[1] <= data1;
		data[2] <= data2;
		data[3] <= data3;
		data[4] <= data4;
		data[5] <= data5;
		data[6] <= data6;
		data[7] <= data7;
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
	if(oneSecCount == one_sec) begin
		start <= 1;
	end else if(data_state == 10) begin
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
		if(data_state == 10 
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
					4'h0 : LCD_DATA <= 8'hcf;
					4'h1 : LCD_DATA <= 8'hce;
					4'h2 : LCD_DATA <= 8'hcd;
					4'h3 : LCD_DATA <= 8'hcc;
					4'h4 : LCD_DATA <= 8'hcb;
					4'h5 : LCD_DATA <= 8'hca;
					4'h6 : LCD_DATA <= 8'hc9;
					4'h7 : LCD_DATA <= 8'hc8;
					4'h8 : LCD_DATA <= 8'hc7;
					4'h9 : LCD_DATA <= 8'hc6;
					default : LCD_DATA <= 8'hc6;
				endcase
		end else if(counter2 >= 2260 && counter2 <= 2300) begin
			if (data_state > 1) begin
				case (number)
					4'h0 : LCD_DATA <= 8'b00110000; 
					4'h1 : LCD_DATA <= 8'b00110001; 
					4'h2 : LCD_DATA <= 8'b00110010;
					4'h3 : LCD_DATA <= 8'b00110011;
					4'h4 : LCD_DATA <= 8'b00110100;
					4'h5 : LCD_DATA <= 8'b00110101;
					4'h6 : LCD_DATA <= 8'b00110110;
					4'h7 : LCD_DATA <= 8'b00110111;
					4'h8 : LCD_DATA <= 8'b00111000;
					4'h9 : LCD_DATA <= 8'b00111001;
				endcase
			end else if(!data_state) begin
				LCD_DATA  <= 8'h7a;
			end else if(data_state == 1) begin
				LCD_DATA  <= 8'h68;
			end 
		end
	end		
end //always

endmodule
