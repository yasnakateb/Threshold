`include "definition_file.v" 

module read_data#(
  	parameter 
  			INPUT_FILE  = "input_picture.hex", 	
  			IMAGE_WIDTH = 768, 					
			IMAGE_HEIGHT = 512, 						
			START_DELAY = 100, 				
			HORIZONTAL_DELAY = 160,					
			THRESHOLD= 90						
	)
	(
		clk,												
		reset,									
		data_R0,				
	    data_G0,				
	    data_B0,				
	    data_R1,				
	    data_G1,				
	    data_B1,
	    vertical_Pulse,							
		horizontal_Pulse,							
		done_Flag					
	);

	input clk;										
	input reset;									
	output reg [7:0]  data_R0;				
    output reg [7:0]  data_G0;			
    output reg [7:0]  data_B0;				
    output reg [7:0]  data_R1;				
    output reg [7:0]  data_G1;				
    output reg [7:0]  data_B1;
    output vertical_Pulse;								
	output reg horizontal_Pulse;						
	output done_Flag;


endmodule					
