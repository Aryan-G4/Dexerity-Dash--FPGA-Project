module minigame2(CLOCK_50, KEY, HEX0, LEDR, SW);
	input CLOCK_50;
	input [3:0] KEY;
	input [4:0] SW;
	output [6:0] HEX0;
	output [5:0] LEDR;
	
	wire [1:0] random_number;
	assign LEDR[2:0] = random_number;
	wire [9:0] max_time;
	wire timer_done;
	assign timer_done = 1'b0;
	assign LEDR[5] = timer_done;
	wire clock;
	assign clock = 1'b1;
	
	wire correct;
	assign LEDR[4] = correct;
	
	wire [3:0] button_signal;
	assign button_signal = ~KEY[3:0];
	
	
	wire [15:0] seed;
	assign seed = 16'b0001110001111111;
	
	// RandomNumberGenerator (clk, reset, seed, random_number);
	randomnumber peepee(SW[0], correct, random_number);
	//hex_decoder poopoo(random_number, HEX0);
	
	// gamecheck(timerdone, reset, clock, randomnumber, buttonsignal, correct)
	gamecheck poopoo(timer_done, SW[0], clock, random_number, button_signal, correct);
	
endmodule 


module randomnumber (
  input wire reset,
  input wire correct,  // Seed input
  output reg [3:0] random_number
);

  //reg [15:0] lfsr; // 16-bit Linear Feedback Shift Register

  // Initial seed assignment
  reg [15:0] xval;

  always @(*) begin
    if (reset) 
    begin
      xval <= 4'b001;
    end 
    if(correct)
    begin
      if (correct) //if the user chose the right number
      xval <= (xval + 1) * 3 + 31;
    end

    // Extract the lower 4 bits of the LFSR as the random number
    random_number <= xval[1:0];//2 BITS FOR TEST
  end

endmodule

module gamecheck(timerdone,reset,clock, randomnumber, buttonsignal, correct);
    input clock;
    input timerdone;
    input [1:0] randomnumber;
    input [3:0] buttonsignal;
    input reset;
    output reg correct;

always@(*)
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