module hw1(
	clk,
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5,
	KEY
);

input clk;
input wire[1:0] KEY;
output wire[6:0] HEX0,
	HEX1,
	HEX2,
	HEX3,
	HEX4,
	HEX5;

reg[3:0] ten_mini_sec_unit, ten_mini_sec_tens, sec_unit, sec_tens, min_unit, min_tens;
reg[31:0] count = 0;
reg stop = 0;
wire finish;

debounce buttomDebounce(.clk(clk),.buttom(KEY[0]),.finish(finish));
SEG_HEX seg1(.iDIG(ten_mini_sec_unit),.oHEX_D(HEX0));
SEG_HEX seg2(.iDIG(ten_mini_sec_tens),.oHEX_D(HEX1));
SEG_HEX seg3(.iDIG(sec_unit),.oHEX_D(HEX2));
SEG_HEX seg4(.iDIG(sec_tens),.oHEX_D(HEX3));
SEG_HEX seg5(.iDIG(min_unit),.oHEX_D(HEX4));
SEG_HEX seg6(.iDIG(min_tens),.oHEX_D(HEX5));

always@(posedge clk or negedge KEY[1] or posedge stop) begin
		if(!KEY[1]) begin
				count <= 0;
		end else if(stop) begin
				count <= count;
		end else if(count == 5) begin
				count <= 0;
		end else 
				count <= count + 1;
end

always@(posedge finish) begin
		stop <= stop + 1;
end

always@(posedge clk or negedge KEY[1]) begin //10 mini sec unit
		if(!KEY[1]) begin
			ten_mini_sec_unit <= 0;
		end else if(ten_mini_sec_unit == 9 && count == 5) begin
			ten_mini_sec_unit <= 0;
		end else if(count == 5 && !stop) begin
			ten_mini_sec_unit <= ten_mini_sec_unit + 1;
		end
end

always@(posedge clk or negedge KEY[1]) begin // 10 mini sec tens
		if(!KEY[1]) begin
			ten_mini_sec_tens <= 0;
		end else if(ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && count == 5) begin
			ten_mini_sec_tens <= 0;
		end else if(ten_mini_sec_unit == 9 && count == 5) begin
			ten_mini_sec_tens <= ten_mini_sec_tens + 1;
		end
end

always@ (posedge clk or negedge KEY[1]) begin //sec unit
		if(!KEY[1])begin
			sec_unit <= 0;
		end else if (sec_unit == 9 && ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && count == 5) begin
			sec_unit <= 0;
		end else if(ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && count == 5) begin
			sec_unit <= sec_unit + 1;
		end 
 end

always@ (posedge clk or negedge KEY[1]) begin //sec tens
		if(!KEY[1])begin
			sec_tens <= 0;
		end else if (ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && sec_unit == 9 && sec_tens == 5 && count == 5) begin
			sec_tens <= 0;
		end else if(sec_unit == 9 && count == 5 && ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9) begin
			sec_tens <= sec_tens + 1;
		end
 end

 always@(posedge clk or negedge KEY[1]) begin //min unit
		if(!KEY[1]) begin
			min_unit <= 0;
		end else if(ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && sec_unit == 9 && sec_tens == 5 && min_unit == 9&& count == 5) begin 
			min_unit <= 0;
		end else if (sec_unit == 9 && sec_tens == 5 && count == 5 && ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9) begin
			min_unit <= min_unit + 1;
		end
 end
 
 always@(posedge clk or negedge KEY[1]) begin // min tens
		if(!KEY[1]) begin
			min_tens <= 0;
		end else if(ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && sec_unit == 9 && sec_tens == 5 && min_unit == 9 && min_tens == 5 && count == 5) begin
			min_tens <= 0;
		end else if(min_unit == 9 && count == 5 && ten_mini_sec_unit == 9 && ten_mini_sec_tens == 9 && sec_unit == 9 && sec_tens == 5) begin
			min_tens <= min_tens + 1;
		end
 end
 
endmodule
