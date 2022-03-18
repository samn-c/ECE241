module part3(Clock, Resetn, Go, Divisor, Dividend, Quotient, Remainder);
    input Clock, Resetn, Go;
    input [3:0] Divisor, Dividend;
    output reg [3:0] Quotient, Remainder;
    reg [3:0] divisible;

    always @ (posedge Clock)
    begin
        if (!Resetn)
        begin
            Remainder = 0;
            Quotient = 0;
        end
        else if (Go)
        begin
            Remainder = (Dividend % Divisor); 
            divisible = (Dividend - Remainder);
            Quotient = (divisible / Divisor);
        end
    end
endmodule