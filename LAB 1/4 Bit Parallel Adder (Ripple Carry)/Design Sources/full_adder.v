module full_adder(a, b, cin, s, cout);
    input a, b, cin;
    output s, cout;
    
    wire sp , c, w; 
    half_adder H1(a, b, sp, c) ;
    half_adder H2(sp, cin, s, w) ;
   
    assign cout = c | w ;
endmodule