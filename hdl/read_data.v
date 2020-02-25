`include "definition_file.v" 

module read_data#(
    parameter 
        INPUT_FILE  = "input_picture.hex",  
        IMAGE_WIDTH = 768,                  
        IMAGE_HEIGHT = 512
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
    localparam  STATE_IDLE  = 2'b00;        
    localparam  STATE_VERTICAL_SYNC = 2'b01;            
    localparam  STATE_HORIZONTAL_SYNC = 2'b10;          
    localparam  STATE_DATA_PROCESSING = 2'b11;  

    parameter DATA_WIDTH = 8;                       
    parameter IMAGE_SIZE = 1179648; 
    // Delay during start up time                       
    parameter    STATEART_DELAY = 100;
    // Delay between Horizontal synchronous pulses                  
    parameter    HORIZONTAL_SYNC_DELAY = 160;
    // Threshold value for Threshold operation                  
    parameter    THRESHOLD= 90 ;                      

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


    reg [31:0] memory_32_Bit [0:IMAGE_SIZE/4];  
    reg [7:0] memory_8_Bit [0:IMAGE_SIZE-1];    

    // Row/Column index of the image
    reg [9:0] row; 
    reg [10:0] column;

    // Temporary storage
    integer temp_Memory [0:IMAGE_WIDTH * IMAGE_HEIGHT * 3 - 1];
    integer storage_Red [0:IMAGE_WIDTH * IMAGE_HEIGHT- 1];    
    integer storage_Green [0:IMAGE_WIDTH * IMAGE_HEIGHT - 1];   
    integer storage_Blue [0:IMAGE_WIDTH * IMAGE_HEIGHT - 1];

    // Counting variables
    integer i;
    integer j;

    // Temporary variables
    integer value1;
    integer value2;

    initial begin
        $readmemh(INPUT_FILE, memory_8_Bit, 0, IMAGE_SIZE-1); 
    end
    
    always@(sig_Start) begin
        if(sig_Start == 1'b1) begin
            for(i = 0; i< IMAGE_WIDTH * IMAGE_HEIGHT * 3 ; i = i + 1) begin
                temp_Memory[i] = memory_8_Bit[i + 0][7:0]; 
            end
            
            for(i = 0; i < IMAGE_HEIGHT; i = i + 1) begin
                for(j = 0; j < IMAGE_WIDTH; j = j + 1) begin
                    storage_Red[IMAGE_WIDTH * i + j] = temp_Memory[IMAGE_WIDTH * 3 * (IMAGE_HEIGHT - i - 1) + 3 * j + 0]; 
                    storage_Green[IMAGE_WIDTH * i + j] = temp_Memory[IMAGE_WIDTH * 3 * (IMAGE_HEIGHT - i - 1) + 3 * j + 1];
                    storage_Blue[IMAGE_WIDTH * i + j] = temp_Memory[IMAGE_WIDTH * 3 * (IMAGE_HEIGHT - i - 1) + 3 * j + 2];
                end
            end
        end
    end


    always@(posedge clk, negedge reset)
    begin
        if(!reset) begin
            sig_Start <= 0;
            sig_Delayed_Reset <= 0;
        end
        else begin                                        
            sig_Delayed_Reset <= reset;                                 
            if(reset == 1'b1 && sig_Delayed_Reset == 1'b0)        
                sig_Start <= 1'b1;
            else
                sig_Start <= 1'b0;
        end
    end




endmodule                   
