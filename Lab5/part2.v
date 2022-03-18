module part2 (ClockIn, Reset, Speed, CounterValue);
    input [1:0] Speed;
    input ClockIn, Reset;
    output reg [3:0] CounterValue;
    wire realClock;

    Clock U0(ClockIn, Reset, Speed, realClock);

    always @ (posedge realClock)
    begin
        if (Reset)
            CounterValue <= 0; 
        else if (CounterValue == 4'b1111)
            CounterValue <= 0;
        else
            CounterValue <= CounterValue + 1; 
    end
endmodule

module Clock(ClockIn, Reset, Speed, ClockOut);
    input [1:0] Speed;
    input ClockIn, Reset;
    output reg ClockOut;
    reg [10:0] Rate;
    reg regular;

    always @ (posedge ClockIn)
    begin
        if (Reset)
            case (Speed)
                2'b00: begin
                    regular <= 1;
                    Rate <= 11'b00000000000; //0
                end
                2'b01: begin
                    regular <= 0;
                    Rate <= 11'b00111110011; //499
                end
                2'b10: begin
                    regular <= 0;
                    Rate <= 11'b01111100111; //999
                end
                2'b11: begin
                    regular <= 0;
                    Rate <= 11'b11111001111; //1999
                end
                default: begin
                    regular <= 1;
                    Rate <= 11'b00000000000; //0
                end
            endcase
        else if (Rate == 11'b0)
            case (Speed)
                2'b00: begin
                    regular <= 1;
                    Rate <= 11'b00000000000; //0
                end
                2'b01: begin
                    regular <= 0;
                    Rate <= 11'b00111110011; //499
                end
                2'b10: begin
                    regular <= 0;
                    Rate <= 11'b01111100111; //999
                end
                2'b11: begin
                    regular <= 0;
                    Rate <= 11'b11111001111; //1999
                end
                default: begin
                    regular <= 1;
                    Rate <= 11'b00000000000; //0
                end
            endcase
        else
            Rate <= Rate - 1;
    end

    always @ *
    begin
        if (regular == 0)
            ClockOut <= (Rate == 0) ? 1 : 0;
        else
            ClockOut <= ClockIn;
    end
endmodule