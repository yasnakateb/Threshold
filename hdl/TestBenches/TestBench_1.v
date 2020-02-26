`timescale 1ns / 1ps

module TestBench_1;
	// Inputs
	reg clk;
	reg reset;

	// Instantiate the Unit Under Test (UUT)
	Image_Processing uut (
		.clk(clk), 
		.reset(reset)
	);
	initial begin 
		clk = 0;
		forever #10 clk = ~clk;
	end

	initial begin
		reset     = 0;
		#25 reset = 1;
	end
endmodule

