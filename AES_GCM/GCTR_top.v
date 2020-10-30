// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 10/29/2020
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
	parameter DATA_WIDTH = 1280,				// Bit size of block input, can be arbitrary size
	parameter ICB_WIDTH = 128,					// Bit size of initial counter block input
	parameter N = DATA_WIDTH / 128,			// Step 2 of algorithm, split input into N 128-bit blocks
	parameter KEY_WIDTH = 128,
	parameter ROM_WIDTH = 20,
	parameter SELECT_SUBBYTE = 1,
	parameter WORD = 32
	)
	(
	input wire clk,
	input wire rst,								// active low
	input wire [DATA_WIDTH-1:0] data_in,	// block input
	input wire [ICB_WIDTH-1:0] icb_in,		// initial counter block
	output reg [DATA_WIDTH-1:0] data_out	// block output, same size as block input
	);
	
	// intermediete logic
	// NOTE: Indexed from 1 to N to match algorithm descriptio
	genvar i;								// to be used in gemerate, to instantiate GCTR module
	integer j;								// to be used in for loop to re-build output
	wire [127:0] X [1:N]; 				// to store partitioned input, always 128-bit block size
	wire [ICB_WIDTH-1:0] CB [1:N];	// to store counter blocks, always same block size as ICB
	wire [127:0] Y [1:N]; 				// to store partitioned output, always same block size as input
	
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
	
	
	//==========================================================================================
	// BEGIN FUNCTIONS
	/*
	// Incrementing Function, Section 6.2
	// Will only need to account for s = 32
	function [ICB_WIDTH-1:0] inc;
		input [ICB_WIDTH-1:0] X; // Input will always be a Counter Block, thus same size of ICB
		
		begin
			// code to increment
		end
	endfunction
	
	// BEGIN MSB function and module
	
	// MSB operation, returns the s left-most bits of X, Section 6.1
	// Used in increment function with s = ICB_WIDTH - 32
	function [ICB_WIDTH-33:0] msb;
		input [ICB_WIDTH-1:0] X; // Input will always be a Counter Block, thus same size of ICB		
		begin
			// code to return MSBs
			msb = X[ICB_WIDTH-1:31];
		end
	endfunction
	
	// MSB operation implemented as a module
	module msb
		#(
		parameter S = 0,
		parameter LEN_X = 0
		)
		(
		input wire [LEN_X-1:0] X,
		output wire [LEN_X-1-S:0] msbX
		);
		
		always @(*) begin
			assign msbX = X[LEN_X-1:S-1];
		end
	endmodule
	// END MSB function and module
	
	
	// BEGIN LSB function and module

	// LSB Function, returns the s right-most bits of X, Section 6.1
	// Used in increment function with s = 32
	function [31:0] lsb;
		input [ICB_WIDTH-1:0] X;
		
		begin
			// code to return MSBs
			lsb = X[31:0];
		end
	endfunction
	
	// LSB operation implemented as a module
	module lsb
		#(
		parameter S = 0,
		parameter LEN_X = 0
		)
		(
		input wire [LEN_X-1:0] X,
		output wire [LEN_X-1-S:0] lsbX
		);
		
		always @(*) begin
			assign lsbX = X[S-1:0];
		end
	endmodule
	// END LSB function and module
	*/
	
endmodule
