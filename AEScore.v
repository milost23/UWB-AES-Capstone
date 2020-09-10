// Milos Trbic
// AES Core - Top level Module which calls the submodules
// Designed for 128-bit ENCRYPTION currently
// Last Updated: 8/16/2020

module AEScore #(parameter KEY_LENGTH = 128)
					(input[127:0] data_in,
					input clk,
					input[127:0] key, 
					output[127:0] data_out);

	// Define parameters:
	// Number of rounds depending on that key length
	// Can only be 10 or 14, so if one is false it has to be the other one
	parameter NUM_ROUNDS = (KEY_LENGTH == 128) ? 10 : 14;
	
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