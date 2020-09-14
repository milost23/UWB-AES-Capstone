// Hamidou Diallo & Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 9/13/2020
// Upper level Subbyte Module. This function will conduct the byte substitution
// function of a single round of AES encrypt. It will take in the 128-bit state
// and produce a 128-bit output.
//
// UPDATES: added functions for sbox by logic, added the GF(2^4) function, added parameters

module subByte
	#(
	parameter DATA_WIDTH = 128,	// Size of data, 128 bits = 0x80 in hex
	parameter SELECT_SUBBYTE = 1	// When high, SubByte will be done using looking table
											// When low, SubByte will be done using combinational logic
	)
	(
	input clk,
	input rst,													// active low
	input subbyte_valid_in, 								// Valid bit. When high, data is valid and should be processed.
	input wire [DATA_WIDTH-1:0] subbyte_data_in, 	// SubByte block data to be processed.
	output reg [DATA_WIDTH-1:0] subbyte_data_out,  	// Block data which has gone through SubByte function
	output reg subbyte_valid_out 							// Valid bit. When high, data is valid and can be used in another function.	
	); 															// end signals
	
	// local parameter to define number of bytes
	// bytes = 128 / 8 = 16 implemented using LSR
	localparam NUM_BYTES = DATA_WIDTH >> 3;
	
	// 16-bit unit of data, 256 total elements in ROM
	reg [15:0] data_ROM [0:255];
	
	integer i; // used in for loop

	initial $readmemh("C:\\Users\\milos\\OneDrive\\Documents\\Capstone I\\aesFull\\rom.txt", data_ROM);
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			subbyte_data_out <= {DATA_WIDTH{1'b0}}; 	// assign entire state to 0
			subbyte_valid_out <= 1'b0;
			
		end else if (subbyte_valid_in) begin			// if valid is high
			if (SELECT_SUBBYTE) begin 						// if SELECT)SUBBYTE is high, use LUT
				for (i = 0 ; i < DATA_WIDTH; i = i + 8) begin :lut		
					subbyte_data_out[i +:8] <= data_ROM[subbyte_data_in[i+:8]][15:8];
				end
			end else begin // if SELECT_SUBBYTE is low, use logic
				// implement subbyte in logic
				for(i = 0; i < NUM_BYTES; i = i + 1) begin :comb
					subByteCombinational sb(.data_in(subbyte_data_in[(i*8)+7:(i*8)]),
													.clk(clk),
													.rst(rst),
													.data_out(subbyte_data_out[(i*8)+7:(i*8)]));
				end
			end // end SELECT_SUBBYTE check
		end else begin 
			subbyte_data_out <= {DATA_WIDTH{1'b0}};
		end // end valid bit check
		subbyte_valid_out <= subbyte_valid_in;
	end // end always block
	
endmodule


// Testbench for subByte

/*module subByteTestbench();
   wire [127:0] data;
	wire [127:0] out;

// assign data=128'h001f0e543c4e08596e221b0b4774311a; // AES document - Round 1 example test
assign data = 128'h5847088b15b61cba59d4e2e8cd39dfce; // Round 2 example - Slides 8/9

subByte subyte(.subbyte_data_in(data),.subbyte_data_out(out));

endmodule*/

// subByte testbench
module subByte_testbench();
	
	reg [127:0] s_in;
	wire [127:0] s_out;
	reg clk;
	reg rst;
	// 128-bit data, 13 rows in shifrRowTest.tv file
	reg [127:0] testvectors [0:12];
	integer i;
	
	// Set up the clock
	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
	initial clk = 1;

	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;				// clock toggle
	end
	
	// add reset
	initial begin 
		rst = 0;
		#1000
		rst = 1;
	end
	
	// reference the device under test (subByte module)
	subByte dut (
						.clk(clk), 
						.rst(rst), 
						.subByte_valid_in(1'b1), // send a constant high valid bit
						.subByte_data_in(s_in),
						.subByte_data_out(s_out),
						.subByte_valid_out()
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
