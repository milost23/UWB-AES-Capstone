// Hamidou Diallo & Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/9/2020
// Upper level Subbyte Module. This function will conduct the byte substitution
// function of a single round of AES encrypt. It will take in the 128-bit state
// and produce a 128-bit output.
//
// UPDATES: added functions for sbox by logic, added the GF(2^4) function

module subByte(
	input  clk,
	input wire [127:0] subbyte_data_in, 	// SubByte block data to be processed.
	input  subbyte_valid_in, // Valid bit. When high, data is valid and should be processed.
	output wire [127:0] subbyte_data_out, // Block data which has gone through SubByte function
	output subbyte_valid_out // Valid bit. When high, data is valid and can be used in another function.	
	); // end signals
	
	// always @(*) begin
	//	if (subbyte_valid_in) begin	// if data is valid
			genvar itr;
			generate
				for (itr = 0 ; itr < 128; itr = itr + 8) begin :s
					sbox sb (.sbox_data_in(subbyte_data_in[itr +:8]) , .sbox_data_out(subbyte_data_out[itr +:8]));
				end // end for loop
				
			endgenerate
		
		//for (i = 16; i > 0; i = i - 1) begin	// for loop to break down data into bytes
		//	if (SELECT_SUBBYTE == 1) begin // use lookup table
		//		sbox Byte(subbyte_data_in[i*8-1:i*8-8], subbyte_data_out[i*8-1:i*8-8]); // check if this is right way to call module
		
		// end else begin // use logic
			
				// add code
				// break down into bytes
				// send byte to galoisFieldInv
				// send that result to affineMap
				
		// end					
		// end // end of for loop
		
		// add code for case when valid is low

	// end // end always block
	 

		//if(subbyte_valid_in==1) begin


endmodule

// Testbench for subByte

module subByteTestbench();
   wire [127:0] data;
	wire [127:0] out;

// assign data=128'h001f0e543c4e08596e221b0b4774311a; // AES document - Round 1 example test
assign data = 128'h5847088b15b61cba59d4e2e8cd39dfce; // Round 2 example - Slides 8/9

subByte subyte(.subbyte_data_in(data),.subbyte_data_out(out));

endmodule



/* Add these as seperate modules
	
// New Module \\
module GaloisFieldInv (
	input logic [7:0] galois_data_in,
	output logic [7:0] galois_data_out);
	
	// implement code for galois field inversion
	
endmodule // end sboxTable

// New Module \\
module affineMap (
	input logic [7:0] affmap_data_in,
	output logic [7:0] affmap_data_out);
	
	// implement code for affine mapping
	
endmodule */

// Functions to be used for SubByte logic implementation
// Developed based on "Practical Implementation of Rijndael S-Box Using Combinational Logic" paper
// "Section" comment reffers to respective section in paper used to develop function 

// Squarer in GF(2^4)
// Section 2.2.2
function [3:0] squarer;
	input [3:0] data;
	
	begin
		squarer[3] = data[3];
		squarer[2] = data[3] ^ data[2];
		squarer[1] = data[2] ^ data[1];
		squarer[0] = data[3] ^ data[1] ^ data[0];
	end
endfunction
	
// Multiplication with constant, lambda, in GF(2^4)
function [3:0] mult_lambda;
	input [3:0] data;
	
	begin
		mult_lambda[3] = data[2] ^ data[0];
		mult_lambda[2] = data[3] ^ data[2] ^ data[1] ^ data[0];
		mult_lambda[1] = data[3];
		mult_lambda[0] = data[2];
	end
endfunction

// Multiplication in GF(2^4)
// Section 2.2.4, Figure 5
// Utilizes mult_gf2 and mult_phi functions
function [3:0] mult_gf2_4;
	input [7:0] data_in;
	
	// intermediete values
	wire [3:0] q, w, data_out; 	// splitting 8-bit input into two 4-bit pieces, as well as final output
	wire [1:0] mul1, mul2, mul3,  // output of three GF(2) multiplications, mult with constant phi
				  phi_out;				// output of multiplication with constant phi
	
	assign q = data[7:4]; // q = [q3, q2, q1, q0]
	assign w = data[3:0]; // w = [w3, w2, w1, w0]
	
	assign mul1 = mult_gf2({q[3:2], w[3:2]}); // top multiplication box
	assign mul2 = mult_gf2({(q[3:2] ^ q[1:0]), (w[3:2] ^ w[1:0])}); // middle multiplication box
	assign mul3 = mult_gf2({q[1:0], w[1:0]}); // bottom multiplication box

	assign phi_out = mult_phi(mul1);
	
	assign data_out = {(mul2 ^ mul3), (phi_out ^ mul3)};
endfunction

// Functions to make up Multiplication in GF(2^4)

// Multiplication in GF(2)
// Section 2.2.5
function [1:0] mult_gf2;
	input [3:0] data;
	
	begin
		mult_gf2[1] = (data[3] & data[1]) ^ (data[2] & data[1]) ^ (data[3] & data[0]);
		mult_gf2[0] = (data[3] & data[1]) ^ (data[2] & data[0]);
	end
endfunction

// Multiplication with constant, phi
// Section 2.2.6
function [1:0] mult_phi;
	input [1:0] data;
	
	begin
		mult_phi[1] = data[1] ^ data[0];
		mult_phi[0] = data[1];
	end
endfunction

// End of functions to make up Multiplication in GF(2^4)

// Multiplicative inversion in GF(2^4)
// Section 2.2.7
// inv(q) = [inv(q3), inv(q2), inv(q1), inv(q0)]
function [3:0] mult_inv_gf2_4;
	input [3:0] data;
	
	begin
		mult_inv_gf2_4[3] = data[3] ^ (data[3] & data[2] & data[1]) ^ (data[3] & data[0]) ^ data[2];
		mult_inv_gf2_4[2] = (data[3] & data[2] & data[1]) ^ (data[3] & data[2] & data[0]) ^
									(data[3] & data[0]) ^ data[2] ^ (data[2] & data[1]);
		// space for readability
		mult_inv_gf2_4[1] = data[3] ^ (data[3] & data[2] & data[1]) ^ (data[3] & data[1] & data[0]) ^
									data[2] ^ (data[2] & data[0]) ^ data[1];
		// space for readability
		mult_inv_gf2_4[0] = (data[3] & data[2] & data[1]) ^ (data[3] & data[2] & data[0]) ^
									(data[3] & data[1]) ^ (data[3] & data[1] & data[0]) ^ (data[3] & data[0])
									^ data[2] ^ (data[2] & data[1]) ^ (data[2] & data[1] & data[0]) ^ 
									data[1] ^ data[0]; 
	end
endfunction



	