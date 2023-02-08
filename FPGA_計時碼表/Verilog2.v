module debounce(
	clk,
	buttom,
	finish
);

input clk,buttom;
output reg finish;

reg [31:0] count = 0;
reg [1:0] temp = 2'b00;

always@(posedge clk) begin
	if(count == 5) begin
		count <= 0;
	end else 
		count <= count + 1;
end

always@(posedge clk) begin
	if(count == 5) begin 
		temp[0] <= buttom;
		temp[1] <= temp[0];
	end
end

always@(posedge clk) begin
	if(~temp[0] && temp[1]) begin
		finish <= 1;
	end else 
		finish <= 0;
end

endmodule
