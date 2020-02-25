module write_data
    #(parameter 
        OUTPUT_FILE  = "output_picture.bmp",                        
        IMAGE_WIDTH = 768,                          
        IMAGE_HEIGHT = 512                          
    )
    (
        clk,                                          
        reset,                                          
        horizontal_Pulse,                                                  
        data_Red_Even,                
        data_Green_Even,                
        data_Blue_Even,                
        data_Red_Odd,             
        data_Green_Odd,             
        data_Blue_Odd,
        sig_Write_Done
    ); 

    input clk; 
    // Active low                                            
    input reset; 
    // Horizontal synchronous pulse                                          
    input horizontal_Pulse;
       
    /*
     * We Use two pixels at the same time because each data has three different components 
     * which is red, green and blue.
     */  

    // 8 bit Red, Green, Blue  data (Even)                                                                         
    input  data_Red_Even;              
    input [7:0]  data_Green_Even;          
    input [7:0]  data_Blue_Even;
    // 8 bit Red, Green, Blue  data (Odd)                       
    input [7:0]  data_Red_Odd;               
    input [7:0]  data_Green_Odd;               
    input [7:0]  data_Blue_Odd;

    output reg sig_Write_Done;

    // Header for bmp image
    parameter BMP_HEADER_NUMBER = 54; 
    
    // BMP header
    integer bmp_Header [0 : BMP_HEADER_NUMBER - 1];                                            

endmodule
