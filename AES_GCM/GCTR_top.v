// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 11/9/2020
// Top-level AES GCM Counter module. Deals with entire data input and splits it into
// 128-bit block data for lower-level operations.
//
// Developed based on NIST SP 800-38D, "Recommendationfor Block Cipher Modes of
// Operation: Galois/Counter Mode (GCM) and GMAC" (Section 6.5).
// 
// UPDATES: Step 3, partitioning the input: Designed to operate if input can be split into N equal parts.
// i.e. DATA_WIDTH is a multiple of 128. Debugged this for loop in Step 3 and compiles with 0 errors.
// Moved N to global parameter from localparam.

module GCTR_top
	#(
	parameter DATA_WIDTH = 1280,		// Bit size of block input, can be arbitrary size
	parameter ICB_WIDTH = 128,		// Bit size of initial counter block input
	parameter N = DATA_WIDTH / 128,		// Step 2 of algorithm, split input into N 128-bit blocks
	parameter KEY_WIDTH = 128,		// Parameters for AES encryption core
	parameter ROM_WIDTH = 20,		// "
	parameter SELECT_SUBBYTE = 1,		// "
	parameter WORD = 32			// "
	)
	(
	input wire clk,
	input wire rst,				// active low
	input wire [DATA_WIDTH-1:0] data_in,	// block input
	input wire [ICB_WIDTH-1:0] icb_in,	// initial counter block
	input wire valid_in,			// Valid bit in. When high, data is valid and should be processed
	input wire [KEY_WIDTH-1:0] key_in, 	// key to be used for Block Cipher (AES core)
	output reg [DATA_WIDTH-1:0] data_out,	// block output, same size as block input
	output reg valid_out			// Valid bit out. When high, data is valid and can be used elsewhere
	);
	
	// intermediete logic
	// NOTE: Indexed from 1 to N to match algorithm descriptio
	genvar i;				// to be used in generate, to instantiate GCTR module
	integer j;				// to be used in for loop to re-build output
	wire [127:0] X [1:N]; 			// to store partitioned input, always 128-bit block size
	wire [ICB_WIDTH-1:0] CB [1:N];		// to store counter blocks, always same block size as ICB
	wire [127:0] Y [1:N]; 			// to store partitioned output, always same block size as input
	
	generate	
	
		// Step 3
		// split input data into N 128-bit values, where X1=X[1], X2=X[2],..., XN=X[N]
		for (i = 1; i <= N; i = i + 1) begin :partition
			assign X[i] = data_in[(DATA_WIDTH - 1 - ((i-1) * 128)) -: 128];
		end
		
		// Step 4
		assign CB[1] = icb_in;

		// Steps 5 and 6
		// The first N-1 blocks of data			
		for (i = 1; i < N; i = i + 1) begin :blockcipher
			// Call the block cipher (AES) on counter blocks, XOR with data input
			// Produce next counterblock
			GCTR #(DATA_WIDTH, ICB_WIDTH, 32, KEY_WIDTH, ROM_WIDTH, SELECT_SUBBYTE, WORD) Yn (
				.clk(clk),
				.rst(rst),
				.data_in(X[i]),
				.cb_in(CB[i]),
				.data_out(Y[i]),
				.cb_out(CB[i+1])
			); // end lower-level GCTR instantiation 
		end
		
		// Nth (final) block of data
		GCTR #(DATA_WIDTH, ICB_WIDTH, 32, KEY_WIDTH, ROM_WIDTH, SELECT_SUBBYTE, WORD) Yn (
			.clk(clk),
			.rst(rst),
			.data_in(X[N]),
			.cb_in(CB[N]),
			.data_out(Y[N]),
			.cb_out() // CB only goes up to N, and final one is calculated in above for loop
		); // end lower-level GCTR instantiation
		
	endgenerate
	
	always @(*) begin
		// Step 1: If data_in is an empty string, then return the empty string as data_out
		if (DATA_WIDTH == 0) begin
			data_out = data_in;
		end else begin
			// Step 8: Concatenate to form result
			for (j = 1; j <= N; j = j + 1) begin :result
				data_out[(DATA_WIDTH - 1 - ((j-1) * 128)) -: 128] = Y[j];
			end
		end
	end
	
endmodule
