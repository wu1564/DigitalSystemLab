module SEG
(
	iDIG,
	oHEX_D
);

input [3:0] iDIG;
output [6:0] oHEX_D;   
reg [6:0] oHEX_D;

always @(iDIG) 
    begin
			case(iDIG)
			4'h0: oHEX_D <= 7'b1000000; //0  
			4'h1: oHEX_D <= 7'b1111001; //1
			4'h2: oHEX_D <= 7'b0100100; //2
			4'h3: oHEX_D <= 7'b0110000; //3
			4'h4: oHEX_D <= 7'b0011001; //4
			4'h5: oHEX_D <= 7'b0010010; //5
			4'h6: oHEX_D <= 7'b0000010; //6
			4'h7: oHEX_D <= 7'b1111000; //7
			4'h8: oHEX_D <= 7'b0000000; //8
			4'h9: oHEX_D <= 7'b0011000; //9
			4'ha: oHEX_D <= 7'b0001000; //a
			4'hb: oHEX_D <= 7'b0000011; //b
			4'hc: oHEX_D <= 7'b1000110; //c
			4'hd: oHEX_D <= 7'b0100001; //d
			4'he: oHEX_D <= 7'b0000110; //e
			4'hf: oHEX_D <= 7'b0001110; //f
	     default: oHEX_D <= 7'b1000000; //0
			endcase
		end

endmodule
