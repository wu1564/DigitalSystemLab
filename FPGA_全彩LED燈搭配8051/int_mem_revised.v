module  int_mem_revised(        
clk, 
                        addr,     
                        data_in,
                        data_out,
                        we1_n,    
                        we2_n,   
                        rd_n
); 
input           clk;                        
input   [7:0]   addr;         
input   [7:0]   data_in;     
output  [7:0]   data_out;  
input           we1_n;
input           we2_n;
input           rd_n;   
reg     [7:0]   mem [255:0];
wire [7:0] mem_8 = mem[8];
wire [7:0] mem_9 = mem[9];
reg [31:0] i = 0;
reg [31:0] count =  0;
wire start = (count == 10) ? 1 : 0;
wire initial_finish = (start) ? 1 : 0;
wire we2_n_dly;
assign we2_n_dly = we2_n;



always@(posedge clk) begin
	if(count == 10) begin
		count <= count;
	end else begin
		count <= count + 1;
	end
end

always@(posedge clk) begin
  if(!initial_finish) begin
		for (i = 0; i <= 255; i = i + 1) begin
			mem[i] = 8'h00;
		end
	end else begin
		if(!we1_n | !we2_n_dly)   
			mem[addr] <= data_in;
	end
end

//assign data_out = rd_n ? 8'hxx : mem[addr];
assign data_out = mem[addr]; 
    
endmodule  
