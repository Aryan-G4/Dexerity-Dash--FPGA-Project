module gamecheck(timerdone,reset,clock, randomnumber, buttonsignal, correct);
    input clock;
    input timerdone;
    input [3:0] randomnumber;
    input [3:0] buttonsignal;
    input reset;
    output reg correct;

always@(posedge clock)
    begin
        if (timerdone)
            correct <= 1'b0;
        else if (reset)
            correct <= 1'b0; 
        else if (randomnumber == buttonsignal) // user pressed the correct button
            correct <= 1'b1;
        else
            correct <= 1'b0;
    //default: correct <= 1'b0;
    end

endmodule
