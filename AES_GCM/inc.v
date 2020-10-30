// Milos Trbic
// AES Capstone - Joseph Decuir
// Updated: 10/29/2020
// Increment operation. For a positive integer S and data input such that DATA_WIDTH >= S,
// this function will take the S right-most bits and increment the value by 1, and leave 
// the DATA_WIDTH - S left-most unaltered.
//
// Developed based on NIST SP 800-38D, "Recommendationfor Block Cipher Modes of
// Operation: Galois/Counter Mode (GCM) and GMAC" (Section 6.5).
// 
// UPDATES: Implemented testbench with 8-bit data, S = 5

module inc
	#(
	parameter S = 32,			// S right-most bits will be incremented
	parameter DATA_WIDTH = 128 		// Will be the same as ICB_WIDTH since inc operation
						// is only done on counter blocks
	)
	(
	input wire clk,
	input wire rst,				// Active low
	input wire [DATA_WIDTH-1:0] data_in,	// Block data input to be processed
	output reg [DATA_WIDTH-1:0] data_out	// Block data output which has underwent increment operation
	);
	
	always @(posedge clk or negedge rst) begin
		if (!rst) begin
			data_out <= 0;
		end else begin
			if (DATA_WIDTH < S || S == 0) begin
				data_out <= data_in;
			end else begin
				data_out <= cb_next(data_in); // increment
			end
		end
	end
	
	// Increment function
	function [DATA_WIDTH-1:0] cb_next;
		input [DATA_WIDTH-1:0] cb;
		
		begin
			cb_next = {cb[DATA_WIDTH-1:S], cb[S-1:0] + 1'b1};
		end
	endfunction
	
endmodule

// Testbench using 8-bit values
module inc_testbench();
   reg [7:0] data;
	wire [7:0] out;
	reg clk;
	reg rst;
	// 8-bit data, 13 rows in incTest.tv file
	reg [7:0] testvectors [0:12];
	integer i;
	
	// Set up the clock
	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
	initial clk = 1;

	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;	// clock toggle
	end
	
	// toggle reset
	initial begin 
		rst = 0;
		#100
		rst = 1;
	end
	
	// use to test Methods 2 and 3
	inc dut(.clk(clk), .rst(rst), .data_in(data), .data_out(out));
	// use to test Method 1
	//inc dut (.data_in(data), .data_out(out));
	
	initial begin	// embed the test vector
		$readmemb("incTest.tv", testvectors); // read in test vectors from .tv file
		for (i = 0; i < 12; i=i+1)
			begin
				data = testvectors[i];
				@(posedge clk);
			end
		$stop; 
	end

endmodule
