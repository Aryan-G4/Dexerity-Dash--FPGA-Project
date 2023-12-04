module signaltester (KEY, GPIO_0, GPIO_1);
    input [1:0] KEY;
    input [35:0] GPIO_0;
    output [35:0] GPIO_1;

    /*always @(*)
        if (!KEY[0]) begin
            GPIO_1[7:0] <= 8'b00000000;
        end
        else if (GPIO_0[0] == 1'b1)begin
            
        end*/

    assign GPIO_1 = GPIO_0;

endmodule