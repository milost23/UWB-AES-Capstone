// Hamidou Diallo & Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/16/2020
// Upper level subByte Module. This function will conduct the byte substitution
// function of a single round of AES encrypt. It will take in the 128-bit state
// and produce a 128-bit output.
//
// UPDATES: added functions for sbox by logic, added the GF(2^4) function, added parameters
// Removed operation which sets state to 0 when valid_in is low, finalizing testbench
// Implemented generate to create temp state using both LUT and logic. The output is then
// selected based on parameter passed down.

module subByte
	#(
	parameter DATA_WIDTH = 128,	// Size of data, 128 bits = 0x80 in hex
	parameter ROM_WIDTH = 20,	// Width of memory element, i.e. M20k has 20 bit width
	parameter SELECT_SUBBYTE = 0	// When high, subByte will be done using looking table
					// When low, subByte will be done using combinational logic
	)
	(
	input clk,
	input rst,					// active low
	input subByte_valid_in,				// Valid bit. When high, data is valid and should be processed
	input wire [DATA_WIDTH-1:0] subByte_data_in, 	// subByte block data to be processed
	output reg [DATA_WIDTH-1:0] subByte_data_out,  	// Block data which has gone through subByte function
	output reg subByte_valid_out 			// Valid bit. When high, data is valid and can be used in another function.	
	); 						// end signals
	
	// local parameter to define number of bytes
	// bytes = 128 / 8 = 16 implemented using LSR
	localparam NUM_BYTES = DATA_WIDTH >> 3;
	
	// Intermediete values to store state
	wire [DATA_WIDTH-1:0] lut_temp, comb_temp;
	
	genvar i, j;
	
	// create sbox using LUT
	generate	
		for (i = 0 ; i < NUM_BYTES; i = i + 1) begin :lut		
			sbox #(ROM_WIDTH) sb (
						.sbox_data_in(subByte_data_in[(i*8)+7:(i*8)]),
						.sbox_data_out(lut_temp[(i*8)+7:(i*8)])
						);
		end
	endgenerate
	
	// create sbox using logic
	generate 
		for(j = 0; j < NUM_BYTES; j = j + 1) begin :comb
			subByteCombinational sbc 	(
							.data_in(subByte_data_in[(j*8)+7:(j*8)]),
							.data_out(comb_temp[(j*8)+7:(j*8)])
							);
		end
	endgenerate
	
	// Now determine what output value will be based on SELECT_SUBBYTE
	// Update registers
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			subByte_valid_out <= 1'b0;
		end else begin // if (rst)
			if (subByte_valid_in) begin
				if (SELECT_SUBBYTE) begin
					subByte_data_out <= lut_temp;
				end else begin
					subByte_data_out <= comb_temp;
				end // end SELECT_SUBBYTE check
			end // end valid check
			subByte_valid_out <= subByte_valid_in;
		end //end rst check
	end // end always block
	
endmodule

// subByte testbench
module subByte_testbench();
	
	reg clk;
	reg rst;
	reg s_valid_in; // Sunny ++
	reg [127:0] s_in;
	wire [127:0] s_out;
	wire s_valid_out;
	
	// 128-bit data, 13 rows in shifrRowTest.tv file
	reg [127:0] testvectors [0:12];
	integer i;
	
	// Set up the clock
	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
	initial clk = 1;

	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;	// clock toggle
	end
	
  // Sunny ++ head
   reg r_valid_in;
   reg [127:0] r_in;

  always @(posedge clk, negedge rst) begin
    if (~rst) begin
      r_valid_in <= 0;
      r_in <= 0;
    end else begin
      r_valid_in <= s_valid_in;
      r_in <= s_in;
    end
  end
  // Sunny ++ tail

	// reference the device under test (subByte module)
	subByte dut (
			.clk(clk), 
			.rst(rst), // Sunny **
			.subByte_valid_in(r_valid_in), // Sunny **
			.subByte_data_in(r_in), // Sunny **
			.subByte_data_out(s_out),
			.subByte_valid_out(valid_out)
			);

	initial begin	// embed the test vector
		$readmemh("subByteTest.tv", testvectors); // read in test vectors from .tv file
		// Sunny ++ head
		rst = 0;
		s_valid_in = 0;
		#100
		rst = 1;
		#100
		// Sunny ++ tail
		for (i = 0; i < 11; i=i+1)
			begin
				s_in = testvectors[i];
				s_valid_in = 1; // Sunny ++
				@(posedge clk);
			end
			s_valid_in = 0; // Sunny ++
		$stop; 
	end

endmodule


/*
// subByte testbench pre Dr. Kim edits
module subByte_testbench();
	
	reg [127:0] s_in;
	wire [127:0] s_out;
	wire valid_out;
	reg clk;
	reg rst;
	// 128-bit data, 13 rows in shifrRowTest.tv file
	reg [127:0] testvectors [0:12];
	integer i;
	
	// Set up the clock
	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
	initial clk = 1;

	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;	// clock toggle
	end
	
	// add reset
	initial begin 
		rst = 0;
		#100
		rst = 1;
	end
	
	// reference the device under test (subByte module)
	subByte dut (
						.clk(clk), 
						.rst(rst), 
						.subByte_valid_in(1'b1), // send a constant high valid bit
						.subByte_data_in(s_in),
						.subByte_data_out(s_out),
						.subByte_valid_out(valid_out)
						);
	
	initial begin	// embed the test vector
		$readmemh("subByteTest.tv", testvectors); // read in test vectors from .tv file
		for (i = 0; i < 11; i=i+1)
			begin
				s_in = testvectors[i];
				@(posedge clk);
			end
		$stop; 
	end

endmodule
*/
