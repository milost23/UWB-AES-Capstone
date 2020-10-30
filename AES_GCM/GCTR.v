// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 10/29/2020
// AES GCM Counter module. This module operates on 128-bit block data to perform Steps 5 and 6 of
// Algorithm 3. This module takes an input block and counter block, applies the block cipher (AES
// encrypt) to the counter block, and XORs the result with the input block to produce an output block.
// This module also generates the next counter block by incrementing the previous counter block.
//
// Developed based on NIST SP 800-38D, "Recommendationfor Block Cipher Modes of
// Operation: Galois/Counter Mode (GCM) and GMAC" (Section 6.5).
// 
// UPDATES: Added counter block operation.

module GCTR
	#(
	parameter DATA_WIDTH = 128,		// Bit size of block input, set to 128-bit
	parameter ICB_WIDTH = 128,		// Bit size of initial counter block input, will define size for all CBs
	parameter S = 32,			// Amount of right-most bits for increment operation
	parameter KEY_WIDTH = 128,		// Parameters for AES encryption core
	parameter ROM_WIDTH = 20,		// "
	parameter SELECT_SUBBYTE = 1,		// "
	parameter WORD = 32			// "
	)
	(
	input wire clk,
	input wire rst,				// Active Low
	input wire [DATA_WIDTH-1:0] data_in,	// block input Xn
	input wire [ICB_WIDTH-1:0] cb_in,	// counter block input CBi
	output wire [DATA_WIDTH-1:0] data_out,	// block output Yn, same size as block input
	output wire [ICB_WIDTH-1:0] cb_out	// next counter block output Cb(i+1)
	);
	
	// temporary variable to store only the ciphertext of AES on the CB
	// Used because AEScoure produces several outputs that we do not use
	reg [DATA_WIDTH-1:0] ciphertext;
	
	// Insert CIPH function, applied to Counter Block CB with key K
	// In our case, we use AES encryption
	AEScore #(KEY_WIDTH, ICB_WIDTH, ROM_WIDTH, SELECT_SUBBYTE, WORD) ciph (
		.clk(clk),
		.rst(rst),
		.valid_in(),
		.plaintext_in(cb_in),
		.key_in(),
		.keyLen(),
		.ciphertext_out(ciphertext),
		.key_out(),
		.valid_out()
	); // end block cipher instantiation
	
	
	// Call inc function to generate next counter block
	inc #(S, ICB_WIDTH) cb_next (
		.clk(clk), 
		.rst(rst), 
		.data_in(cb_in), 
		.data_out(cb_out)
	); // end inc instantiation

	// original bit string input XORed with counter block which has went through AES Encrypt
	assign data_out = data_in ^ ciphertext;
	
endmodule
