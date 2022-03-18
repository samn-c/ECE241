//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot);
    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    input wire          iResetn, iPlotBox, iBlack, iLoadX;
    input wire  [2:0]   iColour;
    input wire  [6:0]   iXY_Coord;
    input wire 	        iClock;
    output wire [7:0]   oX;         // VGA pixel coordinates
    output wire [6:0]   oY;

    output wire [2:0]   oColour;     // VGA pixel colour (0-7)
    output wire 	    oPlot;       // Pixel draw enable

    // ################################################################
    // MY CODE IS HERE 
    // ################################################################

    wire ldX, ldYC, ldM, ldB;
    wire [7:0] drawBlackX;
    wire [6:0] drawBlackY;
    wire [3:0] drawClock;

    //modules
    Control U0 (iClock, iResetn, iLoadX, iPlotBox, iBlack, ldX, ldYC, ldM, ldB, oPlot, drawClock, drawBlackX, drawBlackY, X_SCREEN_PIXELS, Y_SCREEN_PIXELS);
    Datapath U1 (iClock, iResetn, iXY_Coord, iColour, ldX, ldYC, ldM, ldB, oX, oY, oColour, drawClock, drawBlackX, drawBlackY, X_SCREEN_PIXELS, Y_SCREEN_PIXELS);
endmodule // part2

module Control (Clock, Resetn, iLoadX, iPlotBox, iBlack, ldX, ldYC, ldM, ldB, oP, drawClock, drawBlackX, drawBlackY, X_SCREEN_PIXELS, Y_SCREEN_PIXELS);
    input Clock, Resetn, iLoadX, iPlotBox, iBlack;
    input [3:0] drawClock;
    input [7:0] drawBlackX, X_SCREEN_PIXELS;
    input [6:0] drawBlackY, Y_SCREEN_PIXELS;
    output reg ldX, ldYC, ldM, ldB, oP;

    //State Parameters
    parameter   C_LoadX     = 3'd0,
                C_WaitX     = 3'd1,
                C_LoadYC    = 3'd2,
                C_WaitYC    = 3'd3,
                C_Memory    = 3'd4,
                C_DrawWait  = 3'd5,
                C_Black     = 3'd6;

    //Current State, Next State
    reg [2:0] CS, NS;

    //State Table
    always @ *
    begin
        case (CS)
            C_LoadX:    NS = iLoadX ? C_WaitX : CS;
            C_WaitX:    NS = iLoadX ? CS : C_LoadYC;
            C_LoadYC:   NS = iPlotBox ? C_WaitYC : CS;
            C_WaitYC:   NS = iPlotBox ? CS : C_Memory;
            C_Memory:   begin
                            if (drawClock == 4'd15)
                                NS = C_DrawWait;
                            else
                                NS = CS;
                        end
            //TO WIPE THE SCREEN
            C_Black:    begin
                            if (drawBlackY == (Y_SCREEN_PIXELS-1) & drawBlackX == (X_SCREEN_PIXELS-1))
                                NS = C_DrawWait;
                            else
                                NS = CS;
                        end
            //this next cycle is to draw the last pixel
            C_DrawWait: NS = C_LoadX;
            default:    NS = C_LoadX;
        endcase
    end

    //Datapath Control Signals
    always @ *
    begin
        ldX = 0;
        ldYC = 0;
        ldM = 0;

        case (CS)
            C_LoadX:    begin
                            ldX = 1;
                            oP = 0;
                        end   
            C_LoadYC:   ldYC = 1;
            C_Memory:   begin
                            ldM = 1;
                            oP = 1;
                        end
            C_Black:    begin
                            ldB = 1;
                            oP = 1;
                        end
        endcase
    end

    //CS Registers
    always @ (posedge Clock)
    begin
        if (!Resetn) 
            CS <= C_LoadX;
        else if (iBlack)
            CS <= C_Black;
        else
            CS <= NS;
    end
endmodule

module Datapath (Clock, Resetn, iXY, iC, ldX, ldYC, ldM, ldB, oX, oY, oC, drawClock, drawBlackX, drawBlackY, X_SCREEN_PIXELS, Y_SCREEN_PIXELS);
    input Clock, Resetn, ldX, ldYC, ldM, ldB;
    input [7:0] X_SCREEN_PIXELS;
    input [6:0] iXY, Y_SCREEN_PIXELS;
    input [2:0] iC;

    reg [7:0] regX;
    reg [6:0] regY;
    reg [2:0] regC;

    output reg [7:0] oX, drawBlackX;
    output reg [6:0] oY, drawBlackY;
    output reg [3:0] drawClock;
    output reg [2:0] oC;

    //Registers
    always @ (posedge Clock)
    begin
        if (!Resetn)
        begin
            regX <= 0;
            regY <= 0;
            regC <= 0;
        end
        else
        begin
            if (ldX)
            begin
                regX <= {0, iXY};
            end
            else if (ldYC)
            begin
                regY <= iXY;
                regC <= iC;
            end
            //Draw onto screen
            else if (ldM)
            begin
                oX <= regX + drawClock[1:0];
                oY <= regY + drawClock[3:2];
                oC <= regC;
            end
            //iBlack
            else if (ldB)
            begin
                oX <= drawBlackX;
                oY <= drawBlackY;
                oC <= 0;
            end
        end
    end

    //Draw Counter
    always @ (posedge Clock)
    begin
        if (!Resetn)
            drawClock <= 4'd0;
        else if (drawClock == 4'd15)
            drawClock <= 4'd0;
        else if (ldM)
            drawClock <= drawClock + 1;
    end

    //Draw Black
    always @ (posedge Clock)
    begin
        if (!Resetn)
        begin
            drawBlackX <= 0;
            drawBlackY <= 0;
        end
        //if at end of whole screen
        else if (drawBlackY == (Y_SCREEN_PIXELS-1) & drawBlackX == (X_SCREEN_PIXELS-1))
        begin
            drawBlackX <= 0;
            drawBlackY <= 0;
        end
        //if at end of row
        else if (drawBlackX == (X_SCREEN_PIXELS-1))
        begin
            drawBlackX <= 0;
            drawBlackY <= drawBlackY + 1; 
        end
        //otherwise go thru the row
        else if (ldB)
            drawBlackX <= drawBlackX + 1;
    end
endmodule