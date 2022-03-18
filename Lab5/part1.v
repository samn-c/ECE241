module part1 (Clock, Enable, Clear_b, CounterValue);
    input Clock, Enable, Clear_b;
    output [7:0] CounterValue;

    wire and1, and2, and3, and4, and5, and6, and7;

    assign and1 = (Enable & CounterValue[0]);
    assign and2 = (and1 & CounterValue[1]);
    assign and3 = (and2 & CounterValue[2]);
    assign and4 = (and3 & CounterValue[3]);
    assign and5 = (and4 & CounterValue[4]);
    assign and6 = (and5 & CounterValue[5]);
    assign and7 = (and6 & CounterValue[6]);

    tFF U0 (Clock, Clear_b, Enable, CounterValue[0]);
    tFF U1 (Clock, Clear_b, and1, CounterValue[1]);
    tFF U2 (Clock, Clear_b, and2, CounterValue[2]);
    tFF U3 (Clock, Clear_b, and3, CounterValue[3]);
    tFF U4 (Clock, Clear_b, and4, CounterValue[4]);
    tFF U5 (Clock, Clear_b, and5, CounterValue[5]);
    tFF U6 (Clock, Clear_b, and6, CounterValue[6]);
    tFF U7 (Clock, Clear_b, and7, CounterValue[7]);
    
endmodule

module tFF (Clock, Reset, Enable, Q);
    input Clock, Reset, Enable;
    output reg Q;

    always @ (posedge Clock, negedge Reset)
    begin
        if (!Reset)
            Q <= 0;
        else if (Enable)
            Q <= !Q;
        else
            Q <= Q;
    end
endmodule