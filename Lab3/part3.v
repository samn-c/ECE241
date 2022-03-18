
module part3(A, B, Function, ALUout);
    input [3:0] A, B;
    input [2:0] Function; //not yet decided how many bits
    output reg [7:0] ALUout;
    wire [3:0] s, s1, c3;
    wire c4;

    //case 0
    part2 U4(A, B, 0, s, c3);

    //case 1
    assign {c4, s1[3:0]} = (A + B);

    always @ *
        begin
            case(Function)
                3'b000: ALUout = {3'b0, c3[3], s}; // A + B adder
                3'b001: ALUout = {3'b0, c4, (A + B)}; //A + B verilog +
                3'b010: ALUout = {B[3], B[3], B[3], B[3], B}; // Sign extension of B to 8 bits (p167 tb)
                3'b011: ALUout = {|{A, B}}; // 8'b00000001 if at least 1 of the 8 bits in the two inputs is 1 using a single OR operation
                3'b100: ALUout = {&{A, B}}; // Output 8'b00000001 if all of the 8 bits in the two inputs are 1 using a single AND operation
                3'b101: ALUout = {A, B}; // Display A in the most significant four bits and B in the lower four bits
                default: ALUout = {8'b0};
            endcase
        end
endmodule

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