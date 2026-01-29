module adder_4bit(
    input [3:0] a, 
    input [3:0] b, 
    input cin, 
    output [3:0] sum,  
    output cout 
    );
    
    wire c0, c1, c2;
    
    // FA0: bit 0
    full_adder FA0(
        .a(a[0]), 
        .b(b[0]), 
        .cin(cin), 
        .s(sum[0]), 
        .cout(c0)
    );
    
    // FA1: bit 1
    full_adder FA1(
        .a(a[1]), 
        .b(b[1]), 
        .cin(c0), 
        .s(sum[1]), 
        .cout(c1)
    );
    
    // FA2: bit 2
    full_adder FA2(
        .a(a[2]), 
        .b(b[2]), 
        .cin(c1), 
        .s(sum[2]), 
        .cout(c2)
    );
    
    // FA3: bit 3
    full_adder FA3(
        .a(a[3]), 
        .b(b[3]), 
        .cin(c2), 
        .s(sum[3]), 
        .cout(cout)
    );
    
    
endmodule