/*
 * Write the image (the processed image) into a bitmap image
 */

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
    /*
     * When this this pulse is high, it means that the data is valid.
     * We can write the data into the image.
     */                                          
    input horizontal_Pulse;

    /*
     * We use two pixels at the same time because each data has three different components 
     * which is red, green and blue.
     */  

    // 8 bit Red, Green, Blue  data (Even)                         
    input [7:0]  data_Red_Even;                     
    input [7:0]  data_Green_Even;                     
    input [7:0]  data_Blue_Even;  
    // 8 bit Red, Green, Blue  data (Odd)   
    input [7:0]  data_Red_Odd;                     
    input [7:0]  data_Green_Odd;                     
    input [7:0]  data_Blue_Odd;      
    
    output  reg  sig_Write_Done;

    
    // Define the number of bytes of the BMP header
    parameter BMP_HEADER_NUMBER = 54;

    // BMP header
    integer bmp_Header [0 : BMP_HEADER_NUMBER - 1];        

    // Counting variables
    integer i;
    integer k, l, m;
    integer fd; 
    
    wire done_Flag;     

    // Temporary memory 
    reg [7:0] output_Bmp  [0 : IMAGE_WIDTH * IMAGE_HEIGHT * 3 - 1];        
    reg [18:0] data_Counter;                        

    /*
     * If you you change the image size, you'll have to change the header!
     */
    initial begin
        bmp_Header[0]  = 66;bmp_Header[18] =  0; bmp_Header[36] = 0; 
        bmp_Header[1]  = 77;bmp_Header[19] =  3; bmp_Header[37] = 0; 
        bmp_Header[2]  = 54;bmp_Header[20] =  0; bmp_Header[38] = 0; 
        bmp_Header[3]  =  0;bmp_Header[21] =  0; bmp_Header[39] = 0; 
        bmp_Header[4]  = 18;bmp_Header[22] =  0; bmp_Header[40] = 0;                                       
        bmp_Header[5]  =  0;bmp_Header[23] =  2; bmp_Header[41] = 0; 
        bmp_Header[6]  =  0;bmp_Header[24] =  0; bmp_Header[42] = 0; 
        bmp_Header[7]  =  0;bmp_Header[25] =  0; bmp_Header[43] = 0; 
        bmp_Header[8]  =  0;bmp_Header[26] =  1; bmp_Header[44] = 0;
        bmp_Header[9]  =  0;bmp_Header[27] =  0; bmp_Header[45] = 0;
        bmp_Header[10] = 54;bmp_Header[28] = 24; bmp_Header[46] = 0;
        bmp_Header[11] =  0;bmp_Header[29] =  0; bmp_Header[47] = 0;
        bmp_Header[12] =  0;bmp_Header[30] =  0; bmp_Header[48] = 0;
        bmp_Header[13] =  0;bmp_Header[31] =  0; bmp_Header[49] = 0;
        bmp_Header[14] = 40;bmp_Header[32] =  0; bmp_Header[50] = 0;
        bmp_Header[15] =  0;bmp_Header[33] =  0; bmp_Header[51] = 0; 
        bmp_Header[16] =  0;bmp_Header[34] =  0; bmp_Header[52] = 0;
        bmp_Header[17] =  0;bmp_Header[35] =  0; bmp_Header[53] = 0;
    end


    // Row and Column counting for temporary memory of image  
    always@(posedge clk, negedge reset) begin
        if(!reset) begin
            l <= 0;
            m <= 0;
        end 
        else begin
            if(horizontal_Pulse) begin
                if(m == IMAGE_WIDTH / 2 - 1) begin
                    m <= 0;
                    l <= l + 1; 
                end 
                else begin
                    m <= m + 1; 
                end
            end
        end
    end


    always@(posedge clk, negedge reset) begin
        if(!reset) begin
            for(k = 0; k < IMAGE_WIDTH * IMAGE_HEIGHT * 3; k = k + 1) begin
                output_Bmp[k] <= 0;
            end
        end else begin
            if(horizontal_Pulse) begin
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m + 2] <= data_Red_Even;
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m + 1] <= data_Green_Even;
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m    ] <= data_Blue_Even;
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m + 5] <= data_Red_Odd;
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m + 4] <= data_Green_Odd;
                output_Bmp[IMAGE_WIDTH *3 * (IMAGE_HEIGHT - l - 1) +6 * m + 3] <= data_Blue_Odd;
            end
        end
    end


    // Counting data 
    always@(posedge clk, negedge reset)
        begin
            if(~reset) begin
                data_Counter <= 0;
            end
            else begin
                if(horizontal_Pulse)
                    data_Counter <= data_Counter + 1; 
            end
        end
    

    assign done_Flag = (data_Counter == 196607)? 1'b1: 1'b0; 


    always@(posedge clk, negedge reset)
        begin
            if(~reset) begin
                sig_Write_Done <= 0;
            end
            else begin
                sig_Write_Done <= done_Flag;
            end
        end


    initial begin
        fd = $fopen(OUTPUT_FILE, "wb+");
    end

    /*
     * After processing, we  will write the image into the the image file
     */
    always@(sig_Write_Done) begin 
        if(sig_Write_Done == 1'b1) begin

            for(i = 0; i < BMP_HEADER_NUMBER; i = i + 1) begin
                $fwrite(fd, "%c", bmp_Header[i][7:0]); 
            end

            for(i = 0; i < IMAGE_WIDTH * IMAGE_HEIGHT * 3; i = i + 6) begin
                $fwrite(fd, "%c", output_Bmp[i  ][7:0]);
                $fwrite(fd, "%c", output_Bmp[i+1][7:0]);
                $fwrite(fd, "%c", output_Bmp[i+2][7:0]);
                $fwrite(fd, "%c", output_Bmp[i+3][7:0]);
                $fwrite(fd, "%c", output_Bmp[i+4][7:0]);
                $fwrite(fd, "%c", output_Bmp[i+5][7:0]);
            end
        end
    end

endmodule