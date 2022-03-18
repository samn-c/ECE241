module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
    input clock, reset, ParallelLoadn, RotateRight, ASRight;
    input [7:0] Data_IN;
    output reg [7:0] Q;

    always @ (posedge clock)
        begin
            if (reset == 1) 
                begin
                    //sync active high reset
                    Q <= 8'b0;
                end
            else if (ParallelLoadn == 0)
                begin
                    //new data load in
                    Q <= Data_IN;
                end
            else if ((ParallelLoadn == 1) & (RotateRight == 1) & (ASRight == 0))
                begin
                    //rotate right
                    Q[7] <= Q[0];
                    Q[6] <= Q[7];
                    Q[5] <= Q[6];
                    Q[4] <= Q[5];
                    Q[3] <= Q[4];
                    Q[2] <= Q[3];
                    Q[1] <= Q[2];
                    Q[0] <= Q[1];
                end
            else if ((ParallelLoadn == 1) & (RotateRight == 1) & (ASRight == 1))
                begin
                    //arithmetic shift right
                    Q[7] <= Q[7];
                    Q[6] <= Q[7];
                    Q[5] <= Q[6];
                    Q[4] <= Q[5];
                    Q[3] <= Q[4];
                    Q[2] <= Q[3];
                    Q[1] <= Q[2];
                    Q[0] <= Q[1];
                end
            else if ((ParallelLoadn == 1) & (RotateRight == 0))
                begin
                    //rotate left
                    Q[7] <= Q[6];
                    Q[6] <= Q[5];
                    Q[5] <= Q[4];
                    Q[4] <= Q[3];
                    Q[3] <= Q[2];
                    Q[2] <= Q[1];
                    Q[1] <= Q[0];
                    Q[0] <= Q[7];
                end
            else
                begin
                    // hold value
                    Q <= Q;
                end
        end
endmodule