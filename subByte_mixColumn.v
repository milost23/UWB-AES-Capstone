// Vi Ho | Milos Trbic | Hamidou Diallo
// AES Capstone - Joseph Decuir
// Updated: 9/15/2020
// This module combines the SubByte and MixColumn operations of AES encrypt.
// 
// UPDATES: Changed to 20-bit design to avoid using logic entirely
// Added parameters as well as clock and reset.

module subByte_mixColumn
	#(	
	parameter DATA_WIDTH = 128,		// Size of data
	parameter ROM_WIDTH = 20		// Width of memory element, i.e. M20k has 20 bit width
	)
	(
	input clk,
	input rst,				// active low
	input sb_mc_valid_in,			// Valid bit in. When high, data is valid and should be processed
	input [DATA_WIDTH-1:0] state_in,	// 128 bit state input to undergo combined SubByte and MixColumn function using LUT
	output reg [DATA_WIDTH-1:0] state_out,	// 128 bit state output which has gone through SubByte and MixColumn
	output reg sb_mc_valid_out		// Valid bit out. When high, data is valid and can be used in another function
	);
	
	// 20-bit data, 256 rows in data_ROM 
	reg [ROM_WIDTH-1:0] data_ROM [0:255];
	reg [319:0] adress;

	initial $readmemh("C:\\Users\\milos\\OneDrive\\Documents\\Capstone I\\aesFull\\rom.txt", data_ROM); 
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			sb_mc_valid_out <= 1'b0;
			sb_mc_valid_out <= sb_mc_valid_in;
		end else begin 
			if (sb_mc_valid_in) begin
				 
				 adress[0 +:20]		<= data_ROM[state_in[127:120]];
				 adress[20 +:20]	<= data_ROM[state_in[119:112]];
				 adress[40 +:20]	<= data_ROM[state_in[111:104]];
				 adress[60 +:20]	<= data_ROM[state_in[103:96]];

				 state_out[127:120] 	<= ({adress[18:16],adress[11:10],adress[13],adress[9:8]})^(adress[20 +:8])^(adress[52 +:8])^(adress[72 +:8]);
				 state_out[119:112] 	<= (adress[12 +:8])^({adress[20+18:20+16],adress[20+11:20+10],adress[20+13],adress[20+9:20+8]})^(adress[40 +:8])^(adress[72 +:8]);
				 state_out[111:104] 	<= (adress[12 +:8])^(adress[32 +:8])^({adress[40+18:40+16],adress[40+11:40+10],adress[40+13],adress[40+9:40+8]})^(adress[60+:8]);
				 state_out[103:96]  	<= (adress[0 +:8])^(adress[32+:8])^(adress[52 +:8])^({adress[60+18:60+16],adress[60+11:60+10],adress[60+13],adress[60+9:60+8]});

				 //
				 adress[80 +:20]	<= data_ROM[state_in[95:88]];
				 adress[100 +:20]	<= data_ROM[state_in[87:80]];
				 adress[120 +:20] 	<= data_ROM[state_in[79:72]];
				 adress[140 +:20] 	<= data_ROM[state_in[71:64]];

				 state_out[95:88] 	<= ({adress[80+18:80+16],adress[80+11:80+10],adress[80+13],adress[80+9:80+8]})^(adress[100 +:8])^(adress[120+12 +:8])^(adress[140+12 +:8]);
				 state_out[87:80] 	<= (adress[80+12 +:8])^({adress[100+18:100+16],adress[100+11:100+10],adress[100+13],adress[100+9:100+8]})^(adress[120 +:8])^(adress[140+12 +:8]);
				 state_out[79:72] 	<= (adress[80+12 +:8])^(adress[100+12 +:8])^({adress[120+18:120+16],adress[120+11:120+10],adress[120+13],adress[120+9:120+8]})^(adress[140 +:8]);
				 state_out[71:64] 	<= (adress[80 +:8])^(adress[100+12 +:8])^(adress[120+12 +:8])^({adress[140+18:140+16],adress[140+11:140+10],adress[140+13],adress[140+9:140+8]});

				 //
				 adress[160 +:20] 	<= data_ROM[state_in[63:56]];
				 adress[180 +:20] 	<= data_ROM[state_in[55:48]];
				 adress[200 +:20] 	<= data_ROM[state_in[47:40]];
				 adress[220 +:20] 	<= data_ROM[state_in[39:32]];

				 state_out[63:56] 	<= ({adress[160+18:160+16],adress[160+11:160+10],adress[160+13],adress[160+9:160+8]})^(adress[180 +:8])^(adress[200+12 +:8])^(adress[220+12 +:8]);
				 state_out[55:48] 	<= (adress[160+12 +:8])^({adress[180+18:180+16],adress[180+11:180+10],adress[180+13],adress[180+9:180+8]})^(adress[200 +:8])^(adress[220+12 +:8]);
				 state_out[47:40] 	<= (adress[160+12 +:8])^(adress[180+12 +:8])^({adress[200+18:200+16],adress[200+11:200+10],adress[200+13],adress[200+9:200+8]})^(adress[220 +:8]);
				 state_out[39:32] 	<= (adress[160 +:8])^(adress[180+12 +:8])^(adress[200+12 +:8])^({adress[220+18:220+16],adress[220+11:220+10],adress[220+13],adress[220+9:220+8]});

				 //
				 adress[240 +:20] 	<= data_ROM[state_in[31:24]];
				 adress[260 +:20] 	<= data_ROM[state_in[23:16]];
				 adress[280 +:20] 	<= data_ROM[state_in[15:8]];
				 adress[300 +:20] 	<= data_ROM[state_in[7:0]];

				 state_out[31:24] 	<= ({adress[240+18:240+16],adress[240+11:240+10],adress[240+13],adress[240+9:240+8]})^(adress[260 +:8])^(adress[280+12 +:8])^(adress[300+12 +:8]);
				 state_out[23:16] 	<= (adress[240+12 +:8])^({adress[260+18:260+16],adress[260+11:260+10],adress[260+13],adress[260+9:260+8]})^(adress[280 +:8])^(adress[300+12 +:8]);
				 state_out[15:8]  	<= (adress[240+12 +:8])^(adress[260+12 +:8])^({adress[280+18:280+16],adress[280+11:280+10],adress[280+13],adress[280+9:280+8]})^(adress[300 +:8]);
				 state_out[7:0]   	<= (adress[240 +:8])^(adress[260+12 +:8])^(adress[280+12 +:8])^({adress[300+18:300+16],adress[300+11:300+10],adress[300+13],adress[300+9:300+8]});

				 //
				 adress[0 +:20]		<= data_ROM[state_in[127:120]];
				 adress[20 +:20] 	<= data_ROM[state_in[119:112]];
				 adress[40 +:20] 	<= data_ROM[state_in[111:104]];
				 adress[60 +:20] 	<= data_ROM[state_in[103:96]];
				  
				 state_out[127:120] 	<= ({adress[18:16],adress[11:10],adress[13],adress[9:8]})^(adress[20 +:8])^(adress[52 +:8])^(adress[72 +:8]);
				 state_out[119:112] 	<= (adress[12 +:8])^({adress[20+18:20+16],adress[20+11:20+10],adress[20+13],adress[20+9:20+8]})^(adress[40 +:8])^(adress[72 +:8]);
				 state_out[111:104] 	<= (adress[12 +:8])^(adress[32 +:8])^({adress[40+18:40+16],adress[40+11:40+10],adress[40+13],adress[40+9:40+8]})^(adress[60+:8]);
				 state_out[103:96]  	<= (adress[0 +:8])^(adress[32+:8])^(adress[52 +:8])^({adress[60+18:60+16],adress[60+11:60+10],adress[60+13],adress[60+9:60+8]});

				 //
				 adress[80 +:20]	<= data_ROM[state_in[95:88]];
				 adress[100 +:20]	<= data_ROM[state_in[87:80]];
				 adress[120 +:20]	<= data_ROM[state_in[79:72]];
				 adress[140 +:20]	<= data_ROM[state_in[71:64]];

				 state_out[95:88] 	<= ({adress[80+18:80+16],adress[80+11:80+10],adress[80+13],adress[80+9:80+8]})^(adress[100 +:8])^(adress[120+12 +:8])^(adress[140+12 +:8]);
				 state_out[87:80] 	<= (adress[80+12 +:8])^({adress[100+18:100+16],adress[100+11:100+10],adress[100+13],adress[100+9:100+8]})^(adress[120 +:8])^(adress[140+12 +:8]);
				 state_out[79:72] 	<= (adress[80+12 +:8])^(adress[100+12 +:8])^({adress[120+18:120+16],adress[120+11:120+10],adress[120+13],adress[120+9:120+8]})^(adress[140 +:8]);
				 state_out[71:64] 	<= (adress[80 +:8])^(adress[100+12 +:8])^(adress[120+12 +:8])^({adress[140+18:140+16],adress[140+11:140+10],adress[140+13],adress[140+9:140+8]});

				 //
				 adress[160 +:20]	<= data_ROM[state_in[63:56]];
				 adress[180 +:20] 	<= data_ROM[state_in[55:48]];
				 adress[200 +:20] 	<= data_ROM[state_in[47:40]];
				 adress[220 +:20] 	<= data_ROM[state_in[39:32]];

				 state_out[63:56] 	<= ({adress[160+18:160+16],adress[160+11:160+10],adress[160+13],adress[160+9:160+8]})^(adress[180 +:8])^(adress[200+12 +:8])^(adress[220+12 +:8]);
				 state_out[55:48] 	<= (adress[160+12 +:8])^({adress[180+18:180+16],adress[180+11:180+10],adress[180+13],adress[180+9:180+8]})^(adress[200 +:8])^(adress[220+12 +:8]);
				 state_out[47:40] 	<= (adress[160+12 +:8])^(adress[180+12 +:8])^({adress[200+18:200+16],adress[200+11:200+10],adress[200+13],adress[200+9:200+8]})^(adress[220 +:8]);
				 state_out[39:32] 	<= (adress[160 +:8])^(adress[180+12 +:8])^(adress[200+12 +:8])^({adress[220+18:220+16],adress[220+11:220+10],adress[220+13],adress[220+9:220+8]});

				 //
				 adress[240 +:20]	<= data_ROM[state_in[31:24]];
				 adress[260 +:20]	<= data_ROM[state_in[23:16]];
				 adress[280 +:20] 	<= data_ROM[state_in[15:8]];
				 adress[300 +:20] 	<= data_ROM[state_in[7:0]];
				 
				 state_out[31:24] 	<= ({adress[240+18:240+16],adress[240+11:240+10],adress[240+13],adress[240+9:240+8]})^(adress[260 +:8])^(adress[280+12 +:8])^(adress[300+12 +:8]);
				 state_out[23:16] 	<= (adress[240+12 +:8])^({adress[260+18:260+16],adress[260+11:260+10],adress[260+13],adress[260+9:260+8]})^(adress[280 +:8])^(adress[300+12 +:8]);
				 state_out[15:8]  	<= (adress[240+12 +:8])^(adress[260+12 +:8])^({adress[280+18:280+16],adress[280+11:280+10],adress[280+13],adress[280+9:280+8]})^(adress[300 +:8]);
				 state_out[7:0]		<= (adress[240 +:8])^(adress[260+12 +:8])^(adress[280+12 +:8])^({adress[300+18:300+16],adress[300+11:300+10],adress[300+13],adress[300+9:300+8]});

			end
			sb_mc_valid_out <= sb_mc_valid_in;
		end
	end										
endmodule
