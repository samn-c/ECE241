module part2(a, b, c_in, s, c_out);
    input [3:0] a, b;
    input c_in;
    output [3:0] s; 
    output [3:0] c_out;
    wire c0, c1, c2;

    FA U0(a[0], b[0], c_in, s[0], c0);
    FA U1(a[1], b[1], c0, s[1], c1);
    FA U2(a[2], b[2], c1, s[2], c2);
    FA U3(a[3], b[3], c2, s[3], c_out[3]);

    assign c_out[0] = c0;
    assign c_out[1] = c1;
    assign c_out[2] = c2;
endmodule

module FA(a, b, c_in, s, c_out);
    input a, b, c_in;
    output s, c_out;

    assign s = c_in ^ a ^ b;
    assign c_out = (a & b) | (a & c_in) | (b & c_in);
endmodule