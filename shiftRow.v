// Vi Ho | Milos Trbic | Hamidou Diallo
// AES Capstone - Joseph Decuir
// Updated: 9/8/2020
// ShiftRow Module. This function will conduct the shift row function 
// of a single round of AES encrypt. It will take in the 128-bit state
// and produce a 128-bit output.
//
// UPDATES: Created shiftRowTest.tv file and wrote testbench. Need to resolve errors.

module shiftRow(
					//input valid_in,
					input wire [127:0] state_in,
					output wire [127:0] state_out
					//output valid_out
					);
	
		// if (valid == 1) begin // if valid bit is high, do the operation
			
			assign state_out[127:120] = state_in[127:120];  
			assign state_out[119:112] = state_in[87:80];
			assign state_out[111:104] = state_in[47:40];
			assign state_out[103:96]  = state_in[7:0];
				
			assign state_out[95:88] = state_in[95:88];
			assign state_out[87:80] = state_in[55:48];
			assign state_out[79:72] = state_in[15:8];
			assign state_out[71:64] = state_in[103:96];
				
			assign state_out[63:56] = state_in[63:56];
			assign state_out[55:48] = state_in[23:16];
			assign state_out[47:40] = state_in[111:104];
			assign state_out[39:32] = state_in[71:64];
				
			assign state_out[31:24] = state_in[31:24];
			assign state_out[23:16] = state_in[119:112];
			assign state_out[15:8]  = state_in[79:72];
			assign state_out[7:0]   = state_in[39:32]; 
		
		// end else begin // if valid bit is low

		//	assign state_out = 0;
		
		// end
		
	// endgenerate

endmodule

// shiftRow testbench
module shiftRow_testbench();
	
	wire [127:0] s_in;
	wire [127:0] s_out;
	reg clk;	
	// 128-bit data
	// 11 rows in shifrRowTest.tv file
	wire [127:0] testvectors [0:10];
	integer i;
	

	// Set up the clock
	parameter CLOCK_PERIOD = 100;	// simulating a toggling clock
	initial clk = 1;

	always begin
		#(CLOCK_PERIOD/2) clk = ~clk;				// clock toggle
	end
	
	// reference the device under test (shiftRow module)
	shiftRow dut (.state_in(s_in), .state_out(s_out));
	
	initial begin	// embed the test vector
		$readmemh("shiftRowTest.tv", testvectors); // read in test vectors from .tv file
		for (i = 0; i < 11; i=i+1)
			begin
				{s_in, s_out} = testvectors[i];
				@(posedge clk);
			end
		$stop; 
	end

endmodule
	