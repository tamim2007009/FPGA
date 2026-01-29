//`timescale 1ns / 1ps

module adder_4bit_tb;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum;
    wire cout;
    
    adder_4bit UUT (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
    
    initial begin
        $display("========== Starting Simulation ==========");
        $monitor("Time=%0t | a=%b b=%b cin=%b | sum=%b cout=%b | Decimal: %d+%d+%d=%d", 
                 $time, a, b, cin, sum, cout, a, b, cin, {cout,sum});
        
        // Test cases
        a = 4'b0000; b = 4'b0000; cin = 0; #10;
        a = 4'b0011; b = 4'b0101; cin = 0; #10;  // 3 + 5 = 8
        a = 4'b1111; b = 4'b0001; cin = 0; #10;  // 15 + 1 = 16
        a = 4'b1010; b = 4'b0101; cin = 1; #10;  // 10 + 5 + 1 = 16
        a = 4'b0111; b = 4'b0110; cin = 0; #10;  // 7 + 6 = 13
        a = 4'b1111; b = 4'b1111; cin = 1; #10;  // 15 + 15 + 1 = 31
        
        $finish;
    end
    
endmodule