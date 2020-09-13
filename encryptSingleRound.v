// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/12/2020
// Single Round Module. This function will execute a single round of AES encrypt,
// combining the lower level modules shiftRow, SubByte_MixColumn, AddRoundKey.
//
// UPDATES: 

module encryptSingleRound
	#(
	parameter KEY_WIDTH = 128,			// size of key, either 128 or 256 bit
	parameter DATA_WIDTH = 128			// size of data, always 128 bit
	)
	(
	input clk,
	input rst,										// Active low
	input round_valid_in, 						// Valid bit in. When high, data is valid and should be processed
	input wire [DATA_WIDTH-1:0] state_in, 	// Plaintext block data to be ecrypted
	input wire [KEY_WIDTH-1:0] key_in,		// Key used to encrypt plaintext data
	output reg [DATA_WIDTH-1:0] state_out, // Block data which has gone through a single round of encryption
	output reg round_valid_out 				// Valid bit out. When high, data is valid and can be used in another function.	
	);													// end signals

	// intermediete variables
	// NOTE: subByte and mixColumn layers are combined for optimization
	wire [DATA_WIDTH-1:0] state1; 	// connect the data from first layer to second  
	wire [DATA_WIDTH-1:0] state2;	// connect data from second layer to third

	wire round_valid1;	// connect valid bit from first layer to second
	wire round_valid2;	// connect valid bit from second layer to third
	
	// Call lower level modules
	
	// subByte_mixColumn optimized module
	subByte_mixColumn #(DATA_WIDTH) sb_mc(	.sb_mc_valid_in(round_valid_in),
														.state_in(state_in),
														.state_out(state1),
														.sb_mc_valid_out(round_valid1));
														
	
	// shiftRow
	shiftRow #(DATA_WIDTH) sr(	.shiftRow_valid_in(round_valid1),
										.shiftRow_data_in(state1),
										.shiftRow_data_out(state2),
										.shiftRow_valid_out(round_valid2));
	
	// addRoundKey
	/*addRoundKey #(KEY_WIDTH, DATA_WIDTH) ark(	.addRoundKey_valid_in(round_valid2),
															.addRoundKey_data_in(state2),
															.addRoundKey_key_in(key_in),
															.addRoundKey_data_out(state_out), 
															.addRoundKey_valid_out (round_valid_out));
															*/
	
	always @(*) begin
		state_out = state2 ^ key_in;
		round_valid_out = round_valid2;
	end
	
endmodule
	