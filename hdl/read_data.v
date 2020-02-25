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
        data_Red_Even,                
        data_Green_Even,                
        data_Blue_Even,                
        data_Red_Odd,             
        data_Green_Odd,             
        data_Blue_Odd,
        vertical_Pulse,                         
        horizontal_Pulse,                           
        sig_done                   
    );

    input clk;
    // Active low                                       
    input reset;
    // 8 bit Red, Green, Blue  data (Even)                                  
    output reg [7:0]  data_Red_Even;              
    output reg [7:0]  data_Green_Even;          
    output reg [7:0]  data_Blue_Even;
    // 8 bit Red, Green, Blue  data (Odd)                       
    output reg [7:0]  data_Red_Odd;               
    output reg [7:0]  data_Green_Odd;               
    output reg [7:0]  data_Blue_Odd;
    // Vertical synchronous pulse
    output vertical_Pulse;  
    // Horizontal synchronous pulse                         
    output reg horizontal_Pulse;                        
    output sig_done;

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


    always@(posedge clk, negedge reset) begin
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


    always@(posedge clk, negedge reset) begin
        if(~reset) begin
            current_STATE <= STATE_IDLE;
        end
        else begin
            current_STATE <= next_STATE; 
        end
    end


    always @(*) begin
        case(current_STATE)
            STATE_IDLE: begin
                if(sig_Start)
                    next_STATE = STATE_VERTICAL_SYNC;
                else
                    next_STATE = STATE_IDLE;
            end         
            STATE_VERTICAL_SYNC: begin
                if(vsync_Counter == sig_Delayed_Reset) 
                    next_STATE = STATE_HORIZONTAL_SYNC;
                else
                    next_STATE = STATE_VERTICAL_SYNC;
            end
            STATE_HORIZONTAL_SYNC: begin
                if(hsync_Counter == HORIZONTAL_SYNC_DELAY) 
                    next_STATE = STATE_DATA_PROCESSING;
                else
                    next_STATE = STATE_HORIZONTAL_SYNC;
            end     
            STATE_DATA_PROCESSING: begin
                if(sig_done)
                    next_STATE = STATE_IDLE;
                else begin
                    if(column == IMAGE_WIDTH - 2)
                        next_STATE = STATE_HORIZONTAL_SYNC;
                    else
                        next_STATE = STATE_DATA_PROCESSING;
                end
            end
        endcase
    end


    always @(*) begin
        sig_Ctrl_Vsync = 0;
        sig_Ctrl_Hsync = 0;
        sig_Ctrl_Data  = 0;
        case(current_STATE)
            STATE_VERTICAL_SYNC:   
                begin 
                    sig_Ctrl_Vsync = 1; 
                end   
            STATE_HORIZONTAL_SYNC:   
                begin 
                    sig_Ctrl_Hsync = 1; 
                end   
            STATE_DATA_PROCESSING:    
                begin 
                    sig_Ctrl_Data = 1; 
                end   
        endcase
    end

    
    always@(posedge clk, negedge reset)
    begin
        if(~reset) begin
            vsync_Counter <= 0;
            hsync_Counter <= 0;
        end
        else begin
            if(sig_Ctrl_Vsync)
                vsync_Counter <= vsync_Counter + 1; 
            else 
                vsync_Counter <= 0;
                
            if(sig_Ctrl_Hsync)
                hsync_Counter <= hsync_Counter + 1;   
            else
                hsync_Counter <= 0;
        end
    end



endmodule                   
