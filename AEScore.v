// Milos Trbic
// AES Core - Top level Module which calls the submodules
// Designed for 128-bit ENCRYPTION currently
// Last Updated: 9/12/2020

module AEScore
	#(
	parameter KEY_WIDTH = 128,			// size of key, either 128 or 256 bit
	parameter DATA_WIDTH = 128			// size of data, always 128 bit
	)
	(
	input clk,
	input rst, 								// active low
	input[DATA_WIDTH-1:0] data_in,	// unencrypted data in
	input[KEY_WIDTH-1:0] key, 			// key to be used for encryption
	output[DATA_WIDTH-1:0] data_out	// ciphertext out
	); 										// end signals

	// Define parameter:
	// Number of rounds depending on that key length
	// Can only be 10 or 14 rounds, so if 128 bit size is false, it has to be 256 bit
	localparam NUM_ROUNDS = (KEY_LENGTH == 128) ? 10 : 14;
	
	// XOR with the key to establish the state ("Round 0")
	// assign state = data_in ^ key;
	
	// generate/for loop for rounds 1-9
	genvar i;
	generate
		for (i = 0; i < NUM_ROUNDS; i = i + 1) begin :name
		// call Round function which is a single round of encrypt
		end
	endgenerate
	
	// Final round:
	// SubByte
	// ShiftRow
	// AddRoundKey
	// assign data_out = ...
	
endmodule 