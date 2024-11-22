module Adder(x, y, cin, s, cout);
    input [3:0] x;
    input [3:0] y;
    input cin;
    output [3:0] s;  //sum 
    output cout;     //carry out

    wire c1, c2, c3;

    // 1st bit full adder
    wire s0_xor1, s0_and1, s0_and2, s0_and3, s0_or1;
    xor (s0_xor1, x[0], y[0]); 
    xor (s[0], s0_xor1, cin); // s[0] = x[0] ^ y[0] ^ cin
    and (s0_and1, x[0], y[0]); 
    and (s0_and2, x[0], cin); 
    and (s0_and3, y[0], cin);  //
    or  (s0_or1, s0_and1, s0_and2); // s0_or1 = (x[0] & y[0]) | (x[0] & cin)
    or  (c1, s0_or1, s0_and3); // c1 = (x[0] & y[0]) | (x[0] & cin) | (y[0] & cin)

    // 2nd bit full adder
    wire s1_xor1, s1_and1, s1_and2, s1_and3, s1_or1;
    xor (s1_xor1, x[1], y[1]);
    xor (s[1], s1_xor1, c1);
    and (s1_and1, x[1], y[1]);
    and (s1_and2, x[1], c1);
    and (s1_and3, y[1], c1);
    or  (s1_or1, s1_and1, s1_and2);
    or  (c2, s1_or1, s1_and3);

    // 3rd bit full adder
    wire s2_xor1, s2_and1, s2_and2, s2_and3, s2_or1;
    xor (s2_xor1, x[2], y[2]);
    xor (s[2], s2_xor1, c2);
    and (s2_and1, x[2], y[2]);
    and (s2_and2, x[2], c2);
    and (s2_and3, y[2], c2);
    or  (s2_or1, s2_and1, s2_and2);
    or  (c3, s2_or1, s2_and3);

    // 4th bit full adder
    wire s3_xor1, s3_and1, s3_and2, s3_and3, s3_or1;
    xor (s3_xor1, x[3], y[3]);
    xor (s[3], s3_xor1, c3);
    and (s3_and1, x[3], y[3]);
    and (s3_and2, x[3], c3);
    and (s3_and3, y[3], c3);
    or  (s3_or1, s3_and1, s3_and2);
    or  (cout, s3_or1, s3_and3);
endmodule
