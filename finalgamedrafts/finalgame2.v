module finalgame2(CLOCK_50, GPIO_0, KEY, GPIO_1, HEX0, HEX1, LEDR);
    input CLOCK_50;
    input [7:0] GPIO_0;
    input [1:0] KEY;
    output [7:0] GPIO_1;
    output [6:0] HEX0;
    output [6:0] HEX1;
    output[9:0] LEDR;

    wire [7:0] current_led;
    assign GPIO_1 = current_led;

    wire correctsignal;
    are_same check1(GPIO_0,current_led,correctsignal);

    wire [7:0] score_binary;
    countscore score(correctsignal, KEY[0], score_binary);

    setled changeled(correctsignal, KEY[0], current_led);

    //TIMER STUFF
    wire [9:0] max_time;
	wire timer_done;
	wire [9:0] timer_value;
	wire [7:0] dec;
	
	assign max_time = 10'd60;
	assign LEDR[0] = timer_done;
	
	
	timerb T0(CLOCK_50, KEY[0], KEY[1], max_time, timer_done, timer_value);
	
	hex_to_dec HD0(timer_value[7:0], dec);
	
	hex_decoder H0(dec[3:0], HEX0); 
	hex_decoder H1(dec[7:4], HEX1);
    //TIMER STUFF DONE

endmodule

module are_same(input1,input2,correct);
    input [7:0]input1;
    input [7:0] input2;
    output reg correct;
    
    always@(*)
        if (input1 == input2)
            correct = 1'b1;
        else
            correct = 1'b0;    

endmodule

module countscore(correct, reset, score_binary);
    input correct, reset;
    output reg [7:0] score_binary;

    always@(posedge correct or posedge reset)
        if (reset)
            score_binary <= 8'b0;
        else
            score_binary <= score_binary + 1;
    
endmodule

module setled(correct,reset,current_led);
    input correct, reset;
    output reg [7:0]current_led;

    always@(*)
    begin
        if (reset)
            current_led <= 8'b00000001;
        //else if (current_led == 8'b10000000)
            //current_led <= 8'b00000001;
        else if (correct)
            current_led = current_led << 1;
    end
endmodule

/*module timer(CLOCK_50, KEY, HEX0, HEX1, LEDR);
	input CLOCK_50;
	input [1:0] KEY;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [0:0] LEDR;
	

	
endmodule*/


module timerb(clk, resetn, manual_resetn, max_time, timer_done, timer_value); // manual_reset should be reset in the middle somewhere in the state machine
	input clk;
	input resetn;
	input manual_resetn; // makes sure you just reset the timer, not the entire thing
	input [9:0] max_time;
	output timer_done; // active high
	output reg [9:0] timer_value; // 6 bits is enough for 60 seconds, but 10 bits doesn't hurt
	
	wire enable;
	
	

	RateDivider R0(clk, resetn && ~timer_done, enable);
	
	always@(posedge clk)
	begin
		if(resetn || manual_resetn)
			timer_value <= max_time;
		else if(enable)
			timer_value <= timer_value - 1'b1;	
	end
	
	assign timer_done = (timer_value == 10'b0) ? 1'b1 : 1'b0;
endmodule

module RateDivider
#(parameter CLOCK_FREQUENCY = 50000000) (
	input ClockIn,
	input resetn,
	output Enable
);
	reg [27:0] q;	// log2(50000000/0.25)
	
	wire [27:0] q_max;
		
	assign q_max = CLOCK_FREQUENCY;
	
	always@(posedge ClockIn)
	begin
		if (resetn) // active low reset
			q <= q_max;
		else
			if (q == 28'b0)
				q <= q_max;
			else
				q <= q - 1;
	end
	
	assign Enable = (q == 28'b0) ? 1'b1 : 1'b0; // when q reaches 0, enable goes high for one cycle (pulse)
endmodule

module hex_decoder(d, hex); // decoding from 4 bits to 7 bits (translating from binary to 7 seg)
	input wire [3:0] d;
	output reg [6:0] hex;
	
	always@(*)
	begin
		case(d)
			//4'bXXXX: hex = 7'b6543210;
			4'b0000: hex = 7'b1000000; // 0 
			4'b0001: hex = 7'b1111001; // 1 
			4'b0010: hex = 7'b0100100; // 2 
			4'b0011: hex = 7'b0110000; // 3 
			4'b0100: hex = 7'b0011001; // 4 
			4'b0101: hex = 7'b0010010; // 5 
			4'b0110: hex = 7'b0000010; // 6 
			4'b0111: hex = 7'b1111000; // 7 
			4'b1000: hex = 7'b0000000; // 8 
			4'b1001: hex = 7'b0011000; // 9 
			4'b1010: hex = 7'b0001000; // A 
			4'b1011: hex = 7'b0000011; // b 
			4'b1100: hex = 7'b1000110; // C 
			4'b1101: hex = 7'b0100001; // d 
			4'b1110: hex = 7'b0000110; // E 
			4'b1111: hex = 7'b0001110; // F 
		endcase
	end

endmodule

module hex_to_dec(hex, dec);
	input [7:0] hex;
	output reg [7:0] dec;
	
	reg [3:0] dummy;
	
	always@(*)
	begin
		if(hex < 10)
		begin
			dec <= hex;
		end
		
		else if(hex < 20)
		begin
			/*dec[7:4] = 4'b1;
			{dummy, dec[3:0]} = hex - 8'd10;*/ // does the same thing as the lines below
			
			dec <= hex - 8'd10;
			dec[7:4] <= 4'b0001;
		end
		
		else if(hex < 30)
		begin
			dec <= hex - 8'd20;
			dec[7:4] <= 4'b0010;
		end
		
		else if(hex < 40)
		begin
			dec <= hex - 8'd30;
			dec[7:4] <= 4'b0011;
		end
		
		else if(hex < 50)
		begin
			dec <= hex - 8'd40;
			dec[7:4] <= 4'b0100;
		end
		
		else if(hex < 60)
		begin
			dec <= hex - 8'd50;
			dec[7:4] <= 4'b0101;
		end
		
		else
		begin
			dec <= 8'd0;
		end
	end
	
endmodule
