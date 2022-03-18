
module part2(Clock, Reset_b, Data, Function, ALUout);
    input Clock, Reset_b;
    input [3:0] Data;
    input [2:0] Function;
    output reg [7:0] ALUout;

    wire [3:0] s, s1, c3;
    wire c4;

    //case 0
    adder U4(Data, ALUout[3:0], 0, s, c3);

    //case 1
    assign {c4, s1[3:0]} = (Data + ALUout[3:0]);

    always @ (posedge Clock)
        begin
            if (Reset_b == 0) 
                ALUout <= 8'b0;
            else
                case (Function)
                    3'b000: ALUout <= {3'b0, c3[3], s}; // A + B adder
                    3'b001: ALUout <= {3'b0, c4, s1[3:0]}; //A + B verilog +
                    3'b010: ALUout <= {ALUout[3], ALUout[3], ALUout[3], ALUout[3], ALUout[3:0]}; // Sign extension of B to 8 bits (p167 tb)
                    3'b011: ALUout <= {|{Data, ALUout[3:0]}}; // 8'b00000001 if at least 1 of the 8 bits in the two inputs is 1 using a single OR operation
                    3'b100: ALUout <= {&{Data, ALUout[3:0]}}; // Output 8'b00000001 if all of the 8 bits in the two inputs are 1 using a single AND operation
                    3'b101: ALUout <= {ALUout[3:0] << Data}; // Left Shift B by A bits using Verilog Shift
                    3'b110: ALUout <= {Data * ALUout[3:0]}; // A X B using Verliog *
                    3'b111: ALUout <= {ALUout}; //hold current value in the Register
                    default: ALUout <= {8'b0};
                endcase
        end
endmodule

module adder(a, b, c_in, s, c_out);
    input [3:0] a, b;
    input c_in;
    output [3:0] s, c_out;
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