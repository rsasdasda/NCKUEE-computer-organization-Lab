// Module declaration for a 4-bit adder
module Adder (
    input  [3:0] x,      // 4-bit input x
    input  [3:0] y,      // 4-bit input y
    input        cin,    // 1-bit carry-in input
    output [3:0] s,      // 4-bit sum output
    output       cout    // 1-bit carry-out output
    
);

    // Internal wire to store the result of x + y + cin
    wire [4:0] sum;      // 5 bits to capture carry-out

    // Add x, y and cin
    assign sum = x + y + cin;

    // Assign the outputs
    assign s = sum[3:0];     // Lower 4 bits go to s (the sum)
    assign cout = sum[4];    // 5th bit is the carry-out

endmodule
