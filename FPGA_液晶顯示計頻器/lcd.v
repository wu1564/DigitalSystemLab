module hw2(
	CLOCK2_50,
	SMA_CLKIN,
	LCD_EN,
	LCD_RW,
	LCD_RS ,
	LCD_ON ,
	LCD_BLON ,
	LCD_DATA
);

input CLOCK2_50,SMA_CLKIN ;
output LCD_EN ,LCD_RW ,LCD_RS ,LCD_ON ,LCD_BLON ;
output [7:0] LCD_DATA ;

parameter one_sec = 50000000; //100 min sec

reg[31:0] counter = 0;
reg[3:0] countFreq0 = 0,countFreq1 = 0,countFreq2 = 0,countFreq3 = 0,countFreq4 = 0,countFreq5 = 0,countFreq6 = 0,countFreq7 = 0;
reg[1:0] temp = 0;
wire sma_clk_neg_edge = ~temp[0] && temp[1];
assign LCD_BLON = 1;
assign LCD_ON = 1;

lcd_controller l(	.clk(CLOCK2_50),
	.LCD_EN(LCD_EN),
	.LCD_RW(LCD_RW),
	.LCD_RS(LCD_RS),
	.LCD_DATA(LCD_DATA),
	.oneSecCount(counter),
	.data0(countFreq0),
	.data1(countFreq1),
	.data2(countFreq2),
	.data3(countFreq3),
	.data4(countFreq4),
	.data5(countFreq5),
	.data6(countFreq6),
	.data7(countFreq7)
);

always@(posedge CLOCK2_50) begin
	if(counter == one_sec) begin
		temp <= 0;
	end else begin
		temp[0] <= SMA_CLKIN ;
		temp[1] <= temp[0];
	end
end

always@(posedge CLOCK2_50) begin
		if(counter == one_sec) begin
				counter <= 0;
		end else begin
				counter <= counter + 1;
		end
end

always@(posedge CLOCK2_50) begin //1
		if(counter == one_sec) begin
				countFreq0 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9) begin
				countFreq0 <= 0;
		end else if(sma_clk_neg_edge) begin
				countFreq0 <= countFreq0 + 1;
		end
end

always@(posedge CLOCK2_50) begin //10
		if(counter == one_sec) begin
				countFreq1 <= 0;
		end else if(sma_clk_neg_edge && countFreq1 == 9 && countFreq0 == 9) begin
				countFreq1 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9) begin
				countFreq1 <= countFreq1 + 1;
		end
end

always@(posedge CLOCK2_50) begin //100
		if(counter == one_sec) begin
				countFreq2 <= 0;
		end else if(sma_clk_neg_edge && countFreq1 == 9 && countFreq0 == 9 && countFreq2 == 9) begin
				countFreq2 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9) begin
				countFreq2 <= countFreq2 + 1;
		end
end

always@(posedge CLOCK2_50) begin //1000
		if(counter == one_sec) begin
				countFreq3 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9
		&& countFreq3 == 9 ) begin
				countFreq3 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9) begin
				countFreq3 <= countFreq3 + 1;
		end
end

always@(posedge CLOCK2_50) begin //1 0000
		if(counter == one_sec) begin
				countFreq4 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9
		&& countFreq3 == 9 && countFreq4 == 9 ) begin
				countFreq4 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 
		&& countFreq2 == 9 && countFreq3 == 9 ) begin
				countFreq4 <= countFreq4 + 1;
		end
end

always@(posedge CLOCK2_50) begin //10 0000
		if(counter == one_sec) begin
				countFreq5 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9
		&& countFreq3 == 9 && countFreq4 == 9 && countFreq5 == 9) begin
				countFreq5 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 
		&& countFreq2 == 9 && countFreq3 == 9 && countFreq4 == 9) begin
				countFreq5 <= countFreq5 + 1;
		end
end

always@(posedge CLOCK2_50) begin //100 0000
		if(counter == one_sec) begin
				countFreq6 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9
		&& countFreq3 == 9 && countFreq4 == 9 && countFreq5 == 9 && countFreq6 == 9) begin
				countFreq6 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 
		&& countFreq2 == 9 && countFreq3 == 9 && countFreq4 == 9 && countFreq5 == 9) begin
				countFreq6 <= countFreq6 + 1;
		end
end

always@(posedge CLOCK2_50) begin //1000 0000
		if(counter == one_sec) begin
				countFreq7 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 && countFreq2 == 9
		&& countFreq3 == 9 && countFreq4 == 9 && countFreq5 == 9 
		&& countFreq6 == 9 && countFreq7 == 9) begin
				countFreq7 <= 0;
		end else if(sma_clk_neg_edge && countFreq0 == 9 && countFreq1 == 9 
		&& countFreq2 == 9 && countFreq3 == 9 && countFreq4 == 9 && countFreq5 == 9
		&& countFreq6 == 9) begin
				countFreq7 <= countFreq7 + 1;
		end
end


endmodule






