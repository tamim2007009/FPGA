module control(
    input [3:0]b,
    input s0,
    input s1 ,
    output [3:0]y
    );
    
    wire [3:0] y1;
    wire [3:0] y2 ;
    wire [3:0] ss0;
    wire [3:0] ss1;
    
    assign ss0[0] = s0 ;
    assign ss0[1] = s0 ;
    assign ss0[2] = s0 ;
    assign ss0[3] = s0 ;
    
    assign ss1[0] = s1 ;
    assign ss1[1] = s1 ;
    assign ss1[2] = s1 ;
    assign ss1[3] = s1 ;
    
    assign y1 = b & ss0 ;
    assign y2 = (~b) & ss1 ; 
    
    assign y = y1 | y2 ;
    
endmodule