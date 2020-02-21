`include "definition_file.v" 

module read_data#(
  	parameter 
  			INPUT_FILE  = "input_picture.hex", 	
  			IMAGE_WIDTH = 768, 					
			IMAGE_HEIGHT = 512,
			// Delay during start up time 						
			STATEART_DELAY = 100,
			// Delay between Horizontal synchronous pulses	 				
			HORIZONTAL_SYNC_DELAY = 160,
			// Threshold value for Threshold operation					
			THRESHOLD= 90						
	)
	(
		clk,												
		reset,									
		data_R_Even,				
	    data_G_Even,				
	    data_B_Even,				
	    data_R_Odd,				
	    data_G_Odd,				
	    data_B_Odd,
	    vertical_Pulse,							
		horizontal_Pulse,							
		done_Flag					
	);

	input clk;
	// Active low										
	input reset;
	// 8 bit Red, Green, Blue  data (Even)									
	output reg [7:0]  data_R_Even;				
    output reg [7:0]  data_G_Even;			
    output reg [7:0]  data_B_Even;
    // 8 bit Red, Green, Blue  data (Odd)						
    output reg [7:0]  data_R_Odd;				
    output reg [7:0]  data_G_Odd;				
    output reg [7:0]  data_B_Odd;
    // Vertical synchronous pulse
    output vertical_Pulse;	
    // Horizontal synchronous pulse							
	output reg horizontal_Pulse;						
	output done_Flag;

	reg [1:0] current_STATE;						
	reg [1:0] next_STATE;

	// Parameters for FSM
	localparam	STATE_IDLE 	= 2'b00;		
	localparam	STATE_VERTICAL_SYNC	= 2'b01;			
	localparam	STATE_HORIZONTAL_SYNC = 2'b10;			
	localparam	STATE_DATA_PROCESSING = 2'b11;	

	parameter data_Width = 8;						
	parameter image_Size = 1179648; 

	reg sig_Start;	
    // Create start signal								
	reg sig_Delayed_Reset;	
	// Control signal for counters
	reg sig_Ctrl_Vsync; 
	reg sig_Ctrl_Hsync;	
	reg sig_Ctrl_Data;											

	// Counters
	reg [8:0] vsync_Counter;			
	reg [8:0] hsync_Counter;
	reg [18:0] data_Counter; 		


	reg [31:0] memory_32_Bit [0:image_Size/4]; 	
	reg [7:0] memory_8_Bit [0:image_Size-1];	

	// Row/Column index of the image
	reg [9:0] row; 
	reg [10:0] column; 

endmodule					
