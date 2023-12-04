module top_level_vga_background
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
		KEY,							// On Board Keys
		LEDR,
		HEX0,
		HEX1,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input CLOCK_50;				//	50 MHz
	input [3:0]	KEY;
	input [9:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [0:0] LEDR;
	
	// input [6:0] SW;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	//////////////////////// TIMER
	wire [9:0] max_time;
	wire timer_done;
	wire [9:0] timer_value;
	wire [7:0] dec;
	
	assign max_time = 10'd30;
	assign LEDR[0] = timer_done;
	
	// timerb(clk, resetn, manual_resetn, max_time, timer_done, timer_value)
	timerb T0(CLOCK_50, KEY[0], KEY[1], max_time, timer_done, timer_value);
	
	hex_to_dec HD0(timer_value[7:0], dec);
	
	hex_decoder H0(dec[3:0], HEX0); 
	hex_decoder H1(dec[7:4], HEX1);
	///////////////////////////////

	// refresh_vga(clock, resetn, enable, vga_enable);
	refresh_vga RV0(CLOCK_50, resetn, 1'b1, writeEn); // we always enable refresh vga for now
	
	// hex_vga(iClock, iResetn, x_counter, y_counter, pixel_out, x_counter_enable, score_1, score_0, timer_1, timer_0);
	hex_vga HV0(CLOCK_50, !KEY[0], x, y, colour, writeEn, 6, 9, dec[7:4], dec[3:0]);
	
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
	
endmodule

module timer(CLOCK_50, KEY, HEX0, HEX1, LEDR);
	input CLOCK_50;
	input [1:0] KEY;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [0:0] LEDR;
	
	wire [9:0] max_time;
	wire timer_done;
	wire [9:0] timer_value;
	wire [7:0] dec;
	
	assign max_time = 10'd60;
	assign LEDR[0] = timer_done;
	
	//timerb(clk, resetn, manual_resetn, max_time, timer_done, timer_value)
	timerb T0(CLOCK_50, KEY[0], KEY[1], max_time, timer_done, timer_value);
	
	hex_to_dec HD0(timer_value[7:0], dec);
	
	hex_decoder H0(dec[3:0], HEX0); 
	hex_decoder H1(dec[7:4], HEX1);
	
endmodule


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
		if(!resetn || !manual_resetn)
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
		if (!resetn) // active low reset
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


/*
module top_level_vga_background
	(
		CLOCK_50,						//	On Board 50 MHz
		SW,// Your inputs and outputs here
		KEY,							// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,					//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;
	input [9:0] SW;
	//input [6:0] SW;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// refresh_vga(clock, resetn, enable, vga_enable);
	refresh_vga RV0(CLOCK_50, resetn, 1'b1, writeEn); // we always enable refresh vga for now
	
	// hex_vga(iClock, iResetn, x_counter, y_counter, pixel_out, x_counter_enable, score_1, score_0, timer_1, timer_0);
	hex_vga HV0(CLOCK_50, !KEY[0], x, y, colour, writeEn, 6, 9, 3, 4);
	
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor.
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";*/
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	
	
/*endmodule

*/


module hex_vga(iClock, iResetn, x_counter, y_counter, pixel_out, x_counter_enable, score_1, score_0, timer_1, timer_0); // provides plot, x, y, and colour at the right time to the vga adapter

	input iClock;
	input iResetn;
	
	output reg [7:0] x_counter;
	output reg [6:0] y_counter;
	output reg [2:0] pixel_out;
	input x_counter_enable;
	
	input [3:0] score_1, score_0, timer_1, timer_0;
	
    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	parameter BLACK = 3'b0;
	parameter LETTER_W = 50;
	parameter LETTER_H = 10;
	
	// Parameters for Seven Segment Display
	parameter SS_W = 24; // Seven Segment Width
	parameter SS_H = 44; // Seven Segment Height
	parameter SS_C = 3'b111; // Seven Segment Colour
	parameter SS_X0 = 10; // x value of top-left coordinates of leftmost seven segment
	parameter SS_Y0 = 52; // y value of top-left coordinates of leftmost seven segment
	parameter SS_X1 = SS_X0 + 28; // x value of top-left coordinates of second leftmost seven segment
	parameter SS_Y1 = SS_Y0; // y value of top-left coordinates of second leftmost seven segment
	parameter SS_X2 = SS_X0 + 88; // x value of top-left coordinates of second rightmost seven segment
	parameter SS_Y2 = SS_Y0; // y value of top-left coordinates of second rightmost seven segment
	parameter SS_X3 = SS_X0 + 116; // x value of top-left coordinates of rightmost seven segment
	parameter SS_Y3 = SS_Y0; // y value of top-left coordinates of rightmost seven segment
	
	// Parameters for Score and Timer
	parameter SC_X = SS_X0;
	parameter SC_Y = SS_Y0 + 52;
	parameter SC_C = 3'b010; // green
	parameter TI_X = SS_X2;
	parameter TI_Y = SC_Y;
	parameter TI_C = 3'b100; // red
	
	// Parameters for Title
	parameter DEX_X = 35;
	parameter DEX_Y = 15;
	parameter RITY_X = DEX_X + 50;
	parameter RITY_Y = DEX_Y;
	parameter DASH_X = 60;
	parameter DASH_Y = 30;
	parameter TITLE_C = 3'b001;

	wire y_counter_enable;
	
	wire [7:0] x_counter_max;
	wire [6:0] y_counter_max;
	
	wire [2:0] ss_0_pixel_out, ss_1_pixel_out, ss_2_pixel_out, ss_3_pixel_out, score_pixel_out, timer_pixel_out;
	
	assign x_counter_max = X_SCREEN_PIXELS-8'd1;
	assign y_counter_max = Y_SCREEN_PIXELS-7'd1;
	
	assign y_counter_enable = x_counter_enable && (x_counter == x_counter_max);
	
	// x_counter_enable must be ensbled 120 * 160 times

	always@(posedge iClock)
	begin
		if(!iResetn)
		begin
			x_counter <= 8'b0;
		end
		else
			if(x_counter_enable) begin
				if (x_counter == x_counter_max)
					x_counter <= 8'b0;
				else
					x_counter <= x_counter + 1'b1;
			end
	end

	always@(posedge iClock)
	begin
		if(!iResetn)
		begin
			y_counter <= 7'b0;
		end
		else
			if(y_counter_enable) begin
				if (y_counter == y_counter_max)
					y_counter <= 7'b0;
				else
					y_counter <= y_counter + 1'b1;
			end
	end
	
	// vga_seven_seg(disp_val, x, y, c, pixel_out);
	vga_seven_seg VSS0(score_1, x_counter - SS_X0, y_counter - SS_Y0, SS_C, ss_0_pixel_out); // score 1 is the decimal digit value 
	vga_seven_seg VSS1(score_0, x_counter - SS_X1, y_counter - SS_Y1, SS_C, ss_1_pixel_out); // score 0 is the decimal digit value 
	vga_seven_seg VSS2(timer_1, x_counter - SS_X2, y_counter - SS_Y2, SS_C, ss_2_pixel_out); // timer 1 is the decimal digit value 
	vga_seven_seg VSS3(timer_0, x_counter - SS_X3, y_counter - SS_Y3, SS_C, ss_3_pixel_out); // timer 0 is the decimal digit value 
	
	// vga_score(x, y, c, pixel_out)
	vga_score VSCORE(x_counter - SC_X, y_counter - SC_Y, SC_C, score_pixel_out);
	
	// vga_timer(x, y, c, pixel_out)
	vga_timer VTIMER(x_counter - TI_X, y_counter - TI_Y, TI_C, timer_pixel_out);
	
	// vga_dexterity(x, y, c, pixel_out)
	vga_dexte VDEX(x_counter - DEX_X, y_counter - DEX_Y, TITLE_C, dexte_pixel_out);
	vga_rity VRITY(x_counter - RITY_X, y_counter - RITY_Y, TITLE_C, rity_pixel_out);
	
	// vga_dash(x, y, c, pixel_out)
	vga_dash VDASH(x_counter - DASH_X, y_counter - DASH_Y, TITLE_C, dash_pixel_out);
	
	always@(*)
	begin
	if (SS_X0 <= x_counter && x_counter < SS_X0 + SS_W && // for VSS0
	    SS_Y0 <= y_counter && y_counter < SS_Y0 + SS_H) 
		begin
			pixel_out = ss_0_pixel_out;
		end 
	else if (SS_X1 <= x_counter && x_counter < SS_X1 + SS_W && // for VSS1
	         SS_Y1 <= y_counter && y_counter < SS_Y1 + SS_H) 
		begin
			pixel_out = ss_1_pixel_out;
		end 
	else if (SS_X2 <= x_counter && x_counter < SS_X2 + SS_W && // for VSS2
	         SS_Y2 <= y_counter && y_counter < SS_Y2 + SS_H) 
		begin
			pixel_out = ss_2_pixel_out;
		end 

	else if (SS_X3 <= x_counter && x_counter < SS_X3 + SS_W && // for VSS3
	         SS_Y3 <= y_counter && y_counter < SS_Y3 + SS_H) 
		begin
			pixel_out = ss_3_pixel_out;
		end 
	else if (SC_X <= x_counter && x_counter < SC_X + LETTER_W && // for VSCORE
	         SC_Y <= y_counter && y_counter < SC_Y + LETTER_H) 
		begin
			pixel_out = score_pixel_out;
		end
	else if (TI_X <= x_counter && x_counter < TI_X + LETTER_W && // for VTIMER
	         TI_Y <= y_counter && y_counter < TI_Y + LETTER_H) 
		begin
			pixel_out = timer_pixel_out;
		end
	else if (DEX_X <= x_counter && x_counter < DEX_X + LETTER_W && // for VDEX
	         DEX_Y <= y_counter && y_counter < DEX_Y + LETTER_H) 
		begin
			pixel_out = dexte_pixel_out;
		end
	else if (RITY_X <= x_counter && x_counter < RITY_X + LETTER_W && // for VDEX
	         RITY_Y <= y_counter && y_counter < RITY_Y + LETTER_H) // for VRITY
		begin
			pixel_out = rity_pixel_out;
		end
	else if (DASH_X <= x_counter && x_counter < DASH_X + LETTER_W && // for VDASH
	         DASH_Y <= y_counter && y_counter < DASH_Y + LETTER_H) 
		begin
			pixel_out = dash_pixel_out;
		end
////////////////////////////////// using else if, whatever else you want to add can be added here

	else
		begin
			pixel_out = BLACK;
		end
	end
		
	
endmodule


module vga_seven_seg(disp_val, x, y, c, pixel_out);
	input [3:0] disp_val; // 4 bits because it is a digit between 0 and 9
	input [7:0] x; // range [0, 23]
	input [6:0] y; // range [0, 43]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [4:0] y1;
	reg [0:23] row;
	
	
	assign y1 = y[6:2];//y >> 2; // divides y by 4  y = abcdefg
	                                                 // 6543210 --> 65432
	
	//4-16-4
	
	always@(*)
	begin
		case(disp_val)
			4'b0000: // 0
				begin 
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
				 		5'b00001: row = 24'b111100000000000000001111; 
						5'b00010: row = 24'b111100000000000000001111;
						5'b00011: row = 24'b111100000000000000001111;
						5'b00100: row = 24'b111100000000000000001111;
						5'b00101: row = 24'b000000000000000000000000; 
						5'b00110: row = 24'b111100000000000000001111; 
						5'b00111: row = 24'b111100000000000000001111; 
						5'b01000: row = 24'b111100000000000000001111; 
						5'b01001: row = 24'b111100000000000000001111; 
						5'b01010: row = 24'b000011111111111111110000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0001: // 1
				begin
					case(y1)
						5'b00000: row = 24'b000000000000000000000000; 
						5'b00001: row = 24'b000000000000000000001111; 
						5'b00010: row = 24'b000000000000000000001111;
						5'b00011: row = 24'b000000000000000000001111;
						5'b00100: row = 24'b000000000000000000001111;
						5'b00101: row = 24'b000000000000000000000000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000000000000000000000000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0010: // 2
				begin
					case(y1)
 						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b000000000000000000001111; 
						5'b00010: row = 24'b000000000000000000001111;
						5'b00011: row = 24'b000000000000000000001111;
						5'b00100: row = 24'b000000000000000000001111;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b111100000000000000000000; 
						5'b00111: row = 24'b111100000000000000000000; 
						5'b01000: row = 24'b111100000000000000000000; 
						5'b01001: row = 24'b111100000000000000000000; 
						5'b01010: row = 24'b000011111111111111110000;
						default: row = 24'b0; 
					endcase
				end
			4'b0011: // 3
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b000000000000000000001111; 
						5'b00010: row = 24'b000000000000000000001111;
						5'b00011: row = 24'b000000000000000000001111;
						5'b00100: row = 24'b000000000000000000001111;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000011111111111111110000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0100: // 4
				begin
					case(y1)
						5'b00000: row = 24'b000000000000000000000000; 
						5'b00001: row = 24'b111100000000000000001111; 
						5'b00010: row = 24'b111100000000000000001111;
						5'b00011: row = 24'b111100000000000000001111;
						5'b00100: row = 24'b111100000000000000001111;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000000000000000000000000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0101: // 5
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b111100000000000000000000; 
						5'b00010: row = 24'b111100000000000000000000;
						5'b00011: row = 24'b111100000000000000000000;
						5'b00100: row = 24'b111100000000000000000000;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000011111111111111110000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0110: // 6
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b111100000000000000000000; 
						5'b00010: row = 24'b111100000000000000000000;
						5'b00011: row = 24'b111100000000000000000000;
						5'b00100: row = 24'b111100000000000000000000;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b111100000000000000001111; 
						5'b00111: row = 24'b111100000000000000001111; 
						5'b01000: row = 24'b111100000000000000001111; 
						5'b01001: row = 24'b111100000000000000001111; 
						5'b01010: row = 24'b000011111111111111110000; 
						default: row = 24'b0; 
					endcase
				end
			4'b0111: // 7
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b000000000000000000001111; 
						5'b00010: row = 24'b000000000000000000001111;
						5'b00011: row = 24'b000000000000000000001111;
						5'b00100: row = 24'b000000000000000000001111;
						5'b00101: row = 24'b000000000000000000000000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000000000000000000000000; 
						default: row = 24'b0; 
					endcase
				end
			4'b1000: // 8
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b111100000000000000001111; 
						5'b00010: row = 24'b111100000000000000001111;
						5'b00011: row = 24'b111100000000000000001111;
						5'b00100: row = 24'b111100000000000000001111;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b111100000000000000001111; 
						5'b00111: row = 24'b111100000000000000001111; 
						5'b01000: row = 24'b111100000000000000001111; 
						5'b01001: row = 24'b111100000000000000001111; 
						5'b01010: row = 24'b000011111111111111110000; 
						default: row = 24'b0; 
					endcase
				end
			4'b1001: // 9
				begin
					case(y1)
						5'b00000: row = 24'b000011111111111111110000; 
						5'b00001: row = 24'b111100000000000000001111; 
						5'b00010: row = 24'b111100000000000000001111;
						5'b00011: row = 24'b111100000000000000001111;
						5'b00100: row = 24'b111100000000000000001111;
						5'b00101: row = 24'b000011111111111111110000; 
						5'b00110: row = 24'b000000000000000000001111; 
						5'b00111: row = 24'b000000000000000000001111; 
						5'b01000: row = 24'b000000000000000000001111; 
						5'b01001: row = 24'b000000000000000000001111; 
						5'b01010: row = 24'b000000000000000000000000; 
						default: row = 24'b0; 
					endcase
				end
			default: row = 24'b0;	
		endcase
		
		
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule


module vga_score(x, y, c, pixel_out);
	input [7:0] x; // range [0, 49]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:49] row;
	
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 50'b11111111001111111100111111110011111111001111111100; // 0
			4'b0001: row = 50'b11111111001111111100111111110011111111001111111100; // 1
			4'b0010: row = 50'b11000000001100000000110000110011000011001100000000; // 2
			4'b0011: row = 50'b11000000001100000000110000110011000011001100000000; // 3
			4'b0100: row = 50'b11111111001100000000110000110011111111001111111100; // 4
			4'b0101: row = 50'b11111111001100000000110000110011111111001111111100; // 5
			4'b0110: row = 50'b00000011001100000000110000110011110000001100000000; // 6
			4'b0111: row = 50'b00000011001100000000110000110011011000001100000000; // 7
			4'b1000: row = 50'b11111111001111111100111111110011001100001111111100; // 8
			4'b1001: row = 50'b11111111001111111100111111110011000011001111111100; // 9
			default: row = 50'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule

module vga_timer(x, y, c, pixel_out);
	input [7:0] x; // range [0, 49]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:49] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 50'b11111111001111111100111000111001111111100111111110; // 0
			4'b0001: row = 50'b11111111001111111100111101111001111111100111111110; // 1
			4'b0010: row = 50'b00011000000001100000110111011001100000000110000110; // 2
			4'b0011: row = 50'b00011000000001100000110010011001100000000110000110; // 3
			4'b0100: row = 50'b00011000000001100000110000011001111111100111111110; // 4
			4'b0101: row = 50'b00011000000001100000110000011001111111100111111110; // 5
			4'b0110: row = 50'b00011000000001100000110000011001100000000111100000; // 6
			4'b0111: row = 50'b00011000000001100000110000011001100000000110110000; // 7
			4'b1000: row = 50'b00011000001111111100110000011001111111100110011100; // 8
			4'b1001: row = 50'b00011000001111111100110000011001111111100110000110; // 9
			default: row = 50'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule

module vga_dexte(x, y, c, pixel_out);
	input [7:0] x; // range [0, 49]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:49] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 50'b01111000000111111110010000001001111111100111111110; // 0
			4'b0001: row = 50'b01101110000111111110011000011001111111100111111110; // 1
			4'b0010: row = 50'b01100111000110000000001100110000001100000110000000; // 2
			4'b0011: row = 50'b01100011100110000000000111100000001100000110000000; // 3
			4'b0100: row = 50'b01100001100111111110000011000000001100000111111110; // 4
			4'b0101: row = 50'b01100001100111111110000011000000001100000111111110; // 5
			4'b0110: row = 50'b01100001100110000000000111100000001100000110000000; // 6
			4'b0111: row = 50'b01100111000110000000001100110000001100000110000000; // 7
			4'b1000: row = 50'b01101110000111111110011000011000001100000111111110; // 8
			4'b1001: row = 50'b01111000000111111110010000001000001100000111111110; // 9
			default: row = 50'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule

module vga_rity(x, y, c, pixel_out);
	input [7:0] x; // range [0, 89]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:39] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 40'b0111111110011111111001111111100100000010; // 0
			4'b0001: row = 40'b0111111110011111111001111111100110000110; // 1
			4'b0010: row = 40'b0110000110000011000000001100000011001100; // 2
			4'b0011: row = 40'b0110000110000011000000001100000001111000; // 3
			4'b0100: row = 40'b0111111110000011000000001100000000110000; // 4
			4'b0101: row = 40'b0111111110000011000000001100000000110000; // 5
			4'b0110: row = 40'b0111100000000011000000001100000000110000; // 6
			4'b0111: row = 40'b0110110000000011000000001100000000110000; // 7
			4'b1000: row = 40'b0110011000011111111000001100000000110000; // 8
			4'b1001: row = 40'b0110000110011111111000001100000000110000; // 9
			default: row = 40'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule

module vga_dash(x, y, c, pixel_out);
	input [7:0] x; // range [0, 39]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:39] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 40'b0111100000000011000000111111100110000110; // 0
			4'b0001: row = 40'b0110111000000111100001111111100110000110; // 1
			4'b0010: row = 40'b0110011100001100110001110000000110000110; // 2
			4'b0011: row = 40'b0110001110011000011001110000000110000110; // 3
			4'b0100: row = 40'b0110000110011000011001111111100111111110; // 4
			4'b0101: row = 40'b0110000110011111111001111111100111111110; // 5
			4'b0110: row = 40'b0110000110011111111000000011100110000110; // 6
			4'b0111: row = 40'b0110011100011000011000000011100110000110; // 7
			4'b1000: row = 40'b0110111000011000011001111111100110000110; // 8
			4'b1001: row = 40'b0111100000011000011001111111000110000110; // 9
			default: row = 40'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b0; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule


module vga_welc(x, y, c, pixel_out);
	input [7:0] x; // range [0, 39]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:39] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 40'b1100000110011111111001100000000111111110; // 0
			4'b0001: row = 40'b1100000110011111111001100000000111111110; // 1
			4'b0010: row = 40'b1100000110011000000001100000000110000110; // 2
			4'b0011: row = 40'b1100000110011000000001100000000110000000; // 3
			4'b0100: row = 40'b1100000110011111111001100000000110000000; // 4
			4'b0101: row = 40'b1100000110011111111001100000000110000000; // 5
			4'b0110: row = 40'b1100100110011000000001100000000110000000; // 6
			4'b0111: row = 40'b1101110110011000000001100000000110000110; // 7
			4'b1000: row = 40'b1111011110011111111001111111100111111110; // 8
			4'b1001: row = 40'b1110001110011111111001111111100111111110; // 9
			default: row = 40'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b110; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule

module vga_ome(x, y, c, pixel_out);
	input [7:0] x; // range [0, 39]
	input [6:0] y; // range [0, 9]
	input [2:0] c;
	output [2:0] pixel_out; // 3 bits because rgb
	
	wire [3:0] y1;
	assign y1 = y[3:0];
	reg [0:39] row;
	
	
	always@(*)
	begin
		case(y1)
			4'b0000: row = 40'b0111111110011100011100111111110000000000; // 0
			4'b0001: row = 40'b0111111110011110111100111111110000000000; // 1
			4'b0010: row = 40'b0110000110011011101100110000000000000000; // 2
			4'b0011: row = 40'b0110000110011001001100110000000000000000; // 3
			4'b0100: row = 40'b0110000110011000001100111111110000000000; // 4
			4'b0101: row = 40'b0110000110011000001100111111110000000000; // 5
			4'b0110: row = 40'b0110000110011000001100110000000000000000; // 6
			4'b0111: row = 40'b0110000110011000001100110000000000000000; // 7
			4'b1000: row = 40'b0111111110011000001100111111110000000000; // 8
			4'b1001: row = 40'b0111111110011000001100111111110000000000; // 9
			default: row = 40'b0;
		endcase
	end
	
	assign pixel_out = row[x] ? c : 3'b110; // if row[x] is 1, the pixel should be coloured c otherwise it is background colour, black
	
endmodule



module refresh_vga(clock, resetn, enable, vga_enable); // Creates the waveform that is on for 19200 cycles and off for (2.5M - 19200) cycles. 
													   // It is repeated 20 times per second
	input clock;
	input resetn;
	input enable;
	
	output vga_enable;
	
	wire [21:0] vga_enable_high_cycle;
	
	reg [21:0] counter;
	wire [21:0] counter_max;
	
	assign counter_max = 22'd2500000 - 1'd1; // screen is refreshed 20 times per second
	assign vga_enable_high_cycle = 19200;
	
	always@(posedge clock)
	begin
		if(!resetn)
			counter <= 21'b0;
		else if(enable)
			if(counter == counter_max)
				counter <= 21'b0;
			else
				counter <= counter + 21'b1;
	end
	
	assign vga_enable = (counter < vga_enable_high_cycle) ? 1'b1 : 1'b0;
endmodule
