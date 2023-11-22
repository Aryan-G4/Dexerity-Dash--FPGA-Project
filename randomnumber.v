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