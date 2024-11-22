`include "Adder.v"

module tb;
reg [3:0] a, b;
reg cin;
wire [3:0] c;
wire cout;
integer  i, j, k, errno;
Adder adder0(
    .x(a), 
    .y(b), 
    .cin(cin),
    .s(c),
    .cout(cout)
);
initial begin
    errno = 0;
    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            for (k = 0; k < 2; k = k + 1) begin
                a = i;
                b = j;
                cin = k;
                #1;
                if (i + j + k !== {cout, c}) begin
                    $display("Error: %d + %d + %d should be cout: %d, s: %d\n instead of cout: %d, s: %d",i, j, k, (i+j+k)/16, (i+j+k)%16, cout, c);
                    errno = errno + 1;
                end                 
            end
        end
    end
    if (errno == 0) begin
        $display("\n");
        $display("                             (\-.");
        $display("                             / _`> .---------.");
        $display("                     _)     / _)=  |'-------'|");
        $display("Congratulations!    (      / _/    |O   O   o|");
        $display("Simulation Passed!   `-.__(___)_   | o O . o |");
        $display("                                   `---------'");
        $display("\n");
    end
    else begin
        $display("Total Error: %d", errno);
    end
end
endmodule