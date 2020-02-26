module Image_Processing
    #(parameter 
        INPUT_FILE  = "input_picture.hex", 
        OUTPUT_FILE  = "output_picture.bmp"               
    )
    (
        clk,                                                
        reset                                
    );
    
    input clk;
    input reset;

    wire vsync;
    wire hsync;
    wire [ 7 : 0] data_R0;
    wire [ 7 : 0] data_G0;
    wire [ 7 : 0] data_B0;
    wire [ 7 : 0] data_R1;
    wire [ 7 : 0] data_G1;
    wire [ 7 : 0] data_B1;
    wire enc_done;


    read_data 
    #(.INPUT_FILE(INPUT_FILE))
    u_image_read
    ( 
        .clk(clk),
        .reset(reset),
        .vertical_Pulse(vsync),
        .horizontal_Pulse(hsync),
        .data_Red_Even(data_R0),
        .data_Green_Even(data_G0),
        .data_Blue_Even(data_B0),
        .data_Red_Odd(data_R1),
        .data_Green_Odd(data_G1),
        .data_Blue_Odd(data_B1),
        .sig_done(enc_done)
    );

    write_data 
    #(.OUTPUT_FILE(OUTPUT_FILE))
    u_image_write
    (
        .clk(clk),
        .reset(reset),
        .horizontal_Pulse(hsync),
        .data_Red_Even(data_R0),
        .data_Green_Even(data_G0),
        .data_Blue_Even(data_B0),
        .data_Red_Odd(data_R1),
        .data_Green_Odd(data_G1),
        .data_Blue_Odd(data_B1),
        .sig_Write_Done()
    );   
endmodule