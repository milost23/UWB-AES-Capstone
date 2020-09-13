// Vi Ho | Milos Trbic | Hamidou Diallo
// AES Capstone - Joseph Decuir
// Updated: 9/12/2020
// This module combines the SubByte and MixColumn operations of AES encrypt.
// 
// UPDATES:

module subByte_mixColumn
	#(parameter DATA_WIDTH = 128)
	(
	input sb_mc_valid_in,
	input [127:0] state_in,
	output reg [127:0] state_out,
	output reg sb_mc_valid_out
	);
	
	// 16-bit data, 256 rows in data_ROM 
	reg [15:0] data_ROM [0:255];

	initial $readmemh("C:\\Users\\milos\\OneDrive\\Documents\\Capstone I\\aesFull\\rom.txt", data_ROM); 
	
	always @(*) begin
		if (sb_mc_valid_in) begin
			//First Column
			state_out[127:120] = ((data_ROM	[state_in[127:120]][15]) ?
										((data_ROM	[state_in[127:120]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[127:120]][15:8] << 1)) ^
										(data_ROM	[state_in[119:112]][7:0]) ^
										(data_ROM	[state_in[111:104]][15:8]) ^
										(data_ROM	[state_in[103:96]][15:8]);
											
			state_out[119:112] = (data_ROM	[state_in[127:120]][15:8]) ^
										((data_ROM	[state_in[119:112]][15]) ?
										((data_ROM	[state_in[119:112]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[119:112]][15:8] << 1)) ^
										(data_ROM	[state_in[111:104]][7:0]) ^
										(data_ROM	[state_in[103:96]][15:8]);
												
			state_out[111:104] = (data_ROM	[state_in[127:120]][15:8]) ^
										(data_ROM	[state_in[119:112]][15:8]) ^
										((data_ROM	[state_in[111:104]][15]) ?
										((data_ROM	[state_in[111:104]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[111:104]][15:8] << 1)) ^
										(data_ROM	[state_in[103:96]][7:0]);
												
			state_out[103:96]  = (data_ROM	[state_in[127:120]][7:0]) ^
										(data_ROM	[state_in[119:112]][15:8]) ^
										(data_ROM	[state_in[111:104]][15:8]) ^
										((data_ROM	[state_in[103:96]][15] ?
										((data_ROM	[state_in[103:96]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[103:96]][15:8] << 1)));


			//Second Column
			state_out[95:88] 	 =	((data_ROM	[state_in[95:88]][15]) ?
										((data_ROM	[state_in[95:88]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[95:88]][15:8] << 1)) ^
										(data_ROM	[state_in[87:80]][7:0]) ^
										(data_ROM	[state_in[79:72]][15:8]) ^
										(data_ROM	[state_in[71:64]][15:8]);
												
			state_out[87:80] 	 = (data_ROM	[state_in[95:88]][15:8]) ^
										((data_ROM	[state_in[87:80]][15]) ?
										((data_ROM	[state_in[87:80]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[87:80]][15:8] << 1)) ^
										(data_ROM	[state_in[79:72]][7:0]) ^
										(data_ROM	[state_in[71:64]][15:8]);
												
			state_out[79:72] 	 = (data_ROM	[state_in[95:88]][15:8]) ^
										(data_ROM	[state_in[87:80]][15:8]) ^
										((data_ROM	[state_in[79:72]][15]) ?
										((data_ROM	[state_in[79:72]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[79:72]][15:8] << 1)) ^
										(data_ROM	[state_in[71:64]][7:0]);
												
			state_out[71:64]   = (data_ROM	[state_in[95:88]][7:0]) ^
										(data_ROM	[state_in[87:80]][15:8]) ^
										(data_ROM	[state_in[79:72]][15:8]) ^
										((data_ROM	[state_in[71:64]][15]) ?
										((data_ROM	[state_in[71:64]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[71:64]][15:8] << 1));

			//Third Column
			state_out[63:56]   = ((data_ROM	[state_in[63:56]][15]) ?
										((data_ROM	[state_in[63:56]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[63:56]][15:8] << 1)) ^
										(data_ROM	[state_in[55:48]][7:0]) ^
										(data_ROM	[state_in[47:40]][15:8]) ^
										(data_ROM	[state_in[39:32]][15:8]);
										
			state_out[55:48]   =	(data_ROM	[state_in[63:56]][15:8]) ^
										((data_ROM	[state_in[55:48]][15]) ?
										((data_ROM	[state_in[55:48]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[55:48]][15:8] << 1)) ^
										(data_ROM	[state_in[47:40]][7:0]) ^
										(data_ROM	[state_in[39:32]][15:8]);
												
			state_out[47:40]   =	(data_ROM	[state_in[63:56]][15:8]) ^
										(data_ROM	[state_in[55:48]][15:8]) ^
										((data_ROM	[state_in[47:40]][15]) ?
										((data_ROM	[state_in[47:40]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[47:40]][15:8] << 1)) ^
										(data_ROM	[state_in[39:32]][7:0]);
												
			state_out[39:32]   = (data_ROM	[state_in[63:56]][7:0]) ^
										(data_ROM	[state_in[55:48]][15:8]) ^
										(data_ROM	[state_in[47:40]][15:8]) ^
										((data_ROM	[state_in[39:32]][15]) ?
										((data_ROM	[state_in[39:32]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[39:32]][15:8] << 1));

			//Fourth Column
			state_out[31:24]	 = ((data_ROM	[state_in[31:24]][15]) ?
										((data_ROM	[state_in[31:24]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[31:24]][15:8] << 1)) ^
										(data_ROM	[state_in[23:16]][7:0]) ^
										(data_ROM	[state_in[15:8]][15:8]) ^
										(data_ROM	[state_in[7:0]][15:8]);
												
			state_out[23:16]	 =	(data_ROM	[state_in[31:24]][15:8]) ^
										((data_ROM	[state_in[23:16]][15]) ?
										((data_ROM	[state_in[23:16]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[23:16]][15:8] << 1)) ^
										(data_ROM	[state_in[15:8]][7:0]) ^
										(data_ROM	[state_in[7:0]][15:8]);
												
			state_out[15:8]	 = (data_ROM	[state_in[31:24]][15:8]) ^
										(data_ROM	[state_in[23:16]][15:8]) ^
										((data_ROM	[state_in[15:8]][15]) ?
										((data_ROM	[state_in[15:8]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[15:8]][15:8] << 1)) ^
										(data_ROM	[state_in[7:0]][7:0]);
												
			state_out[7:0]		 =	(data_ROM	[state_in[31:24]][7:0]) ^
										(data_ROM	[state_in[23:16]][15:8]) ^
										(data_ROM	[state_in[15:8]][15:8]) ^
										((data_ROM	[state_in[7:0]][15]) ?
										((data_ROM	[state_in[7:0]][15:8] << 1) ^ 8'h1b) :
										(data_ROM	[state_in[7:0]][15:8] << 1));
		end else begin
			state_out = {DATA_WIDTH{1'b0}};
		end
		sb_mc_valid_out = sb_mc_valid_in;
	end										
endmodule
