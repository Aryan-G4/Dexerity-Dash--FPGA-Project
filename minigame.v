module minigame(CLOCK_50, KEY, HEX0, LEDR, SW0);
	input CLOCK_50;
	input [3:0] KEY;
	input [4:0] SW;
	output [6:0] HEX0;
	output [5:0] LEDR;
	
	wire [3:0] random_number;
	wire [9:0] max_time;
	wire timer_done;
	assign timer_done = 1'b0;
	assign LEDR[5] = timer_done;
	
	wire correct;
	assign LEDR[4] = correct;
	
	
	wire [3:0] button_signal;
	assign KEY[3:0] =  button_signal;
	
	
	wire [15:0] seed;
	assign seed = 16'b0001110001111111;
	
	// RandomNumberGenerator (clk, reset, seed, random_number);
	RandomNumberGenerator R0(CLOCK_50, SW[0], seed, random_number);
	hex_decoder H0(random_number, HEX0);
	
	// gamecheck(timerdone, reset, clock, randomnumber, buttonsignal, correct)
	gamecheck G0(timer_done, SW[0], CLOCK_50, random_number, button_signal, correct);
	
endmodule 


module RandomNumberGenerator (
  input wire clk,
  input wire reset,
  input wire [15:0] seed,  // Seed input
  output reg [3:0] random_number
);

  reg [15:0] lfsr; // 16-bit Linear Feedback Shift Register

  // Initial seed assignment
  always @(posedge reset) begin
    lfsr <= seed;
  end

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset the LFSR to the seed value on reset
      lfsr <= seed;
    end else begin
      // LFSR feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
      lfsr <= lfsr ^ (lfsr << 1) ^ (lfsr << 3) ^ (lfsr << 4) ^ 1;
    end

    // Extract the lower 4 bits of the LFSR as the random number
    random_number <= lfsr[3:0];
  end

endmodule

module gamecheck(timerdone,reset,clock, randomnumber, buttonsignal, correct);
    input clock;
    input timerdone;
    input [3:0] randomnumber;
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

module hex_decoder(d, hex); // decoding from 4 bits to 7 bits (translating from binary to 7 seg)
	input wire [3:0] d;
	output reg [6:0] hex;
	
	always@(*)
	begin
		case(d)
			//4'bXXXX: hex = 7'b6543210;
			4'b0000: hex = 7'b0111111; // 0
			4'b0001: hex = 7'b0000110; // 1
			4'b0010: hex = 7'b1001111; // 2
			4'b0011: hex = 7'b1100110; // 3
			4'b0100: hex = 7'b1100110; // 4
			4'b0101: hex = 7'b1101101; // 5
			4'b0110: hex = 7'b1111101; // 6
			4'b0111: hex = 7'b0000111; // 7
			4'b1000: hex = 7'b1111111; // 8
			4'b1001: hex = 7'b1100111; // 9
			4'b1010: hex = 7'b1110111; // A
			4'b1011: hex = 7'b1111100; // b
			4'b1100: hex = 7'b0111001; // C
			4'b1101: hex = 7'b1011110; // d
			4'b1110: hex = 7'b1111001; // E
			4'b1111: hex = 7'b1110001; // F
		endcase
	end

endmodule

module hex_to_dec(hex, dec);
	input [7:0] hex;
	output [7:0] dec;
	
	reg [3:0] dummy;
	
	always@(*)
	begin
		if(hex < 10)
		begin
			dec = hex;
		end
		
		else if(hex < 20)
		begin
			/*dec[7:4] = 4'b1;
			{dummy, dec[3:0]} = hex - 8'd10;*/ // does the same thing as the lines below
			
			dec = hex - 8'd10;
			dec[7:4] = 4'b1;
		end
		
		else if(hex < 30)
		begin
			dec = hex - 8'd20;
			dec[7:4] = 4'b2;
		end
		
		else if(hex < 40)
		begin
			dec = hex - 8'd30;
			dec[7:4] = 4'b3;
		end
		
		else if(hex < 50)
		begin
			dec = hex - 8'd40;
			dec[7:4] = 4'b4;
		end
		
		else if(hex < 60)
		begin
			dec = hex - 8'd50;
			dec[7:4] = 4'b5;
		end
		
		else
		begin
			dec = 8'd0;
		end
	end
	
endmodule