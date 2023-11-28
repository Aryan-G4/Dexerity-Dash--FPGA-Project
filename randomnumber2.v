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