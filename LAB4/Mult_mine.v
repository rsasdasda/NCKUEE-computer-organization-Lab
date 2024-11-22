module Mult(Multiplicand, Multiplier, Product);

    input  [3:0] Multiplicand, Multiplier;
    output reg [7:0] Product;

    reg [7:0] inter[0:3];  // 4 intermediate partial products

    always @(*) begin
        // Initialize partial products to zero
        inter[0] = (Multiplier[0]) ? {4'b0000, Multiplicand} : 8'b00000000;
        inter[1] = (Multiplier[1]) ? {3'b000, Multiplicand, 1'b0} : 8'b00000000;
        inter[2] = (Multiplier[2]) ? {2'b00, Multiplicand, 2'b00} : 8'b00000000;
        inter[3] = (Multiplier[3]) ? {1'b0, Multiplicand, 3'b000} : 8'b00000000;

        // Sum up the partial products to get the final product
        Product = inter[0] + inter[1] + inter[2] + inter[3];
    end

endmodule
