module part3(ClockIn, Resetn, Start, Letter, DotDashOut);
    input ClockIn, Resetn, Start;
    input [2:0] Letter;
    output reg DotDashOut;
    reg [11:0] Load;
    reg [7:0] Rate;
    reg ClockReal;

    parameter speed = 8'b11111001; //249
    parameter A = 12'b1011_1000_0000; //* -
    parameter B = 12'b1110_1010_1000; //- * * * 
    parameter C = 12'b1110_1011_1010; //- * - *
    parameter D = 12'b1110_1010_0000; //- * *
    parameter E = 12'b1000_0000_0000; //*
    parameter F = 12'b1010_1110_1000; //* * - *
    parameter G = 12'b1110_1110_1000; //- - *
    parameter H = 12'b1010_1010_0000; //* * * *

    //Loading the letter
    always @ (posedge Start, negedge Resetn)
    begin
        if (!Resetn)
            Load <= 0;
        else
            case(Letter)
                3'b000: Load <= A;
                3'b001: Load <= B;
                3'b010: Load <= C;
                3'b011: Load <= D;
                3'b100: Load <= E;
                3'b101: Load <= F;
                3'b110: Load <= G;
                3'b111: Load <= H;
                default: Load <= 0;
            endcase
    end

    //2Hz Clock Speed (A)
    always @ (posedge ClockIn, negedge Resetn)
    begin
        if (!Resetn)
            Rate <= speed;
        else if (Rate == 0)
            Rate <= speed;
        else 
            Rate <= Rate - 1;
    end
    //2Hz Clock Speed (B)
    always @ *
    begin
        ClockReal = (Rate == 0) ? 1 : 0;
    end 

    //Output
    always @ (posedge ClockReal, negedge Resetn)
    begin
        if (!Resetn)
            DotDashOut <= 0;
        else
        begin
            DotDashOut <= Load[11];
            Load[11] <= Load[10];
            Load[10] <= Load[9];
            Load[9] <= Load[8];
            Load[8] <= Load[7];
            Load[7] <= Load[6];
            Load[6] <= Load[5];
            Load[5] <= Load[4];
            Load[4] <= Load[3];
            Load[3] <= Load[2];
            Load[2] <= Load[1];
            Load[1] <= Load[0];
            Load[0] <= Load[11];
        end
    end
endmodule